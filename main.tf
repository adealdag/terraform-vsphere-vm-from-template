data "vsphere_datacenter" "vsphere_dc" {
  name = var.vsphere_dc
}

data "vsphere_datastore" "vsphere_ds" {
  name          = var.vsphere_ds
  datacenter_id = data.vsphere_datacenter.vsphere_dc.id
}

data "vsphere_host" "host" {
  count = var.host != null ? 1 : 0

  name          = var.host
  datacenter_id = data.vsphere_datacenter.vsphere_dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.vsphere_dc.id
}

data "vsphere_network" "vm_portgroup" {
  name          = var.vm_portgroup
  datacenter_id = data.vsphere_datacenter.vsphere_dc.id
}

data "vsphere_network" "vm_mgmt_portgroup" {
  name          = var.vm_mgmt_portgroup
  datacenter_id = data.vsphere_datacenter.vsphere_dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.vsphere_dc.id
}

# vm
resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  folder           = var.vm_folder
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  host_system_id   = var.host != null ? data.vsphere_host.host[0].id : null
  datastore_id     = data.vsphere_datastore.vsphere_ds.id

  num_cpus = var.vm_cpu
  memory   = var.vm_mem
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  firmware = data.vsphere_virtual_machine.template.firmware

  tags = var.vm_tags

  network_interface {
    network_id   = data.vsphere_network.vm_portgroup.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  network_interface {
    network_id   = data.vsphere_network.vm_mgmt_portgroup.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[1]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }


  ignored_guest_ips           = ["169.254.0.0/16"]
  wait_for_guest_net_routable = false

  connection {
    type             = "ssh"
    user             = var.vm_username
    password         = var.vm_password
    host             = [for ip in self.guest_ip_addresses : ip if !strcontains(ip, "169.254.")][0]
    bastion_host     = var.bastion_ip
    bastion_user     = var.bastion_username
    bastion_password = var.bastion_password
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.vm_name} > /etc/hostname",
      "hostname -F /etc/hostname",
    ]
  }

  provisioner "file" {
    content     = <<EOT
    iface eth0 inet static
      mtu ${var.vm_network_mtu}
      address ${var.vm_network_ip}
      netmask ${var.vm_network_mask}
      gateway ${var.vm_network_gateway}
    EOT
    destination = "/etc/network/interfaces.d/eth0"
  }

  provisioner "remote-exec" {
    inline = [
      "rc-service networking restart",
      "sleep 10"
    ]
  }
}
