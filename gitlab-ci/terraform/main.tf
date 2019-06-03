provider "google" {
  version = "2.0.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "gitlab-ci" {
    name         = "gitlab-ci"
    machine_type = "${var.machine_type}"
    zone         = "${var.zone}"
    tags         = ["gitlab-ci"]
    boot_disk {
        initialize_params {
            image = "${var.disk_image}"
        }
    }

    network_interface {
        network = "default"
        access_config {}
    }

    metadata {
        ssh-keys = "appuser:${file(var.public_key_path)}"
    }

    connection {
        type        = "ssh"
        user        = "appuser"
        agent       = false
        private_key = "${file(var.private_key_path)}"
    }
}

resource "google_compute_address" "gitlab-ci" {
    name = "gitlab-ci-ip"
}
