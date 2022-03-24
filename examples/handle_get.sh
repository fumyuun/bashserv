#!/bin/bash

user_agent=$($BASHSERV_DIR/get_request_field.sh "User-Agent")
if [[ $user_agent =~ Mobile ]]; then
  mobile=1
fi

body="<html>\n<head><title>Bashserv example page</title></head>\n"
body+="<body>\n"
body+="At $(date +%T) you requested $REQUEST_PATH\n"
if [ $mobile ]; then
  body+="Are you a mobile?\n"
fi

body+="</body></html>"

$BASHSERV_DIR/header.sh -t "text/html" -l $(echo -ne "$body" | wc -c)
printf "%b" "$body"

exit 0
