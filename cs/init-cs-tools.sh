#!/bin/bash
set -e

source $(dirname $0)/common.sh

CLASS=${1:-"npm"}

if [ "$CLASS" != "npm" -a "$CLASS" != "container-image" ]; then
    echo "パッケージ種別には \"npm\" か \"container-image\" のどちらかを指定してください。\"${CLASS}\"は指定できません。"
    exit 1
fi

set -x
npm add --ignore-workspace-root-check --save-dev @changesets/cli
npx changeset init
mkdir -p .github/workflows
# rm -f .github/workflows/*
cp -a node_modules/@procube/cs-tools/workflows-${CLASS}/* .github/workflows
