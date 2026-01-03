#!/bin/bash

# =============================================================================
# Pedalando Ali - Customer Service Setup Script
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Pedalando Ali - Customer Service Setup"
echo "=========================================="

# Check if .env exists
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo "📝 Creating .env file from template..."
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    echo "⚠️  Please edit .env file with your credentials before continuing."
    echo "   File location: $PROJECT_DIR/.env"
    exit 1
fi

# Load environment variables
# Load environment variables (handling potential Windows line endings)
set -a
[ -f "$PROJECT_DIR/.env" ] && . "$PROJECT_DIR/.env"
set +a

# Sanitize variables (remove carriage returns)
POSTGRES_USER=$(echo "$POSTGRES_USER" | tr -d '\r')
POSTGRES_PASSWORD=$(echo "$POSTGRES_PASSWORD" | tr -d '\r')
REDIS_PASSWORD=$(echo "$REDIS_PASSWORD" | tr -d '\r')
AUTHENTICATION_API_KEY=$(echo "$AUTHENTICATION_API_KEY" | tr -d '\r')
EVOLUTION_PORT=$(echo "$EVOLUTION_PORT" | tr -d '\r')
KESTRA_PORT=$(echo "$KESTRA_PORT" | tr -d '\r')

# Create data directories
echo "📁 Creating data directories..."
mkdir -p "$PROJECT_DIR/data/postgres"
mkdir -p "$PROJECT_DIR/data/redis"
mkdir -p "$PROJECT_DIR/data/evolution_instances"
mkdir -p "$PROJECT_DIR/data/evolution_store"
mkdir -p "$PROJECT_DIR/data/kestra_storage"

echo "📦 Starting Docker containers..."
cd "$PROJECT_DIR"
docker-compose up -d

echo "⏳ Waiting for services to be ready..."

# Wait for PostgreSQL
echo "🔍 Checking PostgreSQL..."
until docker exec pedalando_postgres pg_isready -U "$POSTGRES_USER" > /dev/null 2>&1; do
    echo "   Waiting for PostgreSQL..."
    sleep 3
done
echo "✅ PostgreSQL is ready!"

# Wait for Redis
echo "🔍 Checking Redis..."
until docker exec pedalando_redis redis-cli -a "$REDIS_PASSWORD" ping > /dev/null 2>&1; do
    echo "   Waiting for Redis..."
    sleep 3
done
echo "✅ Redis is ready!"

# Wait for Evolution API
echo "🔍 Checking Evolution API..."
sleep 10
until curl -s "http://localhost:${EVOLUTION_PORT}/" > /dev/null 2>&1; do
    echo "   Waiting for Evolution API..."
    sleep 5
done
echo "✅ Evolution API is ready!"

# Wait for Kestra
echo "🔍 Checking Kestra..."
until curl -s "http://localhost:${KESTRA_PORT}/api/v1/flows" > /dev/null 2>&1; do
    echo "   Waiting for Kestra..."
    sleep 5
done
echo "✅ Kestra is ready!"

# Create Evolution API instance
echo "📱 Creating WhatsApp instance 'pedalandoali'..."
INSTANCE_RESPONSE=$(curl -s -X POST "http://localhost:${EVOLUTION_PORT}/instance/create" \
    -H "Content-Type: application/json" \
    -H "apikey: $AUTHENTICATION_API_KEY" \
    -d '{
        "instanceName": "pedalandoali",
        "qrcode": true,
        "integration": "WHATSAPP-BAILEYS"
    }')

echo "$INSTANCE_RESPONSE" | jq . 2>/dev/null || echo "$INSTANCE_RESPONSE"

echo ""
echo "🎉 Setup complete!"
echo "=========================================="
echo ""
echo "Services running:"
echo "  - PostgreSQL:    pedalando_postgres"
echo "  - Redis:         pedalando_redis"
echo "  - Evolution API: http://localhost:${EVOLUTION_PORT}"
echo "  - Kestra:        http://localhost:${KESTRA_PORT}"
echo ""
echo "Next steps:"
echo "1. Connect WhatsApp by running:"
echo "   ./scripts/connect-whatsapp.sh"
echo ""
echo "2. Import Kestra flow:"
echo "   - Go to Kestra UI: http://localhost:${KESTRA_PORT}"
echo "   - Login with: ${KESTRA_ADMIN_USER} / [your password]"
echo "   - Create flow from: $PROJECT_DIR/kestra/customer-service-flow.yaml"
echo ""
