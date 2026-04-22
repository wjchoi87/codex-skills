# codex-skills

Custom Codex skills for long-running execution, workflow orchestration, and resumable handoffs.

These skills were adapted for Codex from durable agent workflow patterns and were informed in part by [code-yeongyu/oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent).

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

## Skills

- `runner`
- `orchestrator`
- `continuity-handoff`

### `runner`

Manages long-running processes as persistent runs instead of disposable shell commands.

Use it for:

- development servers
- long builds
- test suites that take time
- crawlers and batch jobs
- training or data processing runs
- anything that must preserve the original command, session handle, logs, and artifacts

What it emphasizes:

- stable run identity such as `task_id`, `session_id`, `pane_id`, or `pid`
- reconnecting to an existing run before launching a new one
- checking status through session output, process liveness, logs, and artifacts
- not treating quiet stdout as proof of completion

### `orchestrator`

Coordinates complex work as a dependency-aware workflow instead of a loose sequence of edits.

Use it for:

- larger tasks with multiple stages
- work that mixes immediate coding with sidecar research or verification
- tasks with blockers and prerequisites
- background work that should be collected later
- situations where the critical path must stay clear while other workstreams continue

What it emphasizes:

- classifying work before choosing how to run it
- separating critical-path work from sidecar work
- explicit blockers and task dependencies
- background result collection at the right time instead of constant polling
- maintaining an orchestration ledger for multi-step progress

### `continuity-handoff`

Preserves working state so Codex can resume safely after interruptions, summaries, or context compaction.

Use it for:

- long conversations that may be compacted
- tasks that pause and resume later
- work that depends on exact session or task state
- handoffs where "continue from here" is not specific enough
- any workflow where the next step must remain verifiable after a break

What it emphasizes:

- saving exact session, task, command, and artifact references
- distinguishing verified state from remembered state
- reconstructing context from real sources before acting
- preserving the next actionable step and what must be checked first on resume

## How They Fit Together

These skills are designed to work as a small operating layer for Codex:

- use `orchestrator` to structure the overall workflow
- use `runner` when one part of that workflow becomes a persistent process
- use `continuity-handoff` when the workflow or process must survive interruptions and later resume

Typical pattern:

1. Start with `orchestrator` to split the work into stages and blockers.
2. Use `runner` for the server, build, or long-running command that needs durable tracking.
3. Use `continuity-handoff` to preserve exact state before stopping, summarizing, or resuming later.

## Design Goals

These skills aim to make Codex workflows more:

- durable
- restart-safe
- explicit about state
- better suited for long-running or multi-step work
- easier to sync across machines

## Install

Copy or symlink these folders into `~/.codex/skills/`.

Example:

```bash
ln -s ~/src/codex-skills/runner ~/.codex/skills/runner
ln -s ~/src/codex-skills/orchestrator ~/.codex/skills/orchestrator
ln -s ~/src/codex-skills/continuity-handoff ~/.codex/skills/continuity-handoff
```

Or run:

```bash
./install.sh
```

Restart Codex to pick up new skills.
