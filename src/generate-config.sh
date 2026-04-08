#!/usr/bin/env bash
set -euo pipefail

cat > config.toml <<EOF
[app]
address = "0.0.0.0:3000"
admin_username = "$LISTMONK_ADMIN_USER"
admin_password = "$LISTMONK_ADMIN_PASSWORD"

[db]
host = "$DB_HOST"
port = 5432
user = "postgres"
password = "$DB_PASSWORD"
database = "listmonk"
ssl_mode = "disable"
max_open = 25
max_idle = 25
max_lifetime = "300s"
EOF

echo "config.toml generated."
