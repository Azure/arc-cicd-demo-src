#!/usr/bin/env bash

# Simple smoke test requesting demo app url and failing in case of error response

set -x

az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $AKS_NAME

kubectl port-forward svc/azure-vote-front 8080:80 --namespace=$TARGET_NAMESPACE&
portForwardPid=$!

curl -v --fail http://127.0.0.1:8080

kill $portForwardPid