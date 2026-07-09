terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.35"
    }
  }
}

# No explicit resources — just provider config passed from root
variable "namespace" {
  description = "Namespace to create"
  type        = string
  default     = "local-cloud"
}

variable "app_name" {
  description = "Name of the sample app"
  type        = string
  default     = "hello-local-cloud"
}

variable "app_image" {
  description = "Container image for the sample app"
  type        = string
  default     = "nginx:alpine"
}

variable "app_port" {
  description = "Container port"
  type        = number
  default     = 80
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 2
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment_v1" "this" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = var.app_name
          image = var.app_image
          port {
            container_port = var.app_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "this" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      port        = var.app_port
      target_port = var.app_port
    }

    type = "ClusterIP"
  }
}

output "namespace" {
  value = kubernetes_namespace_v1.this.metadata[0].name
}

output "deployment_name" {
  value = kubernetes_deployment_v1.this.metadata[0].name
}

output "service_name" {
  value = kubernetes_service_v1.this.metadata[0].name
}

output "service_namespace" {
  value = kubernetes_service_v1.this.metadata[0].namespace
}