# Agent Instructions — sql_cookbook

This repository is explicitly opted into the AI Knowledge Hub. These instructions apply **only here**, not in unrelated repositories or workspaces.

## Read before substantive work
- Read [PROJECT_MEMORY.md](PROJECT_MEMORY.md) for project context, then check relevant source code, docs, and tests to verify the current implementation.
- Read only task-relevant sources. Consult the private [AI Knowledge Hub](https://github.com/kypnicholas/ai-knowledge-hub) **only when cross-project context is necessary and available**. A URL alone does not confer access. Do not retrieve the hub in other projects.
- Current checked-in code and configuration supersede potentially stale memory.

## Project rules
- **Public repository:** keep agent instructions and memory public-safe; never reveal DSNs, passwords, service-role keys, connection tokens or real user/customer information.
- The progress source of truth is `SQL_COOKBOOK_ROADMAP.md`. Do not mark exercises complete without their actual deliverables and evidence.
- Keep query examples dialect-appropriate for PostgreSQL on Supabase and validate against the Chinook schema. Do not run schema-changing SQL on a production database without explicit approval.
- Use the documented spec generator and query runner when database access is available; never assume local or remote credentials exist.

## Maintaining memory
- After significant work, assess whether durable implementation facts, architectural decisions, deployment behavior, dependencies, contracts or next steps changed.
- If warranted, present a concise, evidence-backed proposed diff to `PROJECT_MEMORY.md` for approval; **never silently commit or push memory**. If no durable information changed, leave it alone.
- Do not include secrets, credentials, private runtime values, personal information or confidential client data. Keep the hub limited to explicitly approved cross-project knowledge; do not duplicate complete memories there.
