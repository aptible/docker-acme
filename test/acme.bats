#!/usr/bin/env bats

TEST_ACME_SERVER="https://acme-staging.api.letsencrypt.org/directory"

setup() {
  export ACCOUNT_KEY="$(cat '/tmp/test/test-account-key.json')"
  export ACCOUNT_EMAIL="null@aptible.com"

  local LOCALTUNNEL_NAME="$(pwgen -A 16)"
  export LOCALTUNNEL_DOMAIN="${LOCALTUNNEL_NAME}.localtunnel.me"

  lt --port 80 --subdomain "$LOCALTUNNEL_NAME" &
  nginx &
}

teardown() {
  pkill -KILL node
  pkill -KILL nginx
}

@test "It generates a new certificate and outputs valid JSON" {
  ACME_PAYLOAD="$(acme-acquire-cert "$TEST_ACME_SERVER" \
                                    "$ACCOUNT_KEY" \
                                    "$ACCOUNT_EMAIL" \
                                    "$LOCALTUNNEL_DOMAIN")"
  ACME_PAYLOAD="$ACME_PAYLOAD" \
  ACME_DOMAIN="$LOCALTUNNEL_DOMAIN" \
    python /tmp/test/validate-output.py
}
