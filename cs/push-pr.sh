#!/bin/bash
set -e

if [ -r .env ]; then
  export $(cat .env | grep -v ^#)
fi

if git remote | grep -q 'upstream'; then
  remote=upstream
else
  remote=origin
fi

function usage() {
    echo "以下の手順でご利用ください。"
    echo " 1. yarn start-pr でプルリクエスト用ブランチを作成し、 Prerelease モードに入る"
    echo " 2. yarn add-change で変更内容ログを追加する"
    echo " 3. yarn push-pr でその内容を github.com にプッシュする"
    echo " 4. yarn end-pr で Prerelease モードを終了し、マージし、 main ブランチに戻り、 pull し、プルリクエスト用ブランチを削除する"
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
  echo "このスクリプトはプルリクエスト用のブランチでリモートにプッシュするものです。現在 main をチェックアウトしているためこのコマンドは使えません。"
  usage
  exit 1
fi
set -x
yarn changeset status
yarn changeset version
version=$(node -e "console.log(require('./package.json').version)")
git add -A
git commit -m "commit for $version"
git push $remote $current_branch
set +x
pr_url=$(gh pr status --jq .currentBranch.url --json url)
if [ -n "$pr_url" ]; then
  echo "プルリクエストは作成済みです。"
  exit 0
fi
set -x
gh pr create -B main -H "${current_branch}" --title "${current_branch}" --body 'Created by tools for changesets'
