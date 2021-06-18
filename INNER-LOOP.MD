
## Developer Inner-Loop. 

This document describes inner-loop flow while making changes to Azure Vote front-end and back-end application code.  

### Prerequisite  

- [DevSpace CLI](https://devspace.sh/cli/docs/getting-started/installation)
- [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Install Docker](https://docs.docker.com/get-docker/)
- [Install Kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Create ACR token](https://docs.microsoft.com/en-us/cli/azure/acr/token?view=azure-cli-latest#az_acr_token_create)
- Login with `docker login -u <TOKEN_NAME> -p <TOKEN> <ACR_NAME>.azurecr.io`
  

This repository is using [DevSpace](https://devspace.sh/cli/docs/introduction) as Inner loop framework. DevSpace runs as a single binary CLI tool directly on your computer and ideally, you use it straight from the terminal within your IDE. DevSpace does not require a server-side component as it communicates directly to your Kubernetes cluster using your kube-context, just like kubectl.

DevSpace allows you to store all your workflows in one declarative config file: [devspace.yaml](./devspace.yaml). This repository has devspace.yaml for Azure vote App that includes both font-end and back-end.


### Inner-Loop Flow 


1. Rename `.env.template` to `.env` and run  `source .env` for setting config values.  
1. Run `devspace use context` and select kubernetes cluster followed by `devspace use namespace <namespace_name>`
1. Post making changes to application code run `devspace dev` to instantly run Azure front-end container along with its dependencies in target cluster. 
   Running `devspace dev` will also implicitly generate manifest required to run 'Azure Vote App'. To explicitly generate manifest  Run `devspace run gen-manifest` 
1. Post running `devspace dev`, you can access Azure front-end through the port forwarding configuration specified in devspace.yaml e.g `http://localhost:8085/`
1. Running `devspace dev` also syncs app files into containers and you can continue making changes to app code without rebuilding image.
1. After the changes are finalized and tested push a new image to Azure Container registry by running `devspace build`
1. Run `devspace deploy` to build container image and deploy application to target cluster.
1. Run `devspace purge` to purge deployed application in target cluster.