#!/bin/bash

request=""
path=""
path_sane=""

request_keys=()
request_values=()

while read -r line; do
  line=$(echo "$line" | tr -d '\r\n')

  echo "[$(date +%T)] '$line'" >> connection_raw.log

  # End of request, time to handle it
  if [ -z "$line" ]; then
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

    echo "[$(date +%T)] GET static, path: $path; path_sane: $path_sane" >> connection.log

cat <<EOF
$($BASHSERV_DIR/header.sh -t $content -l $(wc -c $STATIC_DIR/$path_sane | cut -d ' ' -f1))
$(cat $STATIC_DIR/$path_sane)
EOF
      exit 0
    fi

    # GET, get handler registered
    if [ "$request" == "GET" -a -n "$GET_HANDLER" ]; then
      echo "[$(date +%T)] GET dynamic, path: $path; path_sane: $path_sane" >> connection.log
      request_fields=""
      for i in $(seq 0 $((${#request_keys[@]} - 1))); do
        key="${request_keys[$i]}"
        value="${request_values[$i]}"
        length=$(echo "$value" | wc -w)
        request_fields+="$length $key $value "
      done

      export REQUEST_PATH="$path"
      export REQUEST_PATH_SANE="$path_sane"

      $GET_HANDLER $request_fields
      ret=$?
      [ $ret -eq 0 ] && exit 0
    fi
  fi

  # GET request - GET <path> HTTP/x.x
  if [[ "$line" =~ ^GET ]]; then
    request="GET"
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

