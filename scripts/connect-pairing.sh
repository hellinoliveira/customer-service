#!/bin/bash

# =============================================================================
# Conectar via Pairing Code (Versão Fix - Evolution V2)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Carrega variáveis
set -a
[ -f "$PROJECT_DIR/.env" ] && . "$PROJECT_DIR/.env"
set +a

INSTANCE_NAME="pedalandoali"
API_URL="http://localhost:${EVOLUTION_PORT:-8081}"
API_KEY=$(echo "$AUTHENTICATION_API_KEY" | tr -d '\r')

echo "📱 Conectando via Pairing Code..."
echo "=================================="

# 1. Limpeza Garantida (Para evitar estados zumbis)
# Se estiver "connecting" ou com sessão suja, o pairing code falha.
STATUS=$(curl -s "$API_URL/instance/connectionState/$INSTANCE_NAME" -H "apikey: $API_KEY" | jq -r '.instance.state // .state // "not_found"')

if [ "$STATUS" == "open" ]; then
    echo "✅ Já está conectado!"
    exit 0
fi

if [ "$STATUS" != "not_found" ]; then
    echo "♻️  Resetando instância para garantir..."
    curl -s -X DELETE "$API_URL/instance/logout/$INSTANCE_NAME" -H "apikey: $API_KEY" > /dev/null
    curl -s -X DELETE "$API_URL/instance/delete/$INSTANCE_NAME" -H "apikey: $API_KEY" > /dev/null
    sleep 2
fi

echo "📝 Criando instância nova..."
# IMPORTANTE: Integration deve ser WHATSAPP-BAILEYS para funcionar bem com Pairing
curl -s -X POST "$API_URL/instance/create" \
    -H "apikey: $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
        \"instanceName\": \"$INSTANCE_NAME\",
        \"integration\": \"WHATSAPP-BAILEYS\",
        \"qrcode\": false
    }" > /dev/null
sleep 1

echo ""
echo "📞 Digite o número do WhatsApp (ex: 556299999999):"
read -p "> " PHONE_NUMBER

echo ""
echo "🔗 Solicitando código..."

# ---------------------------------------------------------
# CORREÇÃO AQUI: Rota padrão /instance/connect com query param
# ---------------------------------------------------------
RESPONSE=$(curl -s -X GET "$API_URL/instance/connect/$INSTANCE_NAME?number=$PHONE_NUMBER" \
    -H "apikey: $API_KEY")

# Tenta extrair de vários lugares possíveis do JSON
PAIRING_CODE=$(echo "$RESPONSE" | jq -r '.pairingCode // .code // .qrcode.pairingCode // empty')

if [ -n "$PAIRING_CODE" ] && [ "$PAIRING_CODE" != "null" ]; then
    echo ""
    echo "==========================================="
    echo "✅ CÓDIGO DE PAREAMENTO:  $PAIRING_CODE"
    echo "==========================================="
    echo ""
    echo "1. Abra o WhatsApp no celular > Configurações > Aparelhos Conectados"
    echo "2. 'Conectar Aparelho' > 'Conectar com número de telefone'"
    echo "3. Digite o código acima RAPIDAMENTE (ele expira rápido!)"
else
    echo "❌ Erro ao obter código. Resposta completa:"
    echo "$RESPONSE"
fi