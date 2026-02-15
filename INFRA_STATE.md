# Infrastructure State — 2026-02-14

## What's Done

### Hetzner VMs (all provisioned via Terraform)
- **Manager**: `46.225.112.84` (public), `10.0.1.1` (private), `100.85.130.64` (Tailscale) — Dokploy + Traefik running
- **Worker-1**: `91.99.68.57` (public), `10.0.1.2` (private) — joined Docker Swarm as manager
- **Worker-2**: `46.224.209.199` (public), `10.0.1.3` (private) — joined Docker Swarm as manager
- **DB**: `46.225.122.60` (public), `10.0.1.4` (private) — joined Docker Swarm as worker, `node.labels.role=database`
- **Load Balancer**: `46.225.35.166` (public) — TCP passthrough on 80/443 → all 3 managers (private IPs)

### SSH access
- Key: `~/.ssh/hetzner_tenderbot`
- Manager: `ssh -i ~/.ssh/hetzner_tenderbot root@tenderbot-prod-manager` (Tailscale) or `root@46.225.112.84` (public)
- Workers: `ssh -i ~/.ssh/hetzner_tenderbot -o ProxyJump=root@tenderbot-prod-manager root@10.0.1.2` (or .3)
- DB: `ssh -i ~/.ssh/hetzner_tenderbot -o ProxyJump=root@tenderbot-prod-manager root@10.0.1.4`

### Docker Swarm
- 3-manager HA model: `tenderbot-prod-manager`, `tenderbot-prod-worker-1`, and `tenderbot-prod-worker-2` all act as managers, while `tenderbot-db` joins as a worker with `role=database` for Postgres placement constraints
- All nodes publish deterministic Tailscale hostnames (`tenderbot-prod-*` and `tenderbot-db`), so MagicDNS resolves them consistently even after rebuilds

### Postgres (in Swarm)
- Runs as Docker Swarm services (NOT as a system service)
- Pinned to `tenderbot-db` node via `node.labels.role == database` constraint
- Data volumes at `/mnt/pgdata/{staging,prod}/{app,prefect}` on `tenderbot-db` (Hetzner volume mounted)
- Old system `postgresql` service stopped and disabled on `tenderbot-db`

### Networks
- **Critical**: `dokploy-network` uses subnet `10.0.10.0/24` (was previously `10.0.1.0/24` — conflicted with Hetzner private network, caused routing failures)
- `tenderbot-staging` overlay: `10.0.2.x` range
- `tenderbot-prod` overlay: separate range

### Dokploy (http://tenderbot-prod-manager:3000/)
- API key in Doppler: `DOKPLOY_API_KEY`

### Prefect UI/API (Tailscale only)
- Production: `http://tenderbot-prod-manager:4200`
- Staging: `http://tenderbot-prod-manager:4201`
- Ports are intentionally not exposed via Hetzner public firewall (tailnet access only)
- Staging compose ID: `kyCh_dUXyobVAEDW1VF1x` (stack name: `compose-synthesize-virtual-monitor-79hauw`)
- Prod compose ID: `K-O_kKAvZWp3OijqxUmZM`
- GHCR registry configured: `ghcr.io`, user `dnshio`, PAT from Doppler `GHCR_PAT` ✓
- `/root/.docker/config.json` contains GHCR auth (copied from `dokploy` named volume)

### Traefik
- v3.6.7, global mode (3/3 manager nodes), ports 80+443 `mode: host`
- cert resolver: `letsencrypt` (DNS challenge via Cloudflare, CF_DNS_API_TOKEN_FILE secret)
- ACME storage: `traefik-acme` named volume per node
- Stack file: `/root/traefik.yml` on manager

### Staging Stack (`compose-synthesize-virtual-monitor-79hauw`)
All 5 services running 1/1:
- `api` — on `tenderbot-staging` + `dokploy-network`, 1 replica on manager
- `prefect-server` — on `tenderbot-staging` only, 1 replica on manager
- `prefect-worker` — on `tenderbot-staging` only, 1 replica on manager
- `app-db` (postgres:15-alpine) — on `tenderbot-staging` only, pinned to `tenderbot-db`
- `prefect-db` (postgres:15-alpine) — on `tenderbot-staging` only, pinned to `tenderbot-db`

Env vars in `/etc/dokploy/compose/compose-synthesize-virtual-monitor-79hauw/code/.env`

### Prod Stack (`K-O_kKAvZWp3OijqxUmZM`)
- Deployed and healthy via Dokploy

### Cloudflare DNS (tenderbot.ai)
- Zone ID: `989accb63dc7218760076825bcfdd01b`
- `api-staging.tenderbot.ai` → LB `46.225.35.166` ✓ (returns 200 OK)
- `api.tenderbot.ai` → LB `46.225.35.166` ✓ (returns 200 OK)

### GitHub Actions (TODO)
Secrets needed in `tenbotsai/backend` repo:
- `DOKPLOY_API_KEY` — from Doppler
- `DOKPLOY_URL` — `http://tenderbot-prod-manager:3000/`
- `DOKPLOY_STAGING_COMPOSE_ID` — `kyCh_dUXyobVAEDW1VF1x`
- `DOKPLOY_PROD_COMPOSE_ID` — `K-O_kKAvZWp3OijqxUmZM`

## Known Issues / TODOs
- GitHub Actions secrets not set up yet
- Run `terraform/tailscale-prune-stale-devices.py` after Terraform-driven node rotations to remove stale tailnet entries and keep MagicDNS hostnames stable
