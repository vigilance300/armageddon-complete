terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.27.0"
    }
  }
}

provider "google" {
  # Configuration options
project = "theo-gcp-class-5"
region = "us-central1"
zone = "us-central1-a"
credentials = "theo-gcp-class-5-17424e3ea23f.json"
}

resource "google_compute_network" "voltron-proto-vpc" {
  project                 = "theo-gcp-class-5"
  name                    = "voltron-proto-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "voltron-proto-subnet-a" {
  project                  = "theo-gcp-class-5"
  name                     = "voltron-proto-subnet-a"
  region                   = "us-central1"
  ip_cidr_range            = "10.188.10.0/24"
  network                  = google_compute_network.voltron-proto-vpc.id
}

resource "google_compute_firewall" "allow-icmp" {
  project     = "theo-gcp-class-5"
  name        = "voltron-proto-firewall-icmp"
  network     = google_compute_network.voltron-proto-vpc.id
    allow {
        protocol = "icmp" 
    }
    source_ranges = ["0.0.0.0/0"]
    priority = 600
}

resource "google_compute_firewall" "http" {
  project     = "theo-gcp-class-5"
  name        = "voltron-proto-firewall-http"
  network     = google_compute_network.voltron-proto-vpc.id
    allow {
        protocol = "tcp"
        ports = ["80", "8080", "22", "3389"]
    }
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["http-server"]
    priority = 100
}

resource "google_compute_firewall" "https" {
  project     = "theo-gcp-class-5"
  name        = "voltron-proto-firewall-https"
  network     = google_compute_network.voltron-proto-vpc.id
    allow {
        protocol = "tcp"
        ports = ["443"]
    }
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["https-server"]
    priority = 100
}
 
resource "google_compute_instance" "voltron-proto-vm" {
  name         = "voltron-proto-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  tags         = ["http-server", "https-server"]

   metadata = {
    startup-script = "    #!/bin/bash\n    apt-get update\n    apt-get install -y apache2\n    cat <<EOT > /var/www/html/index.html\n    <html>\n      <head>\n        <title>Welcome to My Homepage</title>\n      </head>\n      <body>\n        <h1>Welcome to My Homepage!</h1>\n        <p>This page is served by Apache on a Google Compute Engine VM instance.</p>\n      </body>\n    </html>"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.voltron-proto-vpc.id
    subnetwork = google_compute_subnetwork.voltron-proto-subnet-a.id

    access_config {
      // Ephemeral IP
    }
  }
}

output "vpc" {
  value       = google_compute_network.voltron-proto-vpc.id
  description = "The ID of the VPC"
}

output "instance_public_ip" {
  value       = google_compute_instance.voltron-proto-vm.network_interface[0].access_config[0].nat_ip
  description = "The public IP address of the web server"
}

output "instance_subnet" {
  value       = google_compute_instance.voltron-proto-vm.network_interface[0].subnetwork
  description = "The subnet of the VM instance"
}

output "instance_internal_ip" {
  value       = google_compute_instance.voltron-proto-vm.network_interface[0].network_ip
  description = "The internal IP address of the VM instance"
}
