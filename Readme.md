# 🧩 Azure App Configuration + Node.js + Terraform Demo  

Este proyecto muestra cómo integrar **Azure App Configuration**, **Terraform** y **Node.js** para gestionar configuraciones dinámicas sin reiniciar tu aplicación.  
El servidor Node.js lee parámetros como el título, color de fondo y tamaño de fuente desde **Azure App Configuration**, reflejando los cambios **en tiempo real**.  

> 💡 Ideal para entornos con múltiples microservicios donde mantener configuraciones sincronizadas es clave.

---

## 🚀 Demo en Acción  

Cada vez que actualices una clave (`ui:title`, `ui:themeColor`, `ui:fontSize`) desde el Portal de Azure, el cambio se reflejará automáticamente en el navegador sin reiniciar el contenedor.

📦 Repositorio del demo:  
👉 [https://github.com/francotel/azure-app-config-terraform-demo](https://github.com/francotel/azure-app-config-terraform-demo)

🧠 Lee la historia completa en Dev.to:  
👉 [Mi viaje con Azure App Configuration](https://dev.to/francotel/despidete-del-caos-de-configs-mi-viaje-con-azure-app-configuration-escalabilidad-seguridad-y-52g7)

---

## ⚙️ Requisitos  

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Docker](https://docs.docker.com/get-docker/)
- [Node.js 18+](https://nodejs.org/en/download/)

---

## 🧱 Makefile  

```makefile
SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

ENV ?= local
PROJECT_NAME ?= demo
INFRA_DIR := infra
APP_DIR := app

az-login:
	@echo "🔐 Logging in to Azure..."
	az login
	az account show

az-sub-id:
    $(eval ARM_SUBSCRIPTION_ID = $(shell az account show --query id -o tsv))

tf-init:
	@echo "🚀 Initializing Terraform (local backend)..."
	cd $(INFRA_DIR) && terraform init -upgrade

tf-plan: az-sub-id
	@echo "📐 Formatting and validating..."
	cd $(INFRA_DIR)
	terraform fmt --recursive && terraform validate
	@echo "📝 Running terraform plan..."
	cd $(INFRA_DIR) && terraform plan -out=tfplan

tf-apply:
	@echo "🚀 Applying Terraform plan..."
	cd $(INFRA_DIR) && terraform apply -auto-approve tfplan

tf-output:
	@echo "👀 Terraform output..."
	cd $(INFRA_DIR) && terraform output

tf-destroy:
	@echo "🔥 Destroying all Terraform-managed infrastructure..."
	cd $(INFRA_DIR) && terraform destroy -auto-approve

tf-clean:
	@echo "🧹 Cleaning up local Terraform state..."
	cd $(INFRA_DIR) && rm -rf .terraform tfplan terraform.tfstate terraform.tfstate.backup

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

dkr-build:
	@echo "🏗️  Building Docker image for $(PROJECT_NAME)..."
	docker build -t $(PROJECT_NAME):latest $(APP_DIR)
	@echo "✅ Image $(PROJECT_NAME):latest built successfully."

dkr-run: dkr-stop
	@echo "🚀 Starting container..."
	docker run --name $(PROJECT_NAME) --rm -p 4000:4000 --env-file $(APP_DIR)/.env $(PROJECT_NAME):latest
	@echo "✅ Container running on http://localhost:4000"

dkr-stop:
	@echo "⏹️  Stopping container..."
	@CID=$$(docker ps -aq --filter "name=$(PROJECT_NAME)"); \
	@docker stop $(CID) 2>/dev/null || echo "⚠️  No container to stop"
	@docker rm $(CID) 2>/dev/null || echo "⚠️  No container to remove"

dkr-clean: dkr-stop
	@echo "🧹 Cleaning images..."
	@docker rmi $(PROJECT_NAME):latest 2>/dev/null || echo "⚠️  No image to remove"


## 🧩 Uso Rápido

# 1️⃣ Login en Azure
make az-login

# 2️⃣ Desplegar infraestructura
make tf-init tf-plan tf-apply

# 3️⃣ Importar configuración YAML
make import-config APP_CONFIG_NAME=app-config-demo

# 4️⃣ Construir y correr el contenedor
make dkr-build dkr-run
```

![demo](app-v1.gif)