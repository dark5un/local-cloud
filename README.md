# local-cloud

TDD-driven infrastructure for a local cloud stack: [Floci](https://github.com/localstack/floci) as AWS emulator, local container registry, and [k3s](https://k3s.io/) via [k3d](https://k3d.io/).

## Modules

| Module | Purpose | Tests |
|---|---|---|
| `storage` | Versioned S3 bucket | 2 |
| `network` | VPC + public subnet | 1 |
| `iam` | ECS task role + policy | 1 |
| `dynamodb` | State table | 1 |
| `ecs` | Fargate cluster + service | 1 |
| `local env` | Full stack integration | 1 |

**7 test runs. All passing.** Via the Dagger pipeline: `dagger call test-modules` from `pipeline/`.

## Stack

- Floci (port 4566) — 69 AWS services
- Local registry (port 5000)
- k3d `local-cloud` cluster (k3s v1.35.5)

## Prerequisites

- [OpenTofu](https://opentofu.org/) >= 1.10
- Docker
- [k3d](https://k3d.io/)
- [distrobox](https://github.com/containers/distrobox) (if running in container)

## Usage

```bash
# Start the stack
./scripts/up.sh

# Run the full CI pipeline (Dagger Go module)
cd pipeline
dagger call fmt-check
dagger call validate-modules
dagger call test-modules
dagger call integration-plan
```

The [Dagger](https://dagger.io) pipeline at `pipeline/` runs OpenTofu format check, schema validation, contract tests, and infrastructure plan — all inside isolated containers. Written in Go using the Dagger SDK v0.21.7.

## Blog Series

The [Philosophical Developer](https://onlyascii.dev) — local cloud chapters:

- [Chapter 13 — Why Local Matters](https://onlyascii.dev/posts/chapter-13-local-matters/)
- [Chapter 14 — Code Your Infrastructure](https://onlyascii.dev/posts/chapter-14-infra-code/)
- [Chapter 15 — The Pipeline](https://onlyascii.dev/posts/chapter-15-the-pipeline/)
- [Chapter 16 — Deploy to the Local Cloud](https://onlyascii.dev/posts/chapter-16-deploy-local-cloud/)
- [Chapter 17 — Observability](https://onlyascii.dev/posts/chapter-17-observability/)
