FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    unzip \
    wget \
    git \
    build-essential \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Instala OpenCode com retry e verificação
RUN mkdir -p /tmp/opencode && cd /tmp/opencode && \
    curl -fsSL --connect-timeout 30 --max-time 120 https://opencode.ai/install > install.sh && \
    chmod +x install.sh && \
    bash install.sh || \
    (echo "Instalação falhou, tentando novamente..." && sleep 5 && bash install.sh) && \
    opencode --version

ENV PORT=7681

EXPOSE 7681

# Health check - garante que o Render saiba que está vivo
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:7681/ || exit 1

# Inicia com log direto (não background) para Render ver os logs
CMD ["opencode", "web", "--port", "7681", "--hostname", "0.0.0.0", "--no-auth"]
