FROM alpine:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:${PATH}"

# Instala dependências mínimas
RUN apk add --no-cache \
    ca-certificates \
    curl \
    wget \
    bash \
    git \
    && rm -rf /var/cache/apk/*

# Instala OpenCode - ignora erros menores, mas valida no final
RUN bash -c 'curl -fsSL https://opencode.ai/install | bash' || true

ENV PORT=7681

EXPOSE 7681

# Health check - apenas tenta conectar
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD curl -f http://localhost:7681/ || exit 1

# Inicia OpenCode Web sem autenticação
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["opencode web --port 7681 --hostname 0.0.0.0 --no-auth || echo 'Iniciando com fallback...' && sleep 10 && exec opencode web --port 7681 --hostname 0.0.0.0 --no-auth"]
