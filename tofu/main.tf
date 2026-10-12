terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "rhel_base_disk" {
  name   = "rhel-secops-disk.qcow2"
  pool   = "default"
  source = "/var/lib/libvirt/images/rhel-9-cloud.qcow2"
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  pool      = "default"
  user_data = templatefile("${path.module}/cloud_init.cfg", {
    ssh_public_key = file("~/.ssh/id_ed25519.pub")
  })
  meta_data = <<EOT
instance-id: secops-node-01
local-hostname: secops-node-01
EOT
}

resource "libvirt_domain" "secops_vm" {
  name   = "secops-node-01"
  memory = "4096"
  vcpu   = 2

  cpu {
    mode = "host-passthrough"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = "default"
    wait_for_lease = false
  }

  disk {
    volume_id = libvirt_volume.rhel_base_disk.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

output "vm_ip" {
  value       = libvirt_domain.secops_vm.network_interface[0].addresses
  description = "IP Address VM RHEL"
}
