#!/bin/sh

set -e

ME=$(basename $0)

test_nginx() {
    echo >&3 "$ME: Running envsubst on $template to $output_path"
    nginx -T
}

test_nginx

exit 0