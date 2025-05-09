terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.30.0"
    }
  }
}
# Provider configuration
provider "kubernetes" {
  config_path = "~/.kube/config"  # Path to your kubeconfig file
  config_context = "minikube"
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "k8s-tf3"
  }
}

resource "kubernetes_deployment" "example" {
  metadata {
    name = "terraform-example-1"
    labels = {
      test = "MyExampleApp2"
    }
    namespace = "k8s-tf3"

  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "MyExampleApp2"
      }
    }

    template {
      metadata {
        labels = {
          app = "MyExampleApp2"
        }
      }

      spec {
        container {
          image = "nginx:1.21.6"
          name  = "example"
          port {
            container_port = 80
          }
         
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }
          }     
        }
      }
    }
  }
}
resource "kubernetes_service" "myDemoApp2Service" {          
    metadata {
        name = "terraform-demo2-service"     
        namespace = "k8s-tf3"                      
    }
    spec {
        selector = {
            app = "MyExampleApp2"
        } 
        session_affinity = "ClientIP"  
        port {
            port  = 8085
            target_port = 80
        }
   
       
        type = "NodePort"                       
    }
}