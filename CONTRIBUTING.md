# コントリビューションガイド

このプロジェクトへの貢献に興味を持っていただき、ありがとうございます。このガイドラインに従って、効率的に開発を進めましょう。

## 目次

- [開発環境のセットアップ](#開発環境のセットアップ)
- [ブランチ戦略](#ブランチ戦略)
- [コミットメッセージ規約](#コミットメッセージ規約)
- [コーディング規約](#コーディング規約)
- [テスト](#テスト)
- [プルリクエスト](#プルリクエスト)

## 開発環境のセットアップ

### 必要な環境

- Docker 20.10+
- Docker Compose 2.0+
- Git

### 初回セットアップ

```bash
# リポジトリをクローン
git clone <repository-url>
cd <project-directory>

# 環境ファイルをコピー
cp .env.example .env

# Dockerコンテナを起動
make up

# 依存関係のインストール（package-lock.jsonも自動生成されます）
make install

# package-lock.jsonをコミット（初回のみ、CI/CD用に必須）
git add package-lock.json
git commit -m "chore: add package-lock.json"

# マイグレーション実行
make migrate

# 開発ツールも起動する場合
make up-dev
```

**重要**: `make install`を実行すると、package-lock.jsonが自動生成されます。これはCI/CDで必要なため、必ずgitにコミットしてください。

### 開発ツールへのアクセス

環境を`make up-dev`で起動した場合、以下のツールにアクセスできます:

- **Mailhog**: http://localhost:8025 (メールテスト)
- **phpMyAdmin**: http://localhost:8080 (DB管理)
- **Redis Commander**: http://localhost:8081 (Redis管理)

## ブランチ戦略

このプロジェクトでは**Git Flow**を採用しています。

### ブランチの種類

- `main`: 本番環境用（常に安定版）
- `staging`: ステージング環境用（本番前の最終確認）
- `develop`: 開発環境用（開発の中心ブランチ）
- `feature/*`: 新機能開発用
- `bugfix/*`: バグ修正用
- `hotfix/*`: 緊急修正用

### ブランチの作成と運用

```bash
# 新機能を開発する場合
git checkout develop
git pull origin develop
git checkout -b feature/新機能名

# バグを修正する場合
git checkout develop
git pull origin develop
git checkout -b bugfix/バグ修正名

# 緊急修正の場合（本番環境）
git checkout main
git pull origin main
git checkout -b hotfix/緊急修正名
```

## コミットメッセージ規約

### フォーマット

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type（必須）

- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響しない変更（空白、フォーマット、セミコロンなど）
- `refactor`: バグ修正や機能追加ではないコードの変更
- `perf`: パフォーマンス改善
- `test`: テストの追加や修正
- `chore`: ビルドプロセスやツールの変更

### 例

```bash
# 良い例
feat(auth): ユーザー登録機能を追加

Google OAuth認証を使用したユーザー登録機能を実装。
- OAuth2.0でGoogleアカウントと連携
- ユーザープロフィールの自動作成
- セッション管理の実装

Closes #123

# 悪い例
update files
```

## コーディング規約

### PHP

このプロジェクトでは**PSR-12**コーディング規約に準拠しています。

```bash
# コードスタイルチェック
make phpcs

# コードスタイル自動修正
make php-cs-fixer

# 静的解析
make phpstan
```

#### 主なルール

- インデント: スペース4つ
- 行の長さ: 120文字以内を推奨
- クラス名: PascalCase
- メソッド名: camelCase
- 定数: UPPER_SNAKE_CASE

### JavaScript/Vue.js

- ESLint + Prettier を使用
- インデント: スペース2つ
- セミコロン: なし

```bash
# Lintチェック
npm run lint

# Lint自動修正
npm run lint:fix
```

### データベース

#### マイグレーションファイル

- ファイル名: `YYYY_MM_DD_HHMMSS_create_テーブル名_table.php`
- テーブル名: 複数形、スネークケース
- カラム名: スネークケース

#### モデル

- クラス名: 単数形、PascalCase
- プロパティ: キャメルケース

```php
// 良い例
class UserProfile extends Model
{
    protected $fillable = ['firstName', 'lastName'];
}

// 悪い例
class user_profile extends Model
{
    protected $fillable = ['first_name', 'last_name'];
}
```

## テスト

### テストの実行

```bash
# 全テスト実行
make test

# カバレッジ付き実行
make test-coverage

# 特定のテストのみ実行
docker compose exec app php artisan test --filter=UserTest
```

### テストの作成

```bash
# Feature Test
php artisan make:test UserRegistrationTest

# Unit Test
php artisan make:test Models/UserTest --unit
```

### テストの書き方

```php
public function test_ユーザーが正常に登録できること(): void
{
    // Given: 前提条件
    $userData = [
        'name' => 'Test User',
        'email' => 'test@example.com',
        'password' => 'password123',
    ];

    // When: 実行
    $response = $this->post('/register', $userData);

    // Then: 検証
    $response->assertStatus(201);
    $this->assertDatabaseHas('users', [
        'email' => 'test@example.com',
    ]);
}
```

### カバレッジ基準

- 新規コード: 最低80%のカバレッジを目指す
- クリティカルなロジック: 100%のカバレッジ

## プルリクエスト

### プルリクエストを作成する前に

1. **最新のdevelopブランチと同期**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout feature/your-feature
   git rebase develop
   ```

2. **テストがすべて通ることを確認**
   ```bash
   make test
   ```

3. **コードスタイルチェック**
   ```bash
   make phpcs
   make phpstan
   ```

4. **コミットメッセージを整理**
   ```bash
   git rebase -i develop
   ```

### プルリクエストのテンプレート

```markdown
## 概要
この変更の目的や背景を簡潔に説明してください。

## 変更内容
- 追加した機能や修正した内容をリスト化

## 関連Issue
Closes #123

## テスト内容
どのようなテストを行ったかを記載

## スクリーンショット（該当する場合）
UIの変更がある場合は、変更前後のスクリーンショットを添付

## チェックリスト
- [ ] テストを追加/更新した
- [ ] ドキュメントを更新した
- [ ] コーディング規約に従っている
- [ ] すべてのテストが通過した
- [ ] レビュー可能な単位に分割されている
```

### レビュープロセス

1. プルリクエストを作成
2. 自動CI/CDチェックが実行される
3. 最低1人のレビュアーによる承認が必要
4. すべてのコメントに対応
5. マージ

### マージ後

```bash
# ローカルブランチの削除
git branch -d feature/your-feature

# リモートブランチの削除
git push origin --delete feature/your-feature

# developブランチを更新
git checkout develop
git pull origin develop
```

## よくある質問

### Q: ローカル環境でのデバッグ方法は？

A: Xdebugを有効化してください:

```bash
# .envファイルで設定
INSTALL_XDEBUG=true

# コンテナを再ビルド
make rebuild
```

### Q: マイグレーションエラーが発生した場合は？

A: 以下を試してください:

```bash
# キャッシュクリア
make cache-clear

# マイグレーションをリセット
make migrate-fresh

# それでも解決しない場合はDBを再構築
make clean-docker
make up
make install
```

### Q: パーミッションエラーが発生する場合は？

A: 以下のコマンドで修正してください:

```bash
make permissions
```

## サポート

問題が発生した場合や質問がある場合は、以下の方法でサポートを受けることができます:

- **Issue作成**: GitHubでIssueを作成してください
- **Discussion**: GitHubのDiscussionで質問してください
- **Slack**: チームのSlackチャンネル #dev-support

## ライセンス

このプロジェクトに貢献することで、あなたのコントリビューションがプロジェクトと同じライセンス（MIT）の下でライセンスされることに同意したものとみなされます。
