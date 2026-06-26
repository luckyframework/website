# Deploy

Production deployment of the Lucky website to [Fly.io](https://fly.io). No database is required.

## Architecture

- **`fly.toml`** (repo root) configures the app: it points `[build]` at `deploy/Dockerfile`, sets non-secret env, listens on port `8080`, forces HTTPS, and scales to zero when idle.
- **Fly builds the image** from `deploy/Dockerfile` on its remote builders — no local Docker needed.
- **Fly's edge** provides the `*.fly.dev` domain (and custom domains) with automatic, auto-renewing TLS.
- A deploy = `flyctl deploy --remote-only`, run for you by the **Deploy** GitHub Action.

## Deploying

Run the **Deploy** Action: **Actions → Deploy → Run workflow**, choose the branch (defaults to `main`). It checks out that branch and runs `flyctl deploy --remote-only`, which builds `deploy/Dockerfile` on Fly and releases it. Fly performs a rolling release.

You can also deploy from your laptop with `fly deploy` for testing.

## Cost / scaling

`fly.toml` is configured **always-on**: `min_machines_running = 1` keeps one 512MB shared-cpu-1x machine running so there are no cold starts (~$3.32/mo + minimal bandwidth, no volume needed). To trade that for lower cost, set `min_machines_running = 0` to scale to zero when idle (the machine then cold-starts within a few seconds on the next request).

## Verify

```bash
fly status
fly logs
curl -I https://<app>.fly.dev
```
