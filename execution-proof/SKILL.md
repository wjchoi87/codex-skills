---
name: execution-proof
description: Record file-backed proof that a Codex task really started, stayed alive, progressed through phases, and reached a terminal state. Use when Codex should minimize chat noise during execution, keep isolated run state, support resume-safe attempts, and leave behind a human-readable proof artifact plus an optional final proof link.
---

# Execution Proof

Use this skill when the user wants external proof that work really ran through to completion without relying on verbose chat output. The goal is to make execution trust visible through filesystem state first, with a human-readable proof file at the end.

## Core Model

This skill uses a two-layer proof system:

- machine proof
  Stored under `.codex/runs/<run_id>/attempts/<attempt_id>/`
- human proof
  Stored at `.codex/runs/<run_id>/attempts/<attempt_id>/artifacts/proof.md`

Machine proof is the source of truth. Human proof is the quick visual confirmation.

## Identity Rules

Use two identifiers:

- `run_id`
  Stable logical task identifier
- `attempt_id`
  Concrete execution or resume attempt identifier

Rules:

- one logical task keeps the same `run_id`
- every new execution attempt gets a new `attempt_id`
- resuming a stopped run must reuse `run_id` and allocate a fresh `attempt_id`
- never rely on a single mutable `current_run` pointer for all work

Recommended formats:

- `run_id`: `YYYYMMDD_HHMMSS_<rand4>`
- `attempt_id`: `001`, `002`, `003`

## Directory Protocol

Target structure:

```text
.codex/
  active_runs/
    <run_id>
  runs/
    <run_id>/
      run.json
      attempts/
        001/
          lock
          state.json
          phases/
          actions/
          heartbeat/
          artifacts/
```

Use `.codex/active_runs/<run_id>` as an active marker or pointer. Do not use a single global `current_run` file when parallel runs are possible.

## Required Files

For each run:

- `.codex/runs/<run_id>/run.json`

For each attempt:

- `.codex/runs/<run_id>/attempts/<attempt_id>/lock`
- `.codex/runs/<run_id>/attempts/<attempt_id>/state.json`
- phase event files as JSON
- action event files as JSON
- heartbeat tick files
- `.codex/runs/<run_id>/attempts/<attempt_id>/artifacts/proof.md`

Do not use empty `.done` or `.started` files as the primary proof format. Use JSON event files instead.

## Run Metadata

`run.json` is required and should include:

- `run_id`
- `task`
- `created_at`
- `latest_attempt`
- `status`

Example:

```json
{
  "run_id": "20260423_021530_ab12",
  "task": "repo analyze and fix",
  "created_at": "2026-04-23T02:15:30.123Z",
  "latest_attempt": "001",
  "status": "running"
}
```

`state.json` is required for each attempt and should include:

- `run_id`
- `attempt_id`
- `status`
- `current_phase`
- `started_at`
- `updated_at`
- `next_expected_event`
- `resume_of_attempt`

Example:

```json
{
  "run_id": "20260423_021530_ab12",
  "attempt_id": "001",
  "status": "running",
  "current_phase": "implement",
  "started_at": "2026-04-23T02:15:30.123Z",
  "updated_at": "2026-04-23T02:18:02.001Z",
  "next_expected_event": "030_implement.completed",
  "resume_of_attempt": null
}
```

## Canonical Phases

Use these whole-task phases:

- `analyze`
- `plan`
- `implement`
- `verify`
- `handoff`

Use monotonic numbered filenames:

```text
phases/
  010_analyze.started.json
  010_analyze.completed.json
  020_plan.started.json
  020_plan.completed.json
```

Each phase event should record:

- `phase`
- `event`
- `at`
- `run_id`
- `attempt_id`

Example:

```json
{
  "phase": "implement",
  "event": "completed",
  "at": "2026-04-23T02:20:15.100Z",
  "run_id": "20260423_021530_ab12",
  "attempt_id": "001"
}
```

## Action Rules

Actions are fine-grained proof of concrete work. Store them as numbered JSON files:

```text
actions/
  001_repo_scan.json
  002_plan_created.json
  003_auth_fix.json
```

Each action should include:

- `seq`
- `action`
- `phase`
- `at`

Example:

```json
{
  "seq": 1,
  "action": "repo_scan",
  "phase": "analyze",
  "at": "2026-04-23T02:16:11.221Z"
}
```

Rules:

- action numbers must be strictly increasing
- names should be short and machine-readable
- every action write should refresh `state.json.updated_at`

## Heartbeat Rules

Heartbeat is the primary proof that execution stayed alive over time.

Store heartbeat evidence under:

```text
heartbeat/
  2026-04-23T02-15-30.123Z.tick
  2026-04-23T02-16-00.102Z.tick
```

Defaults:

- heartbeat interval: 30 seconds
- stale timeout: about 75 seconds

Rules:

- a running attempt must keep producing heartbeat evidence
- every heartbeat should also refresh `state.json.updated_at`
- `lock` alone is not enough to prove active execution
- stale heartbeat plus `status=running` means the attempt should be treated as `stalled`

## Terminal Status Rules

Use these statuses:

- `running`
- `completed`
- `failed`
- `stalled`
- `abandoned`

Terminal behavior:

- `completed`
  Final phase finished, `proof.md` written, `lock` removed
- `failed`
  Failure recorded, terminal metadata written, `lock` removed
- `stalled`
  Inferred from stale heartbeat while still marked running
- `abandoned`
  Older attempt replaced by a newer attempt for the same run

`running` is only trustworthy when the lock exists and heartbeat remains fresh.

## Human-Readable Proof

Every terminal attempt must write:

```text
artifacts/proof.md
```

`proof.md` should include:

- final status
- run id
- attempt id
- task label
- start time
- end time
- duration
- completed phases in order
- summarized actions
- heartbeat health summary
- artifact list
- failure point if applicable

This file is what a human should open first when they want to trust that the task really ran through.

## Verification Rules

A run is trustworthy completed only if the latest attempt has:

- `status=completed`
- no `lock`
- all required phase completion events
- monotonic action numbering
- fresh heartbeat up to terminal completion
- a `proof.md` that matches machine state

A run is stalled if:

- the latest attempt still has `lock`
- `status=running`
- heartbeat is older than the stale timeout

A run is incomplete if:

- a phase start exists without matching completion
- action sequence stops before terminal state
- the machine state and `proof.md` disagree

## Output Policy

Keep chat noise low during execution:

- no verbose progress chatter by default
- do not dump the full proof into chat
- a final one-line proof pointer is allowed

Good final output shape:

- terminal status
- run id
- link to `proof.md`

## Integration Guidance

Use this skill together with the existing skills:

- `orchestrator`
  controls high-level phase flow
- `runner`
  records runtime actions and liveness evidence
- `continuity-handoff`
  preserves `run_id` and creates a new `attempt_id` on resume

Treat these as coordination rules, not hard code dependencies.
