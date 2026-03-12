SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

## Default environment name (not strictly used here, but kept for possible future use)
ENV ?= dev
PROJECT_NAME ?= secure-serverless-banking
INFRA_DIR := infra
APP_DIR := app
CONFIG_DIR := config
SEC_DIR := security

TFVARS := $(ENV).tfvars
TFPLAN := tfplan
TFPLAN_JSON := tfplan.json

## Azure CLI login
az-login:
	@echo "🔐 Logging in to Azure..."
	az login
	az account show

az-sub-id:
    $(eval ARM_SUBSCRIPTION_ID = $(shell az account show --query id -o tsv))

## Terraform commands
tf-init:
	@echo "🚀 Initializing Terraform (local backend)..."
	cd $(INFRA_DIR) && terraform init -upgrade

tf-plan: az-sub-id
	@echo "📐 Formatting and validating..."
	cd $(INFRA_DIR) && terraform fmt --recursive
	cd $(INFRA_DIR) && terraform validate
	@echo "📝 Running terraform plan..."
	cd $(INFRA_DIR) && terraform plan -var-file=$(TFVARS) -out=$(TFPLAN)

.PHONY: tf-plan-json
tf-plan-json: tf-plan
	@echo "📄 Exporting Terraform plan to JSON"
	cd $(INFRA_DIR) && terraform show -json $(TFPLAN) > $(TFPLAN_JSON)

tf-apply:
	@echo "🚀 Applying Terraform plan..."
	cd $(INFRA_DIR) && terraform apply -auto-approve -input=false $(TFPLAN)

tf-output:
	@echo "👀 Terraform output..."
	cd $(INFRA_DIR) && terraform output

tf-destroy:
	@echo "🔥 Destroying all Terraform-managed infrastructure..."
	cd $(INFRA_DIR) && terraform destroy -var-file=$(TFVARS) -auto-approve

tf-clean:
	@echo "🧹 Cleaning up local Terraform state..."
	cd $(INFRA_DIR) && rm -rf .terraform tfplan terraform.tfstate terraform.tfstate.backup

## Usage: make import-config APP_CONFIG_NAME=my-app-config LABEL=dev
import-config:
	@echo "📦 Importing key-values from $(APP_DIR)/app-config.yml into Azure App Configuration [$(APP_CONFIG_NAME)]..."
	az appconfig kv import \
		-n $(APP_CONFIG_NAME) \
		--source file \
		--path $(APP_DIR)/app-config.yml \
		--format yaml \
		--separator : \
		--yes
	@echo "✅ Import completed successfully."

## 🐳 Build Docker image for the Node.js app
dkr-build:
	@echo "🏗️  Building Docker image for $(PROJECT_NAME)..."
	docker build -t $(PROJECT_NAME):latest $(APP_DIR)
	@echo "✅ Image $(PROJECT_NAME):latest built successfully."

## Docker Run
dkr-run: dkr-stop
	@echo "🚀 Starting container..."
	docker run --name $(PROJECT_NAME) --rm -p 4000:4000 --env-file $(APP_DIR)/.env $(PROJECT_NAME):latest
	@echo "✅ Container running on http://localhost:4000"

## Docker Stop
dkr-stop:
	@echo "⏹️  Stopping container..."
	@CID=$$(docker ps -aq --filter "name=$(PROJECT_NAME)"); \
	@docker stop $(CID) 2>/dev/null || echo "⚠️  No container to stop"
	@docker rm $(CID) 2>/dev/null || echo "⚠️  No container to remove"

## Docker Clean
dkr-clean: dkr-stop
	@echo "🧹 Cleaning images..."
	@docker rmi $(PROJECT_NAME):latest 2>/dev/null || echo "⚠️  No image to remove"

.PHONY: sec-iac
sec-iac: tf-plan-json
	@echo "🔐 Running Checkov scan on Terraform PLAN"
	checkov \
		--framework terraform_plan \
		--config-file $(SEC_DIR)/checkov.yaml \
		-f $(INFRA_DIR)/$(TFPLAN_JSON)

sec-fs:
	@echo "🛡️ Running Trivy filesystem scan"
	trivy fs ./src \
		--config $(SEC_DIR)/trivy.yaml

# -------- Security: All --------
.PHONY: sec-all
sec-all: sec-iac sec-fs
	@echo "✅ All DevSecOps security scans completed"

# -------- FinOps --------
.PHONY: infracost
infracost: tf-plan
	@echo "💰 Infracost breakdown"
	infracost breakdown --path $(INFRA_DIR)/$(TFPLAN)

.PHONY: infracost-html
infracost-html: tf-plan
	@echo "📊 Infracost HTML report"
	infracost breakdown --path . --format html > cost-report.html
	open cost-report.html