#!/usr/bin/env bash
# Fallback para plataformas que dão um shell Linux comum (sem Docker).
# Ex.: ambientes baseados em Ubuntu/Debian. Rode com:  bash start.sh
#
# Ao terminar, o OpenCode aparece num terminal web em http://<host>:7681

set -euo pipefail

echo "==> Atualizando pacotes..."
sudo apt-get update

echo "==> Instalando curl, git, tmux e ttyd (terminal web)..."
sudo apt-get install -y curl git tmux ttyd

echo "==> Instalando o OpenCode..."
curl -fsSL https://opencode.ai/install | bash

export PATH="$HOME/.local/bin:$PATH"

PORT="${PORT:-7681}"
echo "==> Abrindo OpenCode num terminal web na porta $PORT"
echo "    Acesse: http://localhost:$PORT  (ou a URL da sua plataforma)"
echo "    Para parar: Ctrl+C"

exec ttyd -W -p "$PORT" tmux new-session -A -s oc opencode
