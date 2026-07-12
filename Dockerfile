FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl git tmux && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd
RUN curl -fsSL https://opencode.ai/install | bash
ENV PATH="/root/.local/bin:${PATH}"
ENV PORT=7681
EXPOSE 7681
CMD ["sh", "-c", "ttyd -W -p ${PORT:-7681} tmux new-session -A -s oc opencode"]
