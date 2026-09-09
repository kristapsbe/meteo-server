#!/bin/sh
DOMAIN="meteo.kristapsbe.lv"
LIVE="/etc/letsencrypt/live/$DOMAIN"

# the container is recreated on every redeploy - pick up any renewal that
# landed while it was down (no-op locally, where /etc/letsencrypt isn't mounted)
if [ -f "$LIVE/fullchain.pem" ] && [ -f "$LIVE/privkey.pem" ]; then
    cat "$LIVE/fullchain.pem" "$LIVE/privkey.pem" > /certs/haproxy.pem
fi

crond -L /certs/crond.log

exec haproxy -W -p /var/run/haproxy.pid -f /haproxy/haproxy.cfg
