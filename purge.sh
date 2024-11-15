#!/bin/bash

set -e
set -x

curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/purge_cache" -H "X-Auth-Email: $CF_EMAIL" -H "X-Auth-Key: $CF_API_KEY" -H "Content-Type: application/json" --data '{"purge_everything":true}'
