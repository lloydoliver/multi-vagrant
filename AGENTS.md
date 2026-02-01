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
1. `vagrantfile` validates `config.yaml` (checks required fields, types, valid provider/provisioner names)
2. Provider check scripts are evaluated from `providers/checks/<provider>`
3. Master VM is created first with IP `.10` (can be disabled with `settings.master: false`)
4. Client VMs are created iteratively, starting at IP `.11`

### Key Files
- `vagrantfile` - Main entry point with validation; uses Ruby `eval` to load provider/provisioner code
- `config.yaml` - User configuration (gitignored; copy from `examples/config.yaml.example`)

### Provider System (`providers/`)
Each provider has two files:
- `providers/checks/<provider>` - Pre-flight validation (e.g., checks if VirtualBox is installed)
- `providers/<provider>` - VM-specific configuration block (network, CPU, RAM settings)

Provider files expect these variables to be set: `name`, `ip`, `ram`, `cpu`, `dev` (VM config block)

To add a new provider:
1. Create `providers/<provider>` with VM configuration
2. Create `providers/checks/<provider>` with installation validation
3. Add provider name to `VALID_PROVIDERS` array in vagrantfile

### Provisioner System (`provisioners/`)
Each provisioner has:
- `provisioners/<provisioner>/master` - Master VM provisioning config
- `provisioners/<provisioner>/client` - Client VM provisioning config

To add a new provisioner:
1. Create master and client files in `provisioners/<provisioner>/`
2. Add provisioner name to `VALID_PROVISIONERS` array in vagrantfile

### Supported Providers
- `virtualbox` (default)
- `vmware_desktop`
- `vmware_fusion`
- `lxc`

### Supported Provisioners
- `none` (default) - No provisioning
- `ansible` - Installs Ansible on master VM as control node; installs Python on clients
- `salt` - Sets up SaltStack master/minion topology

## Configuration Reference

### settings (required)
- `codebase` / `codedest` (required) - Local code directory mounted to master VM
- `network` - First 3 octets of private network (default: `192.168.56`)
- `domain` - VM domain suffix (default: `dev.arpa`)
- `provider` - Default provider (default: `virtualbox`)
- `provisioner` - Default provisioner (default: `none`)
- `master` - Set to `false` to disable master VM

### master (optional)
- `ram` - Master VM RAM in MB (default: `1024`)
- `cpu` - Master VM CPU count (default: `1`)
- `folders` - Additional shared folders for master VM

### vms (array)
- `name` (required) - VM name (alphanumeric and hyphens only)
- `box`, `ram`, `cpu`, `folders`, `provider`, `domain` - Per-VM overrides
