#!/bin/bash
# cleanup.sh - Script de Destruição Segura para Economia de Custos

set -e

# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Vai para raiz do projeto
cd "$ROOT_DIR"

PROJECT_ID="ldp21k-labs"

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--------------------------------------------------------${NC}"
echo -e "🏦 Iniciando Desligamento da Infraestrutura Hospitalar..."
echo -e "${GREEN}--------------------------------------------------------${NC}"

# Função reutilizável
destroy_module() {
    local dir=$1
    local description=$2

    echo -e "\n${YELLOW}🧨 ${description}${NC}"

    cd "$ROOT_DIR/terraform/$dir" || {
        echo -e "${RED}❌ Pasta terraform/$dir não encontrada${NC}"
        exit 1
    }

    echo -e "${YELLOW}🔧 Inicializando Terraform...${NC}"

    terraform init -reconfigure

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Falha no terraform init em $dir${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Init OK${NC}"

    echo -e "${YELLOW}📋 Gerando plano de destruição...${NC}"

    terraform plan \
        -destroy \
        -var="project_id=$PROJECT_ID" \
        -lock=false \
        -input=false

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Falha no terraform plan destroy em $dir${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Plan Destroy OK${NC}"

    echo -e "${YELLOW}🔥 Destruindo infraestrutura...${NC}"

    terraform destroy \
        -auto-approve \
        -var="project_id=$PROJECT_ID"

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Falha no terraform destroy em $dir${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Recursos de $dir removidos com sucesso${NC}"

    # Volta para raiz
    cd "$ROOT_DIR"
}

# Ordem reversa de dependência
destroy_module "observability" "Passo 1: Removendo Observabilidade"
destroy_module "workloads" "Passo 2: Removendo Workloads (Cloud Run)"
destroy_module "security" "Passo 3: Removendo Segurança (Artifact Registry)"
destroy_module "network" "Passo 4: Removendo Rede Hub (VPC, NAT, Router)"

echo -e "\n${GREEN}--------------------------------------------------------${NC}"
echo -e "✅ Todos os recursos passíveis de cobrança foram removidos."
echo -e "💰 Custos recorrentes interrompidos com sucesso."
echo -e "ℹ️ Recursos de bootstrap podem permanecer ativos:"
echo -e "   • Bucket Terraform State"
echo -e "   • Workload Identity Federation"
echo -e "   • Service Accounts"
echo -e "${GREEN}--------------------------------------------------------${NC}"