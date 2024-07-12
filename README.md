## このリポジトリは？

Firelensを素振りするためのリポジトリ。

## 構成

nginxとfirelensを同一タスクで動かし、nginxのログをfirelensでcloudwatchlogsの出力する。

nginxはdockerhubから取得。

firelensはfluentbitで構成している。

## 使い方


1. terraformでインフラを構築。
2. fluentbitをビルドして、ECRにPUSH。
3. タスク定義の登録
4. ECSへのデプロイ

環境によって書き換える。特にS3はバケット名が一意となる必要がある。


## タスク定義の登録

```bash
aws ecs register-task-definition --cli-input-json file://task-def.json
```

## ECSへのデプロイ

```bash
aws ecs update-service --cluster stag-yamada-ecs --service stag-yamada-nginx-service --task-definition stag-yamada-nginx-def
```


## イマイチわかっていないこと

- fluent-bit.confをコンテナに入れているが、使われていない気がする。定義をいくら変更しても出力結果は変わらないから。
- 代わりにタスク定義に記述した内容が反映される。反映されているのは、nginxコンテナの定義が反映される。
