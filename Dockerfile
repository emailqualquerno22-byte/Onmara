FROM alpine:latest

ENV PATH="/root/.local/bin:${PATH}"

# Instala dependências essenciais
RUN apk add --no-cache \
    ca-certificates \
    curl \
    wget \
    bash \
    git \
    nodejs \
    npm \
    python3 \
    py3-pip \
    && rm -rf /var/cache/apk/*

# Tenta instalar OpenCode via npm (mais confiável)
RUN npm install -g opencode 2>/dev/null || \
    (curl -fsSL https://opencode.ai/install | bash 2>/dev/null) || \
    echo "Aviso: instalação com problemas, continuando mesmo assim..."

ENV PORT=7681

EXPOSE 7681

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
    CMD curl -f http://localhost:7681/ || exit 1

# Tenta diferentes formas de iniciar
CMD ["/bin/bash", "-c", "which opencode && opencode web --port 7681 --hostname 0.0.0.0 --no-auth || (echo 'Tentando via npm...' && npx -y opencode web --port 7681 --hostname 0.0.0.0 --no-auth)"]
