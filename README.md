# TenderBot Workspace

This is the parent workspace repository for TenderBot development. It contains business context, PRDs, and coordination files while the actual code lives in separate repositories.

## Repository Structure

```
tenderbot/
├── business.md              # Business overview and key features
├── workspace.json           # Repository manifest and configuration
├── setup.sh                 # Setup script for new machines
├── AGENTS.md               # Agent/AI tooling documentation
├── backend/                # FastAPI backend (separate git repo)
├── signup/                 # Next.js frontend (separate git repo)
└── remix-of-tenderbot-prototype/  # UI reference prototype (separate git repo)
```

## Setting Up on a New Machine

1. Clone this meta repository:
   ```bash
   git clone git@github.com:tenbotsai/tenderbot-workspace.git tenderbot
   cd tenderbot
   ```

2. Run the setup script to clone all child repositories:
   ```bash
   ./setup.sh
   ```

3. Set up individual projects:
   ```bash
   # Backend
   cd backend
   pip install -r requirements.txt

   # Frontend
   cd ../signup
   npm install
   ```

## Working Across Repos

This structure allows you to:
- Keep business context and PRDs versioned separately from code
- Work on multiple repos from a single parent directory
- Share the same context with AI coding agents
- Track workspace state independently from individual projects

## Child Repositories

- **backend**: Python FastAPI application with Prefect workers for async tender processing
- **signup**: Next.js frontend application for user signup and dashboard
- **remix-of-tenderbot-prototype**: Lovable.dev prototype used as UI/UX reference

Each repository maintains its own git history and can be worked on independently.

## Why Not Submodules?

This approach avoids submodule complexity while achieving the same goals:
- Child repos are ignored by the parent `.gitignore`
- Each repo operates independently
- Simple `setup.sh` script handles initial cloning
- No special git commands needed for day-to-day work
