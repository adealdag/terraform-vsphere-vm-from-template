# terraform-vsphere-vm-from-template

This module creates a new VM by cloning the specified template.

## Considerations and limitations

* The VM settings are copied from the template
* The disk is set to Thin Provisioned and cannot be changed
* The VM Template must have a single interface. IP address and port-group specified as input are configured on that first interface

## Usage

```hcl
module "test-vm" {
  source             = "github.com/adealdag/terraform-aci-access-interface"

  vsphere_dc         = "DC1"
  vsphere_ds         = "DS1"
  cluster            = "CLUSTER-A"
  host               = "esxi-host-a-1"
  vm_template        = "CentOS-template"
  vm_name            = "test-vm"
  vm_domain          = "cisco.com"
  vm_folder          = "my-vms"
  vm_network_ip      = "192.168.1.101"
  vm_network_mask    = 24
  vm_network_gateway = "192.168.1.1"
  vm_portgroup       = join("|", regex("uni/tn-([^/]+)/ap-([^/]+)/epg-([^/]+)", aci_application_epg.my_epg.id))
}
```