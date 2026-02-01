# Multi Vagrant

## Overview

The idea behind this is to have a vagrant setup to support multiple providers and provisioners defined in a single config.
Supported providers and provisioners are listed below, support for others will be added over time.

This has been tested on Linux and MacOS

### Supported Providers

Currently supported providers;
  - Virtualbox (default)
  - VMWare Desktop
  - VMWare Fusion
  - LXC

Additional providers will be added either when I have a need for them, or when someone requests one.

### Supported Provisioners

Currently the following provisioners are supported for install on the master box
  - Ansible
  - Saltstack

#### Ansible

The master VM is the system that has Ansible installed, this is so that it acts as a control node. Ansible is not required on your machine (we like to keep it clean!). The control node will be used to run the playbooks on the other vagrant VMs.
Playbooks are mounted from your codesource folder into the codedest folder on the VM (see below).

## Requirements

### Software Versions

1. [vagrant 2.4.3+](http://www.vagrantup.com/downloads.html)
2. [virtualbox 7.1.0+](https://www.virtualbox.org/wiki/Linux_Downloads) (default provider)
3. [VMWare Workstation](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion)

## Configuration

To define dev VMs you need to create a `config.yaml` in the repo directory.  
A very minimal config would look like;

```yaml
settings:
  codebase: ~/your/local/code
  codedest: /some/remote/dir

vms:
  - name: foo
  - name: bar
  - name: baz
```

Let's look at what all this means!...

#### settings

The settings block defines some basic settings for your environment.   
There are only two required values in this block (validation will fail if these are missing) -

```yaml
settings:
  codebase: ~/your/local/code                                                   
  codedest: /some/remote/dir
```
These define the source and destination of your code base to be mounted/shared with the master VM. 
Doing this allows you to modify your code and run it straight away without having to upload your code or redploy the master VM.

Other options under the settings block are entirely optional. If they are not supplied, default values will be used.   
Some options and the defaults are:-

```yaml
domain: dev.arpa
defaultbox: bento/ubuntu-22.04
masterbox: bento/ubuntu-22.04
mastername: master
network: 192.168.56
provider: virtualbox
provisioner: none
master: true
```
**note:** when using the network option, omit the last octet as this is handled in the vagrantfile.

#### master

The master VM can be customized with the `master` block. This allows you to configure RAM, CPU, and additional shared folders for the master VM:

```yaml
master:
  ram: 2048
  cpu: 2
  folders:
    - from: ~/extra/local/path
      to: /extra/vm/path
```

To disable the master VM entirely (useful for simpler setups), set `master: false` in the settings block:

```yaml
settings:
  master: false
  # ... other settings
```

#### vms

To add VMs to your environment, you will need to add a `vms` block to the config file. The absolute minimum you need is -

```yaml
vms:
  - name: dev-box
```
you can specify a different provider for individual VMS

```yaml
vms:
  - name: dev-box
    provider: lxc
```
**note:** when using a different provider, ensure you specify a box that supports the requested provider!


you can customise certain parameters of your VM like this:-

```yaml
vms:
  - name: dev-box
    box: ubuntu/trusty64
    ram: 4096
    cpu: 4
```

If you need to share folders with the VM you can add them in like so:

```yaml
vms:
  - name: dev-box
    box: ubuntu/trusty64
    ram: 512
    folders:
      - from: ~/source/folder
        to: /destination/folder
```

You can repeat this as many times as needed:

```yaml
   folders:
     - from: ~/source/folder1
       to: /destination/folder1
     - from: ~/source/folder2
       to: /destination/folder2
     - from: ~/source/folder3
       to: /destination/folder3
```


#### Boxes

Below are some example boxes to use for your environment more are available from [VagrantCloud](https://portal.cloud.hashicorp.com/vagrant/discover)

| Distribution | VagrantCloud box |
| ------------ | ---------------- |
| Ubuntu Trusty 14.04 | [ubuntu/trusty64](https://portal.cloud.hashicorp.com/vagrant/discover/ubuntu/trusty64) |
| Rocky 9  | [rockylinux/9](https://portal.cloud.hashicorp.com/vagrant/discover/rockylinux/9) |
| Debian 12 | [bento/debian-12](https://portal.cloud.hashicorp.com/vagrant/discover/bento/debian-12) |

### A complete example

```yaml
settings:
  codebase: ~/git/myproject/
  codedest: /srv/code
  domain: dev.arpa
  defaultbox: bento/ubuntu-22.04
  masterbox: bento/ubuntu-22.04
  mastername: control
  network: 192.168.56
  provider: virtualbox
  provisioner: ansible

master:
  ram: 2048
  cpu: 2
  folders:
    - from: ~/git/ansible-playbooks
      to: /srv/ansible

vms:
  - name: web01
    box: bento/ubuntu-22.04
    ram: 2048
    cpu: 2
    folders:
      - from: ~/git/webapp
        to: /var/www/html

  - name: db01
    box: rockylinux/9
    ram: 4096
    cpu: 4

  - name: cache01
    ram: 1024
```

## Testing

Run the test suite:

```bash
make test
```

Or run tests directly:

```bash
rake test
```

## TODO

  * add support for more providers
  * add support for more provisioners
  * add support for multiple domains
  * drink beer
