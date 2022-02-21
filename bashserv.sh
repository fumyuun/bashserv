#!/bin/bash

OTHERS=()

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  -h|--help)
    HELP=1
    shift
    ;;
  -s|--static)
    export STATIC_DIR="$2"
    shift
    shift
    ;;
  -g|--get)
    export GET_HANDLER="$2"
    shift
    shift
    ;;
  *)
    OTHERS+=("$2")
    shift
    shift
    ;;
  esac
done

if [ "$HELP" ]; then
  echo "Usage: $0 [-h|--help] [-s|--static <dir>] [-g|--get <script>]"
  echo "  -h | --help: Show this help"
  echo "  -s | --static <dir>: Serve static content in <dir>"
  echo "  [get_handler]: Script to use to handle GET requests"
  echo "Note that at least a static content directory or a get handler must be registered"
  exit 1
fi

if [ -z "$GET_HANDLER" -a -z "$STATIC_DIR" ]; then
  echo "Neither a static content directory nor a get handler is set, nothing to serve?"
  exit 1
fi

if [ ! -x "$GET_HANDLER" ]; then
  echo "$GET_HANDLER is not an executable file"
  exit 1
fi

if [ -n "$STATIC_DIR" -a ! -d "$STATIC_DIR" ]; then
  echo "$STATIC_DIR is not a directory"
  exit 1
fi

export BASHSERV_DIR=$(dirname $0)

echo "Setting up server in $BASHSERV_DIR"
if [ -n "$GET_HANDLER" ]; then
  echo "Using get handler $GET_HANDLER"
fi
if [ -n "$STATIC_DIR" ]; then
  echo "Using static content directory $STATIC_DIR"
fi

trap 'exit' INT
while true; do
  nc -l -p 8000 -e "$BASHSERV_DIR/handle_connection.sh"
done

