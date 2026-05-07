#!/bin/bash
# setup.sh - Script de Inicialização da Landing Zone Hospitalar

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
echo -e "🏦 Iniciando Provisionamento da Infraestrutura Hospitalar..."
echo -e "${GREEN}--------------------------------------------------------${NC}"

# Função reutilizável
deploy_module() {
    local dir=$1
    local description=$2

    echo -e "\n${YELLOW}🚀 ${description}${NC}"

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

    echo -e "${YELLOW}📋 Executando terraform plan...${NC}"

    terraform plan \
        -var="project_id=$PROJECT_ID" \
        -lock=false \
        -input=false

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Falha no terraform plan em $dir${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Plan OK${NC}"

    echo -e "${YELLOW}🏗️ Aplicando infraestrutura...${NC}"

    terraform apply \
        -auto-approve \
        -var="project_id=$PROJECT_ID"

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Falha no terraform apply em $dir${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Deploy de $dir concluído com sucesso${NC}"

    # Volta para raiz
    cd "$ROOT_DIR"
}

# Ordem de dependência correta
deploy_module "network" "Passo 1: Construindo Rede Hub (VPC, Subnet, NAT)"
deploy_module "security" "Passo 2: Configurando Segurança (Artifact Registry)"
deploy_module "workloads" "Passo 3: Deploy do Workload (Cloud Run)"
deploy_module "observability" "Passo 4: Ativando Observabilidade"

echo -e "\n${GREEN}--------------------------------------------------------${NC}"
echo -e "✨ Landing Zone Hospitalar está ONLINE!"
echo -e "📍 Acesse o Console do GCP para visualizar:"
echo -e "   • Cloud Run"
echo -e "   • Artifact Registry"
echo -e "   • Dashboards"
echo -e "   • Monitoring"
echo -e "${GREEN}--------------------------------------------------------${NC}"