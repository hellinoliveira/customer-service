#!/bin/bash

# =============================================================================
# Connect WhatsApp Instance and Get QR Code
# Evolution API v2.1.1
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment variables
set -a
[ -f "$PROJECT_DIR/.env" ] && . "$PROJECT_DIR/.env"
set +a

INSTANCE_NAME="pedalandoali"
API_URL="http://localhost:${EVOLUTION_PORT:-8081}"

# Evolution API v2 usa apenas AUTHENTICATION_API_KEY
API_KEY=$(echo "$AUTHENTICATION_API_KEY" | tr -d '\r')

echo "📱 Connecting WhatsApp instance: $INSTANCE_NAME"
echo "================================================"
echo "   API URL: $API_URL"
echo "   API Key: ${API_KEY:0:8}..."
echo ""

# Check instance status
echo "🔍 Checking instance status..."
STATUS_RESPONSE=$(curl -s "$API_URL/instance/connectionState/$INSTANCE_NAME" \
    -H "apikey: $API_KEY")

echo "   Response: $STATUS_RESPONSE"

STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.instance.state // .state // "not_found"')
echo "   Status: $STATUS"

# If instance is stuck or closed, reset it
if [ "$STATUS" == "connecting" ] || [ "$STATUS" == "close" ]; then
    echo ""
    echo "⚠️  Instance stuck in '$STATUS'. Resetting..."

    # Logout
    echo "   → Logging out..."
    curl -s -X DELETE "$API_URL/instance/logout/$INSTANCE_NAME" \
        -H "apikey: $API_KEY" > /dev/null 2>&1
    sleep 2

    # Delete
    echo "   → Deleting instance..."
    curl -s -X DELETE "$API_URL/instance/delete/$INSTANCE_NAME" \
        -H "apikey: $API_KEY" > /dev/null 2>&1
    sleep 2

    STATUS="not_found"
fi

# Create instance if needed
if [ "$STATUS" == "not_found" ] || [ "$STATUS" == "null" ]; then
    echo ""
    echo "📝 Creating instance '$INSTANCE_NAME'..."

    CREATE_RESPONSE=$(curl -s -X POST "$API_URL/instance/create" \
        -H "Content-Type: application/json" \
        -H "apikey: $API_KEY" \
        -d "{
            \"instanceName\": \"$INSTANCE_NAME\",
            \"qrcode\": true,
            \"integration\": \"WHATSAPP-BAILEYS\"
        }")

    echo "   Response: $CREATE_RESPONSE"

    # Check if QR came in create response
    QR_BASE64=$(echo "$CREATE_RESPONSE" | jq -r '.qrcode.base64 // empty')
    if [ -n "$QR_BASE64" ] && [ "$QR_BASE64" != "null" ]; then
        echo ""
        echo "✅ QR Code received!"
        echo ""
        echo "$QR_BASE64"
        echo ""
        echo "💡 Decode with: echo '<base64>' | base64 -d > qr.png"
    fi

    sleep 3
fi

# Already connected?
if [ "$STATUS" == "open" ]; then
    echo "✅ WhatsApp is already connected!"
    exit 0
fi

# Fetch QR Code via connect endpoint
echo ""
echo "📷 Fetching QR Code..."

QR_RESPONSE=$(curl -s "$API_URL/instance/connect/$INSTANCE_NAME" \
    -H "apikey: $API_KEY")

echo "   Response: $QR_RESPONSE"

# Try to extract QR code
QR_BASE64=$(echo "$QR_RESPONSE" | jq -r '.base64 // .qrcode.base64 // empty')
QR_CODE=$(echo "$QR_RESPONSE" | jq -r '.code // .qrcode.code // empty')
PAIRING_CODE=$(echo "$QR_RESPONSE" | jq -r '.pairingCode // empty')

if [ -n "$QR_BASE64" ] && [ "$QR_BASE64" != "null" ]; then
    echo ""
    echo "✅ QR Code (base64):"
    echo ""
    echo "$QR_BASE64"
    echo ""
    echo "💡 To view: echo '<base64>' | base64 -d > qr.png && open qr.png"
elif [ -n "$PAIRING_CODE" ] && [ "$PAIRING_CODE" != "null" ]; then
    echo ""
    echo "✅ Pairing Code: $PAIRING_CODE"
    echo "   Enter this code in WhatsApp > Linked Devices > Link with phone number"
elif [ -n "$QR_CODE" ] && [ "$QR_CODE" != "null" ]; then
    echo ""
    echo "✅ QR Code text: $QR_CODE"
else
    echo ""
    echo "⚠️  No QR code returned. Checking fetchInstances..."

    INSTANCES=$(curl -s "$API_URL/instance/fetchInstances" \
        -H "apikey: $API_KEY")

    INSTANCE_DATA=$(echo "$INSTANCES" | jq ".[] | select(.instance.instanceName==\"$INSTANCE_NAME\")")
    echo "   Instance data:"
    echo "$INSTANCE_DATA" | jq '.'
fi

echo ""
echo "⏳ Waiting for connection... (Ctrl+C to cancel)"
echo ""

# Poll for connection
ATTEMPTS=0
MAX_ATTEMPTS=60

while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    sleep 5
    ATTEMPTS=$((ATTEMPTS + 1))

    STATUS=$(curl -s "$API_URL/instance/connectionState/$INSTANCE_NAME" \
        -H "apikey: $API_KEY" | jq -r '.instance.state // .state // "unknown"')

    if [ "$STATUS" == "open" ]; then
        echo ""
        echo "✅ WhatsApp connected successfully!"
        echo ""
        echo "Instance Info:"
        curl -s "$API_URL/instance/fetchInstances" \
            -H "apikey: $API_KEY" | jq ".[] | select(.instance.instanceName==\"$INSTANCE_NAME\") | .instance"
        exit 0
    fi

    echo -n "."
done

echo ""
echo "❌ Timeout. Check logs: docker logs pedalando_evolution --tail 100"
