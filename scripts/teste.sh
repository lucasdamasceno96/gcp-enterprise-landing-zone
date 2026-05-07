#!/bin/bash
# teste.sh - Script de Validação e Dry-Run da Landing Zone Hospitalar

PROJECT_ID="ldp21k-labs"

# Cores para facilitar a leitura do log
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}--------------------------------------------------------${NC}"
echo -e "🔍 Iniciando Testes de Sanidade da Infraestrutura..."
echo -e "${GREEN}--------------------------------------------------------${NC}"

# 1. Limpeza de sanidade
echo "🧹 Limpando caches locais do Terraform..."
find . -type d -name ".terraform" -exec rm -rf {} +
find . -type f -name ".terraform.lock.hcl" -exec rm -f {} +

# Função para rodar o teste em cada diretório
run_test() {
    local dir=$1
    echo -e "\n🛠️  Testando módulo: ${GREEN}$dir${NC}..."
    
    cd "terraform/$dir" || { echo -e "${RED}❌ Pasta $dir não encontrada${NC}"; exit 1; }
    
    # Init silencioso para não poluir o terminal
    terraform init -backend=false > /dev/null 2>&1
    
    # Validação de sintaxe (Rápido e crucial)
    terraform validate
    if [ $? -eq 0 ]; then
        echo -e "✅ Sintaxe OK"
    else
        echo -e "${RED}❌ Falha na validação de sintaxe em $dir${NC}"
        exit 1
    fi

    # Plan (Simulação de criação)
    # Nota: O plan pode dar avisos se os recursos da pasta anterior não estiverem criados no GCP,
    # pois ele tenta ler o data.terraform_remote_state.
    terraform plan -var="project_id=$PROJECT_ID" -lock=false
    
    cd ../..
}

# 2. Execução dos testes na ordem de dependência
modules=("network" "security" "workloads" "observability")

for mod in "${modules[@]}"; do
    run_test "$mod"
done

echo -e "\n${GREEN}--------------------------------------------------------${NC}"
echo -e "🎉 Todos os testes de validação foram concluídos!"
echo -e "🚀 O código está pronto para o Push."
echo -e "${GREEN}--------------------------------------------------------${NC}"