# Bashserv
A simple webserver written in bash. Needless to say, please don't use this for anything if you are sensible. It currently relies on `ncat`, part of the `nmap` family of tools.

Basic usage:

    ./bashserv.sh -s "./static_content/" -g "./get_handler.sh" --post "./post_handler.sh"

Where static files to serve are placed in the `static_content` directory, and external script to render GET requests that don't match the static content, or POST requests.

These scripts should simply write their respective responses to STDOUT. Furthermore, a convenience-script is also available to write a response header:

    $BASHSERV_DIR/header.sh -t "content_type" -l "content_length" "return_code"

For example `$BASHSERV_DIR/header.sh -t "text/html" -l 1337 "200 OK"` would generate a response header stating the request was OK and we'll send an HTML page of 1337 characters.

# Handling GET requests
The GET handler script will be called with several environment variables set: `$REQUEST_PATH_SANE`, `$REQUEST_PATH` and `BASHSERV_DIR`: the first gives a slightly sanitised path, and the second gives the full original path as requested. The last will contain bashserv's directory, which is useful when using the helper scripts provided.

Request header fields will be written to a special `REQUEST_HEADERS` variable, but an additional helper script is provided to extract specific fields:

    $BASHSERV_DIR/get_request_field.sh "field_name"

If a field with the given name is defined, the script will write the value to STDOUT and exit with a 0 status code. For example `$BASHSERV_DIR/get_request_field.sh "User-Agent"`.

## Handling POST requests
In addition to the above, POST requests have one additional environment variable, `$POST_DATA`, set. This simply contains the POST data in a big string, as-received and unparsed (for now).
