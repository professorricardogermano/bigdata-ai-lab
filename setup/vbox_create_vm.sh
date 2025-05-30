#!/bin/bash

# ==============================================================================
# Script para Criar e Configurar uma VM Debian 12 no VirtualBox
# Autor: Adaptado por Gemini para Ricardo Germano
# Data: 30 de Maio de 2025
#
# Este script cria uma nova máquina virtual Debian 12 no VirtualBox.
# Ele configura a VM com recursos adequados para o ambiente Big Data/IA.
#
# Pré-requisitos:
# - VirtualBox instalado no sistema host (Linux Mint).
# - Imagem ISO do Debian 12 (netinst ou live) baixada.
#   Recomendado: https://www.debian.org/CD/http-ftp/#stable
#   Exemplo: debian-12.5.0-amd64-netinst.iso
# ==============================================================================

# --- Variáveis de Configuração da VM ---
VM_NAME="BigDataAILab_Debian12"
VM_OS_TYPE="Debian_64"
VM_RAM_MB="8192"      # 8 GB RAM
VM_CPUS="4"           # 4 vCPUs
VM_DISK_SIZE_MB="102400" # 100 GB disco
VM_DISK_FORMAT="VMDK" # Formato do disco (VMDK, VDI, VHD)
VM_DISK_PATH="$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vmdk"
VM_NETWORK_ADAPTER="bridged" # bridged, nat, hostonly
VM_BRIDGE_ADAPTER="enp0s31f6" # **ALtere para a interface de rede do seu HOST (ex: enp0s31f6, eth0, wlp2s0)**
                               # Use 'ip a' ou 'ifconfig' no seu Linux Mint para descobrir.
ISO_PATH="$HOME/Downloads/debian-12.5.0-amd64-netinst.iso" # **ALtere para o caminho real da sua ISO do Debian 12**
USER_IN_VM="aluno"
PASSWORD_IN_VM="senha123" # A senha será definida manualmente na instalação da VM.
                          # Lembre-se dela para o JupyterLab e VS Code Server.

# --- Funções de Log ---
log_info() {
    echo "INFO: $1"
}
log_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# --- 1. Verificar Pré-requisitos ---
log_info "Verificando pré-requisitos..."
if ! command -v VBoxManage &> /dev/null; then
    log_error "VirtualBox não está instalado. Por favor, instale o VirtualBox primeiro."
fi

if [ ! -f "$ISO_PATH" ]; then
    log_error "Imagem ISO do Debian 12 não encontrada em '$ISO_PATH'. Por favor, baixe e ajuste a variável ISO_PATH."
fi

# --- 2. Criar a VM ---
log_info "Criando VM '$VM_NAME'..."
VBoxManage createvm --name "$VM_NAME" --ostype "$VM_OS_TYPE" --register || log_error "Falha ao criar a VM."

# --- 3. Configurar Recursos da VM ---
log_info "Configurando recursos da VM (RAM, CPUs, rede)..."
VBoxManage modifyvm "$VM_NAME" --memory "$VM_RAM_MB" || log_error "Falha ao configurar RAM."
VBoxManage modifyvm "$VM_NAME" --cpus "$VM_CPUS" || log_error "Falha ao configurar CPUs."
VBoxManage modifyvm "$VM_NAME" --vram 128 || log_error "Falha ao configurar VRAM."
VBoxManage modifyvm "$VM_NAME" --acpi on || log_error "Falha ao configurar ACPI."
VBoxManage modifyvm "$VM_NAME" --boot1 dvd --boot2 disk --boot3 none --boot4 none || log_error "Falha ao configurar ordem de boot."

# Configurar Adaptador de Rede
case "$VM_NETWORK_ADAPTER" in
    "bridged")
        VBoxManage modifyvm "$VM_NAME" --nic1 bridged --bridgeadapter1 "$VM_BRIDGE_ADAPTER" || log_error "Falha ao configurar rede Bridge. Verifique se o adaptador '$VM_BRIDGE_ADAPTER' existe."
        ;;
    "nat")
        VBoxManage modifyvm "$VM_NAME" --nic1 nat || log_error "Falha ao configurar rede NAT."
        ;;
    "hostonly")
        # Precisa ter uma rede host-only configurada, ex: vboxnet0
        VBoxManage modifyvm "$VM_NAME" --nic1 hostonly --hostonlyadapter1 vboxnet0 || log_error "Falha ao configurar rede Host-Only."
        ;;
    *)
        log_error "Tipo de adaptador de rede desconhecido: $VM_NETWORK_ADAPTER. Use 'bridged', 'nat' ou 'hostonly'."
        ;;
esac

# --- 4. Criar e Anexar Disco Rígido ---
log_info "Criando disco virtual de ${VM_DISK_SIZE_MB}MB..."
VBoxManage createmedium disk --filename "$VM_DISK_PATH" --size "$VM_DISK_SIZE_MB" --format "$VM_DISK_FORMAT" || log_error "Falha ao criar disco virtual."

log_info "Anexando disco à VM..."
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci || log_error "Falha ao adicionar controlador SATA."
VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_DISK_PATH" || log_error "Falha ao anexar disco."

# --- 5. Anexar Imagem ISO ---
log_info "Anexando imagem ISO do Debian 12..."
VBoxManage storagectl "$VM_NAME" --name "IDE Controller" --add ide || log_error "Falha ao adicionar controlador IDE."
VBoxManage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISO_PATH" || log_error "Falha ao anexar ISO."

# --- 6. Iniciar a VM para Instalação Manual ---
log_info "VM '$VM_NAME' criada e configurada com sucesso!"
log_info "Você precisará instalar o Debian 12 manualmente na VM."
log_info "Lembre-se de criar o usuário '${USER_IN_VM}' com a senha que desejar durante a instalação."
log_info "Após a instalação, instale o 'sudo' e adicione o usuário '${USER_IN_VM}' ao grupo 'sudo':"
log_info "  sudo apt update && sudo apt install -y sudo"
log_info "  sudo usermod -aG sudo ${USER_IN_VM}"
log_info "  sudo reboot"
log_info "E reinicie a VM para que as mudanças de grupo façam efeito."

echo ""
echo "--------------------------------------------------------------------------------"
log_info "Iniciando a VM para a instalação do Debian 12. Siga os passos na janela da VM."
log_info "Após a instalação do SO, você pode copiar o script 'setup_bigdata_ai_lab.sh' para a VM."
log_info "Exemplo de como copiar (no seu HOST Linux Mint):"
log_info "  scp setup/setup_bigdata_ai_lab.sh ${USER_IN_VM}@<IP_DA_SUA_VM>:/home/${USER_IN_VM}/"
log_info "Após copiar, execute-o DENTRO da VM (como o usuário ${USER_IN_VM}):"
log_info "  cd /home/${USER_IN_VM}/"
log_info "  chmod +x setup_bigdata_ai_lab.sh"
log_info "  sudo ./setup_bigdata_ai_lab.sh"
echo "--------------------------------------------------------------------------------"

VBoxManage startvm "$VM_NAME" --type gui || log_error "Falha ao iniciar a VM."

log_info "Script de criação da VM concluído."