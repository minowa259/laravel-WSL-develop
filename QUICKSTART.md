# クイックスタートガイド

このガイドでは、プロジェクトを最短時間でセットアップする方法を説明します。

## 前提条件

- Docker 20.10+
- Docker Compose 2.0+
- Git

## 5分でセットアップ

### 1. リポジトリをクローン

```bash
git clone <your-repository-url>
cd <project-directory>
```

### 2. 環境ファイルをコピー

```bash
cp .env.example .env
```

### 3. Dockerコンテナを起動

```bash
make up
# または
docker compose up -d
```

### 4. 依存関係をインストール

```bash
make install
# または
docker compose exec app composer install
docker compose exec app npm install
```

**重要**: この手順で`package-lock.json`が自動生成されます。

### 5. アプリケーションキーを生成

```bash
docker compose exec app php artisan key:generate
```

### 6. データベースマイグレーション

```bash
make migrate
# または
docker compose exec app php artisan migrate
```

### 7. ブラウザで確認

http://localhost:8000 にアクセス

✅ Laravelのウェルカムページが表示されれば成功です！

## CI/CD用の追加手順（GitHub使用時）

### 1. 開発ツールのインストール（推奨）

コード品質チェック（PHPStan、PHP-CS-Fixer、PHPCS）を有効にするため、開発ツールをインストールします:

```bash
make install-dev-tools
# または
docker compose exec app composer require --dev \
  friendsofphp/php-cs-fixer \
  phpstan/phpstan \
  larastan/larastan \
  squizlabs/php_codesniffer
```

**注意**: このステップをスキップすると、CI/CDで静的解析がスキップされます（警告のみ、エラーにはなりません）。

### 2. package-lock.jsonと開発ツールをコミット

```bash
git add package-lock.json composer.json composer.lock
git commit -m "chore: add package-lock.json and dev tools for CI/CD"
git push
```

これで GitHub Actions のすべての機能が有効になります。

## 開発ツール（オプション）

開発支援ツールも起動する場合:

```bash
make up-dev
# または
docker compose --profile dev up -d
```

以下のツールが利用可能になります:

- **Mailhog**: http://localhost:8025 (メールテスト)
- **phpMyAdmin**: http://localhost:8080 (データベース管理)
- **Redis Commander**: http://localhost:8081 (Redis管理)

## よく使うコマンド

```bash
# コンテナの状態確認
make ps

# ログを表示
make logs

# コンテナに入る
make shell

# テスト実行
make test

# キャッシュクリア
make cache-clear

# コンテナを停止
make down
```

## トラブルシューティング

### ポートが既に使用されている

`.env`ファイルでポートを変更:

```env
APP_PORT=8001  # 8000から変更
```

### パーミッションエラー

```bash
make permissions
# または
docker compose exec -u root app chmod -R 775 storage bootstrap/cache
docker compose exec -u root app chown -R www:www storage bootstrap/cache
```

### データベース接続エラー

1. `.env`ファイルで`DB_HOST=db`になっているか確認
2. コンテナを再起動: `make restart`

## 次のステップ

- 📖 詳細なドキュメント: [README.md](README.md)
- 🚀 デプロイ方法: [.github/DEPLOYMENT.md](.github/DEPLOYMENT.md)
- 🤝 コントリビューション: [CONTRIBUTING.md](CONTRIBUTING.md)
- 🛡️ セキュリティ: [SECURITY.md](SECURITY.md)

## サポート

問題が発生した場合:

1. [README.md](README.md) のトラブルシューティングセクションを確認
2. GitHubの Issues で既存の問題を検索
3. 新しい Issue を作成

---

これで開発を始められます！ 🎉
