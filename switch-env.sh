#!/bin/bash

# Laravel環境切り替えスクリプト

set -e

ENVS=("local" "development" "staging" "production")
ENV=$1

# 引数チェック
if [ -z "$ENV" ]; then
    echo "使用方法: ./switch-env.sh [local|development|staging|production]"
    echo ""
    echo "現在の環境を確認:"
    if [ -f .env ]; then
        grep "^APP_ENV=" .env || echo "APP_ENVが設定されていません"
    else
        echo ".envファイルが存在しません"
    fi
    exit 1
fi

# 環境の検証
if [[ ! " ${ENVS[@]} " =~ " ${ENV} " ]]; then
    echo "エラー: 無効な環境です: $ENV"
    echo "有効な環境: local, development, staging, production"
    exit 1
fi

# .envファイルの決定
if [ "$ENV" = "local" ]; then
    ENV_FILE=".env.local"
elif [ "$ENV" = "development" ]; then
    ENV_FILE=".env.development"
elif [ "$ENV" = "staging" ]; then
    ENV_FILE=".env.staging"
elif [ "$ENV" = "production" ]; then
    ENV_FILE=".env.production"
fi

# .envファイルの存在確認
if [ ! -f "$ENV_FILE" ]; then
    echo "エラー: $ENV_FILE が見つかりません"
    exit 1
fi

echo "========================================="
echo "環境を ${ENV} に切り替えます"
echo "========================================="

# 現在のコンテナを停止
echo ""
echo "[1/3] 現在のコンテナを停止中..."
newgrp docker << 'DOCKERCMD'
docker compose down 2>/dev/null || true
DOCKERCMD

# .envファイルをバックアップ
if [ -f .env ] && [ "$ENV" != "local" ]; then
    echo ""
    echo "[2/3] 現在の.envをバックアップ中..."
    cp .env .env.backup.$(date +%Y%m%d%H%M%S)
fi

# .envファイルをコピー
echo ""
echo "[3/3] $ENV_FILE を .env にコピー中..."
cp "$ENV_FILE" .env

# 新しい環境を起動
echo ""
echo "環境を起動中..."
newgrp docker << DOCKERCMD
docker compose up -d

echo ""
echo "========================================="
echo "✓ ${ENV} 環境への切り替えが完了しました"
echo "========================================="
echo ""

# 環境情報を表示
docker compose ps

echo ""
echo "環境設定:"
docker compose exec app php artisan env
DOCKERCMD

echo ""
echo "次のステップ:"
echo "  マイグレーション実行:"
echo "    docker compose exec app php artisan migrate"
