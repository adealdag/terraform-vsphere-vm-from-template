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

    customize {
      linux_options {
        host_name = var.vm_name
        domain    = var.vm_domain
      }

      network_interface {
        ipv4_address = var.vm_network_ip
        ipv4_netmask = var.vm_network_mask
      }

      network_interface {}

      ipv4_gateway = var.vm_network_gateway
    }
  }
}

resource "null_resource" "provision_vm" {

  connection {
    type     = "ssh"
    user     = var.vm_username
    password = var.vm_password
    host     = "10.50.3.43"
  }

  provisioner "file" {
    source      = "${path.module}/../../data/02-application/ansible/inventory-filter-group.vmware.yml"
    destination = "/tmp/inventory-filter-group.vmware.yml"
  }

  provisioner "file" {
    source      = "${path.module}/../../data/02-application/ansible/online-boutique.yml"
    destination = "/tmp/online-boutique.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "export ANSIBLE_HOST_KEY_CHECKING=False",
      "ansible-playbook -i inventory-filter-group.vmware.yml online-boutique.yml"
    ]
  }

  depends_on = [
    module.vm
  ]
}
