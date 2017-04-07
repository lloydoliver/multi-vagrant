# Vagrant

## Overview


## Requirements

### Packages

1. [vagrant 1.9.3+](http://www.vagrantup.com/downloads.html)
2. [virtualbox 5.1.14+](https://www.virtualbox.org/wiki/Linux_Downloads)

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
There are only two required values in this block which are -

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
domain: local.dev
defaultbox: ubuntu/xenial64
masterbox: ubuntu/xenial64
mastername: master
network: 192.168.56
```
**note:** when using the network option, omit the last octet as this is handled in the vagrantfile.

#### vms

To add VMs to your environment, you will need to add a `vms` block to the config file. The absolute minimum you need is -

```yaml
vms:
  - name: dev-box
```

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

Below are some example boxes to use for your environment more are available from [Atlas search](https://atlas.hashicorp.com/boxes/search)

| Distribution | VagrantCloud box |
| ------------ | ---------------- |
| Ubuntu Trusty 14.04 x86_64 | [ubuntu/trusty64](https://atlas.hashicorp.com/ubuntu/boxes/trusty64) |
| Ubuntu Xenial 16.04 x86_64 | [ubuntu/xenial64](https://atlas.hashicorp.com/ubuntu/boxes/xenial64) |
| RHEL 7.3 x86_64 | [iamseth/rhel-7.3](https://atlas.hashicorp.com/iamseth/boxes/rhel-7.3) |

### A complete example

```yaml

settings:                              
  codebase: ~/git/suchcode/
  codedest: /srv/muchamaze/           
  domain: wow.com                  
  defaultbox: ubuntu/xenial64          
  masterbox: ubuntu/xenial64           
  mastername: iamthedoge            
  network: 172.10.91                  
                                       
vms:                                   
  - name: foo                       
    box: ubuntu/xenial64               
    ram: 2048                                                 
    cpu: 2                                                    
    folders:                                                  
      from: '~/git/amazing/code/'                                
      to: '/var/www/html/code/'   

  - name: bar
    box: iamseth/rhel-7.3
    ram: 4096
    cpu: 4

  - name: baz
    folders:
      from: '~/git/amazing/scripts'
      to: '/var/lib/scripts/'
```
  
  
# TODO

  * add support for multiple providers
  * add support for multiple domains
  * add support for multiple provisioners
  * drink beer
