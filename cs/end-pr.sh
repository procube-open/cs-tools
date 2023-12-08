#!/bin/bash
set -e

if [ -r .env ]; then
  export $(cat .env | grep -v ^#)
fi

function usage() {
    echo "以下の手順でご利用ください。"
    echo " 1. ./cs/start-pr.sh でプルリクエスト用ブランチを作成し、 Prerelease モードに入る"
    echo " 2. ./cs/add.sh で変更内容ログを追加する"
    echo " 3. ./cs/push-pr.sh でその内容を github.com にプッシュする"
    echo " 4. ./cs/end-pr.sh で Prerelease モードを終了し、マージし、 main ブランチに戻り、 pull し、プルリクエスト用ブランチを削除する"
}

if [ -z "$GH_TOKEN" ]; then
    echo "環境変数 GH_TOKEN にパーソナルアクセストークンを設定して利用してください"
    echo ".env に GH_TOKEN=XXX という形式で設定していただけます。"
    exit 1
fi
if [ ! -r .changeset/pre.json ]; then
    echo "Preleaseモードに入っていません。"
    usage
    exit 1
fi
current_branch=$(git branch --show-current)
if [ "$current_branch" == "main" ]; then
  echo "このスクリプトはプルリクエスト用のブランチから初めてプルリクエストを終了するものです。現在 main をチェックアウトしているためこのコマンドは使えません。"
  usage
  exit 1
fi
set -x
yarn changeset pre exit
yarn changeset version
set +x
version=$(node -e "console.log(require('./package.json').version)")
set -x
git add -A
git commit -m "commit for $version"
git push origin $current_branch
pr_url=$(gh pr status --jq .currentBranch.url --json url)
if [ -z "$pr_url" ]; then
  echo "プリリクエストが作成されていません。"
  exit 1
fi
gh pr review "$pr_url" --approve
gh pr merge --auto --delete-branch --squash "$pr_url"
sleep 10
git checkout main
git pull origin main
git branch -D $current_branch
