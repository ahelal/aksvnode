# AKS Virtual node

## Requirements 

* terraform > 0.12
* az cli
* kubenet 
* docker

## Deploy

```
# create infra with terraform
make infra

# gets kubectl config, build/push python app to ACR and deploy to AKS
make app

# get nodes/pods 
kubectl get nodes
kubectl get pods

# clean infra
make clean
```
