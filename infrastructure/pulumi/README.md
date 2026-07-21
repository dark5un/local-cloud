# Pulumi Local Cloud (AWS)

Pulumi Go port of the local-cloud infrastructure modules. Seven modules, each with unit tests using Pulumi mocks, a CI pipeline, and integration test scripts for Floci.

## Modules

| Module | What It Creates | Test |
|--------|----------------|------|
| `storage` | Versioned S3 bucket | `TestStorageModule` |
| `network` | VPC + public subnet | `TestNetworkModule` |
| `iam` | ECS task role + policy + attachment | `TestIAMModule` |
| `dynamodb` | DynamoDB table (PAY_PER_REQUEST) | `TestDynamoDBModule` |
| `ecs` | Fargate cluster + task definition + service | `TestECSModule` |
| `ecr` | ECR repository with image scanning | `TestECRModule` |
| `k8s` | Kubernetes namespace + deployment + service | `TestK8sModule` |
| `stack` | Full composition | `TestLocalCloudStack` |

**8 tests. All passing.** Via Pulumi mocks -- no infrastructure needed.

## Prerequisites

- Go 1.26
- Pulumi CLI (`curl -fsSL https://get.pulumi.com | sh`)
- Docker (for integration tests with Floci)

## Quick Start

```bash
cd infrastructure/pulumi

# Unit tests (fast, no infrastructure needed)
go test -v -count=1 ./...

# Deploy to local Floci
./scripts/up.sh
./scripts/deploy.sh

# Full integration test (deploy, verify, destroy)
./scripts/integration-test.sh
```

## Project Layout

```
infrastructure/pulumi/
├── main.go                # Stack composition
├── main_test.go            # Unit tests with Pulumi mocks
├── storage.go              # Versioned S3 bucket
├── network.go              # VPC + public subnet
├── iam.go                  # ECS task role + policy
├── dynamodb.go             # DynamoDB state table
├── ecs.go                  # Fargate cluster + service
├── ecr.go                  # ECR repository
├── k8s.go                  # Kubernetes resources
├── Pulumi.yaml             # Project config
├── Pulumi.dev.yaml         # Floci endpoint config
└── scripts/
    ├── up.sh                # Start Floci
    ├── deploy.sh            # Deploy to Floci
    └── integration-test.sh  # Full lifecycle test
```

## Testing Approach

Unit tests use Pulumi mocks (`pulumi.WithMocks`) to verify resource contracts without making real API calls. This mirrors the OpenTofu `command = plan` test pattern -- fast, deterministic, no side effects.

Integration tests deploy to a real Floci instance and verify the stack outputs match expectations.

## CI

The GitHub Actions workflow at `.github/workflows/ci.yaml` runs Pulumi tests alongside the existing OpenTofu pipeline:

```yaml
pulumi-ci:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-go@v5
      with: { go-version: '1.26' }
    - run: go build ./...
    - run: go test -v -count=1 ./...
```

## Related

- [OpenTofu modules](../opentofu/) -- the original HCL implementation
- [local-cloud-gcp](https://github.com/dark5un/local-cloud-gcp) -- GCP port
- [local-cloud-az](https://github.com/dark5un/local-cloud-az) -- Azure port