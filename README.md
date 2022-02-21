# Bashserv
A simple webserver written in bash. Needless to say, please don't use this for anything if you are sensible. It currently relies on gnu-netcat.

Basic usage:
    ./bashserv.sh -s "./static_content/" -g "./get_handler.sh"

Where static files to serve are placed in the `static_content` directory, and an external script to render GET requests that don't match the static content.

The GET handler script will be called with two parameters: the first parameter gives a slightly sanitised path, and the second gives the full original path as requested. It can use the header script to generate a header as well, which can be called as such:

    ./header.sh -t "content_type" -l "content_length" "return_code"

For example `./header.sh -t "text/html" -l 1337 200`.
