#!/usr/bin/env python

# taken from https://gist.github.com/johanwiren/5217095

import libvirt
import json

from optparse import OptionParser

parser = OptionParser()
parser.add_option("--list", action="store_const", const="list", dest="action")
parser.add_option("--host", action="store", dest="host")

(options, args) = parser.parse_args()

conn = libvirt.openReadOnly("qemu:///system")

def vm_to_host(vm):
  vm=vm.split("@")
  return vm[0]+".example.net"

def vm_group(vm):
  vm=vm.split("@")
  return vm[1]

def host_to_vm(host):
  short=host.split(".");
  vmids = conn.listDomainsID()
  for vmid in vmids:
     xvm=conn.lookupByID(vmid).name()
     if xvm.split("@")[0] == short[0]:
        host = xvm
  return host

def get_vm_info(host):
  vm = conn.lookupByName(host_to_vm(host))
  vars = dict()
  vars['libvirt_maxmem'], vars['libvirt_memory'] = vm.info()[1:3]
  return vars

def get_vms():
  groups = {}  
  groups['allvms'] = { 'hosts': [ ] }
  vmids = conn.listDomainsID()
  for vmid in vmids:
      vmname = conn.lookupByID(vmid).name()
      host = vm_to_host(vmname)
      group = vm_group(vmname)
      try:
          groups[group]['hosts'].append(host)
      except:
          groups[group] = { 'hosts': [ host ] }
      
      groups['allvms']['hosts'].append(host)

  return groups

if options.host is not None:
  print json.dumps(get_vm_info(options.host))
elif options.action == "list":
   print json.dumps(get_vms())
