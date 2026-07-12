# OpenCode em janela no navegador (acessivel pelo celular)
# TUDO embutido em UM arquivo: instala OpenCode + ttyd (terminal web),
# ja configura o provedor OpenRouter e sobe na porta que o host informar.
# A chave vem da variavel de ambiente OPENROUTER_API_KEY (defina no Render).

FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl git tmux \
 && rm -rf /var/lib/apt/lists/*

# ttyd (terminal via navegador) - binario precompilado x86_64
RUN curl -fsSL https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -o /usr/local/bin/ttyd \
 && chmod +x /usr/local/bin/ttyd

# Instala o OpenCode (binario Go standalone, via script oficial)
RUN curl -fsSL https://opencode.ai/install | bash
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

# Config do OpenCode: provedor OpenRouter ja definido (a chave vem de env em runtime)
RUN cat > /app/opencode.json <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "openrouter": {
      "models": {
        "~anthropic/claude-sonnet-latest": {},
        "~google/gemini-flash-latest": {},
        "~openai/gpt-4o-mini": {}
      }
    }
  }
}
EOF

# Script de entrada: grava a chave (vinda do env) e sobe o ttyd + opencode
RUN cat > /app/entrypoint.sh <<'EOF'
#!/bin/sh
set -e
if [ -n "$OPENROUTER_API_KEY" ]; then
  mkdir -p "$HOME/.local/share/opencode"
  cat > "$HOME/.local/share/opencode/auth.json" <<JSON
{
  "openrouter": {
    "type": "api",
    "key": "$OPENROUTER_API_KEY"
  }
}
JSON
fi
exec ttyd -W -p "${PORT:-7681}" tmux new-session -A -s oc opencode
EOF
RUN chmod +x /app/entrypoint.sh

ENV PORT=7681
EXPOSE 7681
ENTRYPOINT ["/app/entrypoint.sh"]
