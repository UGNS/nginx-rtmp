#!/bin/sh

set -e

ME=$(basename $0)

test_nginx() {
    echo >&3 "$ME: Validating NGINX configuration"
    nginx -T
}

test_nginx

exit 0