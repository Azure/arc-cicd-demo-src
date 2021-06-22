#!/usr/bin/env bash

env_name=$1
tenant_name=$2
release_number=$3
manifests_repo=$4
manifests_branch=$5

pr_user_name="Git Ops"
pr_user_email="agent@gitops.com"

git config --global user.email $pr_user_email
git config --global user.name $pr_user_name

git checkout $env_name
./utils/add-release-env.sh $tenant_name $release_number $manifests_repo $manifests_branch

git add *
if [[ `git status --porcelain | head -1` ]]; then
  git commit -m 'add release to fleet'
fi
