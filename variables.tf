variable "vsphere_dc" {
  description = "Datacenter name in vSphere vCenter where the VM will be created"
}

variable "vsphere_ds" {
  description = "Datastore name in vSphere vCenter where the VM will be stored"
}

variable "cluster" {
  description = "Cluster name in vSphere vCenter where the VM will be deployed"
}

variable "host" {
  description = "Host name in vSphere vCenter where the VM will be deployed. Optional, if ommited the host will be selected automatically"
  default     = null
}

variable "vm_template" {
  description = "VM Template name that will be cloned to create the new VM"
}

variable "vm_name" {
  description = "VM Name"
}

variable "vm_folder" {
  description = "Folder where the new VM will be placed within the Datacenter in vSphere vCenter"
}

variable "vm_domain" {
  description = "Domain name to be configured in the VM. Optional, if ommited lab.local will be used"
  default     = "lab.local"
}

variable "vm_network_ip" {
  description = "IP address to be assigned to the VM interface"
}

variable "vm_network_mask" {
  description = "Mask length to be used for VM interface IP address"
}

variable "vm_network_gateway" {
  description = "Default gateway to be configured in VM network settings"
}

variable "vm_portgroup" {
  description = "Port Group where the VM interface will be connected. By default, quarantine will be used"
  default     = "quarantine"
}

variable "vm_mgmt_portgroup" {
  description = "Port Group where the VM management interface will be connected. By default, quarantine will be used"
  default     = "quarantine"
}

variable "vm_tags" {
  type        = list(string)
  description = "Tags to be configured in the VM"
  default     = []
}

