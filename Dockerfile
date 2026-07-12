# OpenCode em janela no navegador (acessível pelo celular)
#
# OpenCode e um programa de terminal. Para ver a "janela" dele dentro do
# navegador do celular, usamos o `ttyd` (um terminal servido via web) rodando
# o OpenCode dentro de uma sessao `tmux`.
#
# A chave da OpenRouter e lida da variavel de ambiente OPENROUTER_API_KEY
# (defina no Render / ou no seu host). A configuracao do provedor ja esta
# em opencode.json nesta pasta.
#
# O app fica disponivel em:  http://<host>:<PORTA>   (porta injetada pelo host)

FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Instala base: curl (baixar OpenCode/ttyd), git, tmux
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        tmux \
    && rm -rf /var/lib/apt/lists/*

# ttyd (terminal web) - binario precompilado x86_64
RUN curl -fsSL https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -o /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd

# Instala o OpenCode (binario Go standalone, via script oficial)
RUN curl -fsSL https://opencode.ai/install | bash

ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

COPY opencode.json /app/opencode.json
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENV PORT=7681
EXPOSE 7681

ENTRYPOINT ["/app/entrypoint.sh"]
