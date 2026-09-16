# sessmove

[English](README.md) | [简体中文](README.zh-CN.md) | **[日本語](README.ja.md)** | [Español](README.es.md)

プロジェクトディレクトリの移動と、全 AI コーディングエージェントの
ローカル履歴の移行を**同時に**行います。

```
~/abc  ──リネーム──>  ~/cba
  └─ 各エージェントが記録した /home/me/abc  ──sessmove──>  /home/me/cba
```

## 背景

多くの AI コーディングエージェント（Claude Code、Codex、Gemini CLI 系、
OpenCode、omp、Cursor、Windsurf など）は、セッション履歴を
**プロジェクトパス**をキーとして保存します。ディレクトリ名はパスの
何らかのエンコード（ダッシュ化 / sha256 / md5）で、cwd の値は JSON・
JSONL・SQLite・protobuf ファイルの中にあります。ディレクトリを移動・
リネームすると、古いセッションは「消えた」ようになります——実際には
ディスク上に残っていて、存在しないパスに紐づいているだけです。
`sessmove` はディレクトリの移動と、これら全キーの新パスへの付け替えを
一括で行い、完全な取り消し（undo）に対応します。

## インストール

Rust 実装。実行時依存なし、Linux / macOS / Windows に対応：

```bash
# タグ付き Release ごとに GitHub Actions がビルド成果物を公開します：
#   tar.gz / zip（exe を含む）と .deb / .rpm / .dmg ネイティブパッケージ
#   https://github.com/fly88oj/sessmove/releases

cargo install --path .        # `sessmove` と `agentpath` コマンドが使えます
```

UI 言語はシステムロケールに自動追従します（English / 简体中文 / 日本語 /
한국어 / Español / Français / Deutsch / Português）。`--lang` または
`SESSMOVE_LANG` で上書きできます。

## 使い方

```bash
# mv の代わりに使う —— ディレクトリ移動 + 全エージェント履歴の移行
sessmove ~/works/abc ~/works/cba          # agentpath mv ... と同等
sessmove ~/works/abc ~/works/archived/    # dst が既存ディレクトリなら移入
sessmove --dry-run ~/works/abc ~/works/cba

# どのエージェントがこのパスを記録しているか確認
agentpath scan --from ~/works/abc

# 移行のみ（ディレクトリは移動済み）
agentpath migrate --from ~/works/abc --to ~/works/cba --yes

# 全部取り消す
agentpath backups
agentpath undo --id 20260903-131427-644777
```

問題が起きても `agentpath undo` 1 回でディレクトリ位置と全エージェント
状態を復元します。ディレクトリのみ受け付けます。移動先が既に存在・
親ディレクトリが無い・ src == dst は拒否します。

| オプション | 意味 |
|---|---|
| `--agents claude,codex` | 対象エージェントを限定（デフォルト：全て） |
| `--extra-root PATH` | 任意のツリーも書き換え。繰り返し可 |
| `--deep` | チャット本文内の旧パスも書き換え（デフォルトは身分フィールドのみ） |
| `--backup-dir DIR` | バックアップディレクトリ（デフォルト `~/.sessmove/backups`） |
| `--dry-run` | レポートのみ |
| `--json` | stdout に単一の JSON ドキュメントを出力 |

## 安全性

- **境界を考慮した置換**：`/a/abc` は `/a/abc2` や `/a/abc-def` には
  一致しません。`file://` URI、JSON エスケープ、サブパスも正しく扱います。
- **派生トークンも置換**：sha256 / sha256[:16] / md5 / 各ベンダーの
  ダッシュエンコードディレクトリ名。
- 移行のたびに完全バックアップ（`wal_checkpoint` 後に SQLite を丸ごと
  コピー、リネーム記録、`undo` が全て復元）。
- 移動先が存在する場合はスキップ。`--from /` は拒否。

## 対応エージェント

18 エージェント（Claude Code / Codex / Gemini / Qwen / iFlow /
OpenCode / omp / ZCode / Cursor / Windsurf / Antigravity / Crush /
Factory Droid / Continue / pi / Zed / Aider / cc-connect）に対応。
詳細な一覧表は [English 版 README](README.md#supported-agents) を
参照してください。

非対応（調査済み）：GitHub Copilot CLI、Amp、claude-code-router。

## コントリビューション

```bash
git clone https://github.com/fly88oj/sessmove && cd sessmove
cargo test --all                          # 32 件のテストが全て通ること
cargo clippy --all-targets -- -D warnings # 警告ゼロ
cargo fmt --all -- --check
pre-commit install                        # ローカルフック（CI と同一）
```

詳細は [CONTRIBUTING.md](CONTRIBUTING.md)、[CHANGELOG.md](CHANGELOG.md)、
[SECURITY.md](SECURITY.md)、[docs/research.md](docs/research.md) を参照。

## ライセンス

Copyright (C) 2026 sessmove contributors.

このプログラムはフリーソフトウェアです。あなたはこれを、フリーソフトウェア
財団が発行する GNU 一般公衆利用許諾書（バージョン 3 か、希望によっては
それ以降のバージョン）の定めの下で再頒布または改変することができます。
詳細は [LICENSE](LICENSE) を参照してください。
