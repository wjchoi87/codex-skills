---
name: continuity-handoff
description: Preserve and recover working state across compaction, recovery, and resume flows. Use when Codex must hand off or resume ongoing work without losing session context, task state, commands, agent/model identity, logs, artifacts, or next actions.
---

# Continuity Handoff

Treat continuity as a first-class runtime concern. A handoff is successful only if resumed work can reconnect to the same state without guessing, replaying blindly, or starting over unnecessarily.

## Continuity Pattern

This skill is built around durable continuity patterns:

- sessions can be resumed instead of recreated
- compaction should preserve critical working context
- recovery logic distinguishes real state from broken transient state
- task continuity survives beyond a single response
- the nearest trustworthy non-compaction context is preferred over noisy or partial memory

## Core Rules

- Preserve enough state before any summary, pause, interruption, or compaction.
- On resume, reconnect to real state before taking action.
- Prefer durable identifiers and artifacts over remembered prose.
- Distinguish session continuity from task continuity.
- Never restart work just because context became shorter.

## Continuity Record

Maintain a compact record with:

- `goal`: intended outcome
- `status`: running, blocked, completed, failed, interrupted, unknown
- `cwd`: active working directory
- `session_id`: current or last known session id
- `task_ids`: active task identifiers
- `agent_context`: relevant agent, model, tool, or execution mode identity if applicable
- `files`: changed files or files under investigation
- `commands`: exact commands already run or queued
- `logs`: log paths and stdout sources
- `artifacts`: build outputs, screenshots, reports, checkpoints
- `last_good_state`: most recent verified state before interruption or compaction
- `risks`: unresolved assumptions or failure modes
- `next_step`: exact next action
- `verify_first`: first thing to re-check on resume

## What Must Survive Compaction

Before work is summarized or compressed, preserve:

- exact session and task handles
- current stage of the workflow
- active blockers
- most recent trustworthy agent and model context if that matters
- tools or permissions already in use if they affect continuation
- commands already launched
- logs and artifacts that prove current state

If the task includes a persistent process, pair this skill with `runner`.

## Resume Procedure

When resuming:

1. read the continuity record
2. reconnect to the current session, task, or log source
3. recover the nearest trustworthy state from artifacts, logs, or session history
4. ignore misleading noise from compaction markers, stale summaries, or partial recollections
5. verify whether the preserved `next_step` is still valid
6. continue from the restored state

The first job on resume is orientation, not action.

## Recovery Discipline

If something looks broken after a pause or compaction:

- check whether the session still exists
- check whether the task still exists
- check whether the process is still alive
- check whether recent files, logs, or artifacts still support the last known state

Only after those checks should you classify the situation as:

- `resumable`
- `interrupted`
- `failed`
- `stale`
- `unknown`

## Good Handoff Notes

Good handoff notes are:

- restart-safe
- short
- attached to concrete identifiers
- grounded in files, logs, or session state
- clear about what to verify first

Bad handoff notes:

- "continue from here"
- "I think the test server is still up"
- "probably done except maybe one thing"

## Session-Aware Continuity

If the runtime exposes session history or session search, continuity should prefer:

1. current live session state
2. latest non-compaction message history
3. task and log artifacts
4. prior summaries

Plain prose summaries are the weakest continuity source unless backed by artifacts.

## Relationship To Other Skills

- Use `runner` for durable command and process continuity.
- Use `orchestrator` when what must persist is a multi-task workflow with dependencies.

## Minimal Record Template

```text
goal:
status:
cwd:
session_id:
task_ids:
agent_context:
files:
commands:
logs:
artifacts:
last_good_state:
risks:
next_step:
verify_first:
```
