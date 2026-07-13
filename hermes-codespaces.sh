#!/usr/bin/env bash
#
# hermes-codespaces.sh
# --------------------
# Instala o Hermes Agent e sobe o painel web (dashboard) na porta 9119,
# para ser acessado pelo navegador no endereço de port-forward do GitHub Codespaces.
#
# Como usar no terminal do seu Codespace (cole tudo de uma vez):
#   cat > ~/hermes-setup.sh <<'EOF'
#   ...conteudo deste script...
#   EOF
#   bash ~/hermes-setup.sh
#
set -euo pipefail

PORT="${PORT:-9119}"
HOST="${HOST:-127.0.0.1}"          # loopback: o port-forward do Codespaces ja autentica o acesso
LOG="$HOME/hermes-dashboard.log"
AGENT_DIR="$HOME/.hermes/hermes-agent"

echo "==> [1/4] Instalando pré-requisitos (git, curl, xz-utils)..."
if command -v sudo >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y git curl xz-utils
else
  apt-get update -y
  apt-get install -y git curl xz-utils
fi

echo "==> [2/4] Instalando o Hermes Agent (pode levar alguns minutos)..."
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# garante que uv / binarios locais estejam no PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"

# link simbolico do binario 'hermes' para facilitar
mkdir -p "$HOME/.local/bin"
ln -sf "$AGENT_DIR/venv/bin/hermes" "$HOME/.local/bin/hermes" 2>/dev/null || true
export PATH="$HOME/.local/bin:$PATH"

echo "==> [3/4] Instalando os extras do painel web (web + terminal)..."
cd "$AGENT_DIR"
export VIRTUAL_ENV="$(pwd)/venv"
if command -v uv >/dev/null 2>&1; then
  uv pip install -e ".[web,pty]"
else
  "$(pwd)/venv/bin/python" -m pip install -e ".[web,pty]"
fi

echo "==> [4/4] Iniciando o Hermes Dashboard na porta $PORT..."
# mata execucoes anteriores na mesma porta, se houver
pkill -f "hermes dashboard" 2>/dev/null || true
sleep 1
nohup hermes dashboard --host "$HOST" --port "$PORT" --no-open > "$LOG" 2>&1 &

sleep 4
echo
echo "==================================================================="
echo "PRONTO! Abra no navegador (use a RAIZ, sem o /files):"
echo "  https://symmetrical-space-parakeet-5g74pq7q99vjhv4rq-${PORT}.app.github.dev"
echo
echo "Na PRIMEIRA abertura pode demorar 1-3 min (compila o frontend)."
echo "Para CONVERSAR, adicione sua chave de API em: 'API Keys' (menu do painel)."
echo "  Sugestao: OpenRouter (https://openrouter.ai/keys) -> cole a chave la."
echo "Log de execucao: $LOG"
echo "==================================================================="
