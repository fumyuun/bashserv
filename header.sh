#!/bin/bash

CODE="200 OK"

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
    CODE="$1"
    shift
    ;;
  esac
done

if [ $HELP ]; then
  echo "Usage: $0 [-t|--type <type>] [-l|--length <length> [code]"
  echo "  <type>: Content Type to serve"
  echo "  <length: Content Length to serve"
  echo "  [code]: Status code to return, defaults to 200 OK"
  exit 0
fi

printf "HTTP/1.1 $CODE\r\n"

if [ -n "$TYPE" ]; then
  printf "Content-Type: $TYPE\r\n"
fi

if [ -n "$LENGTH" ]; then
  content_length="$2"
  printf "Content-Length: $LENGTH\r\n"
fi

printf "\r\n"

