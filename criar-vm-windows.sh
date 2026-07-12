#!/usr/bin/env bash
#
# criar-vm-windows.sh
# --------------------
# Cria e inicia uma máquina virtual Windows no VirtualBox para você rodar
# aplicativos .exe de forma isolada, sem precisar instalar nada no seu sistema.
#
# Pré-requisitos (instale no SEU computador, não aqui):
#   - VirtualBox  (https://www.virtualbox.org/)  -> fornece o comando `VBoxManage`
#   - Uma ISO do Windows (10 ou 11) licenciada sua
#
# Uso:
#   chmod +x criar-vm-windows.sh
#   ./criar-vm-windows.sh /caminho/para/windows.iso
#
# Opções (variáveis de ambiente, todas opcionais):
#   VM_NOME       nome da VM            (padrão: WinSandbox)
#   VM_RAM_MB     memória em MB         (padrão: 4096)
#   VM_CPUS       núcleos de CPU        (padrão: 2)
#   VM_DISCO_GB   tamanho do disco      (padrão: 60)
#   ISO_WIN       caminho da ISO        (também pode ser o argumento $1)
#
set -euo pipefail

# ---- parâmetros --------------------------------------------------------
ISO_WIN="${1:-${ISO_WIN:-}}"
VM_NOME="${VM_NOME:-WinSandbox}"
VM_RAM_MB="${VM_RAM_MB:-4096}"
VM_CPUS="${VM_CPUS:-2}"
VM_DISCO_GB="${VM_DISCO_GB:-60}"

# ---- validações --------------------------------------------------------
if ! command -v VBoxManage >/dev/null 2>&1; then
  echo "ERRO: VirtualBox não encontrado. Instale em https://www.virtualbox.org/" >&2
  exit 1
fi

if [[ -z "$ISO_WIN" || ! -f "$ISO_WIN" ]]; then
  echo "ERRO: informe o caminho da ISO do Windows como argumento." >&2
  echo "Exemplo: ./criar-vm-windows.sh ~/Downloads/Windows11.iso" >&2
  exit 1
fi

# Caminho do disco virtual (VMDK/VDI) dentro da pasta de máquinas do VirtualBox
VM_DIR="$HOME/VirtualBox VMs/$VM_NOME"
DISCO="$VM_DIR/$VM_NOME.vdi"

# ---- cria a VM ---------------------------------------------------------
echo "==> Criando VM '$VM_NOME'..."
VBoxManage createvm --name "$VM_NOME" --ostype "Windows11_64" --register 2>/dev/null \
  || VBoxManage createvm --name "$VM_NOME" --ostype "Windows10_64" --register

VBoxManage modifyvm "$VM_NOME" \
  --memory "$VM_RAM_MB" \
  --cpus "$VM_CPUS" \
  --graphicscontroller vboxsvga \
  --vram 128 \
  --nic1 nat \
  --audio none \
  --clipboard bidirectional \
  --draganddrop bidirectional

# Habilita pastas compartilhadas e USB 2/3 (Extension Pack opcional)
VBoxManage modifyvm "$VM_NOME" --usb on --usbehci on --usbxhci on 2>/dev/null || true

# ---- cria e anexa o disco ---------------------------------------------
echo "==> Criando disco de $VM_DISCO_GB GB..."
VBoxManage createmedium disk --filename "$DISCO" --size "$((VM_DISCO_GB * 1024))" --format VDI

VBoxManage storagectl "$VM_NOME" --name "SATA" --add sata --controller IntelAhci
VBoxManage storageattach "$VM_NOME" --storagectl "SATA" --port 0 --device 0 \
  --type hdd --medium "$DISCO"

# ---- anexa a ISO de instalação ----------------------------------------
echo "==> Anexando ISO: $ISO_WIN"
VBoxManage storagectl "$VM_NOME" --name "IDE" --add ide --controller PIIX4
VBoxManage storageattach "$VM_NOME" --storagectl "IDE" --port 0 --device 0 \
  --type dvddrive --medium "$ISO_WIN"

# ---- pasta compartilhada para jogar arquivos/exe pra dentro da VM ------
mkdir -p "$HOME/vm-compartilhado"
VBoxManage sharedfolder add "$VM_NOME" --name "compartilhado" \
  --hostpath "$HOME/vm-compartilhado" --automount 2>/dev/null || true

# ---- inicia ------------------------------------------------------------
echo "==> Iniciando a VM (janela do VirtualBox vai abrir)..."
VBoxManage startvm "$VM_NOME" --type gui

echo
echo "Pronto! Na janela que abriu:"
echo "  1. Instale o Windows normalmente."
echo "  2. Dentro da VM, instale o 'VirtualBox Guest Additions' (menu Dispositivos > Inserir CD)."
echo "  3. Coloque o .exe em '$HOME/vm-compartilhado' para acessá-lo dentro da VM."
echo "  4. Para ligar de novo depois: VBoxManage startvm $VM_NOME --type gui"
echo "  5. Para remover tudo: VBoxManage unregistervm $VM_NOME --delete"
