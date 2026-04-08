#!/usr/bin/env bash
set -euo pipefail

# ── Start Listmonk in background ──────────────────────
./listmonk --config config.toml &
PID=$!

# ── Wait for Listmonk to be ready ─────────────────────
echo "Waiting for Listmonk to become ready..."
for i in $(seq 1 60); do
  if curl -sf http://localhost:3000/health > /dev/null 2>&1; then
    echo "Listmonk is ready."
    break
  fi
  if ! kill -0 "$PID" 2>/dev/null; then
    echo "Listmonk process died unexpectedly."
    exit 1
  fi
  sleep 1
done

# ── Configure SMTP via Listmonk Admin API ─────────────
# Listmonk stores SMTP config in the database, not in config.toml.
# We use the settings API to inject it on every startup so env var
# changes are always picked up.
echo "Configuring SMTP settings..."

SMTP_JSON=$(cat <<JSON
{
  "smtp": [
    {
      "enabled": true,
      "host": "${SMTP_HOST}",
      "port": ${SMTP_PORT:-587},
      "auth_protocol": "login",
      "username": "${SMTP_USER}",
      "password": "${SMTP_PASSWORD}",
      "tls_type": "STARTTLS",
      "max_conns": 5,
      "idle_timeout": "15s",
      "wait_timeout": "5s",
      "max_msg_retries": 2
    }
  ],
  "app.site_name": "${SITE_NAME:-Listmonk}",
  "app.from_email": "${FROM_EMAIL:-noreply@example.com}"
}
JSON
)

curl -sf \
  -u "${LISTMONK_ADMIN_USER}:${LISTMONK_ADMIN_PASSWORD}" \
  -X PUT "http://localhost:3000/api/settings" \
  -H 'Content-Type: application/json' \
  -d "$SMTP_JSON" \
  && echo "SMTP and app settings configured." \
  || echo "WARNING: Settings update failed — configure SMTP manually via the admin UI."

# ── Keep the service alive ─────────────────────────────
wait $PID
