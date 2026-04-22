---
name: orchestrator
description: Coordinate complex work with category-based delegation, background tasks, persistent task state, and dependency-aware execution. Use when Codex must split work into stages, assign ownership, manage blockers, run parallel workstreams, collect background results, or keep multi-step progress moving across a long session.
---

# Orchestrator

Treat complex work as an orchestration problem, not a sequence of ad hoc replies. The goal is to keep the main thread moving while specialized workstreams run with clear ownership, explicit dependencies, and durable state.

## Orchestration Pattern

This skill is built around explicit orchestration patterns:

- work is classified before execution
- parallel work is launched only when it has a clear role
- background work receives a durable task identity
- dependent work waits on blockers instead of racing ahead
- background results are collected when needed, not polled reflexively
- progress survives beyond a single reply through explicit task state

## Core Rules

- Identify the work type before choosing the execution style.
- Separate critical-path work from sidecar work.
- Prefer explicit dependencies over informal mental tracking.
- Preserve durable task state for multi-step work.
- Keep one owner per workstream.
- Background work should produce a task handle and a clear retrieval path.

## Execution Modes

Use three orchestration modes:

1. `local-sync`
   Use for immediate blocker work where the next step depends on the result now.

2. `background`
   Use for exploration, verification, research, long-running commands, or sidecar implementation that can finish asynchronously.

3. `dependency-gated`
   Use when downstream work must wait for one or more prerequisites to complete.

Do not launch background work if the very next action is blocked on it.

## Classification

Before starting, classify the work:

- `deep`: difficult logic, architecture, deep debugging
- `quick`: small bounded edits or checks
- `writing`: docs, summaries, user-facing prose
- `visual`: UI, styling, front-end design
- `research`: codebase search, investigation, evidence gathering
- `runtime`: commands, servers, builds, tests, crawlers

The exact labels can vary, but the discipline matters: identify what kind of work it is before deciding who or what should do it.

## Orchestration Ledger

Maintain a compact ledger:

- `goal`: target outcome
- `mode`: local-sync, background, or dependency-gated
- `stage`: current phase
- `critical_path`: immediate blocker work
- `tasks`: active work items with owners and status
- `blocked_by`: dependency edges
- `background_ids`: task ids, session ids, pane ids if any
- `artifacts`: files, logs, outputs, reports
- `next_collect`: which background result or blocker to check next

If the work is large enough to outlive the reply, the ledger should be durable and resumable.

## Task Design

A good orchestrated task has:

- one clear subject
- one owner
- an explicit status
- explicit blockers
- an observable output

For multi-step work, prefer task records that can express:

- `pending`
- `in_progress`
- `completed`
- `blocked`
- `cancelled`

If two tasks can run without blockers, they can run in parallel. If one depends on another, record that dependency instead of relying on memory.

## Background Work Rules

When launching background work:

1. capture a durable identifier
2. record the purpose of the task
3. record what result will be needed later
4. continue local critical-path work
5. collect the result when the workflow actually needs it

Do not repeatedly poll background work just because it exists. Check when:

- the user asks
- a notification or checkpoint suggests the state changed
- a dependent task is ready to consume the result

## Result Collection

When a background workstream finishes:

- retrieve the latest verified result
- summarize only the parts needed for integration
- update dependent tasks
- close the loop with the next action immediately

Do not let completed sidecar work sit idle while the main thread drifts.

## Dependency Discipline

Prefer explicit dependency graphs such as:

```text
[frontend fix] ----\
                    -> [integration verification] -> [release decision]
[backend fix]  ----/
```

Use this logic:

- empty blockers: eligible to start now
- blocked tasks: do not start yet
- completed blockers: unlock downstream work

## Continuation Discipline

Plans are not progress. Orchestration is only successful when:

- workstreams were actually launched or executed
- blockers are tracked explicitly
- background results are retrieved when needed
- downstream tasks react to upstream completion

## Relationship To Other Skills

- Use `runner` when a workstream becomes a persistent process or service.
- Use `continuity-handoff` when orchestration state must survive interruptions, compaction, or later resume.

## Minimal Ledger Template

```text
goal:
mode:
stage:
critical_path:
tasks:
blocked_by:
background_ids:
artifacts:
next_collect:
```
