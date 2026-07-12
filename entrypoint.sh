#!/bin/sh
# Entrypoint: prepara a chave do OpenRouter (vinda do Render como var de ambiente)
# e sobe o OpenCode dentro de um terminal web (ttyd) na porta que o Render informar.
set -e

if [ -n "$OPENROUTER_API_KEY" ]; then
  mkdir -p "$HOME/.local/share/opencode"
  cat > "$HOME/.local/share/opencode/auth.json" <<EOF
{
  "openrouter": {
    "type": "api",
    "key": "$OPENROUTER_API_KEY"
  }
}
EOF
fi

exec ttyd -W -p "${PORT:-7681}" tmux new-session -A -s oc opencode
