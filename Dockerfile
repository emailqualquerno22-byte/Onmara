FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:${PATH}"
RUN apt-get update && apt-get install -y ca-certificates curl unzip
RUN curl -fsSL https://opencode.ai/install -o /tmp/oc-install.sh && bash /tmp/oc-install.sh && opencode --version
ENV PORT=7681
ENV OPENCODE_SERVER_PASSWORD=opencode
EXPOSE 7681
CMD ["sh", "-c", "opencode web --port ${PORT:-7681} --hostname 0.0.0.0"]
