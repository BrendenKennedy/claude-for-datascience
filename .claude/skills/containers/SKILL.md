---
name: containers
description: >
  Docker + Compose for DS — reproducible images and the local support services pipelines need.
  Carries: the training image pattern (CUDA base matched to the host driver, `uv sync --frozen`
  from the lockfile, non-root user), the serving image (slim; the model pulled from the registry
  at start, not baked in), GPU runtime (nvidia-container-toolkit, `--gpus all`, CUDA-base vs
  driver compatibility), Compose for support services (MLflow server + Postgres, Label Studio)
  with named volumes and `.env` wiring, `.dockerignore` as a hard rule (data/, models/, .env —
  images must never swallow datasets or secrets), digest-pinned base images, and volume-mounting
  data instead of copying it. Kubernetes is deliberately out of scope (parked). Load when writing
  a Dockerfile or compose file, or containerizing training/serving. Triggers: docker, dockerfile,
  container, containerize, compose, docker-compose, image, base image, nvidia runtime, --gpus,
  volume, bind mount, .dockerignore, docker build.
---

# containers — images and services without surprises

**Pinned:** docker engine, compose — unpinned · authored 2026-07-18 · run
`/skill-update containers` against the installed engine (`docker --version`)

> On-demand: load this when the project needs an image (training on another box, serving) or
> local services (a real MLflow server, Postgres, Label Studio). The reproducibility rules are
> the repo's usual ones at image altitude: pin what you build from, build from the lockfile,
> and keep data/secrets out of layers. **K8s is deliberately parked** — Compose covers the
> support-service need at this scaffold's scale; orchestration is a platform decision, not a
> default.

## The training image (reproducibility is the point)
```dockerfile
FROM nvidia/cuda:VERSION-cudnn-runtime-ubuntu22.04@sha256:DIGEST   # digest-pinned, CUDA ≤ host driver
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev                       # THE lockfile, not a requirements guess
COPY conf/ conf/
COPY src/ src/
RUN useradd -m runner && chown -R runner /app
USER runner                                        # never train as root
ENTRYPOINT ["uv", "run", "python", "src/PKG/train.py"]
```
- **CUDA base vs host driver:** the image's CUDA version must be ≤ what the host driver
  supports (`nvidia-smi` on the host shows the max). This is `env-uv`'s wheel-matching problem
  wearing a container; same failure mode (`torch.cuda.is_available()` False inside the box).
- **GPU runtime:** host needs nvidia-container-toolkit; run with `--gpus all` (compose:
  `deploy.resources.reservations.devices`). Verify inside the container, not from the Dockerfile.
- **Data is mounted, never copied:** `-v $DATA_ROOT:/data:ro` (read-only for training). Copying
  a dataset into a layer makes a multi-GB image that leaks data with every push.
- **`.dockerignore` is a security control, not tidiness:** `data/`, `models/`, `mlruns/`,
  `.env`, `.git/` — a `COPY . .` without it bakes datasets and secrets into layers that
  out-live the container. Same class of leak `guard-secrets` blocks in files.

## The serving image
Slim base (no CUDA unless GPU inference is real), the same `uv sync --frozen`, and the model
**pulled at startup from the registry alias** (`models:/NAME@champion`, per `serving`) — not
baked into the image. Baking couples redeploys to retrains and hides which model is live;
pulling keeps rollback = alias move. Health endpoint + `model_version` in responses as `serving`
specifies.

## Compose — the support services
One `docker-compose.yml` for the services the pipeline leans on, e.g. a real tracking backend:
```yaml
services:
  postgres:
    image: postgres:16@sha256:DIGEST
    env_file: .env                       # POSTGRES_PASSWORD lives there, not here
    volumes: ["pgdata:/var/lib/postgresql/data"]   # named volume = the database's life
  mlflow:
    image: ghcr.io/mlflow/mlflow:VERSION
    command: mlflow server --backend-store-uri postgresql://... --host 0.0.0.0
    ports: ["5000:5000"]
    depends_on: [postgres]
volumes:
  pgdata:
```
- **Named volumes hold the state that matters** (the tracking DB!). `docker compose down -v`
  deletes them — the bash hook confirm-gates it; treat volumes like `mlflow.db`, not like cache.
- Secrets ride `env_file: .env` (gitignored, per the security canon) — never literal in YAML.
- Pin image tags **with digests**; `latest` is an unpinned dependency by another name.

## Gotchas
- Rebuild triggers: `uv.lock` changes must rebuild the sync layer — order COPY of lockfile
  before source so code edits don't bust the dependency cache (and lockfile edits do).
- A container is not isolation from cost or data loss: mounted volumes and cloud creds passed
  in are as live as on the host — the same guards apply.
- Image provenance: record the image digest of a training run with the run (a tag/param) —
  "which container produced this checkpoint" is part of reproducibility.
