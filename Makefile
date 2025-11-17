.PHONY: help up down restart build logs shell test migrate fresh seed install dev-tools

# デフォルトターゲット
.DEFAULT_GOAL := help

# 環境変数
DOCKER_COMPOSE = docker compose
ARTISAN = $(DOCKER_COMPOSE) exec app php artisan
COMPOSER = $(DOCKER_COMPOSE) exec app composer
NPM = $(DOCKER_COMPOSE) exec app npm

## ヘルプ
help:
	@echo "使用可能なコマンド:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

## Docker操作
up: ## コンテナを起動
	$(DOCKER_COMPOSE) up -d

up-dev: ## 開発ツール含めてコンテナを起動
	$(DOCKER_COMPOSE) --profile dev up -d

down: ## コンテナを停止・削除
	$(DOCKER_COMPOSE) down

restart: ## コンテナを再起動
	$(DOCKER_COMPOSE) restart

build: ## イメージを再ビルド
	$(DOCKER_COMPOSE) build --no-cache

rebuild: ## 完全再ビルド（ボリューム含む）
	$(DOCKER_COMPOSE) down -v
	$(DOCKER_COMPOSE) build --no-cache
	$(DOCKER_COMPOSE) up -d

logs: ## ログを表示
	$(DOCKER_COMPOSE) logs -f

ps: ## コンテナ一覧を表示
	$(DOCKER_COMPOSE) ps

## アプリケーション操作
shell: ## appコンテナにシェル接続
	$(DOCKER_COMPOSE) exec app bash

root-shell: ## appコンテナにroot権限でシェル接続
	$(DOCKER_COMPOSE) exec -u root app bash

## Laravel操作
install: ## 初回セットアップ
	$(COMPOSER) install
	cp .env.example .env || true
	$(ARTISAN) key:generate
	$(ARTISAN) storage:link
	$(ARTISAN) migrate
	$(NPM) install

migrate: ## マイグレーション実行
	$(ARTISAN) migrate

migrate-fresh: ## マイグレーションをリセットして再実行
	$(ARTISAN) migrate:fresh

migrate-rollback: ## マイグレーションをロールバック
	$(ARTISAN) migrate:rollback

seed: ## シーダー実行
	$(ARTISAN) db:seed

fresh: ## データベースをリセットしてシーダー実行
	$(ARTISAN) migrate:fresh --seed

## テスト
test: ## テスト実行
	$(DOCKER_COMPOSE) exec app php artisan test

test-coverage: ## カバレッジ付きテスト実行
	$(DOCKER_COMPOSE) exec app php artisan test --coverage

phpstan: ## PHPStan静的解析
	$(DOCKER_COMPOSE) exec app vendor/bin/phpstan analyse

php-cs-fixer: ## コードスタイル修正
	$(DOCKER_COMPOSE) exec app vendor/bin/php-cs-fixer fix

phpcs: ## コードスタイルチェック
	$(DOCKER_COMPOSE) exec app vendor/bin/phpcs

## キャッシュ操作
cache-clear: ## 全キャッシュクリア
	$(ARTISAN) optimize:clear

config-cache: ## 設定キャッシュ
	$(ARTISAN) config:cache

route-cache: ## ルートキャッシュ
	$(ARTISAN) route:cache

view-cache: ## ビューキャッシュ
	$(ARTISAN) view:cache

optimize: ## 本番用最適化
	$(ARTISAN) config:cache
	$(ARTISAN) route:cache
	$(ARTISAN) view:cache
	$(COMPOSER) install --optimize-autoloader --no-dev

## フロントエンド操作
npm-install: ## npmパッケージインストール
	$(NPM) install

npm-dev: ## 開発ビルド
	$(NPM) run dev

npm-build: ## 本番ビルド
	$(NPM) run build

npm-watch: ## 監視モード
	$(NPM) run watch

## データベース操作
db-shell: ## MySQLシェル接続
	$(DOCKER_COMPOSE) exec db mysql -u laravel -psecret laravel

db-backup: ## データベースバックアップ
	$(DOCKER_COMPOSE) exec db mysqldump -u laravel -psecret laravel > backup_$(shell date +%Y%m%d_%H%M%S).sql

db-restore: ## データベースリストア（FILE=backup.sql）
	$(DOCKER_COMPOSE) exec -T db mysql -u laravel -psecret laravel < $(FILE)

## 環境切り替え
env-local: ## ローカル環境に切り替え
	./switch-env.sh local

env-dev: ## 開発環境に切り替え
	./switch-env.sh development

env-staging: ## ステージング環境に切り替え
	./switch-env.sh staging

env-prod: ## 本番環境に切り替え
	./switch-env.sh production

## パーミッション修正
permissions: ## パーミッション修正
	$(DOCKER_COMPOSE) exec -u root app chmod -R 775 storage bootstrap/cache
	$(DOCKER_COMPOSE) exec -u root app chown -R www:www storage bootstrap/cache

## クリーンアップ
clean: ## 不要なファイルを削除
	rm -rf vendor node_modules
	rm -f .env

clean-docker: ## Dockerリソースをクリーンアップ
	docker system prune -af
	docker volume prune -f
