# dfkjf
#
//resource "proxmox_virtual_environment_vm" "nixos_template" {
//  acpi                = true
//  bios                = "seabios"
//  boot_order          = null
//  description         = null
//  hook_script_file_id = null
//  keyboard_layout     = null
//  kvm_arguments       = null
//  mac_addresses       = []
//  machine             = null
//  migrate             = null
//  name                = "nixos-template"
//  node_name           = "pve"
//  on_boot             = null
//  pool_id             = null
//  protection          = false
//  reboot              = null
//  scsi_hardware       = "virtio-scsi-single"
//  started             = false
//  stop_on_destroy     = null
//  tablet_device       = true
//  tags                = []
//  template            = true
//  timeout_clone       = null
//  timeout_create      = null
//  timeout_migrate     = null
//  timeout_reboot      = null
//  timeout_shutdown_vm = null
//  timeout_start_vm    = null
//  timeout_stop_vm     = null
//  agent {
//    enabled = true
//    timeout = "15m"
//    trim    = false
//    type    = null
//  }
//  cpu {
//    affinity     = null
//    architecture = null
//    cores        = 2
//    flags        = []
//    hotplugged   = 0
//    limit        = 0
//    numa         = false
//    sockets      = 1
//    type         = "host"
//    units        = 1024
//  }
//  disk {
//    datastore_id      = "local-lvm"
//    file_id           = proxmox_virtual_environment_file.nixos_dump.id
//    interface         = "virtio0"
//    iothread          = true
//    discard           = "on"
//    size              = 20
//
//    aio               = "io_uring"
//    backup            = true
//    cache             = "none"
//    file_format       = "raw"
//    path_in_datastore = "vm-200-disk-0"
//    serial            = null
//    ssd               = true
//  }
//  memory {
//    dedicated      = 2048
//    floating       = 1024
//    hugepages      = null
//    keep_hugepages = false
//    shared         = 0
//  }
//  network_device {
//    bridge       = "vmbr0"
//    disconnected = false
//    enabled      = true
//    firewall     = true
//    model        = "virtio"
//    mtu          = 0
//    queues       = 0
//    rate_limit   = 0
//    trunks       = null
//    vlan_id      = 0
//  }
//  operating_system {
//    type = "l26"
//  }
//}

//resource "proxmox_virtual_environment_download_file" "nixos_image" {
//  content_type = "iso"
//  datastore_id = "local"
//  node_name    = "pve"
//
//  url = "https://channels.nixos.org/nixos-24.11/latest-nixos-minimal-x86_64-linux.iso"
//}

#resource "proxmox_virtual_environment_vm" "nixos-test" {
#  name      = "nixos-test"
#  node_name = "pve"
#
#  # should be true if qemu agent is not installed / enabled on the VM
#  stop_on_destroy = true
#
#  initialization {
#    user_account {
#      # do not use this in production, configure your own ssh key instead!
#      username = "dmitrii"
#      password = "123456"
#    }
#  }
#  agent {
#    enabled = true
#    timeout = "15m"
#    trim    = false
#    type    = null
#  }
#  network_device {
#    bridge       = "vmbr0"
#    disconnected = false
#    enabled      = true
#    firewall     = true
#    model        = "virtio"
#    mtu          = 0
#    queues       = 0
#    rate_limit   = 0
#    trunks       = null
#    vlan_id      = 0
#  }
#  cpu {
#    affinity     = null
#    architecture = null
#    cores        = 2
#    flags        = []
#    hotplugged   = 0
#    limit        = 0
#    numa         = false
#    sockets      = 1
#    type         = "host"
#    units        = 1024
#  }
#  memory {
#    dedicated      = 2048
#    floating       = 1024
#    hugepages      = null
#    keep_hugepages = false
#    shared         = 0
#  }
#  
#  disk {
#    datastore_id = "local-lvm"
#    file_id      = proxmox_virtual_environment_file.nixos_iso.id
#    interface    = "virtio0"
#    iothread     = true
#    discard      = "on"
#    size         = 20
#  }
#}

locals {
  nixos_dump_dir  = "${path.module}/nix/result"
  nixos_dump_file = one([for f in fileset(local.nixos_dump_dir, "vzdump-*.vma.zst") : f])
  #nixos_iso_dir  = "${path.module}/nix/result/iso"
  #nixos_iso_file = one([for f in fileset(local.nixos_iso_dir, "*.iso") : f])
}

#resource "proxmox_virtual_environment_file" "nixos_iso" {
#  content_type = "iso"
#  datastore_id = "local"
#  node_name    = "pve"
#
#  source_file {
#    path = "${local.nixos_iso_dir}/${local.nixos_iso_file}"
#  }
#}

resource "proxmox_virtual_environment_file" "nixos_dump" {
  content_type = "backup"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path = "${local.nixos_dump_dir}/${local.nixos_dump_file}"
  }
}

data "local_file" "ssh_public_key" {
  filename = "../id_rsa.pub"
}

#resource "proxmox_virtual_environment_vm" "nixos_clone" {
#  name      = "nixos-clone"
#  node_name = "pve"
#
#  clone {
#    vm_id = proxmox_virtual_environment_vm.nixos_template.id
#  }
#
#  initialization {
#    ip_config {
#      ipv4 {
#        address = "dhcp"
#      }
#    }
#    user_account {
#      username = "nixos"
#      keys     = [trimspace(data.local_file.ssh_public_key.content)]
#    }
#  }
#}

#output "vm_ipv4_address" {
#  value = proxmox_virtual_environment_vm.nixos_clone.ipv4_addresses[1][0]
#}
