# セキュリティポリシー

## サポートされているバージョン

現在、以下のバージョンでセキュリティアップデートを提供しています。

| バージョン | サポート状況 |
| ------- | ----------- |
| 最新版   | ✅ サポート中 |
| 旧バージョン | ❌ サポート終了 |

## 脆弱性の報告

セキュリティ上の脆弱性を発見した場合は、以下の方法で報告してください。

### 報告方法

**公開せずに報告してください。** セキュリティ上の問題を公開のIssueやPull Requestで報告しないでください。

以下のいずれかの方法で報告してください:

1. **GitHub Security Advisories** (推奨)
   - リポジトリの「Security」タブから「Report a vulnerability」を選択
   - 詳細を入力して送信

2. **メール**
   - security@example.com にメールを送信
   - 件名に「[SECURITY] 」を含める
   - 問題の詳細、再現手順、影響範囲を記載

### 報告内容に含めるべき情報

- 脆弱性の種類（例: SQL Injection, XSS, CSRF など）
- 影響を受けるファイルやコード
- 脆弱性の再現手順
- 想定される影響や悪用シナリオ
- 可能であれば修正案

### 対応プロセス

1. **24時間以内**: 報告の受領を確認
2. **7日以内**: 初期評価と重要度の判定
3. **30日以内**: 修正の実施とリリース（重要度により変動）
4. **リリース後**: 脆弱性の公開（報告者と協議の上）

### 報奨金制度

現在、脆弱性報奨金制度は実施していません。しかし、貴重な報告に対しては、リポジトリのCONTRIBUTORS.mdにて謝辞を記載させていただきます。

## セキュリティベストプラクティス

このプロジェクトを安全に運用するために、以下のベストプラクティスを推奨します。

### 環境変数の管理

```bash
# .envファイルに機密情報を保存
# NEVER commit .env to git
APP_KEY=base64:...  # 本番環境では必ず変更
DB_PASSWORD=強力なパスワード
```

### 依存パッケージの更新

```bash
# 定期的に依存パッケージを更新
composer update
npm update

# セキュリティ監査
composer audit
npm audit
```

### Dockerセキュリティ

```bash
# 最新のベースイメージを使用
docker pull php:8.3-fpm
docker pull nginx:alpine
docker pull mysql:8.0

# 不要なコンテナやイメージを削除
docker system prune -a
```

### 本番環境での設定

**.env.production**
```env
APP_DEBUG=false
APP_ENV=production
SESSION_SECURE_COOKIE=true
SESSION_ENCRYPT=true
```

**Nginx設定**
- HTTPSを必須化
- セキュリティヘッダーの設定
- レート制限の実装

**PHP設定**
- `expose_php=Off`
- `allow_url_fopen=Off`
- 不要な関数の無効化

### アクセス制御

```bash
# ファイルパーミッション
chmod 755 storage/
chmod 644 .env

# 特定のディレクトリへのアクセス制限
location ~ /\.git {
    deny all;
}
```

## 既知の脆弱性

現在、既知の脆弱性はありません。

過去の脆弱性については、[GitHub Security Advisories](../../security/advisories)をご確認ください。

## セキュリティチェックリスト

本番環境にデプロイする前に、以下の項目を確認してください:

### アプリケーションレベル

- [ ] `APP_DEBUG=false` が設定されている
- [ ] 強固な`APP_KEY`が生成されている
- [ ] すべての依存パッケージが最新版
- [ ] セキュリティ脆弱性スキャンを実施（`composer audit`, `npm audit`）
- [ ] CSRF保護が有効
- [ ] XSS対策が実装されている（Bladeテンプレートの`{{ }}`使用）
- [ ] SQL Injection対策（Eloquent ORM、パラメータバインディング使用）
- [ ] 認証・認可が適切に実装されている
- [ ] ユーザー入力の検証とサニタイズ

### インフラストラクチャレベル

- [ ] HTTPS/TLS が有効（Let's Encrypt等）
- [ ] 適切なファイアウォール設定
- [ ] 不要なポートを閉じている
- [ ] データベースが外部から直接アクセスできない
- [ ] Redisが外部から直接アクセスできない
- [ ] セキュリティヘッダーが設定されている
- [ ] レート制限が実装されている
- [ ] ログ監視が設定されている

### Docker/コンテナレベル

- [ ] 最新の安定版ベースイメージを使用
- [ ] rootユーザーでコンテナを実行していない
- [ ] 機密情報がイメージに含まれていない
- [ ] ボリュームのパーミッションが適切
- [ ] 本番環境ではボリュームが読み取り専用（`:ro`）

### データベースレベル

- [ ] 強固なデータベースパスワード
- [ ] rootアカウントを使用していない
- [ ] 定期的なバックアップが設定されている
- [ ] バックアップの暗号化
- [ ] アクセスログの記録

### 監視とログ

- [ ] エラーログが適切に記録されている
- [ ] セキュリティイベントのログ監視
- [ ] 異常なアクセスパターンの検出
- [ ] ログのローテーション設定

## セキュリティアップデート

セキュリティアップデートは以下の方法で通知されます:

- GitHub Security Advisories
- リリースノート
- メーリングリスト（購読者のみ）

重要なセキュリティアップデートは、直ちに適用することを強く推奨します。

## 参考リンク

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Laravel Security Best Practices](https://laravel.com/docs/security)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [PHP Security Guide](https://www.php.net/manual/ja/security.php)

## 連絡先

セキュリティに関する質問や懸念がある場合は、以下にお問い合わせください:

- Email: security@example.com
- GitHub Security: [Security Advisories](../../security/advisories)

---

最終更新日: 2025-11-17
