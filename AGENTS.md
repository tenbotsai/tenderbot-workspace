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
