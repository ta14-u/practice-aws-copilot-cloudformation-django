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

公式インストーラー：Linux, macOS, Windows (WSL) の場合

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

公式インストーラー：Windows (Powershell) の場合

```powerShell
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | py -
```

その他のインストール方法：https://python-poetry.org/docs/#installation



### 依存関係をインストールする

```bash
poetry env use $(cat .python-version)
make install
```

### 環境変数をセットアップする

```bash
# ローカル開発用の環境変数
# 一通り自身の環境に合わせて値をセットしてください
cp .env.sample .env && vim .env

# アプリ用の環境変数
# RDS_* は RDS との接続時に使用するので後述する手順で値をセットします
cp .env.app.sample .env.app && vim .env.app

# RDS の CloudFormation スタック用の環境変数
# このファイルには後述する手順で値をセットするのでファイルのコピーのみ行います
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

[AWS 公式の手順](https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/docker-push-ecr-image.html)を参考に Nginx の Docker イメージを ECR に push する  

※ Nginx の Docker イメージビルドコマンドは以下
```bash
docker build -t example-django-app/nginx -f docker/nginx/nginx_Dockerfile docker/nginx
````

Copilot service manifest を自身の環境に合わせて編集する
```bash
vim copilot/django/manifest.yml
# http.alias には自身のドメインをセットしてください(Route53 で管理しているドメインを想定)
#  ex) example.com, sub.example.com
# platform は自身の Docker ビルド環境に合わせてセットしてください
# sidecars.nginx.image に事前に ECR に push した Nginx のイメージをセットしてください
```

Copilot にデプロイする
```bash
./scripts/copilot.sh create-app
```

- この時点でデプロイされるのは Copilot の Django アプリのみです
- 完了後に表示される URL にアクセスすると Django アプリのトップページが表示されます

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

### 5. Django アプリに RDS の接続情報をセットして Copilot service に再デプロイする

RDS の接続情報をセットする
```bash
# RDS_* のコメントアウトを外して値をセットする
vim .env.app
```

Copilot service を再デプロイする
```bash
./scripts/copilot.sh deploy-svc
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
