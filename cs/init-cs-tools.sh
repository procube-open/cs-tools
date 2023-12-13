#!/bin/bash
set -e

if [ -r .env ]; then
  export $(cat .env | grep -v ^#)
fi

CLASS=${1:-"npm"}

if [ "$CLASS" != "npm" -a "$CLASS" != "container-image" ]; then
    echo "パッケージ種別には \"npm\" か \"container-image\" のどちらかを指定してください。\"${CLASS}\"は指定できません。"
    exit 1
fi

function usage() {
    echo "以下の手順でご利用ください。"
    echo " 1. ./cs/start-pr.sh でプルリクエスト用ブランチを作成し、 Prerelease モードに入る"
    echo " 2. ./cs/add.sh で変更内容ログを追加する"
    echo " 3. ./cs/push-pr.sh でその内容を github.com にプッシュする"
    echo " 4. ./cs/end-pr.sh で Prerelease モードを終了し、マージし、 main ブランチに戻り、 pull し、プルリクエスト用ブランチを削除する"
}

set -x
yarn add @changesets/cli
yarn changeset init
mkdir -p .github/workflows
rm -f .github/workflows/*
cp -a node_modules/@procube/cs-tools/workflows-${CLASS}/* .github/workflows
