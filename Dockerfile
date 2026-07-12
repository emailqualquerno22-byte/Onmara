FROM alpine:latest

ENV PATH="/root/.local/bin:${PATH}"

# Instala dependências
RUN apk add --no-cache \
    ca-certificates \
    curl \
    wget \
    bash \
    git \
    tmux \
    python3 \
    py3-pip \
    build-base \
    && rm -rf /var/cache/apk/*

# Instala ttyd (terminal web)
RUN wget -qO /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# Instala OpenCode via pip (alternativa)
RUN pip3 install --no-cache-dir opencode || echo "pip install falhou, continuando..."

ENV PORT=7681

EXPOSE 7681

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:7681/ || exit 1

# Inicia ttyd com bash interativo na porta 7681
CMD ["ttyd", "-W", "-p", "7681", "bash"]
