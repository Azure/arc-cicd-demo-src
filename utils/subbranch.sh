#!/usr/bin/env bash


orig_branch_name=$1
branch_name=$2

git ls-remote --exit-code --heads origin $branch_name 2> /dev/null

if [ $? -eq 2 ]
then
    echo "Branch $branch_name doesn't exist"
    git checkout origin/$orig_branch_name
    git checkout -b $branch_name
    git push --set-upstream origin $branch_name
    exit 0
fi
