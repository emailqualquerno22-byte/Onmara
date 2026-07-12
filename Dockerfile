# OpenCode em janela no navegador (acessível pelo celular)
#
# OpenCode é um programa de terminal. Para ver a "janela" dele dentro do
# navegador do celular, usamos o `ttyd` (um terminal servido via web) rodando
# o OpenCode dentro de uma sessão `tmux`.
#
# O app fica disponível em:  http://<host>:<PORTA>
# Porta padrão: 7681

FROM debian:bookworm-slim

# Evita prompts interativos durante o apt
ENV DEBIAN_FRONTEND=noninteractive

# Instala ferramentas base: curl (baixar OpenCode), git, tmux e o ttyd (terminal web)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        tmux \
        ttyd \
    && rm -rf /var/lib/apt/lists/*

# Instala o OpenCode (binário Go standalone, via script oficial)
RUN curl -fsSL https://opencode.ai/install | bash

# Garante que o binário fique no PATH
ENV PATH="/root/.local/bin:${PATH}"

# Porta que será exposta/publicada
ENV PORT=7681
EXPOSE 7681

# ttyd serve um terminal web. Dentro dele abrimos o OpenCode via tmux
# (a sessão "oc" é reutilizada, então não fecha ao recarregar a página).
# -W  -> permite digitar no terminal (writable)
# -p  -> porta
CMD ["sh", "-c", "ttyd -W -p ${PORT} tmux new-session -A -s oc opencode"]
