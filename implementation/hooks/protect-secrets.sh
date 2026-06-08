#!/bin/bash
# Secrets protection hook
# Blocks Claude from reading or modifying sensitive credential files
# Install: chmod +x this file, reference in .claude/settings.json PreToolUse for Read/Edit/Write

TOOL_INPUT=$(cat)
FILE=$(echo "$TOOL_INPUT" | jq -r '.file_path // .path // empty' 2>/dev/null)

[ -z "$FILE" ] && exit 0

FILENAME=$(basename "$FILE")

# Exact filename matches
BLOCKED_EXACT=(
  ".env"
  ".env.local"
  ".env.production"
  ".env.prod"
  ".env.staging"
  ".env.development"
  "id_rsa"
  "id_ed25519"
  "id_ecdsa"
  ".netrc"
  "credentials"
  ".aws_credentials"
)

for blocked in "${BLOCKED_EXACT[@]}"; do
  if [ "$FILENAME" = "$blocked" ]; then
    echo "BLOCKED: '$FILE' is a sensitive credentials file"
    exit 2
  fi
done

# Pattern matches
if echo "$FILENAME" | grep -qE "\.(pem|key|p12|pfx|jks|crt|cer)$"; then
  echo "BLOCKED: '$FILE' is a certificate/key file"
  exit 2
fi

if echo "$FILENAME" | grep -qiE "(secret|credential|password|token)\.(json|yaml|yml|toml|txt)$"; then
  echo "BLOCKED: '$FILE' appears to be a secrets file"
  exit 2
fi

if echo "$FILENAME" | grep -qE "^terraform\.tfvars$|^terraform\.tfvars\.json$"; then
  echo "BLOCKED: '$FILE' is a Terraform variables file that may contain secrets"
  exit 2
fi

exit 0
