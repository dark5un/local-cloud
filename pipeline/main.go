package main

import (
	"context"
	"dagger/pipeline/internal/dagger"
)

// Pipeline is the OpenTofu CI pipeline — validates, tests, and plans infrastructure.
type Pipeline struct{}

// infraDir returns the infrastructure directory from the module context.
func (m *Pipeline) infraDir() *dagger.Directory {
	return dag.CurrentModule().Source().Directory("../infrastructure")
}

// tofuContainer returns a container with OpenTofu installed.
func (m *Pipeline) tofuContainer() *dagger.Container {
	return dag.Container().
		From("debian:latest").
		WithExec([]string{"apt-get", "update"}).
		WithExec([]string{"apt-get", "install", "-y", "wget", "ca-certificates", "tar", "gzip"}).
		WithExec([]string{"mkdir", "-p", "/tmp/tofu"}).
		WithWorkdir("/tmp/tofu").
		WithExec([]string{
			"wget", "-O", "tofu.tar.gz",
			"https://github.com/opentofu/opentofu/releases/download/v1.12.1/tofu_1.12.1_linux_amd64.tar.gz",
		}).
		WithExec([]string{"tar", "-xzf", "tofu.tar.gz"}).
		WithExec([]string{"mv", "tofu", "/usr/local/bin/tofu"}).
		WithExec([]string{"rm", "-rf", "/tmp/tofu"})
}

// FmtCheck checks OpenTofu formatting (fmt -check -diff).
func (m *Pipeline) FmtCheck(ctx context.Context) (string, error) {
	return m.tofuContainer().
		WithDirectory("/infra", m.infraDir()).
		WithWorkdir("/infra/opentofu").
		WithExec([]string{"tofu", "fmt", "-check", "-diff", "."}).
		Stdout(ctx)
}

// ValidateModules validates all OpenTofu modules.
func (m *Pipeline) ValidateModules(ctx context.Context) (string, error) {
	cmd := "for mod in modules/*/; do echo '=== $mod ==='; cd \"$mod\" && tofu init -backend=false && tofu validate; cd -; done"
	return m.tofuContainer().
		WithDirectory("/infra", m.infraDir()).
		WithWorkdir("/infra/opentofu").
		WithExec([]string{"sh", "-c", cmd}).
		Stdout(ctx)
}

// TestModules runs OpenTofu tests for all modules.
func (m *Pipeline) TestModules(ctx context.Context) (string, error) {
	cmd := "for mod in modules/*/; do echo '=== Testing $mod ==='; cd \"$mod\" && tofu init -backend=false && tofu test; cd -; done"
	return m.tofuContainer().
		WithDirectory("/infra", m.infraDir()).
		WithWorkdir("/infra/opentofu").
		WithExec([]string{"sh", "-c", cmd}).
		Stdout(ctx)
}

// IntegrationPlan generates an integration plan for the local environment.
func (m *Pipeline) IntegrationPlan(ctx context.Context) (string, error) {
	return m.tofuContainer().
		WithDirectory("/infra", m.infraDir()).
		WithWorkdir("/infra/opentofu/environments/local").
		WithExec([]string{"tofu", "init", "-backend=false"}).
		WithExec([]string{"tofu", "plan", "-no-color"}).
		Stdout(ctx)
}