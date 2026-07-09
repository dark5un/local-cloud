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

**7 test runs. All passing.** `tofu test` in any module directory.

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

# Run tests
cd infrastructure/opentofu/modules/storage
tofu test

# Plan the full environment
cd infrastructure/opentofu/environments/local
tofu plan
```

## Blog Series

The [Philosophical Developer](https://onlyascii.dev) — local cloud chapters:

- [Chapter 13 — Local Matters](https://onlyascii.dev/posts/chapter-13-local-matters/)
- [Chapter 14 — Code Your Infrastructure](https://onlyascii.dev/posts/chapter-14-infra-code/)
