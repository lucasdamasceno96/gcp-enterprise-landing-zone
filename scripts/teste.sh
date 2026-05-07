#!/bin/bash
# teste.sh - Script de Validação e Dry-Run da Landing Zone Hospitalar

set -e

# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Vai para a raiz do projeto
cd "$ROOT_DIR"

PROJECT_ID="ldp21k-labs"

# Cores para facilitar leitura
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--------------------------------------------------------${NC}"
echo -e "🔍 Iniciando Testes de Sanidade da Infraestrutura..."
echo -e "${GREEN}--------------------------------------------------------${NC}"

# Limpeza local
echo -e "${YELLOW}🧹 Limpando caches locais do Terraform...${NC}"

find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null
find . -type f -name ".terraform.lock.hcl" -exec rm -f {} + 2>/dev/null

echo -e "${GREEN}✅ Cache limpo${NC}"

# Função principal de teste
run_test() {
    local dir=$1

    echo -e "\n🛠️  Testando módulo: ${GREEN}$dir${NC}..."

    cd "$ROOT_DIR/terraform/$dir" || {
        echo -e "${RED}❌ Pasta terraform/$dir não encontrada${NC}"
        exit 1
    }

    echo -e "${YELLOW}🚀 Inicializando Terraform...${NC}"

    terraform init -reconfigure > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Falha no terraform init em $dir${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Init OK${NC}"

    echo -e "${YELLOW}🔎 Validando sintaxe...${NC}"

    terraform validate > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Falha na validação de sintaxe em $dir${NC}"
        terraform validate
        exit 1
    fi

    echo -e "${GREEN}✅ Sintaxe OK${NC}"

    echo -e "${YELLOW}📋 Executando terraform plan...${NC}"

    terraform plan \
        -var="project_id=$PROJECT_ID" \
        -lock=false \
        -input=false \
        > /dev/null

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Falha no terraform plan em $dir${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Plan OK${NC}"

    # Volta para raiz
    cd "$ROOT_DIR"
}

# Ordem correta de dependência
modules=(
    "network"
    "security"
    "workloads"
    "observability"
)

# Execução
for mod in "${modules[@]}"; do
    run_test "$mod"
done

echo -e "\n${GREEN}--------------------------------------------------------${NC}"
echo -e "🎉 Todos os testes de validação foram concluídos!"
echo -e "🚀 O código está pronto para o Push."
echo -e "${GREEN}--------------------------------------------------------${NC}"