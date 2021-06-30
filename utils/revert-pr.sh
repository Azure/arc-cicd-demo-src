#!/usr/bin/env bash

while getopts "r:b:p:" option;
    do
    case "$option" in      
        r ) REPO=${OPTARG};;
        b ) TARGET_BRANCH=${OPTARG};;        
        p ) PR_ID=${OPTARG};;
    esac
done
echo "List input params"
echo $REPO
echo $TARGET_BRANCH
echo $PR_ID
echo "end of list"

set -euo pipefail  # fail on error

export REVERT_BRANCH='refs/heads/revert-'$PR_ID

# https://docs.microsoft.com/en-us/rest/api/azure/devops/git/repositories/get%20repository?view=azure-devops-rest-6.0
git_repo=$(curl -v -H "Authorization: Bearer $SYSTEM_ACCESSTOKEN" -H "Content-Type: application/json" --fail \
           "$SYSTEM_COLLECTIONURI$SYSTEM_TEAMPROJECT/_apis/git/repositories/$REPO?api-version=6.0")           


# https://docs.microsoft.com/en-us/rest/api/azure/devops/git/reverts/create?view=azure-devops-rest-6.0
revert_response=$(curl -v -X POST -H "Authorization: Bearer $SYSTEM_ACCESSTOKEN" -H "Content-Type: application/json" --fail -d '{"repository":'$git_repo',"source":{"pullRequestId":"'$PR_ID'"},"ontoRefName":"'$TARGET_BRANCH'","generatedRefName":"'$REVERT_BRANCH'"}' "$SYSTEM_COLLECTIONURI$SYSTEM_TEAMPROJECT/_apis/git/repositories/$REPO/reverts?api-version=6.0-preview.1")
export REVERT_ID=$(echo $revert_response | jq '.revertId')

echo $SYSTEM_ACCESSTOKEN | az devops login
az devops configure --defaults organization=$SYSTEM_COLLECTIONURI project=$SYSTEM_TEAMPROJECT --use-git-aliases true

pr_response=$(az repos pr create --project $SYSTEM_TEAMPROJECT --repository $REPO --target-branch $TARGET_BRANCH --source-branch $REVERT_BRANCH --title Rollback --squash -o json)
export pr_num=$(echo $pr_response | jq '.pullRequestId')


echo "===================================== OUTPUT ====================================="
echo 'Revert ID = '$REVERT_ID
echo 'Rollback Pull Request ID = '$pr_num
echo 'Rollback Pull Request URL = '$SYSTEM_COLLECTIONURI''$SYSTEM_TEAMPROJECT'/_git/'$REPO'/pullrequest/'$pr_num
   

