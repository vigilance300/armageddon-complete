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
region = "europe-central2"
zone = "europe-central2-a"
credentials = "theo-gcp-class-5-17424e3ea23f.json"
}


#europe vpc and vm
resource "google_compute_network" "voltron-black-vpc" {
  project                 = "theo-gcp-class-5"
  name                    = "voltron-black-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "voltron-black-subnet-a" {
  project                  = "theo-gcp-class-5"
  name                     = "voltron-black-subnet-a"
  region                   = "europe-central2"
  ip_cidr_range            = "10.188.20.0/24"
  network                  = google_compute_network.voltron-black-vpc.id
}


resource "google_compute_firewall" "black-firewall-http" {
  project     = "theo-gcp-class-5"
  name        = "voltron-black-firewall-http"
  network     = google_compute_network.voltron-black-vpc.id
    allow {
        protocol = "tcp"
        ports = ["80"]
    }
    source_ranges = ["172.18.40.0/24", "172.20.100.0/24", "192.168.50.0/24"]
    target_tags = ["http-server"]
    priority = 100
}





resource "google_compute_instance" "voltron-black-vm" {
  project      = "theo-gcp-class-5"
  name         = "voltron-black-vm"
  machine_type = "e2-micro"
  zone         = "europe-central2-a"
  tags         = ["http-server", "https-server"]

   metadata = {
    startup-script = "    #!/bin/bash\n    apt-get update\n    apt-get install -y apache2\n    cat <<EOT > /var/www/html/index.html\n    <html>\n      <head>\n        <title>Voltron</title>\n      </head>\n      <body>\n        <h1>Voltron-Unite!</h1>\n        <p>This page is served by Apache on a Google Compute Engine VM instance.</p>\n      </body>\n    </html>"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = google_compute_network.voltron-black-vpc.id
    subnetwork = google_compute_subnetwork.voltron-black-subnet-a.id
    access_config {
      // Ephemeral IP
    }
  }
}




#southamerica and northamerica vpc's 
resource "google_compute_network" "voltron-red-vpc" {
  project                 = "theo-gcp-class-5"
  name                    = "voltron-red-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "voltron-red-subnet-a" {
  project                  = "theo-gcp-class-5"
  name                     = "voltron-red-subnet-a"
  region                   = "us-central1"
  ip_cidr_range            = "172.18.40.0/24"
  network                  = google_compute_network.voltron-red-vpc.id
}

resource "google_compute_subnetwork" "voltron-red-subnet-b" {
  project                  = "theo-gcp-class-5"
  name                     = "voltron-red-subnet-b"
  region                   = "southamerica-east1"
  ip_cidr_range            = "172.20.100.0/24"  
  network                  = google_compute_network.voltron-red-vpc.id
}

#firewall rules for America's vpc

resource "google_compute_firewall" "red-firewall-rdp" {
  project     = "theo-gcp-class-5"
  name        = "voltron-red-firewall-rdp"
  network     = google_compute_network.voltron-red-vpc.id
    allow {
        protocol = "tcp"
        ports = [ "3389"]
    }
    source_ranges = ["0.0.0.0/0"]
    priority = 100
}

#VM's for America's 

resource "google_compute_instance" "voltron-red-vm-na" {
  project      = "theo-gcp-class-5"
  name         = "voltron-red-vm-na"
  machine_type = "n2-standard-4"
  zone         = "us-central1-a"
  


  boot_disk {
    auto_delete = true
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
      size  = 120
      type  = "pd-balanced"
    }
     mode = "READ_WRITE"
  }
     labels= {
        goog-ec-src = "vm_add-tf"
     }

  network_interface {
    network = google_compute_network.voltron-red-vpc.id
    subnetwork = google_compute_subnetwork.voltron-red-subnet-a.id
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_instance" "voltron-red-vm-sa" {
  project      = "theo-gcp-class-5"
  name         = "voltron-red-vm-sa"
  machine_type = "n2-standard-4"
  zone         = "southamerica-east1-a"
 

  boot_disk {
    auto_delete = true
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
      size  = 120
      type  = "pd-balanced"
    }
     mode = "READ_WRITE"
  }
     labels= {
        goog-ec-src = "vm_add-tf"
     }

  network_interface {
    network = google_compute_network.voltron-red-vpc.id
    subnetwork = google_compute_subnetwork.voltron-red-subnet-b.id
    access_config {
      // Ephemeral IP
    }
  }
}


#asia vpc

resource "google_compute_network" "voltron-blue-vpc" {
  project                 = "theo-gcp-class-5"
  name                    = "voltron-blue-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "voltron-blue-subnet" {
  project                  = "theo-gcp-class-5"
  name                     = "voltron-blue-subnet"
  region                   = "asia-northeast1"
  ip_cidr_range            = "192.168.50.0/24"
  network                  = google_compute_network.voltron-blue-vpc.id
}

#firewall rules for asia vpc

resource "google_compute_firewall" "blue-firewall-rdp" {
  name        = "voltron-blue-firewall-rdp"
  network     = google_compute_network.voltron-blue-vpc.id
    allow {
        protocol = "tcp"
        ports = ["3389",]
    }
    source_ranges = ["0.0.0.0/0"]
    priority = 100
}

#VM for asia

resource "google_compute_instance" "voltron-blue-vm" {
  project      = "theo-gcp-class-5"
  name         = "voltron-blue-vm"
  machine_type = "n2-standard-4"
  zone         = "asia-northeast1-a"
  

 boot_disk {
    auto_delete = true
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
      size  = 120
      type  = "pd-balanced"
    }
     mode = "READ_WRITE"
  }
     labels= {
        goog-ec-src = "vm_add-tf"
     }

  network_interface {
    network = google_compute_network.voltron-blue-vpc.id
    subnetwork = google_compute_subnetwork.voltron-blue-subnet.id
    access_config {
      // Ephemeral IP
    }
  }
}


#Peering-Americas to europe and europe to Americas
resource "google_compute_network_peering" "americas-to-europe" {
  name         = "americas-to-europe"
  network      = google_compute_network.voltron-red-vpc.id
  peer_network = google_compute_network.voltron-black-vpc.id
}

resource "google_compute_network_peering" "europe-americas" {
  name         = "europe-americas"
  network      = google_compute_network.voltron-black-vpc.id
  peer_network = google_compute_network.voltron-red-vpc.id
}


#VPN-to-europe
resource "google_compute_vpn_gateway" "to-europe-gateway" {
  name    = "to-europe-gateway"
  region  = "asia-northeast1"
  network = google_compute_network.voltron-blue-vpc.id
}

resource "google_compute_address" "vpn-static-ip-to-europe" {
  name = "vpn-static-ip-to-europe"
  region = "asia-northeast1"
}

resource "google_compute_vpn_tunnel" "to-europe" {
  name          = "asia-to-europe-tunnel"
  peer_ip       =  google_compute_address.vpn-static-ip-to-asia.address
  shared_secret = "vigilance-lives"
  local_traffic_selector = [google_compute_subnetwork.voltron-blue-subnet.ip_cidr_range]
  remote_traffic_selector = [google_compute_subnetwork.voltron-black-subnet-a.ip_cidr_range]
  target_vpn_gateway = google_compute_vpn_gateway.to-europe-gateway.id

  depends_on = [
    google_compute_forwarding_rule.esp-asia-to-europe,
    google_compute_forwarding_rule.asia-to-europe_udp500,
    google_compute_forwarding_rule.asia-to-europe_udp4500,
  ]

}

#Forwarding rules for VPN-to-europe

resource "google_compute_forwarding_rule" "esp-asia-to-europe" {
  name        = "esp-asia-to-europe"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn-static-ip-to-europe.address
  target      = google_compute_vpn_gateway.to-europe-gateway.id
  region      = "asia-northeast1"
}

resource "google_compute_forwarding_rule" "asia-to-europe_udp500" {
  name        = "asia-to-europe-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn-static-ip-to-europe.address
  target      = google_compute_vpn_gateway.to-europe-gateway.id
  region      = "asia-northeast1"
}

resource "google_compute_forwarding_rule" "asia-to-europe_udp4500" {
  name        = "asia-to-europe-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn-static-ip-to-europe.address
  target      = google_compute_vpn_gateway.to-europe-gateway.id
  region      = "asia-northeast1"
}

resource "google_compute_route" "asia-to-europe-route" {
  name       = "asia-to-europe-route" 
  network    = google_compute_network.voltron-blue-vpc.name
  dest_range = "10.188.20.0/24"
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.to-europe.id
}

#VPN-to-asia

resource "google_compute_vpn_gateway" "to-asia-gateway" {
  name    = "to-asia-gateway"
  region  = "europe-central2"
  network = google_compute_network.voltron-black-vpc.id
}

resource "google_compute_address" "vpn-static-ip-to-asia" {
  name = "vpn-static-ip-to-asia"
  region = "europe-central2"
}

resource "google_compute_vpn_tunnel" "to-asia" {
  name          = "europe-to-asia-tunnel"
  peer_ip       = google_compute_address.vpn-static-ip-to-europe.address
  shared_secret = "vigilance-lives"
  local_traffic_selector = [google_compute_subnetwork.voltron-black-subnet-a.ip_cidr_range]
  remote_traffic_selector = [google_compute_subnetwork.voltron-blue-subnet.ip_cidr_range]
  target_vpn_gateway = google_compute_vpn_gateway.to-asia-gateway.id

  depends_on = [
    google_compute_forwarding_rule.esp-asia-to-europe,
    google_compute_forwarding_rule.asia-to-europe_udp500,
    google_compute_forwarding_rule.asia-to-europe_udp4500,
  ]

}

#Forwarding rules for VPN-to-asia

resource "google_compute_forwarding_rule" "esp-europe-to-asia" {
  name        = "esp-europe-to-asia"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn-static-ip-to-asia.address
  target      = google_compute_vpn_gateway.to-asia-gateway.id
  region      = "europe-central2"
}

resource "google_compute_forwarding_rule" "europe-to-asia_udp500" {
  name        = "europe-to-asia-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn-static-ip-to-asia.address
  target      = google_compute_vpn_gateway.to-asia-gateway.id
  region      = "europe-central2"
}

resource "google_compute_forwarding_rule" "europe-to-asia_udp4500" {
  name        = "europe-to-asia-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn-static-ip-to-asia.address
  target      = google_compute_vpn_gateway.to-asia-gateway.id
  region      = "europe-central2"
}

resource "google_compute_route" "europe-to-asia-route" {
  name       = "europe-to-asia-route" 
  network    = google_compute_network.voltron-black-vpc.name
  dest_range = "192.168.50.0/24"
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.to-asia.id
}

