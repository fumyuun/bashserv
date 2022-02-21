#!/bin/bash

rm -f connection_raw.log connection.log

while read -r line; do
  echo "$line" >> connection_raw.log
  line=$(echo "$line" | tr -d '\r\n')

  if [[ "$line" =~ ^GET ]]; then

    # extract path
    path=$(echo "$line" | cut -d ' ' -f2)

    # remove slashes and dots in the beginning
    path_sane=$(echo $path | sed 's/^[./]*//')

    echo "line: $line; path: $path; path_sane: $path_sane" >> connection.log

    if [ -n "$STATIC_DIR" -a -n "$path_sane" -a -r "$STATIC_DIR/$path_sane" ]; then
      filetype=$(echo "$path_sane" | sed 's/^.*\.//')
      content="text/html"

      case "$filetype" in
      css)
        content="text/css"
        ;;
      js)
        content="application/javascript"
        ;;
      esac

cat <<EOF
$($BASHSERV_DIR/header.sh -t $content -l $(wc -c $STATIC_DIR/$path_sane | cut -d ' ' -f1))
$(cat $STATIC_DIR/$path_sane)
EOF

      break
    fi

    if [ -n "$GET_HANDLER" ]; then
      $GET_HANDLER "$path_sane" "$path"
      break
    fi
  fi
done

