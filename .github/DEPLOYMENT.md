# デプロイメントガイド

このドキュメントでは、GitHub Actionsを使用した自動デプロイの設定方法を説明します。

## 前提条件

- デプロイ先サーバーへのSSHアクセス
- サーバーにDocker、Docker Composeがインストール済み
- GitHubリポジトリの管理者権限

## デプロイワークフローの概要

このプロジェクトには2つのデプロイワークフローがあります:

1. **CI/CDパイプライン** (`.github/workflows/ci.yml`)
   - テスト、静的解析、セキュリティチェック
   - 全ブランチで自動実行

2. **デプロイメント** (`.github/workflows/deploy.yml`)
   - ステージング環境: `staging`ブランチ
   - 本番環境: `main`ブランチ
   - **デフォルトでは無効**: `DEPLOY_ENABLED`変数を設定する必要があります

## セットアップ手順

### 1. SSH鍵の生成

デプロイ用のSSH鍵ペアを生成します:

```bash
# ステージング環境用
ssh-keygen -t ed25519 -C "github-actions-staging" -f ~/.ssh/github_actions_staging

# 本番環境用
ssh-keygen -t ed25519 -C "github-actions-production" -f ~/.ssh/github_actions_production
```

### 2. 公開鍵をサーバーに配置

```bash
# ステージングサーバー
ssh-copy-id -i ~/.ssh/github_actions_staging.pub user@staging-server.com

# 本番サーバー
ssh-copy-id -i ~/.ssh/github_actions_production.pub user@production-server.com
```

### 3. GitHubシークレットの設定

**リポジトリ設定 → Secrets and variables → Actions**

#### Variables（変数）

| 変数名 | 値 | 説明 |
|--------|-----|------|
| `DEPLOY_ENABLED` | `true` | デプロイを有効化 |

#### Secrets（シークレット）

##### ステージング環境

| シークレット名 | 値の例 | 説明 |
|---------------|--------|------|
| `SSH_PRIVATE_KEY_STAGING` | `-----BEGIN OPENSSH PRIVATE KEY-----...` | SSH秘密鍵の内容 |
| `SSH_USER_STAGING` | `deploy` | SSHユーザー名 |
| `SSH_HOST_STAGING` | `staging.example.com` | サーバーホスト名 |
| `DEPLOY_PATH_STAGING` | `/var/www/app-staging` | デプロイ先パス |

##### 本番環境

| シークレット名 | 値の例 | 説明 |
|---------------|--------|------|
| `SSH_PRIVATE_KEY_PROD` | `-----BEGIN OPENSSH PRIVATE KEY-----...` | SSH秘密鍵の内容 |
| `SSH_USER_PROD` | `deploy` | SSHユーザー名 |
| `SSH_HOST_PROD` | `example.com` | サーバーホスト名 |
| `DEPLOY_PATH_PROD` | `/var/www/app` | デプロイ先パス |
| `DB_PASSWORD_PROD` | `your-secure-password` | データベースパスワード |
| `APP_URL_PROD` | `https://example.com` | 本番環境URL |

##### オプション（Slack通知）

| シークレット名 | 値の例 | 説明 |
|---------------|--------|------|
| `SLACK_WEBHOOK` | `https://hooks.slack.com/services/...` | Slack Webhook URL |

### 4. サーバー側の準備

各サーバーで以下を実行:

```bash
# プロジェクトディレクトリを作成
sudo mkdir -p /var/www/app-staging
sudo chown deploy:deploy /var/www/app-staging

# リポジトリをクローン
cd /var/www/app-staging
git clone https://github.com/your-org/your-repo.git .

# 環境ファイルを設定
cp .env.staging .env
nano .env  # 必要な設定を編集

# 初回セットアップ
./switch-env.sh staging
make install
```

## デプロイフロー

### ステージング環境へのデプロイ

```bash
# developブランチで開発
git checkout develop
git add .
git commit -m "feat: 新機能追加"
git push origin develop

# stagingブランチにマージ
git checkout staging
git merge develop
git push origin staging  # <- 自動デプロイ開始
```

### 本番環境へのデプロイ

```bash
# stagingで十分テストした後
git checkout main
git merge staging
git push origin main  # <- 自動デプロイ開始
```

## デプロイプロセス

デプロイワークフローは以下のステップを実行します:

### ステージング環境

1. メンテナンスモードON
2. 最新コードをpull
3. Composer依存関係更新
4. マイグレーション実行
5. キャッシュクリア・最適化
6. アセットビルド
7. コンテナ再起動
8. メンテナンスモードOFF

### 本番環境（追加機能）

1. **データベースバックアップ** ← 追加
2. メンテナンスモードON
3. 最新コードをpull
4. Composer依存関係更新
5. マイグレーション実行
6. キャッシュクリア・最適化
7. アセットビルド
8. Queue Worker再起動
9. コンテナ再起動
10. **ヘルスチェック** ← 追加
11. メンテナンスモードOFF
12. **失敗時の自動ロールバック** ← 追加

## トラブルシューティング

### デプロイが実行されない

**原因**: `DEPLOY_ENABLED`変数が設定されていない

**解決策**:
```
Settings > Secrets and variables > Actions > Variables
→ New repository variable
→ Name: DEPLOY_ENABLED, Value: true
```

### SSH接続エラー

**原因**: SSH鍵が正しく設定されていない

**解決策**:
1. SSH秘密鍵の内容を確認（改行を含む完全な内容）
2. サーバーの`~/.ssh/authorized_keys`に公開鍵が登録されているか確認
3. サーバーのSSHポート設定を確認

### マイグレーションエラー

**原因**: データベース接続エラーまたはマイグレーションの互換性問題

**解決策**:
1. サーバーで`.env`ファイルのDB設定を確認
2. マイグレーションファイルを確認
3. 手動でロールバック: `php artisan migrate:rollback`

### デプロイは成功したがアプリケーションが動作しない

**チェックリスト**:
- [ ] `.env`ファイルが正しく設定されているか
- [ ] `APP_KEY`が生成されているか
- [ ] ストレージのパーミッションが正しいか
- [ ] データベースマイグレーションが完了しているか
- [ ] キャッシュがクリアされているか

```bash
# サーバーで確認
docker compose logs -f app
docker compose exec app php artisan config:clear
docker compose exec app php artisan optimize:clear
```

## ベストプラクティス

### 1. ステージング環境で必ずテスト

本番環境へのデプロイ前に、必ずステージング環境でテストしてください。

### 2. 小さなデプロイを頻繁に

大きな変更を一度にデプロイするより、小さな変更を頻繁にデプロイする方が安全です。

### 3. バックアップの確認

本番環境のデプロイ前に、最新のバックアップがあることを確認してください。

### 4. ログの監視

デプロイ後はログを監視して、エラーがないか確認してください。

```bash
# GitHub Actionsのログ
# Actions タブで確認

# サーバーログ
docker compose logs -f app
```

### 5. ロールバック計画

問題が発生した場合のロールバック手順を事前に確認しておいてください。

## 手動デプロイ（緊急時）

自動デプロイが失敗した場合の手動デプロイ手順:

```bash
# サーバーにSSH
ssh deploy@production-server.com

# プロジェクトディレクトリへ移動
cd /var/www/app

# メンテナンスモード
docker compose exec app php artisan down

# 最新のコードを取得
git pull origin main

# 依存関係更新
docker compose exec app composer install --no-dev --optimize-autoloader

# マイグレーション
docker compose exec app php artisan migrate --force

# キャッシュ最適化
docker compose exec app php artisan optimize:clear
docker compose exec app php artisan config:cache
docker compose exec app php artisan route:cache
docker compose exec app php artisan view:cache

# アセットビルド
docker compose exec app npm ci
docker compose exec app npm run build

# コンテナ再起動
docker compose restart

# メンテナンスモードOFF
docker compose exec app php artisan up
```

## Slack通知の設定

### 1. Slack Incoming Webhookの作成

1. Slackワークスペースで[Incoming Webhooks](https://api.slack.com/messaging/webhooks)アプリを追加
2. 通知先チャンネルを選択
3. Webhook URLをコピー

### 2. GitHubシークレットに追加

```
Settings > Secrets and variables > Actions > Secrets
→ New repository secret
→ Name: SLACK_WEBHOOK
→ Value: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

## 参考リンク

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Laravel Deployment](https://laravel.com/docs/deployment)
- [Docker Compose](https://docs.docker.com/compose/)

---

最終更新日: 2025-11-17
