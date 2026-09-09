#!/bin/sh
# certbot --deploy-hook: only runs when a certificate was actually renewed.
set -eu

PEM="/certs/haproxy.pem"
TMP="/certs/haproxy.pem.new"
PIDFILE="/var/run/haproxy.pid"

log() {
    echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') deploy: $*"
}

cat "$RENEWED_LINEAGE/fullchain.pem" "$RENEWED_LINEAGE/privkey.pem" > "$TMP"

# don't swap in something HAProxy will refuse to bind
grep -q "BEGIN CERTIFICATE" "$TMP"
grep -q "BEGIN .*PRIVATE KEY" "$TMP"

mv "$TMP" "$PEM" # same filesystem, so this is atomic
log "wrote $PEM from $RENEWED_LINEAGE"

if [ -s "$PIDFILE" ]; then
    HAP_PID="$(cat "$PIDFILE")"
else
    HAP_PID=1 # start.sh execs haproxy, so the master is PID 1
fi

kill -USR2 "$HAP_PID"
log "reloaded haproxy master (pid $HAP_PID)"
