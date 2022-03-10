# Bashserv
A simple webserver written in bash. Needless to say, please don't use this for anything if you are sensible. It currently relies on `ncat`, part of the `nmap` family of tools.

Basic usage:

    ./bashserv.sh -s "./static_content/" -g "./get_handler.sh"

Where static files to serve are placed in the `static_content` directory, and an external script to render GET requests that don't match the static content.

The GET handler script will be called with two environment variables set: `$REQUEST_PATH_SANE` and `$REQUEST_PATH`: the first gives a slightly sanitised path, and the second gives the full original path as requested. Furthermore it currently receives all http header fields as arguments, in a triplet form. The first contains the number of words in the value field (as these can contain spaces), the second contains the key, and it will be followed by one or more words forming the value.

To parse these values, you could do something like this in your get-handler:

`
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
`

It can use the header script to generate a header as well, which can be called as such:

    ./header.sh -t "content_type" -l "content_length" "return_code"

For example `./header.sh -t "text/html" -l 1337 200`.
