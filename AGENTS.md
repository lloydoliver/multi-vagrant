# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Multi-Vagrant is a framework for managing multiple Vagrant VMs with different providers (VirtualBox, VMware Desktop, VMware Fusion, LXC) and provisioners (Ansible, SaltStack) through a single YAML configuration file.

## Common Commands

```bash
# Start all VMs
vagrant up

# Start a specific VM
vagrant up <vm-name>.<domain>   # e.g., vagrant up foo.dev.arpa

# Destroy VMs
vagrant destroy -f

# Check VM status
vagrant status

# SSH into a VM
vagrant ssh <vm-name>.<domain>

# Reload VMs (after config changes)
vagrant reload

# Provision existing VMs
vagrant provision
```

## Architecture

### Configuration Flow
1. `vagrantfile` reads `config.yaml`
2. Provider check scripts are evaluated from `providers/checks/<provider>`
3. Master VM is created first with IP `.10` on the configured network
4. Client VMs are created iteratively, starting at IP `.11`

### Key Files
- `vagrantfile` - Main entry point; uses Ruby `eval` to dynamically load provider/provisioner code
- `config.yaml` - User configuration (gitignored; copy from `examples/config.yaml.example`)

### Provider System (`providers/`)
Each provider has two files:
- `providers/checks/<provider>` - Pre-flight validation (e.g., checks if VirtualBox is installed)
- `providers/<provider>` - VM-specific configuration block (network, CPU, RAM settings)

To add a new provider: create both files following existing patterns. The provider file contains Ruby code that will be `eval`'d within the VM configuration block.

### Provisioner System (`provisioners/`)
Each provisioner has:
- `provisioners/<provisioner>/master` - Master VM provisioning config
- `provisioners/<provisioner>/client` - Client VM provisioning config (Salt only currently)

Provisioner files are Ruby snippets that configure the Vagrant provisioner within the VM block context.

### Supported Providers
- `virtualbox` (default)
- `vmware_desktop`
- `vmware_fusion`
- `lxc`

### Supported Provisioners
- `ansible` - Installs Ansible on master VM as control node
- `salt` - Sets up SaltStack master/minion topology

## Configuration Reference

Settings in `config.yaml`:
- `codebase` / `codedest` (required) - Local code directory mounted to master VM
- `network` - First 3 octets of private network (default: `192.168.56`)
- `domain` - VM domain suffix (default: `dev.arpa`)
- `provider` / `provisioner` - Default provider/provisioner for all VMs

Per-VM overrides: `box`, `ram`, `cpu`, `folders`, `provider`, `domain`
