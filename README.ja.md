# codex-skills

長時間実行、ワークフローのオーケストレーション、再開可能なハンドオフのための Codex カスタムスキル集です。

これらのスキルは、永続的なエージェントワークフローのパターンを Codex 向けに調整したものであり、一部は [code-yeongyu/oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) を参考にしています。

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

## スキル一覧

- `runner`
- `orchestrator`
- `continuity-handoff`

### `runner`

使い捨てのシェルコマンドとしてではなく、長時間実行されるプロセスを永続的な実行単位として管理するスキルです。

次のような場面に向いています。

- 開発サーバーの起動
- 時間のかかるビルド
- 長時間のテストスイート
- クローラーやバッチ処理
- 学習ジョブやデータ処理
- 元のコマンド、セッションハンドル、ログ、成果物を失ってはいけないあらゆる作業

特に重視する点:

- `task_id`、`session_id`、`pane_id`、`pid` など安定した実行識別子の維持
- 新しく起動する前に既存の実行へ再接続すること
- セッション出力、プロセスの生存確認、ログ、成果物から状態を確認すること
- stdout が静かになっただけで完了とみなさないこと

### `orchestrator`

複雑な作業を、ばらばらな編集の連続ではなく、依存関係と段階を持つワークフローとして扱うスキルです。

次のような場面に向いています。

- 複数の段階に分かれる大きな作業
- すぐに行う実装と、並行する調査や検証が混ざる作業
- blocker や prerequisite がある作業
- 後で結果を回収する background 作業
- クリティカルパスを止めずに他の作業も並行して進めたい場面

特に重視する点:

- 実行方法を決める前に作業の性質を分類すること
- critical path と sidecar work を分離すること
- blocker と task dependency を明示すること
- 必要なタイミングで background 結果を回収すること
- 複数段階の進行を追うための orchestration ledger を維持すること

### `continuity-handoff`

中断、要約、コンテキスト圧縮の後でも Codex が安全に作業を再開できるよう、状態を保存するスキルです。

次のような場面に向いています。

- 途中で compact される可能性のある長い会話
- いったん止めて後で再開する作業
- 正確な session 状態や task 状態が重要な作業
- 「ここから続けて」だけでは不十分なハンドオフ
- 休止後でも次のステップを検証可能な形で残したいワークフロー

特に重視する点:

- 正確な session、task、command、artifact の参照を保存すること
- 記憶に頼った状態と検証済みの状態を区別すること
- 行動する前に実際の情報源からコンテキストを復元すること
- 次のアクションと、再開時に最初に確認すべき項目を残すこと

## 組み合わせ方

これらのスキルは、Codex の上に薄い運用レイヤーを作るように設計されています。

- 全体のワークフローを構造化するには `orchestrator`
- その中の一部が長時間実行プロセスになる場合は `runner`
- そのワークフローやプロセスを後で再開する必要がある場合は `continuity-handoff`

一般的な流れ:

1. `orchestrator` で作業を段階と blocker に分けます。
2. サーバー、ビルド、長時間実行コマンドは `runner` で追跡します。
3. 停止、要約、後日の再開が必要なときは `continuity-handoff` で正確な状態を残します。

## 設計目標

これらのスキルは、Codex のワークフローを次のように改善することを目指しています。

- 長時間の作業に強い
- 再起動や再開に強い
- 状態を明示的に扱える
- 長時間実行や多段階の作業に適している
- 複数マシン間で同期しやすい

## インストール

各フォルダを `~/.codex/skills/` 配下へコピーするか、シンボリックリンクで接続してください。

例:

```bash
ln -s ~/src/codex-skills/runner ~/.codex/skills/runner
ln -s ~/src/codex-skills/orchestrator ~/.codex/skills/orchestrator
ln -s ~/src/codex-skills/continuity-handoff ~/.codex/skills/continuity-handoff
```

または:

```bash
./install.sh
```

新しいスキルを認識するには Codex を再起動してください。
