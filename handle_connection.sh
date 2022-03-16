#!/bin/bash

request=""
path=""
path_sane=""

request_keys=()
request_values=()

# serve_error(code, body, type="text/plain)
function serve_error()
{
  local t="$3"
  [ -z "$t" ] && local t="text/plain"
  local body="$2"
  local length=$(echo -ne "$body" | wc -c)
  local header=$($BASHSERV_DIR/header.sh -t "text/plain" -l "$length" "$1")
  printf "%b\n%b" "$header" "$body"
}

while read -r line; do
  line=$(echo "$line" | tr -d '\r\n')

  echo "[$(date +%T)][$$] '$line'" >> connection_raw.log

  # End of request, time to handle it
  if [ -z "$line" ]; then
    export REQUEST_PATH="$path"
    export REQUEST_PATH_SANE="$path_sane"

    request_fields=""
    for i in $(seq 0 $((${#request_keys[@]} - 1))); do
      key="${request_keys[$i]}"
      value="${request_values[$i]}"
      length=$(echo "$value" | wc -w)
      request_fields+="$length $key $value "
    done
    export REQUEST_FIELDS="$request_fields"

    # GET, static content directory defined and matches a file
    if [ "$request" == "GET" -a -n "$STATIC_DIR" -a -n "$path_sane" -a -r "$STATIC_DIR/$path_sane" ]; then
      filetype=$(echo "$path_sane" | sed 's/^.*\.//')
      content="text/plain"

      case "$filetype" in
      css)
        content="text/css"
        ;;
      js)
        content="application/javascript"
        ;;
      html)
        content="text/html"
        ;;
      esac

      echo "[$(date +%T)][$$] GET static, path: $path; path_sane: $path_sane" >> connection.log
      header=$($BASHSERV_DIR/header.sh -t $content -l $(wc -c $STATIC_DIR/$path_sane | cut -d ' ' -f1))
      body=$(cat $STATIC_DIR/$path_sane)
      printf "%s\n%s\n" "$header" "$body"
      exit 0
    fi

    # GET, get handler registered
    if [ "$request" == "GET" -a -n "$GET_HANDLER" ]; then
      echo "[$(date +%T)][$$] GET dynamic, path: $path; path_sane: $path_sane" >> connection.log

      $GET_HANDLER
      [ $? -eq 0 ] && exit 0
    fi

    # POST, post handler registered
    if [ "$request" == "POST" -a -n "$POST_HANDLER" ]; then
      length=0
      for i in $(seq 0 $(( ${#request_keys[@]} - 1 )) ); do
        if [ "${request_keys[$i]}" == "Content-Length" ]; then
          length=${request_values[$i]}
          break
        fi
      done
      read -r -n "$length" data
      if [ ! $? -eq 0 ]; then
        serve_error "400" "Bad request\n" "text/plain"
        exit 0
      fi

      echo "[$(date +%T)][$$] POST path: $path; path_sane: $path_sane, content-length: $length" >> connection.log
      echo "[$(date +%T)][$$] Data: '$data'" >> connection.log

      export POST_DATA="$data"
      $POST_HANDLER
      [ $? -eq 0 ] && exit 0
    fi

    # Can't handle the request, better 404 for now
    echo "[$(date +%T)][$$] Returning 404 for $request $REQUEST_PATH" >> connection.log
    serve_error "404" "File not found\n" "text/plain"
    exit 0
  fi

  # GET request - GET <path> HTTP/x.x
  if [[ "$line" =~ ^GET ]]; then
    request="GET"
    path=$(echo "$line" | cut -d ' ' -f2)
    path_sane=$(echo "$path" | sed 's/^[./]*//')
    continue
  fi
  # POST request - POST <path> HTTP/x.x
  if [[ "$line" =~ ^POST ]]; then
    request="POST"
    path=$(echo "$line" | cut -d ' ' -f2)
    path_sane=$(echo "$path" | sed 's/^[./]*//')
    continue
  fi

  # Parse request fields of form Key: Value
  key=$(echo "$line" | cut -d ':' -f1 | sed 's/^\s*//')
  val=$(echo "$line" | cut -d ':' -f2-)
  if [ -n "$key" -a -n "$val" ]; then
    request_keys+=("$key")
    request_values+=("$val")
  fi
done

