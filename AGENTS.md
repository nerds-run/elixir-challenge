# Project: Items API

## GitHub Repository
- **Owner**: nerds-run
- **Repo**: elixir-challenge
- **Full**: nerds-run/elixir-challenge

## Linear
- **Initiative ID**: ba6a04d0-644d-4488-b3f3-a2495de19706
- **Team ID**: 7b08a30f-68c9-426c-8820-176403395483
- **Project ID**: db289243-3437-4873-8d8a-7275897df9a8

## Build Commands
```bash
install: mix deps.get
build:   mix compile
run:     mix run --no-halt
test:    mix test
```

## Workflow
Issues progress: Backlog → Todo → In Progress → In Review → Done

## Agent Conventions
- Commit messages: conventional commits (feat/fix/refactor/test/docs/chore)
- Branch naming: feature/[ISSUE-ID]-short-description
- PRs: always draft, always target main
- Never force push, never commit .env files

## Technology Stack
- **Language**: Elixir
- **Framework**: Plug + Bandit (no Phoenix)
- **Database**: SQLite via Ecto + ecto_sqlite3
- **Runtime**: Erlang/OTP 28, Elixir 1.19.4

## Project Structure
- `/lib/items_api` - Main application code
- `/lib/items_api/application.ex` - Supervision tree (Repo + Bandit)
- `/lib/items_api/repo.ex` - Ecto Repo for SQLite
- `/lib/items_api/item.ex` - Item schema
- `/lib/items_api/router.ex` - API routes
- `/config` - Configuration files
- `/priv/repo/migrations` - Database migrations
