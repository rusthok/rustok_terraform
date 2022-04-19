resource "kubernetes_deployment" "wordpress" {
  depends_on = [module.kwordpressdb]
  metadata {
    name = "wordpress"
    labels = {
      App = "wordpress"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "wordpress"
      }
    }
    template {
      metadata {
        labels = {
          App = "wordpress"
        }
      }
      spec {
        container {
          image = "bitnami/wordpress:latest"
          name  = "wordpress"

          port {
            container_port = 80 #8080
            #target_port = 80 #8080
          }

          resources {
            limits = {
              cpu    = "1024"
              memory = "3072"
            }
            requests = {
              cpu    = "500m"
              memory = "100Mi"
            }
          }
        }
        #liveness_probe {
        #    http_get {
        #      path = "/"
        #      port = 80
        #
        #      http_header {
        #        name  = "X-Custom-Header"
        #        value = "Awesome"
        #      }
        #    }
        #}
      }
    }
  }
}

resource "kubernetes_service" "kservice" {
  depends_on = [kubernetes_deployment.wordpress]
  metadata {
    name = "wp-service"
  }
  spec {
    selector = {
      App = kubernetes_deployment.wordpress.metadata.0.labels.App
    }
    port {
      port        = 80 #8080
      target_port = 80
    }
    type = "NodePort"
  }
}



#resource "aws_efs_file_system" "wordpressEFS"