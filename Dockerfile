FROM codercom/code-server:latest

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

ENV PASSWORD=opencode
ENV BIND_ADDR=0.0.0.0:8080

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080 || exit 1

CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password"]
