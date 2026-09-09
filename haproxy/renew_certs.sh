#!/bin/sh
# Renew the Let's Encrypt cert used by HAProxy.
# Safe to run daily - certbot no-ops until the cert is within 30 days of expiry.
set -eu

DOMAIN="meteo.kristapsbe.lv"
LOG="/certs/cert_renewal.log"

# rotate before taking over stdout/stderr, so the redirect below stays valid
if [ -f "$LOG" ] && [ "$(wc -c < "$LOG")" -gt 1000000 ]; then
    tail -n 500 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
fi
exec >> "$LOG" 2>&1

log() {
    echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') $*"
}

cd /haproxy

if [ ! -f "/etc/letsencrypt/renewal/$DOMAIN.conf" ]; then
    log "ERROR no renewal config for $DOMAIN - issue the first cert manually (see README)"
    exit 1
fi

log "checking $DOMAIN"
uv run --frozen certbot renew \
    --cert-name "$DOMAIN" \
    --standalone \
    --non-interactive \
    --deploy-hook /haproxy/deploy_cert.sh
log "check finished"
