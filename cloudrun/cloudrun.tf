resource "google_cloud_run_service" "default" {
  project                    = var.project
  name                       = "cloudrun-hello"
  location                   = var.location
  autogenerate_revision_name = true
  template {
    spec {
      containers {
        image = var.container_image
      }
      service_account_name = var.service_account_name
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

output "url" {
  value = google_cloud_run_service.default.status[0].url
}