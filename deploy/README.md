# Deploy

Production deployment to a single Docker host (e.g. Hetzner) with Caddy in front.

## Architecture

- GitHub Actions builds the image (using `deploy/Dockerfile`) and pushes it to GHCR.
- The server runs `docker compose` with two services: `caddy` (reverse proxy + Let's Encrypt) and `app` (the Lucky binary).
- A deploy = `docker compose pull app && docker compose up -d app`.

## One-time server setup

1. Provision a Ubuntu 24.04 box, harden it, enable `unattended-upgrades` with automatic reboots.
2. Install Docker Engine + Compose plugin.
3. Point your DNS A record at the server.
4. Create a deploy directory and copy these files into it:
   ```
   /opt/lucky_website/
     docker-compose.yml
     Caddyfile
     .env
   ```
5. Fill in `.env` from `.env.example`. Generate the secret key with `lucky gen.secret_key` on your laptop.
6. Log in to GHCR so the server can pull private images (skip if the package is public):
   ```
   echo $GHCR_PAT | docker login ghcr.io -u <github-user> --password-stdin
   ```
7. Start it:
   ```
   docker compose up -d
   ```
   Caddy will request a certificate on first request to the domain.

## GitHub Actions secrets

Set these on the repo:

- `SSH_HOST` — server hostname or IP
- `SSH_USER` — deploy user (must be in the `docker` group)
- `SSH_KEY` — private key matching an authorized key on the server
- `DEPLOY_PATH` — absolute path to the deploy directory on the server, e.g. `/opt/lucky_website`

The workflow uses the built-in `GITHUB_TOKEN` to push to GHCR; no extra secret needed.

## Updating

Push to `main`. The workflow builds, pushes `:latest` and `:<sha>`, then SSHes in and runs `docker compose pull app && docker compose up -d app`. Brief downtime during the swap.
