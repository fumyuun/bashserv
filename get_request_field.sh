#!/bin/bash

requested_key="$1"
return_value=""

set -f
set $REQUEST_FIELDS
set +f
while [[ $# -gt 0 ]]; do
  length="$1"
  key="$2"
  shift
  shift

  value=""
  for i in $(seq 1 $length); do
    value+="$1 "
    shift
  done

  if [ "$key" == "$requested_key" ]; then
    echo "$value"
    exit 0
  fi
done

exit 1
