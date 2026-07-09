from dagger import (
    Container,
    directory,
    function,
    object_type,
)


@object_type
class ToFuCI:
    """OpenTofu CI pipeline — validates, tests, and plans infrastructure."""

    @function
    def source(self) -> directory.Directory:
        return directory("infrastructure")

    @function
    def fmt_check(self, infra: directory.Directory = None) -> str:
        if infra is None:
            infra = self.source()
        return (
            Container.debian()
            .with_exec(["apt-get", "update"])
            .with_exec(["apt-get", "install", "-y", "wget", "ca-certificates"])
            .with_exec([
                "wget",
                "-O", "/usr/local/bin/tofu",
                "https://get.opentofu.org/tofu",
            ])
            .with_exec(["chmod", "+x", "/usr/local/bin/tofu"])
            .with_directory("/infra", infra)
            .with_workdir("/infra")
            .with_exec(["tofu", "fmt", "-check", "-diff", "."])
            .stdout()
        )

    @function
    def validate_modules(self, infra: directory.Directory = None) -> str:
        if infra is None:
            infra = self.source()
        return (
            Container.debian()
            .with_exec(["apt-get", "update"])
            .with_exec(["apt-get", "install", "-y", "wget", "ca-certificates"])
            .with_exec([
                "wget",
                "-O", "/usr/local/bin/tofu",
                "https://get.opentofu.org/tofu",
            ])
            .with_exec(["chmod", "+x", "/usr/local/bin/tofu"])
            .with_directory("/infra", infra)
            .with_workdir("/infra")
            .with_exec([
                "sh", "-c",
                "for mod in modules/*/; do echo '=== $mod ==='; "
                "cd \"$mod\" && tofu init -backend=false && tofu validate; cd -; done",
            ])
            .stdout()
        )

    @function
    def test_modules(self, infra: directory.Directory = None) -> str:
        if infra is None:
            infra = self.source()
        return (
            Container.debian()
            .with_exec(["apt-get", "update"])
            .with_exec(["apt-get", "install", "-y", "wget", "ca-certificates"])
            .with_exec([
                "wget",
                "-O", "/usr/local/bin/tofu",
                "https://get.opentofu.org/tofu",
            ])
            .with_exec(["chmod", "+x", "/usr/local/bin/tofu"])
            .with_directory("/infra", infra)
            .with_workdir("/infra")
            .with_exec([
                "sh", "-c",
                "for mod in modules/*/; do echo '=== Testing $mod ==='; "
                "cd \"$mod\" && tofu test; cd -; done",
            ])
            .stdout()
        )

    @function
    def integration_plan(self, infra: directory.Directory = None) -> str:
        if infra is None:
            infra = self.source()
        return (
            Container.debian()
            .with_exec(["apt-get", "update"])
            .with_exec(["apt-get", "install", "-y", "wget", "ca-certificates"])
            .with_exec([
                "wget",
                "-O", "/usr/local/bin/tofu",
                "https://get.opentofu.org/tofu",
            ])
            .with_exec(["chmod", "+x", "/usr/local/bin/tofu"])
            .with_directory("/infra", infra)
            .with_workdir("/infra/environments/local")
            .with_exec(["tofu", "init", "-backend=false"])
            .with_exec(["tofu", "plan", "-no-color"])
            .stdout()
        )
