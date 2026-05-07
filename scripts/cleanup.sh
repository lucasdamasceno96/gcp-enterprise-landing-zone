#!/bin/bash
# cleanup.sh - Script de Destruição Segura para Economia de Custos (Hospital Lab)

PROJECT_ID="ldp21k-labs"

echo "--------------------------------------------------------"
echo "🏦 Iniciando Desligamento da Infraestrutura Hospitalar..."
echo "--------------------------------------------------------"

# 1. Observability (Dashboard e Uptime Checks - Sem custo alto, mas boa prática)
echo "🚀 Destruindo Camada de Observabilidade..."
cd terraform/observability
terraform init && terraform destroy -auto-approve -var="project_id=$PROJECT_ID"

# 2. Workloads (Cloud Run - Cobra apenas por execução, mas o NAT associado cobra por hora)
echo "🚀 Destruindo Camada de Workloads (Cloud Run)..."
cd ../workloads
terraform init && terraform destroy -auto-approve -var="project_id=$PROJECT_ID"

# 3. Security (Artifact Registry - Cobra apenas armazenamento, custo quase zero)
# Você pode escolher NÃO destruir esta pasta para manter suas imagens,
# mas se quiser limpeza total, use as linhas abaixo:
echo "🚀 Destruindo Camada de Segurança (Artifact Registry)..."
cd ../security
terraform init && terraform destroy -auto-approve -var="project_id=$PROJECT_ID"

# 4. Network (VPC, Cloud NAT e Router - OS VILÕES DO CUSTO)
# O Cloud NAT cobra ~US$ 1.00 por dia só por estar ligado.
echo "🚀 Destruindo Camada de Rede (HUB VPC & NAT)..."
cd ../network
terraform init && terraform destroy -auto-approve -var="project_id=$PROJECT_ID"

echo "--------------------------------------------------------"
echo "✅ Todos os recursos passíveis de cobrança foram removidos."
echo "✅ Bootstrap (Bucket) e WIF permanecem ativos (Custo Zero)."
echo "--------------------------------------------------------"