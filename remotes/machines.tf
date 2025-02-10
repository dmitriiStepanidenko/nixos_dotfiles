resource "proxmox_virtual_environment_vm" "nixos-vpn" {
  name      = "nixos-vpn"
  node_name = "pve"

  stop_on_destroy = true

  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = null
  }
  cpu {
    affinity     = null
    architecture = null
    cores        = 2
    flags        = []
    hotplugged   = 0
    limit        = 0
    numa         = false
    sockets      = 1
    type         = "host"
    units        = 1024
  }
  memory {
    dedicated      = 2048
    floating       = 1024
    hugepages      = null
    keep_hugepages = false
    shared         = 0
  }
  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = true
    mac_address  = "BC:24:11:4A:D6:0A"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    trunks       = null
    vlan_id      = 0
  }

  clone {
    vm_id = proxmox_virtual_environment_vm.nixos_template.id
  }
  
  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }
}

