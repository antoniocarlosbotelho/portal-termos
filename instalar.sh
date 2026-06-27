#!/usr/bin/env bash
set -Eeuo pipefail

OWNER="antoniocarlosbotelho"
REPO="portal-termos"

PORTA="${1:-5001}"

ROOT_DIR="/root"
PACOTE="${ROOT_DIR}/portal-termos.tar.gz"
CHECKSUM="${ROOT_DIR}/portal-termos.tar.gz.sha256"
PASTA_TEMP="$(mktemp -d /tmp/portal-termos-github-XXXXXX)"

limpar() {
    rm -rf "$PASTA_TEMP"
}

trap limpar EXIT

if [ "$(id -u)" -ne 0 ]; then
    echo "ERRO: execute como root ou usando sudo."
    exit 1
fi

if ! [[ "$PORTA" =~ ^[0-9]+$ ]] || [ "$PORTA" -lt 1 ] || [ "$PORTA" -gt 65535 ]; then
    echo "ERRO: porta inválida: $PORTA"
    exit 1
fi

for COMANDO in curl tar sha256sum awk find bash; do
    if ! command -v "$COMANDO" >/dev/null 2>&1; then
        echo "ERRO: comando obrigatório não encontrado: $COMANDO"
        exit 1
    fi
done

URL_BASE="https://raw.githubusercontent.com/${OWNER}/${REPO}/main"

echo "=================================================="
echo " PORTAL DE TERMOS DICASA - INSTALAÇÃO VIA GITHUB"
echo "=================================================="
echo

echo "[1/5] Baixando pacote..."
curl -fL --retry 3 --connect-timeout 20 \
    -o "$PACOTE" \
    "${URL_BASE}/portal-termos.tar.gz"

echo "[2/5] Baixando checksum..."
curl -fL --retry 3 --connect-timeout 20 \
    -o "$CHECKSUM" \
    "${URL_BASE}/portal-termos.tar.gz.sha256"

echo "[3/5] Validando integridade..."

HASH_ESPERADO="$(awk 'NR==1 {print $1}' "$CHECKSUM")"
HASH_ATUAL="$(sha256sum "$PACOTE" | awk '{print $1}')"

if [ -z "$HASH_ESPERADO" ] || [ "$HASH_ESPERADO" != "$HASH_ATUAL" ]; then
    echo "ERRO: checksum inválido. Instalação cancelada."
    echo "Esperado: $HASH_ESPERADO"
    echo "Obtido:   $HASH_ATUAL"
    exit 1
fi

echo "Checksum validado com sucesso."

echo "[4/5] Extraindo pacote..."
tar -xzf "$PACOTE" -C "$PASTA_TEMP"

INSTALADOR_INTERNO="$(find "$PASTA_TEMP" -type f -name 'instalar_portal_termos.sh' -print -quit)"

if [ -z "$INSTALADOR_INTERNO" ]; then
    echo "ERRO: instalador interno não encontrado no pacote."
    exit 1
fi

PASTA_PACOTE="$(dirname "$INSTALADOR_INTERNO")"

if [ ! -f "$PASTA_PACOTE/source/PortalTermos.csproj" ]; then
    echo "ERRO: código-fonte não encontrado dentro do pacote."
    exit 1
fi

echo "[5/5] Instalando Portal de Termos..."
chmod 0755 "$INSTALADOR_INTERNO"

cd "$PASTA_PACOTE"
bash "$INSTALADOR_INTERNO" "$PORTA"

echo
echo "=================================================="
echo " INSTALAÇÃO CONCLUÍDA"
echo "=================================================="
echo
echo "Acesso:"
echo "http://$(hostname -I | awk '{print $1}'):$PORTA"
