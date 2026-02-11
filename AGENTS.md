# Workspace Agent Notes

This workspace contains multiple git repositories. Each top-level directory under `/home/dnshio/tenderbot` is its own repo.
Common ones include:
- `signup/` (frontend)
- `backend/` (FastAPI backend)
- `remix-of-tenderbot-prototype/` (prototype source)

Follow repo-specific guidance:
- Frontend: `signup/AGENTS.md` and `signup/README.md`
- Backend: `backend/AGENTS.md` and `backend/README.md`

Cross-repo coordination:
- Frontend expects a running backend via `NEXT_PUBLIC_API_BASE_URL`.
- If API contracts change, update any frontend mocks/tests accordingly.

## Ticket Pickup Trigger

When the user says "pick up the next ticket" (or close variants like "continue with next ticket"), treat it as an execution command.

Required behavior:
- Read `stories/CODING_AGENT_EXECUTION_PROTOCOL.md` first.
- Select the next eligible story from `stories/refined/` using that protocol.
- Do not select stories in `stories/in-progress/` or `stories/done/`.
- Do not select planning-only epic tickets unless the user explicitly requests one.
- Identify the target repo from the story context (`backend/` or `signup/`).
- Follow repo-local rules in `<repo>/AGENTS.md` for implementation, validation, and CI checks.
- Create a feature branch and never commit directly to `main`.
- Implement the story, run required checks, and raise a PR.
- Report back with selected story, rationale, branch name, PR URL, acceptance criteria status, and checks run.
