#!/bin/bash
#set -x

ZONE=exaple.com
DNS_RECORD=myip.exaple.com

CLOUDFLARE_AUTH_EMAIL=my@exaple.com
CLOUDFLARE_AUTH_KEY=893654978563249753258


IP=$(curl -s http://whatismyip.akamai.com/)

if [[ "$(host ${DNS_RECORD} 8.8.8.8 | head -n 1 | cut -d " " -f4)" == "${IP}" ]]; then
  exit
fi

ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${ZONE}&status=active" \
  -H "X-Auth-Email: ${CLOUDFLARE_AUTH_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_AUTH_KEY}" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

DNS_RECORDid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?type=A&name=$DNS_RECORD" \
  -H "X-Auth-Email: ${CLOUDFLARE_AUTH_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_AUTH_KEY}" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/$DNS_RECORDid" \
  -H "X-Auth-Email: ${CLOUDFLARE_AUTH_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_AUTH_KEY}" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$DNS_RECORD\",\"content\":\"${IP}\",\"ttl\":1,\"proxied\":false}" > /dev/null
