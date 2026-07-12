#!/usr/bin/env bash
#
# desktop-novnc.sh
# ----------------
# Cria um DESKTOP LINUX acessível pelo navegador (sem precisar de cliente VNC).
# Você abre http://<host>:6080 e "vê a janela" — pode instalar/clicar em apps Linux.
#
# ONDE RODA:
#   - Seu PC Linux  OU  uma VM Linux na nuvem (Oracle free tier, full Codespaces, etc.)
#   - NÃO roda no chat-only do Codespaces e nem neste ambiente (sem shell/GUI aqui).
#
# PRÉ-REQUISITOS: sistema base Debian/Ubuntu, acesso root (sudo) e internet.
#
# USO:
#   chmod +x desktop-novnc.sh
#   ./desktop-novnc.sh
#   Depois abra no navegador:  http://localhost:6080  (ou http://IP-da-VM:6080)
#
set -euo pipefail

PORTA="${PORTA:-6080}"
SENHA="${SENHA:-changeme}"
USUARIO="${USUARIO:-$(logname 2>/dev/null || echo $USER)}"

echo "==> Atualizando e instalando desktop + VNC + noVNC..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  xfce4 xfce4-goodies \
  tigervnc-standalone-server tigervnc-common \
  novnc websockify \
  git curl

echo "==> Configurando VNC para o usuário $USUARIO..."
HOME_U="$HOME"
sudo -u "$USUARIO" bash -c '
  mkdir -p $HOME/.vnc
  echo "'"$SENHA"'" | vncpasswd -f > $HOME/.vnc/passwd
  chmod 600 $HOME/.vnc/passwd
  cat > $HOME/.vnc/xstartup <<EOF
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
  chmod +x $HOME/.vnc/xstartup
'

echo "==> Iniciando o VNC (desktop XFCE)..."
sudo -u "$USUARIO" vncserver :1 -geometry 1280x720 -depth 24

echo "==> Iniciando noVNC (ponte VNC->navegador) na porta $PORTA..."
# websockify traduz VNC para WebSocket que o navegador entende
nohup websockify --web /usr/share/novnc "$PORTA" localhost:5901 >/tmp/novnc.log 2>&1 &

echo
echo "Pronto! Abra no navegador:"
echo "   http://localhost:$PORTA    (se rodou no seu PC)"
echo "   http://<IP-da-VM>:$PORTA   (se rodou numa VM de nuvem)"
echo "Senha do VNC: $SENHA"
echo
echo "Para parar:  vncserver -kill :1   e   pkill websockify"
echo "Observação: isto é LINUX. Para rodar um .exe do Windows, use o script"
echo "criar-vm-windows.sh (VirtualBox) no seu PC."
