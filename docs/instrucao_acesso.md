# Instruções de Acesso ao Ambiente do Laboratório

Este documento detalha como acessar o ambiente de laboratório para a disciplina de Big Data Analytics e Inteligência Artificial.

## Pré-requisito

Antes de prosseguir, certifique-se de que a sua Máquina Virtual (VM) foi configurada com sucesso utilizando os scripts fornecidos em `setup/`.

## Acesso via Navegador (JupyterLab / VS Code Server)

O ambiente de laboratório é acessível primariamente via navegador web, permitindo que você interaja com os notebooks (PySpark, Hive) e o Ollama de forma centralizada e sem a necessidade de instalações complexas em sua máquina local.

### 1. Descobrir o IP da sua Máquina Virtual

Para acessar a VM, você precisará do endereço IP dela. Dentro da sua VM (seja Proxmox ou VirtualBox, via console ou SSH), execute o seguinte comando:

```bash
ip a show eth0 | grep inet | grep -v inet6 | awk '{print $2}' | cut -d/ -f1