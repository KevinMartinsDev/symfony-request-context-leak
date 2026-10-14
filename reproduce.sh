#!/bin/sh
# Sends the same two requests to the worker and to the classic container.
set -eu

for mode in worker:8180 classic:8181; do
    name=${mode%%:*}
    port=${mode##*:}
    echo "=== $name mode (port $port)"
    echo "1) request that sets tenant=acme:"
    curl -s "http://localhost:$port/x/dashboard?tenant=acme"; echo
    echo "2) next request, without tenant:"
    curl -s "http://localhost:$port/x/dashboard"; echo
    echo
done
