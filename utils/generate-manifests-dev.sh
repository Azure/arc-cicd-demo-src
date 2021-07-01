#!/usr/bin/env bash
# Generates K8s manifests from Helm + Kustomize templates
# Uses env variables to substitute values 
# Requires to be installed:  
#   - helm 
#   - kubectl
#   - envsubst (https://command-not-found.com/envsubst)
# 

# Usage:
# generate-manifests.sh FOLDER_WITH_MANIFESTS GENERATED_MANIFESTS_FOLDER
# e.g.:
# generate-manifests-dev.sh cloud-native-ops/azure-vote/manifests


# Substitute env variables in all yaml files in the manifest folder
for file in `find $1 -name '*.yaml'`; do envsubst <"$file" > "$file"1 && mv "$file"1 "$file"; done


# Generate manifests
for app in `find $1 -maxdepth 1 -mindepth 1 -type d `; do \
    helm template "$app"/helm > "$app"/kustomize/base/manifests.yaml
done
pwd

