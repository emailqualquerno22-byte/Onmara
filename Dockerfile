FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    unzip \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instala OpenCode
RUN curl -fsSL https://opencode.ai/install -o /tmp/oc-install.sh && \
    bash /tmp/oc-install.sh && \
    opencode --version

ENV PORT=7681
ENV OPENCODE_SERVER_PASSWORD=opencode

EXPOSE 7681

# Health check - garante que o Render saiba que está vivo
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:7681/ || exit 1

# Inicia com log direto (não background) para Render ver os logs
CMD ["sh", "-c", "opencode web --port ${PORT:-7681} --hostname 0.0.0.0 --no-auth"]
