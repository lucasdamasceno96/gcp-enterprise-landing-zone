#!/bin/bash
# setup.sh - Script de Inicialização da Landing Zone Hospitalar

PROJECT_ID="ldp21k-labs"

echo "--------------------------------------------------------"
echo "🏦 Iniciando Provisionamento da Infraestrutura Hospitalar..."
echo "--------------------------------------------------------"

# 1. Foundation: Network (VPC e NAT)
echo "🌐 Passo 1: Construindo a Rede Hub (VPC, Subnet, NAT)..."
cd terraform/network
terraform init && terraform apply -auto-approve -var="project_id=$PROJECT_ID"
if [ $? -ne 0 ]; then echo "❌ Erro na Rede. Abortando."; exit 1; fi

# 2. Security: Artifact Registry
echo "🔐 Passo 2: Configurando Segurança (Artifact Registry)..."
cd ../security
terraform init && terraform apply -auto-approve -var="project_id=$PROJECT_ID"
if [ $? -ne 0 ]; then echo "❌ Erro em Security. Abortando."; exit 1; fi

# 3. Workloads: Cloud Run
echo "🚀 Passo 3: Deploy do Workload (Hospital API no Cloud Run)..."
cd ../workloads
terraform init && terraform apply -auto-approve -var="project_id=$PROJECT_ID"
if [ $? -ne 0 ]; then echo "❌ Erro no Workload. Abortando."; exit 1; fi

# 4. Observability: Dashboard e Monitoramento
echo "📊 Passo 4: Ativando Observabilidade (Dashboards e Uptime)..."
cd ../observability
terraform init && terraform apply -auto-approve -var="project_id=$PROJECT_ID"
if [ $? -ne 0 ]; then echo "❌ Erro em Observability. Abortando."; exit 1; fi

echo "--------------------------------------------------------"
echo "✨ Landing Zone Hospitalar está ONLINE!"
echo "📍 Acesse o Console do GCP para ver seu Dashboard e API."
echo "--------------------------------------------------------"