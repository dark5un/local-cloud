provider "kubernetes" {
  config_path = "/var/home/panos/Distros/Hermes/.kube/config"
}

run "namespace_created" {
  command = plan

  module {
    source = "./."
  }

  assert {
    condition     = output.namespace == "local-cloud"
    error_message = "Expected namespace 'local-cloud'"
  }
}

run "deployment_created" {
  command = plan

  module {
    source = "./."
  }

  variables {
    app_name = "hello-local-cloud"
    replicas = 2
  }

  assert {
    condition     = output.deployment_name == "hello-local-cloud"
    error_message = "Expected deployment name 'hello-local-cloud'"
  }
}

run "service_created" {
  command = plan

  module {
    source = "./."
  }

  assert {
    condition     = output.service_name != ""
    error_message = "Expected service to be created"
  }
}