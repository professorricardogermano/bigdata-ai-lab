#!/bin/bash

# Este script configura o remote 'origin' e faz o push para o GitHub
# usando um Personal Access Token (PAT) via HTTPS.

# URL do seu repositório GitHub
REPO_URL="https://github.com/professorricardogermano/bigdata-ai-lab.git"

echo "--- Configuração e Push para o GitHub ---"

# 1. Verificar e configurar o remote 'origin'
echo "Verificando a configuração do remote 'origin'..."
if git remote -v | grep -q "origin"; then
    echo "Remote 'origin' já existe. Verificando a URL..."
    CURRENT_ORIGIN_URL=$(git remote get-url origin)
    if [ "$CURRENT_ORIGIN_URL" = "$REPO_URL" ]; then
        echo "URL do 'origin' já está correta: $REPO_URL"
    else
        echo "URL do 'origin' está incorreta ($CURRENT_ORIGIN_URL). Atualizando para: $REPO_URL"
        git remote set-url origin "$REPO_URL"
        if [ $? -ne 0 ]; then
            echo "Erro ao atualizar a URL do remote 'origin'. Saindo."
            exit 1
        fi
    fi
else
    echo "Remote 'origin' não encontrado. Adicionando: $REPO_URL"
    git remote add origin "$REPO_URL"
    if [ $? -ne 0 ]; then
        echo "Erro ao adicionar o remote 'origin'. Saindo."
        exit 1
    fi
fi

# 2. Renomear a branch local para 'main'
echo "Garantindo que a branch local seja 'main'..."
git branch -M main
if [ $? -ne 0 ]; then
    echo "Erro ao renomear a branch para 'main'. Saindo."
    exit 1
fi
echo "Branch local definida como 'main'."

# 3. Puxar as mudanças do remoto ANTES de fazer o push
echo "Puxando as últimas alterações do repositório remoto..."
git pull origin main --rebase # <--- LINHA ADICIONADA AQUI
if [ $? -ne 0 ]; then
    echo "Erro ao puxar as alterações do remote. Pode haver conflitos que precisam ser resolvidos manualmente."
    echo "Por favor, resolva os conflitos e tente novamente."
    exit 1
fi
echo "Alterações do remote integradas."

# 4. Fazer o push para o GitHub
echo "Pronto para fazer o push para o GitHub."
echo "IMPORTANTE: Você precisará colar seu Personal Access Token (PAT) quando for solicitada a 'Password'."
echo "Certifique-se de que o PAT foi gerado com as permissões corretas (pelo menos 'repo')."

# Força o Git a solicitar as credenciais (PAT) no terminal
git config --global credential.helper store # ou cache, ou manager
echo "Executando: git push -u origin main"
git push -u origin main

if [ $? -ne 0 ]; then
    echo "O push falhou. Por favor, verifique:"
    echo "1. Se o Personal Access Token (PAT) está correto."
    echo "2. Se o PAT tem as permissões ('scopes') corretas (especialmente 'repo')."
    echo "3. Se a URL do repositório ($REPO_URL) está correta."
    echo "4. Sua conexão com a internet."
    echo "NOTA: Se o erro for 'Updates were rejected', certifique-se de que o 'git pull' foi bem-sucedido e resolveu qualquer conflito."
else
    echo "--- Push para o GitHub realizado com sucesso! ---"
fi

echo "--- Script concluído ---"