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

## Deployment to Real AWS

The modules are tested against [Floci](https://github.com/localstack/floci) (an AWS emulator) but are provider-agnostic — they work with real AWS unchanged.

### Prerequisites

- An AWS account with credentials (access key + secret key)
- AWS CLI configured (`aws configure`)

### Setup

1. Copy the real AWS environment template:
   ```bash
   cp -r infrastructure/opentofu/environments/real-aws infrastructure/opentofu/environments/staging
   ```

2. Edit `environments/staging/main.tf` — uncomment the S3 backend section and set your state bucket name.

3. Plan against real AWS (credentials never touch your filesystem — passed as Dagger secrets):
   ```bash
   cd pipeline
   dagger call aws-plan \
     --aws-access-key=env:AWS_ACCESS_KEY_ID \
     --aws-secret-key=env:AWS_SECRET_ACCESS_KEY \
     --env=staging
   ```

4. Review the plan output. If it looks correct, apply:
   ```bash
   dagger call aws-apply \
     --aws-access-key=env:AWS_ACCESS_KEY_ID \
     --aws-secret-key=env:AWS_SECRET_ACCESS_KEY \
     --env=staging
   ```

**Important:** `aws-apply` is intentionally gated — it never runs automatically in CI. Plans are read-only; apply requires an explicit local `dagger call` with human confirmation.

### How It Works

The pipeline functions accept AWS credentials as Dagger `Secret` objects — they are never written to disk, never logged, and never exposed in the container's environment to other processes. The same modules, the same tests, the same pipeline. Only the environment directory and provider config change.

## Blog Series

The [Philosophical Developer](https://onlyascii.dev) — local cloud chapters:

- [Chapter 13 — Why Local Matters](https://onlyascii.dev/posts/chapter-13-local-matters/)
- [Chapter 14 — Code Your Infrastructure](https://onlyascii.dev/posts/chapter-14-infra-code/)
- [Chapter 15 — The Pipeline](https://onlyascii.dev/posts/chapter-15-the-pipeline/)
- [Chapter 16 — Deploy to the Local Cloud](https://onlyascii.dev/posts/chapter-16-deploy-local-cloud/)
- [Chapter 17 — Observability](https://onlyascii.dev/posts/chapter-17-observability/)
- [Chapter 18 — Image Management & ECR](https://onlyascii.dev/posts/chapter-18-image-management/)
