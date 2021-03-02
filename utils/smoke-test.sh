#!/usr/bin/env bash

# Simple smoke test requesting demo app url and failing in case of error response
# Usage smoke-test.sh DEMO_APP_URL

curl -v --fail $1