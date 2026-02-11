# Refined Story Execution Protocol

Purpose: tell coding agents how to pick and execute the next refined story.
Repo-specific coding, testing, and quality rules remain in each repo's `AGENTS.md`.

## Source of Truth

- Story lifecycle and index: `stories/README.md`
- Implementable stories: `stories/refined/`
- Repo-specific implementation/testing rules: `<repo>/AGENTS.md`

## 1) Pick the Next Story

Choose the next story from `stories/refined/` using:

1. `priority` (`high` > `medium` > `low`)
2. Dependencies satisfied (implementation dependencies completed first)
3. Smaller estimate first when same priority
4. Lowest story ID as tie-breaker

Do not pick:

- stories in `stories/in-progress/` or `stories/done/`
- planning-only epic stories unless explicitly requested

## 2) Prepare Before Coding

For the chosen story:

1. Read the full story file
2. Extract acceptance criteria, implementation tasks, dependencies, and out-of-scope notes
3. Read files listed under technical context and file locations
4. Convert acceptance criteria into a checklist and track completion

## 3) Implementation Rules

- Implement only what is required for the acceptance criteria
- Keep changes focused and minimal
- Follow patterns already used in the target repo
- Add or update tests needed to prove the criteria

If blocked by ambiguity:

- ask one targeted question with a recommended default
- do not continue with risky assumptions

## 4) Branch and PR Workflow

- Never commit directly to `main`
- Create a feature branch: `feature/story-<id>-<short-slug>`
- Commit with clear story-linked messages
- Open a PR that includes:
  - story reference
  - concise summary of changes
  - acceptance criteria mapping
  - validation evidence from executed checks

## 5) Validation and CI

Run the required checks defined by the target repo's `AGENTS.md` and ensure they pass before opening or updating the PR.

Do not duplicate command lists in this file; always follow repo-local guidance.

## 6) Handoff Format

When PR is ready, provide:

- story ID and title
- branch name
- PR URL
- acceptance criteria checklist status
- checks run and pass or fail
- known risks and follow-ups

## 7) Completion State

- PR opened is not done
- Story is done only after PR review and merge per team workflow
- If story file status or location changes are required, follow coordinator instructions exactly

## 8) Blocker Protocol

Escalate immediately when blocked by:

- unresolved dependency
- missing credentials or secrets
- architecture or security decision needed
- failing checks not attributable to current changes

Include in escalation:

- blocker summary
- what was tried
- recommended next step
