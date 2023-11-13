output "id" {
  value = vsphere_virtual_machine.vm.id
}

output "moid" {
  value = vsphere_virtual_machine.vm.moid
}

output "ip_addr" {
  value = vsphere_virtual_machine.vm.guest_ip_addresses
}

