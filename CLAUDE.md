# Project Rules for Claude

## NEVER do these without explicit user confirmation

- Remove, recreate, or restart `dokploy`, `dokploy-postgres`, `dokploy-redis`, or `traefik` services/stacks
- Run `docker service rm`, `docker stack rm`, `docker network rm`, `docker volume rm`
- Bypass Dokploy to deploy app stacks directly (`docker stack deploy`, `docker service create` for app services)
- Modify Dokploy state directly on the server (env vars, compose files, DB)
- Stop or restart systemd services on VMs via SSH
- `terraform destroy` or `terraform apply` without showing a plan first

**When in doubt, ask. The cost of pausing is zero.**

## Terraform owns infrastructure. SSH is read-only.

All VM configuration, service setup, and persistent state changes go through Terraform (`infrastructure-tf/`).
Do NOT apply permanent changes via SSH — they will be lost on VM rebuild.

SSH is OK for: reading logs, checking status, investigating errors, one-off tests.
SSH is NOT OK for: installing packages, changing configs, creating files that need to persist.

## VMs are cattle, not pets

Any VM can be destroyed and recreated at any time. All persistent state must live on Hetzner volumes:
1. Encode VM setup in `cloud-init` (Terraform templated)
2. Store all data on Hetzner volumes (survive VM destruction)

Current Hetzner volumes:
- `tenderbot-db-data` (20 GB) → mounted at `/mnt/pgdata` on `tenderbot-db` — app/prefect DB data
- `tenderbot-manager-data` (40 GB) → mounted at `/mnt/manager-data` on manager — Dokploy postgres/redis/config

## Dokploy owns application deployments

All compose file updates, env var changes, and deploys go through the Dokploy API or UI.
Do NOT use `docker stack deploy` directly — that bypasses Dokploy's state.

## Named Docker volumes are node-local

Moving a service to a different node without a placement constraint creates a new empty volume.
Dokploy core services must:
- Run on manager by hostname constraint (`node.hostname == tenderbot-prod-manager`)
- **NOT** `node.role == manager` — all three worker nodes are also managers in this 3-node quorum
- Use bind mounts to `/mnt/manager-data/...` (NOT named volumes)

## Infrastructure quick reference

- Dokploy: http://tenderbot-prod-manager:3000/ (API key in Doppler: `DOKPLOY_API_KEY`)
- Staging compose ID: `kyCh_dUXyobVAEDW1VF1x`
- Prod compose ID: `K-O_kKAvZWp3OijqxUmZM`
- `dokploy-network` subnet: `10.0.10.0/24` (NOT `10.0.1.0/24` — conflicts with Hetzner private net)
- Traefik stack file: `/root/traefik.yml` on manager
- SSH to manager: `ssh -i ~/.ssh/hetzner_tenderbot root@tenderbot-prod-manager`
- SSH to DB: `ssh -i ~/.ssh/hetzner_tenderbot -o ProxyJump=root@tenderbot-prod-manager root@10.0.1.4`
- Terraform dir: `infrastructure-tf/terraform/`
