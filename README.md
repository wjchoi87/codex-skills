# codex-skills

Custom Codex skills for long-running execution, workflow orchestration, resumable handoffs, and execution proof.

These skills were adapted for Codex from durable agent workflow patterns and were informed in part by [code-yeongyu/oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent).

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md)

## Skills

- `runner`
- `orchestrator`
- `continuity-handoff`
- `execution-proof`
- `ddukddak`

### `ddukddak`

Builds a reliable execution harness around Codex work instead of treating coding as isolated edits.

Use it for:

- non-trivial coding tasks that need context gathering, implementation, and verification
- requests where soft wording still implies action, such as "look into this" or "what is the best way"
- work that must combine tool discipline, delegation, persistent state, and recovery
- tasks where completion must be proven by tests, builds, diagnostics, artifacts, or documented blockers

What it emphasizes:

- intent classification before execution
- concrete context from files, commands, docs, and artifacts
- routing work into local, background, persistent, delegated, or dependency-gated lanes
- narrow-to-broad verification
- failure recovery by changing strategy rather than guessing

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

### `execution-proof`

Leaves behind file-backed proof that a Codex task really started, stayed alive, progressed through phases, and reached a terminal state.

Use it for:

- tasks where chat output is not enough to build trust
- long workflows that need externally verifiable completion
- execution runs that should leave machine-readable and human-readable proof
- resume-safe work that may require multiple attempts under one logical run

What it emphasizes:

- isolated `run_id` and `attempt_id` tracking
- heartbeat-based proof of continued liveness
- machine proof under `.codex/runs/...`
- human-readable `proof.md` for quick confirmation

## How They Fit Together

These skills are designed to work as a small operating layer for Codex:

- use `ddukddak` as the top-level execution loop for non-trivial engineering work
- use `orchestrator` to structure the overall workflow
- use `runner` when one part of that workflow becomes a persistent process
- use `continuity-handoff` when the workflow or process must survive interruptions and later resume
- use `execution-proof` when you want the run to leave behind visible proof that it truly progressed and completed

Typical pattern:

1. Start with `ddukddak` to classify intent, gather context, choose tools, execute, verify, and recover.
2. Use `orchestrator` when the work splits into stages, blockers, or parallel workstreams.
3. Use `runner` for the server, build, or long-running command that needs durable tracking.
4. Use `continuity-handoff` to preserve exact state before stopping, summarizing, or resuming later.
5. Use `execution-proof` when the task should produce machine-readable proof plus a human-readable proof artifact.

## Design Goals

These skills aim to make Codex workflows more:

- durable
- restart-safe
- explicit about state
- better suited for long-running or multi-step work
- easier to sync across machines
- easier to verify from outside the chat transcript

## Install

Copy or symlink these folders into `~/.codex/skills/`.

Example:

```bash
ln -s ~/src/codex-skills/runner ~/.codex/skills/runner
ln -s ~/src/codex-skills/orchestrator ~/.codex/skills/orchestrator
ln -s ~/src/codex-skills/continuity-handoff ~/.codex/skills/continuity-handoff
ln -s ~/src/codex-skills/execution-proof ~/.codex/skills/execution-proof
ln -s ~/src/codex-skills/ddukddak ~/.codex/skills/ddukddak
```

Or run:

```bash
./install.sh
```

Restart Codex to pick up new skills.

## Plugin Packaging

This repository now also includes a Codex plugin package:

- plugin root: `plugins/codex-skills`
- manifest: `plugins/codex-skills/.codex-plugin/plugin.json`
- local marketplace metadata: `.agents/plugins/marketplace.json`

This is useful for installable distribution of the bundled skills as one unit.

The marketplace metadata in this repository is **repo-scoped metadata for Codex UI ordering and availability**, not proof that the plugin is automatically listed in a global public plugin marketplace.
