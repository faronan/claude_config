# Project: [プロジェクト名]

TypeScript + React の Web アプリケーション。

## Commands
- `pnpm dev` - 開発サーバー起動
- `pnpm build` - プロダクションビルド
- `pnpm test` - Vitest でテスト実行
- `pnpm lint` - Biome でリント

## Architecture
- `src/components/` - UIコンポーネント
- `src/hooks/` - カスタムフック
- `src/lib/` - ユーティリティ・API
- `src/types/` - 型定義

## Conventions
- コンポーネント: 関数コンポーネント + Hooks
- スタイル: Tailwind CSS / CSS Modules
- 状態管理: React Context または Zustand
