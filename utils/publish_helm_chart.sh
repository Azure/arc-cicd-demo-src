# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#!/usr/bin/env bash

# Usage:
# publish_helm_chart.sh FOLDER_WITH_CHART CHART_REPO_NAME CHART_REPO_URL

set -euo pipefail  # fail on error

FOLDER_WITH_CHART=$1
CHART_REPO_NAME=$2
CHART_REPO_URL=$3



DEST_BRANCH="gh-pages"

pr_user_name="Git Ops"
pr_user_email="agent@gitops.com"

git config --global user.email $pr_user_email
git config --global user.name $pr_user_name

# Clone chart repo
echo "Clone chart repo"
repo_url="${CHART_REPO_NAME#http://}"
repo_url="${CHART_REPO_NAME#https://}"
repo_url="https://automated:$TOKEN@$repo_url"

echo "git clone $repo_url -b $DEST_BRANCH --depth 1 --single-branch"

git clone $repo_url -b $DEST_BRANCH --depth 1 --single-branch

echo "git clone"

repo=${CHART_REPO_NAME##*/}
repo_name=${repo%.*}

for app in `find $FOLDER_WITH_CHART -type d -maxdepth 1 -mindepth 1`; 
do 
  echo $app
  ls -ltr $app
  helm package $app/helm
  cp *.tgz $repo_name/
done

cd $repo_name
helm repo index . --url $CHART_REPO_URL

git add -A
echo "git status"
git status

git commit -m "add a new chart"
git push origin