## このリポジトリは

firelensとfirehoseを素振りするためのリポジトリ。

## 構成

### 構成図

素振りの構成は以下の構成。

![](figure/poc-system.jpg)

### 簡単な説明

nginxとfirelensを同一タスクで動かし、nginxのログをfirelensでcloudwatchlogsとS3に出力する。

firelensそのもののログ（起動して初期化していることがわかるログ）はfirehose経由でS3に出力する。

### コンテナイメージの取得元

各コンテナイメージは以下から取得している。

- nginx：dockerhubから取得
- firelens：fluentbitを使用している。また、AWSからイメージを取得。（fluentdではなく、fluentbit）

## 使い方

1. terraformでインフラを構築する
2. extra.confをs3にアップロードする
3. タスク定義を登録する
4. タスクをECSにデプロイする

動かない場合は、コードを書き換える。特にタスク定義にアカウントIDを明記しているし、S3はバケット名が一意となる必要がある。

## extra.confをs3にアップロードする

```bash
aws s3 cp extra.conf s3://fluent-bit-yamada
```
## タスク定義の登録

```bash
aws ecs register-task-definition --cli-input-json file://task-def.json
```

## ECSへのデプロイ

```bash
aws ecs update-service --cluster stag-yamada-ecs --service stag-yamada-nginx-service --task-definition stag-yamada-nginx-def
```


