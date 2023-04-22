# practice-aws-copilot-cloudformation-django

## 概要

AWS Copilot と CloudFormation 学習のために作成したサンプルアプリケーションです。
- 主要技術：AWS Copilot, CloudFormation, Django, RDS
- Django は Copilot の Load Balanced Web Service でデプロイ
  - カスタムドメインを使った HTTPS 通信に対応
  - Sidecar コンテナで Nginx を使って静的ファイルを配信
- RDS は CloudFormation でデプロイ

## セットアップ

### pyenv を使って Python をセットアップする

```bash
pyenv install $(cat .python-version)
```

### poetry をセットアップする
参照: https://python-poetry.org/docs/

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

### 依存関係をインストールする

```bash
poetry env use $(cat .python-version)
make install
```

### 環境変数をセットアップする

```bash
# ローカル開発用の環境変数
cp .env.sample .env && vim .env

# アプリ用の環境変数
cp .env.app.sample .env.app && vim .env.app

# RDS の CloudFormation スタック用の環境変数
# このファイルにはまだ値をセットする必要はありません
cp cloudformation/rds.parameters.properties.sample cloudformation/rds.parameters.properties
```

## 実行方法

### Django 開発サーバーを使ってローカルで実行する

```bash
make dev
```

### gunicorn を使ってローカルで実行する

```bash
make start
```

## デプロイ方法

### 1. Copilot にデプロイする

```bash
./scripts/copilot.sh create-app
```

### 2. Copilot でデプロイされた VPC, Subnet, SecurityGroup の ID を確認する

```bash
make cf-describe | grep -A 1 \
  -e '"OutputKey": "VpcId"' \
  -e '"OutputKey": "PrivateSubnets"' \
  -e '"OutputKey": "PublicSubnets"' \
  -e '"OutputKey": "EnvironmentSecurityGroup"' 
```

### 3. 確認した値を cloudformation/rds.parameters.properties にセットする

```properties
VpcId=vpc-xxxxx
CopilotServiceSecurityGroupId=sg-xxxxx
PrivateSubnetId1=subnet-xxxxx
PrivateSubnetId2=subnet-xxxxx
PublicSubnetId1=subnet-xxxxx
PublicSubnetId2=subnet-xxxxx

# 以下の項目は任意の値をセットしてください
DBMasterUsername=admin-xxxxx
DBMasterUserPassword=xxxxx
DBName=xxxxx
DBSubnetGroupName=subnet-group-xxxxx
DBBackupRetentionPeriod=7
```

### 4. RDS をデプロイする

CloudFormation スタックを作成する
```bash
./scripts/rds.cloudformation.sh create-cf-stack
```

デプロイプランを確認する (任意)
```bash
./scripts/rds.cloudformation.sh plan-cf
```

デプロイする
```bash
./scripts/rds.cloudformation.sh deploy-cf
```

## 更新方法

### Copilot を更新する

svc

```bash
./scripts/copilot.sh deploy-svc
```

env

```bash
./scripts/copilot.sh deploy-env
```

### RDS を更新する

デプロイプランを確認する (任意)
```bash
./scripts/rds.cloudformation.sh plan-cf
```

デプロイする
```bash
./scripts/rds.cloudformation.sh deploy-cf
```

## その他

### Copilotアプリのシェルに接続する

```bash
./scripts/copilot.sh exec-svc
```
