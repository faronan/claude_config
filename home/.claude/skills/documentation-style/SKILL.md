---
name: documentation-style
description: |
  コードドキュメントのスタイル規約。
  「ドキュメント生成」「docstring」「JSDoc」「コメント追加」と言われたら使用。
---

# Documentation Style Rules

## 言語別フォーマット

### TypeScript / JavaScript (JSDoc/TSDoc)

```typescript
/**
 * ユーザーを認証し、セッショントークンを返す
 *
 * @param email - ユーザーのメールアドレス
 * @param password - ユーザーのパスワード
 * @returns セッショントークン。認証失敗時はnull
 * @throws {AuthenticationError} 認証情報が無効な場合
 *
 * @example
 * const token = await authenticate("user@example.com", "password123");
 * if (token) {
 *   console.log("認証成功");
 * }
 */
```

### Python (Google Style Docstring)

```python
def authenticate(email: str, password: str) -> Optional[str]:
    """ユーザーを認証し、セッショントークンを返す。

    Args:
        email: ユーザーのメールアドレス
        password: ユーザーのパスワード

    Returns:
        セッショントークン。認証失敗時はNone。

    Raises:
        AuthenticationError: 認証情報が無効な場合

    Example:
        >>> token = authenticate("user@example.com", "password123")
        >>> if token:
        ...     print("認証成功")
    """
```

### Rust (rustdoc)

```rust
/// ユーザーを認証し、セッショントークンを返す
///
/// # Arguments
///
/// * `email` - ユーザーのメールアドレス
/// * `password` - ユーザーのパスワード
///
/// # Returns
///
/// 認証成功時は `Ok(String)` でトークンを返す。
/// 失敗時は `Err(AuthError)` を返す。
///
/// # Examples
///
/// ```
/// let token = authenticate("user@example.com", "password123")?;
/// println!("Token: {}", token);
/// ```
```

## 共通ガイドライン

### 必須項目
1. **概要**: 関数/クラスの目的を1行で
2. **引数**: 各パラメータの説明
3. **戻り値**: 返却値の説明
4. **例外/エラー**: 発生しうるエラー

### 推奨項目
- **使用例**: 典型的な使い方
- **注意事項**: 使用上の注意点
- **関連項目**: 関連する関数/クラスへの参照

### スタイル原則
- 簡潔かつ明確に
- 実装詳細より「何をするか」を優先
- 非自明な動作は必ず説明
- 型情報が明確なら重複説明は避ける
