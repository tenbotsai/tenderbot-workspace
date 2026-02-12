Execution Plan
- Objective: Drain all actionable stories with strict priority order: stories/in-progress/ first, then stories/refined/, following stories/CODING_AGENT_EXECUTION_PROTOCOL.md and repo-local AGENTS.md.
- Hard rule: Keep looping ticket-by-ticket until no eligible ticket remains; only then output <promise>COMPLETE</promise>.
- Current actionable queue (from your workspace):
  - stories/in-progress/017-be-test-fixtures-and-integration-harness-hardening.md
  - stories/refined/014-be-onboarding-api-contract-tests.md
  - stories/refined/015-be-billing-checkout-confirmation-contract-tests.md
  - stories/refined/016-be-dashboard-api-contract-tests.md
- Planning-only epic note: stories/refined/003-comprehensive-testing-strategy.md is a planning epic; per protocol it is not a coding ticket unless explicitly requested. If you want strict “all refined files closed,” process it last as lifecycle/admin closure after child tickets are merged.
Per-Ticket Loop (repeat until empty)
- 1) Select next ticket
  - Choose from in-progress first.
  - If none, choose from refined by protocol ordering (priority, deps, estimate, story ID).
  - Skip planning-only epic unless explicitly included.
- 2) Move lifecycle state before coding
  - If ticket is in refined, move it to stories/in-progress/ immediately and set frontmatter status: in-progress.
  - Read full story and extract AC checklist + dependencies + out-of-scope.
- 3) Implement in target repo
  - Identify target repo from story context (backend/ for 014–017).
  - Create branch: feature/story-<id>-<short-slug> (never commit to main).
  - Implement only AC-required changes; keep scope tight.
  - Add/update tests to prove each acceptance criterion.
- 4) Validate locally before PR
  - Run required repo checks (for backend, use backend/AGENTS.md):
    - mise run test
    - mise run test-coverage
    - mise run typecheck
    - mise run docker-build
  - If required by story: mise run test-integration.
  - Fix failures before opening/updating PR.
- 5) Open PR
  - Push branch and create PR with:
    - Story reference (#<id>)
    - Change summary
    - AC mapping checklist
    - Validation evidence (commands + pass results)
- 6) Ensure CI green and merge
  - Watch CI checks to completion.
  - Resolve failures, repush, re-run until green.
  - Merge PR (per repo workflow).
- 7) Post-merge ticket closure
  - Move story file stories/in-progress/ -> stories/done/.
  - Update frontmatter status: done and timestamp.
  - Report completion for that story (ID, branch, PR URL, AC status, checks).
Execution Order Recommended
1. 017 (already in progress)
2. 014
3. 015
4. 016
5. 003 last only if you want all refined files fully closed (non-coding closure)
Blocker Protocol (do not stall silently)
- If blocked by missing secrets, unresolved dependency, required architecture/security decision, or unrelated failing baseline:
  - Report blocker, what was tried, recommended next step.
  - Continue with next eligible ticket if possible (maintain momentum).
Definition of Done for your instruction
- No actionable tickets remain in stories/in-progress/ or stories/refined/ (excluding unrequested planning-only epic unless you include it).
- All associated PRs are merged and ticket files moved to stories/done/.
- Final output exactly: <promise>COMPLETE</promise>.
