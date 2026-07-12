#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# opencode-phone.sh
#
# Sobe o OpenCode dentro de um "terminal web" (ttyd) e abre um TUnel publico
# gratuito com o cloudflared, gerando uma URL do tipo:
#     https://xxxx.trycloudflare.com
# que voce abre no navegador do celular. Nao precisa de conta nem cartao.
#
# Como usar (num ambiente Linux que rode comandos, ex.: Kilo Cloud Agent):
#     bash opencode-phone.sh
# e copie a URL que o cloudflared imprimir.
# ---------------------------------------------------------------------------
set -euo pipefail

echo "==> Atualizando pacotes e instalando base (apt)..."
sudo apt-get update
sudo apt-get install -y curl git tmux

echo "==> Instalando o ttyd (terminal via navegador)..."
if ! command -v ttyd >/dev/null 2>&1; then
  sudo apt-get install -y ttyd || {
    echo "    apt sem ttyd, baixando binario..."
    curl -fsSL https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -o ttyd
    sudo mv ttyd /usr/local/bin/ttyd
    sudo chmod +x /usr/local/bin/ttyd
  }
fi

echo "==> Instalando o OpenCode..."
curl -fsSL https://opencode.ai/install | bash
export PATH="$HOME/.local/bin:$PATH"

echo "==> Instalando o cloudflared (tunel publico gratuito)..."
if ! command -v cloudflared >/dev/null 2>&1; then
  curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
  sudo mv cloudflared /usr/local/bin/cloudflared
  sudo chmod +x /usr/local/bin/cloudflared
fi

# O OpenCode precisa de uma chave de API para funcionar de verdade.
# Defina antes de rodar, exemplo:
#   export ANTHROPIC_API_KEY="sk-ant-..."
# (sem a chave, a janela abre mas o OpenCode nao consegue conversar)

echo "==> Abrindo o OpenCode num terminal web na porta 7681..."
ttyd -W -p 7681 tmux new-session -A -s oc opencode &
TTYD_PID=$!

echo ""
echo "=============================================================="
echo " Agora o cloudflared vai gerar uma URL publica gratuita."
echo " COPIE a linha 'https://....trycloudflare.com' e abra no celular."
echo "=============================================================="
echo ""

cloudflared tunnel --url http://localhost:7681

# ao sair (Ctrl+C), encerra o terminal web
kill "$TTYD_PID" 2>/dev/null || true
