package main

import (
	"context"
	"dagger/pipeline/internal/dagger"
)

type Pipeline struct{}

func (m *Pipeline) infraDir() *dagger.Directory {
	return dag.CurrentModule().Source().Directory("infrastructure/opentofu")
}

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

func (m *Pipeline) FmtCheck(ctx context.Context) (string, error) {
	return m.tofuContainer().
		WithDirectory("/infra", m.infraDir()).
		WithWorkdir("/infra").
		WithExec([]string{"tofu", "fmt", "-check", "-diff", "."}).
		Stdout(ctx)
}

func (m *Pipeline) ValidateModules(ctx context.Context) (string, error) {
	cmd := "for mod in modules/*/; do echo '=== $mod ==='; cd \"$mod\" && tofu init -backend=false && tofu validate; cd -; done"
	return m.tofuContainer().
		WithDirectory("/infra", m.infraDir()).
		WithWorkdir("/infra").
		WithExec([]string{"sh", "-c", cmd}).
		Stdout(ctx)
}

func (m *Pipeline) IntegrationPlan(ctx context.Context) (string, error) {
	return m.tofuContainer().
		WithDirectory("/infra", m.infraDir()).
		WithWorkdir("/infra/environments/local").
		WithExec([]string{"tofu", "init", "-backend=false"}).
		WithExec([]string{"tofu", "plan", "-no-color"}).
		Stdout(ctx)
}
