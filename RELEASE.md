# リリース手順

## 1. ブランチ作成

git checkout -b ブランチ名

## 2. 修正

VSCode で修正

## 3. commit

VSCode のコミット機能でコミットする

## 4. RC版タグ付け
以下を実行して package.json を編集し、タグをつける

```
npm version prerelease --preid rc
git push origin ブランチ名
```

## 5. プルリクエスト作成

github の Web UI でプルリクエストを作成する

## 6. 結合テスト

参照側リポジトリで以下を実行する

```
npm install --ignore-workspace-root-check https://github.com/procube-open/cs-tools.git#ブランチ名
```

## 7. 修正

結合テストの結果、必要に応じて修正し、 3. に戻る。
結合テストに成功した場合は、以下を実行して次に進む

```
npm version patch
git push origin ブランチ名
```

## 8. プルリクエストをマージ

Githubの Web UI か VSCode からプルリクエストをマージする。
これにより、 npmjs にパッケージがリリースされる。

