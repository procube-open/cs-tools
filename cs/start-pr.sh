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
if [ -r .changeset/pre.json ]; then
    echo "Preleaseモードに入っています。"
    usage
    exit 1
fi
current_branch=$(git branch --show-current)
if [ "$current_branch" != "main" ]; then
  echo "このスクリプトは main ブランチから新しくプルリクエスト用のブランチを作成するものです。現在 ${current_branch} をチェックアウトしているためこのコマンドは使えません。"
  usage
  exit 1
fi
branch_name=${1:-$(date +pr-%y%m%d%H%M%S)}
echo "${remote}/main ブランチを pull します。"
if ! git pull $remote main; then
  echo "${remote}/main ブランチの pull に失敗しました。 git コマンドのメッセージに従って解消してください。"
  exit 1
fi
set -x
git checkout -b ${branch_name}
yarn changeset pre enter rc
