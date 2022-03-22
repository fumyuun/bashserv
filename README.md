# Bashserv
A simple webserver written in bash. Needless to say, please don't use this for anything if you are sensible. It currently relies on `ncat`, part of the `nmap` family of tools.

Basic usage:

    ./bashserv.sh -s "./static_content/" -g "./get_handler.sh" --post "./post_handler.sh"

Where static files to serve are placed in the `static_content` directory, and external script to render GET requests that don't match the static content, or POST requests.

These scripts should simply write their respective responses to STDOUT. Furthermore, a convenience-script is also available to write a response header:
.
    ./header.sh -t "content_type" -l "content_length" "return_code"

For example `./header.sh -t "text/html" -l 1337 "200 OK"` would generate a response header stating the request was OK and we'll send an HTML page of 1337 characters.

# Handling GET requests
The GET handler script will be called with three environment variables set: `$REQUEST_PATH_SANE`, `$REQUEST_PATH` and `$REQUEST_FIELDS`: the first gives a slightly sanitised path, and the second gives the full original path as requested. The third contains all http header fields in a triplet form. The first contains the number of words in the value field (as these can contain spaces), the second contains the key, and it will be followed by one or more words forming the value.

To parse these values, you could do something like this in your get-handler:

```
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

  case $key in
  User-Agent)
    if [[ $value =~ Mobile ]]; then
      mobile=1
    fi
    ;;
  esac
```

## Handling POST requests
In addition to the above, POST requests have one additional environment variable, `$POST_DATA`, set. This simply contains the POST data in a big string, as-received and unparsed (for now).
