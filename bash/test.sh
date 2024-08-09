#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <load_balancer_url>"
    exit 1
fi

URL=$1

while true; do
    curl $URL
    sleep 1
done
