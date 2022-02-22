#!/bin/bash

CODE="200"

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  -h|--help)
    HELP=1
    shift
    ;;
  -t|--type)
    TYPE="$2"
    shift
    shift
    ;;
  -l|--length)
    LENGTH="$2"
    shift
    shift
    ;;
  *)
    CODE="$2"
    shift
    shift
    ;;
  esac
done

if [ $HELP ]; then
  echo "Usage: $0 [-t|--type <type>] [-l|--length <length> [code]"
  echo "  <type>: Content Type to serve"
  echo "  <length: Content Length to serve"
  echo "  [code]: Status code to return, defaults to 200"
  exit 0
fi

echo -ne "HTTP/1.1 $CODE OK\r\n"

if [ -n "$TYPE" ]; then
  echo -ne "Content-Type: $TYPE\r\n"
fi

if [ -n "$LENGTH" ]; then
  content_length="$2"
  echo -ne "Content-Length: $LENGTH\r\n"
fi

echo -ne "\r\n"

