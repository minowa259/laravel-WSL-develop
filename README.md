<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

<p align="center">
<a href="https://github.com/laravel/framework/actions"><img src="https://github.com/laravel/framework/workflows/tests/badge.svg" alt="Build Status"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/dt/laravel/framework" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/v/laravel/framework" alt="Latest Stable Version"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/l/laravel/framework" alt="License"></a>
</p>

# Laravel Docker 開発環境

このプロジェクトは、Dockerを使用したLaravel開発環境です。

## 環境情報

- Laravel Framework: 12.38.1
- PHP: 8.3-fpm
- MySQL: 8.0
- Nginx: Alpine
- Redis: Alpine

## 必要な環境

- Docker
- Docker Compose

## 環境構成

このプロジェクトは4つの環境に対応しており、**1つのdocker-compose.yml**で全環境を管理します。

| 環境 | .envファイル | ポート | デバッグ | 再起動ポリシー | ボリューム |
|------|-------------|--------|---------|--------------|-----------|
| ローカル | `.env.local` | 8000 | ON | unless-stopped | 読み書き可 |
| 開発 | `.env.development` | 8001 | ON | unless-stopped | 読み書き可 |
| ステージング | `.env.staging` | 8002 | OFF | unless-stopped | 読み取り専用 |
| 本番 | `.env.production` | 80 | OFF | always | 読み取り専用 |

### 環境別の主な違い

各環境は`.env`ファイルの切り替えだけで完全に分離されます:

- **データベース**: 環境ごとに独立したボリューム（dbdata_local, dbdata_development, など）
- **コンテナ名**: 環境名がサフィックスとして付与（laravel-app-local, laravel-app-development, など）
- **PHP設定**: 環境ごとに異なるiniファイル（local.ini, dev.ini, staging.ini, prod.ini）
- **ログレベル**: 本番はerror、ステージングはwarning、開発/ローカルはdebug
- **セッション暗号化**: 本番・ステージングは有効、ローカル・開発は無効

## セットアップ

### 簡単な環境切り替え（推奨）

環境切り替えスクリプトを使用すると、簡単に環境を切り替えることができます:

```bash
# ローカル環境
./switch-env.sh local

# 開発環境
./switch-env.sh development

# ステージング環境
./switch-env.sh staging

# 本番環境
./switch-env.sh production

# 現在の環境を確認
./switch-env.sh
```

スクリプトは以下を自動的に実行します:
1. 現在のコンテナを停止
2. .envファイルをバックアップ（ローカル環境以外）
3. 環境別の.envファイルをコピー
4. 対応する環境でコンテナを起動
5. 環境設定を表示

### 手動での環境切り替え

スクリプトを使わず手動で切り替える場合は、.envファイルをコピーするだけです:

```bash
# 環境を停止
docker compose down

# 使用したい環境の.envファイルをコピー
cp .env.local .env        # ローカル環境
# または
cp .env.development .env  # 開発環境
# または
cp .env.staging .env      # ステージング環境
# または
cp .env.production .env   # 本番環境

# コンテナを起動（同じコマンドで全環境対応）
docker compose up -d
```

**重要**: docker-compose.ymlは1つだけです。環境は.envファイルで自動的に切り替わります。

## 主要なコマンド

### Artisanコマンド

```bash
# マイグレーション実行
docker compose exec app php artisan migrate

# マイグレーションのロールバック
docker compose exec app php artisan migrate:rollback

# シーダー実行
docker compose exec app php artisan db:seed

# キャッシュクリア
docker compose exec app php artisan cache:clear
docker compose exec app php artisan config:clear
docker compose exec app php artisan route:clear
docker compose exec app php artisan view:clear

# 全キャッシュクリア
docker compose exec app php artisan optimize:clear
```

### Composerコマンド

```bash
# パッケージのインストール
docker compose exec app composer install

# パッケージの追加
docker compose exec app composer require パッケージ名

# パッケージの削除
docker compose exec app composer remove パッケージ名

# オートロードの最適化
docker compose exec app composer dump-autoload
```

### npmコマンド

```bash
# npm パッケージのインストール
docker compose exec app npm install

# アセットのビルド（開発）
docker compose exec app npm run dev

# アセットのビルド（本番）
docker compose exec app npm run build

# 監視モード
docker compose exec app npm run watch
```

### データベース操作

```bash
# MySQLコンテナに接続
docker compose exec db mysql -u laravel -psecret laravel

# データベースのバックアップ
docker compose exec db mysqldump -u laravel -psecret laravel > backup.sql

# データベースのリストア
docker compose exec -T db mysql -u laravel -psecret laravel < backup.sql
```

### ログの確認

```bash
# 全コンテナのログ
docker compose logs -f

# アプリケーションログ
docker compose logs -f app

# Nginxログ
docker compose logs -f nginx

# データベースログ
docker compose logs -f db
```

## コンテナの操作

### コンテナの停止

```bash
docker compose down
```

### コンテナの再起動

```bash
docker compose restart
```

### コンテナの状態確認

```bash
docker compose ps
```

### コンテナに入る

```bash
# アプリケーションコンテナ
docker compose exec app bash

# Nginxコンテナ
docker compose exec nginx sh

# データベースコンテナ
docker compose exec db bash
```

## トラブルシューティング

### ポートが既に使用されている場合

`.env`ファイルで以下のポートを変更してください:

```env
APP_PORT=8000  # 任意のポートに変更
DB_PORT=3306   # 任意のポートに変更
```

### パーミッションエラーが発生する場合

```bash
docker compose exec app chmod -R 777 storage bootstrap/cache
```

### データベース接続エラーが発生する場合

1. `.env`ファイルのDB_HOSTが`db`になっているか確認
2. コンテナを再起動

```bash
docker compose down
docker compose up -d
```

### キャッシュの問題

```bash
docker compose exec app php artisan optimize:clear
```

## 環境切り替えガイド

### 環境切り替えの流れ

環境を切り替える際の推奨フローです:

1. **現在の環境で作業を保存**
   ```bash
   git add .
   git commit -m "作業内容を保存"
   ```

2. **環境を切り替える**
   ```bash
   ./switch-env.sh development
   ```

3. **マイグレーションとシーダーを実行**
   ```bash
   docker compose exec app php artisan migrate
   docker compose exec app php artisan db:seed
   ```

### 環境間でのデータ移行

**開発環境から本番環境へのマイグレーション:**

```bash
# 開発環境でマイグレーションファイルを確認
./switch-env.sh development
docker compose exec app php artisan migrate:status

# 本番環境に切り替え
./switch-env.sh production

# 本番環境でマイグレーション実行（注意！）
docker compose exec app php artisan migrate --force
```

**データベースのコピー:**

```bash
# ローカル環境からバックアップを作成
./switch-env.sh local
docker compose exec db mysqldump -u laravel -psecret laravel > local_backup.sql

# 開発環境でリストア
./switch-env.sh development
docker compose exec -T db mysql -u laravel -psecret laravel_dev < local_backup.sql
```

### 複数環境の同時起動

異なるポートを使用しているため、複数の環境を同時に起動できます:

```bash
# ターミナル1: ローカル環境（ポート8000）
./switch-env.sh local

# ターミナル2: 開発環境（ポート8001）
./switch-env.sh development
```

**注意**: データベースポートは共有されるため、同時起動する場合は`.env`ファイルで`DB_PORT`を変更してください。

## デプロイガイド

### 初回デプロイ

#### 1. サーバーの準備

```bash
# サーバーにSSH接続
ssh user@your-server.com

# Dockerとdocker-composeのインストール
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# プロジェクトをクローン
git clone https://github.com/your-repo/project.git
cd project
```

#### 2. 本番環境設定ファイルの作成

```bash
# .env.productionファイルを作成（gitignoreされているため手動作成）
cp .env.staging .env.production

# 本番環境用に編集
nano .env.production
```

必須の変更項目:
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com
APP_KEY=  # php artisan key:generate で生成

DB_DATABASE=laravel_prod
DB_PASSWORD=強固なパスワード

REDIS_PASSWORD=強固なパスワード

# メール設定
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
```

#### 3. 本番環境を起動

```bash
# 本番環境で起動
./switch-env.sh production

# アプリケーションキーを生成（まだの場合）
docker compose exec app php artisan key:generate

# パーミッション設定
docker compose exec app chmod -R 775 storage bootstrap/cache
docker compose exec app chown -R www-data:www-data storage bootstrap/cache

# マイグレーション実行
docker compose exec app php artisan migrate --force

# キャッシュ最適化
docker compose exec app php artisan config:cache
docker compose exec app php artisan route:cache
docker compose exec app php artisan view:cache
```

#### 4. SSL証明書の設定（Let's Encrypt推奨）

```bash
# Certbotコンテナを追加するか、別途Nginxプロキシを使用
# 詳細は https://letsencrypt.org/ja/ を参照
```

### 更新デプロイ

コードの更新時の手順:

```bash
# サーバーにSSH接続
ssh user@your-server.com
cd project

# 最新のコードを取得
git pull origin main

# 依存関係の更新
docker compose exec app composer install --no-dev --optimize-autoloader

# マイグレーション実行（必要な場合）
docker compose exec app php artisan migrate --force

# キャッシュクリアと最適化
docker compose exec app php artisan optimize:clear
docker compose exec app php artisan config:cache
docker compose exec app php artisan route:cache
docker compose exec app php artisan view:cache

# アセットのビルド（必要な場合）
docker compose exec app npm install
docker compose exec app npm run build

# コンテナを再起動
docker compose restart
```

### ゼロダウンタイムデプロイ

Blue-Greenデプロイメント手法:

```bash
# 1. 新しいバージョンを別環境で起動
cp .env.production .env.production.new
# PORT を変更（例: 8080）
sed -i 's/APP_PORT=80/APP_PORT=8080/' .env.production.new
cp .env.production.new .env
docker compose up -d

# 2. 新環境の動作確認
curl http://localhost:8080

# 3. ロードバランサーまたはリバースプロキシで切り替え
# Nginxの設定を変更してポート8080を向ける

# 4. 旧環境を停止
# 確認後、旧環境のコンテナを停止
```

### デプロイのベストプラクティス

1. **常にバックアップを取る**
   ```bash
   # デプロイ前に必ずDBバックアップ
   docker compose exec db mysqldump -u laravel -p laravel_prod > backup_$(date +%Y%m%d_%H%M%S).sql
   ```

2. **メンテナンスモードを使用**
   ```bash
   # デプロイ前
   docker compose exec app php artisan down

   # デプロイ作業...

   # デプロイ後
   docker compose exec app php artisan up
   ```

3. **ログを監視**
   ```bash
   # リアルタイムでログを確認
   docker compose logs -f app
   ```

4. **ロールバック計画**
   ```bash
   # 問題が発生した場合、前のバージョンに戻す
   git checkout 前のコミットハッシュ
   docker compose exec app composer install --no-dev
   docker compose exec app php artisan migrate:rollback
   docker compose restart
   ```

### 本番環境のセキュリティチェックリスト

- [ ] `APP_DEBUG=false` になっている
- [ ] `APP_ENV=production` になっている
- [ ] 強固なパスワードを設定（DB、Redis等）
- [ ] SSL/TLS証明書が設定されている
- [ ] ファイアウォールが適切に設定されている
- [ ] 不要なポートが公開されていない
- [ ] 定期的なバックアップが設定されている
- [ ] ログローテーションが設定されている
- [ ] `.env.production`がgitignoreされている
- [ ] アプリケーションキーが本番用に生成されている

## Laravelについて

Laravelは、表現力豊かでエレガントな構文を持つWebアプリケーションフレームワークです。以下のような機能を提供します:

- [シンプルで高速なルーティングエンジン](https://laravel.com/docs/routing)
- [強力な依存性注入コンテナ](https://laravel.com/docs/container)
- [セッション](https://laravel.com/docs/session)と[キャッシュ](https://laravel.com/docs/cache)ストレージの複数バックエンド
- [表現力豊かで直感的なデータベースORM](https://laravel.com/docs/eloquent)
- [データベース非依存のスキーママイグレーション](https://laravel.com/docs/migrations)
- [堅牢なバックグラウンドジョブ処理](https://laravel.com/docs/queues)
- [リアルタイムイベントブロードキャスト](https://laravel.com/docs/broadcasting)

## 学習リソース

- [Laravel公式ドキュメント](https://laravel.com/docs)
- [Laravel Learn](https://laravel.com/learn)
- [Laracasts](https://laracasts.com) - 動画チュートリアル

## ライセンス

Laravelフレームワークは、[MITライセンス](https://opensource.org/licenses/MIT)の下でオープンソースソフトウェアとしてライセンスされています。
