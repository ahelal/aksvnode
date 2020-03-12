-include .env

infra: init apply output_env
app: aks_creds docker_build deploy
clean: undeploy destroy

init:
	@cd terraform; terraform init

plan:
	@cd terraform; terraform plan

apply:
	@cd terraform; terraform apply

output_env:
	@printf "DOCKER_URL=" > .env 
	@cd terraform; terraform output acr_server | tr -d '[:space:]' >> ../.env 
	@printf "\nDOCKER_PASSWORD=" >> .env 
	@cd terraform; terraform output docker_password | tr -d '[:space:]' >> ../.env 
	@printf "\nDOCKER_USER=" >> .env 
	@cd terraform; terraform output docker_username | tr -d '[:space:]' >> ../.env 
	@printf "\nAKS_NAME=" >> .env 
	@cd terraform; terraform output aks_name | tr -d '[:space:]' >> ../.env 
	@printf "\nAKS_RG=" >> .env 
	@cd terraform; terraform output aks_rg | tr -d '[:space:]' >> ../.env 
	
output:
	@cd terraform; terraform output

destroy:
	@cd terraform; terraform destroy

aks_creds:
	@echo "Get AKS creds"
	@az aks get-credentials --name "${AKS_NAME}" -g "${AKS_RG}"

docker_build:
	@echo "Docker login/build/push"
	@cd app_ping; docker build . -t ${DOCKER_URL}/ping
	@docker login -u "${DOCKER_USER}" -p "${DOCKER_PASSWORD}" "${DOCKER_URL}"
	@docker push "${DOCKER_URL}/ping"

deploy:
	@echo "Template our objects (poors man helm)"
	@cd k8s;DOCKER_URL="${DOCKER_URL}" ./template.sh
	@echo "Create image secrets"
	@kubectl delete secret acr || echo "nothing to delete"
	@kubectl create secret docker-registry acr --docker-username="${DOCKER_USER}" --docker-password="${DOCKER_PASSWORD}" --docker-server="${DOCKER_URL}"
	@echo "Deploy to aks"
	@cd k8s;kubectl apply -f generated

undeploy:
	@kubectl delete deployments ping-1 ping-2 ping-3 ping-a ping-b ping-c
