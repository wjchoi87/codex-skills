---
name: runner
description: Manage persistent execution for background tasks and tmux-backed sessions. Use when Codex must launch, reconnect to, monitor, resume, report on, or safely stop long-running commands, servers, scripts, builds, crawlers, training jobs, or other work that outlives a single response without losing task ids, session ids, pane handles, logs, or artifacts.
---

# Runner

Treat long-running work as a managed runtime, not a disposable shell command. Preserve the original execution identity and keep monitoring the same run until it reaches a verified terminal state.

## Persistence Pattern

This skill is built around durable execution patterns:

- background work is launched once, then tracked by durable identifiers
- each run keeps both a task-level identity and a session-level identity
- output can be watched live through tmux panes when available
- completion is determined by explicit state checks, not by a quiet terminal alone
- resumed work reconnects to the same session instead of creating a replacement

## Core Rules

- Prefer one durable run with stable identifiers over repeated fresh commands.
- Record the original launch context immediately.
- Preserve both control-plane handles and data-plane evidence.
- Reattach before relaunching.
- Never infer completion from silence alone.
- Do not poll aggressively without a reason. Check when there is a notification, a timed checkpoint, or a clear need for status.
- Only declare completion after a verified terminal state such as `completed`, `failed`, `cancelled`, `interrupt`, or a confirmed process exit.

## Runtime Ledger

Maintain a compact ledger for every persistent run:

- `cwd`: working directory
- `command`: exact launch command and arguments
- `env`: important environment variables and runtime config
- `task_id`: durable task identifier if one exists
- `session_id`: durable session identifier if one exists
- `pane_id`: tmux pane or window handle if one exists
- `pid`: process id or stable `pgrep` pattern
- `status`: `pending`, `running`, `completed`, `failed`, `cancelled`, `interrupt`, or `unknown`
- `stdout`: primary live output source
- `logs`: durable log file paths
- `artifacts`: output directories, checkpoints, reports, build outputs
- `stage`: current phase and next expected milestone
- `next_check`: what to poll next and why

If the system exposes both `task_id` and `session_id`, keep both. They solve different problems: task state versus session continuity.

## Launch Rules

When starting long-running work:

1. Launch it once in a durable execution context.
2. Capture the exact command immediately.
3. Capture the stable identity immediately:
   - `task_id` if the runtime has a task abstraction
   - `session_id` if the runtime has a resumable session
   - `pane_id` if output is visible in tmux
   - `pid` or a stable process pattern if it is a raw process
4. Record where live output and durable logs can be read later.
5. Record expected artifacts even if they do not exist yet.

Prefer durable contexts such as:

- tmux sessions, windows, or panes
- managed background task handles
- named services or containers
- PTY sessions with a reusable session id

## Monitoring Model

Monitor in this order:

1. Original session or pane output
2. Explicit runtime status attached to the task or session
3. Process liveness
4. Durable logs
5. Artifact growth, mtimes, checkpoints, reports

Use the highest-fidelity source available. A quiet pane is weaker evidence than an explicit runtime status.

## Polling Rules

Follow a disciplined polling model:

- Immediately after launch, record ids first before doing anything else.
- If the runtime says completion notifications will arrive later, do not hammer status checks right away without reason.
- Poll when:
  - the user asks for an update
  - a timer or checkpoint says it is time
  - a notification suggests the task changed state
  - you need the result now to continue
- When blocking on status, use bounded waits and return the latest verified state if the task is still active.
- If the task remains active after a wait window, report that it is still running rather than guessing.

## Tmux Behavior

If tmux is available and the job is being watched interactively:

- preserve the tmux session name and pane id
- reconnect to that pane before starting anything new
- read the pane output first when checking progress
- treat pane visibility as observability, not as the only source of truth
- if a pane disappears, confirm whether the underlying process or session is also gone before deciding the run is dead

If you use isolated tmux sessions, prefer stable names and keep enough detail to reattach later.

## Resume Rules

When resuming an existing run:

1. Read the saved ledger.
2. Reconnect to the original session, pane, or stdout source.
3. Verify current runtime status.
4. Verify process liveness if applicable.
5. Check logs and artifacts if live output is quiet.
6. Continue monitoring the same run.

Do not silently replace the run with a new command just because prior context was summarized, the output is quiet, or the pane is no longer visible.

## Completion Rules

A run is complete only when one of these is verified:

- the runtime marks it `completed`
- the runtime marks it `failed`, `cancelled`, or `interrupt`
- the original process has exited and final logs or artifacts confirm the end state

On completion, capture:

- final status or exit code
- final stdout or pane highlights
- final log highlights
- produced artifacts
- warnings, failures, or incomplete cleanup

## Failure And Cleanup

If a run appears broken:

- check whether the session still exists
- check whether the process is alive
- check whether logs are still moving
- check whether artifacts are still changing

Only after those checks should you mark it failed or stale.

If using durable sessions such as tmux, clean up stale sessions only after confirming the owning process is really gone.

## Relationship To Other Skills

- Use `orchestrator` when this run is one part of a larger multi-step workflow.
- Use `continuity-handoff` when the run must survive summaries, interruptions, or later resumption.

## Minimal Ledger Template

```text
cwd:
command:
env:
task_id:
session_id:
pane_id:
pid:
status:
stdout:
logs:
artifacts:
stage:
next_check:
```
