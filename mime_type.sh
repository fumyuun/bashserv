#!/bin/bash

filetype=$(echo "$1" | sed 's/^.*\.//')

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
  ico)
    content="image/vnd.microsoft.icon"
    ;;
  jpg|jpeg)
    content="image/jpeg"
    ;;
esac

echo "$content"
exit 0
