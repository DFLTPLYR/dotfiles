#!/usr/bin/env zsh
# =========================================
# Cloudflare DDNS Updater (Multi-domain) - Zsh Version
# =========================================
# Requirements: curl, jq
# sudo apt install curl jq
# =========================================

# --- Cloudflare Credentials ---
CF_API_TOKEN="your_api_token_here"
CF_ZONE_ID="your_zone_id_here"

# --- Domains to Update ---
DOMAINS=(
  "home.example.com"
  "nas.example.com"
  "vpn.example.com"
)

# --- Settings ---
TTL=120          # Time to live in seconds
PROXIED=false    # true = orange cloud, false = gray cloud

# --- Get current public IP ---
CURRENT_IP=$(curl -s https://ifconfig.me)
if [[ -z "$CURRENT_IP" ]]; then
  print "❌ Could not retrieve public IP."
  exit 1
fi

print "🌍 Current IP: $CURRENT_IP"
print "-----------------------------------"

# --- Loop through domains and update each ---
for RECORD_NAME in $DOMAINS; do
  print "🔹 Updating $RECORD_NAME ..."

  # Get record info
  RECORD_INFO=$(curl -s -X GET \
    "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?name=$RECORD_NAME" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json")

  RECORD_ID=$(echo "$RECORD_INFO" | jq -r '.result[0].id')
  OLD_IP=$(echo "$RECORD_INFO" | jq -r '.result[0].content')

  # If record doesn’t exist, create it
  if [[ "$RECORD_ID" == "null" || -z "$RECORD_ID" ]]; then
    print "  ➕ Record not found, creating new one..."
    CREATE_RESULT=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records" \
      -H "Authorization: Bearer $CF_API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":$TTL,\"proxied\":$PROXIED}")
    if echo "$CREATE_RESULT" | grep -q '"success":true'; then
      print "  ✅ Created $RECORD_NAME → $CURRENT_IP"
    else
      print "  ❌ Failed to create $RECORD_NAME"
    fi
    continue
  fi

  # Skip if IP hasn’t changed
  if [[ "$OLD_IP" == "$CURRENT_IP" ]]; then
    print "  ⏩ No change ($OLD_IP)"
    continue
  fi

  # Update existing record
  UPDATE_RESULT=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$RECORD_ID" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":$TTL,\"proxied\":$PROXIED}")

  if echo "$UPDATE_RESULT" | grep -q '"success":true'; then
    print "  ✅ Updated $RECORD_NAME → $CURRENT_IP"
  else
    print "  ❌ Failed to update $RECORD_NAME"
  fi
done

print "-----------------------------------"
print "✅ All updates completed."
