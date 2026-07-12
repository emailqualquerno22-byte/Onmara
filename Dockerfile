

```dockerfile
# OpenCode em janela no navegador (acessivel pelo celular)
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl git tmux \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -o /usr/local/bin/ttyd \
 && chmod +x /usr/local/bin/ttyd

RUN curl -fsSL https://opencode.ai/install | bash
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

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
```

