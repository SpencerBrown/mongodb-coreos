# Install CoreOS to bare metal

## Create CoreOS bootable flash drive

[Download the CoreOS ISO}(https://coreos.com/os/docs/latest/booting-with-iso.html). Then create your bootable flash drive on your Mac:

```bash
diskutil list
# pick your flash drive from the list, in this example it is /dev/disk2
diskutil unmountDisk /dev/disk2
# be really careful with the following. IT WILL WIPE whatever you put as of= WITH NO WARNING. note "rdisk2" not "disk2". 
sudo dd if=~/Downloads/coreos_production_iso_image.iso of=/dev/rdisk2 bs=1m
diskutil eject /dev/disk2
```

## Prepare the config

Edit config.json and insert your own SSH public key in the "sshAuthorizedKeys" value. Also set your hostname in the "source" value for "/etc/hostname".

## Install CoreOS to the target machine

Copy config.json to another flash drive. Insert both flash drives into your target machine, then boot the CoreOS ISO flash drive. You will need a keyboard and monitor connected to it, just to get going. Note that the ISO on the flash drive supports UEFI boot as well as legacy boot.

Use `lsblk` to find the flash drive with config.json on it. Then mount it on /media, for example: `sudo mount /dev/sde1 /media`.

Install CoreOS to a disk device. **WARNING** this will DESTROY everything on that drive, including all partitions, WITH NO WARNING. Get it right! We use /dev/sdb in this example, **BUT MAKE SURE YOU ARE WRITING TO THE RIGHT DEVICE**!

```bash
sudo coreos-install -d /dev/sdb -C alpha -i /media/config.json
```

Now reboot your machine from /dev/sdb. Note that UEFI boot is supported by this CoreOS install. It should come up and allow you to SSH into it as user "core", using the key you specified.

# Install CoreOS to VirtualBox

Download the production image `coreos_production_image.bin.bz2` from CoreOS:  https://alpha.release.core-os.net/amd64-usr/current/ and inflate it. Then convert it to VirtualBox VDI format.

```bash
bzip2 -d coreos_production_image.bin.bz2
vboxmanage convertdd coreos_production_image.bin coreos_production_image.vdi --format VDI
```

When you wish to launch a VM with CoreOS, clone the disk and resize it as you wish (in this example 32GB):

```bash
vboxmanage clonehd coreos_production_image.vdi server-a.vdi
vboxmanage modifyhd server-a.vdi --resize 32768
```

Create the virtual machine using the VirtualBox GUI.

Now prepare a config disk, which is an ISO representing a CD-ROM. It has to have a certain label and certain directory structure, and it contains the CoreOS cloud config file.

```bash
mkdir -p server-a.config/openstack/latest
cp cloud-config.yaml server-a.config/openstack/latest/user_data
hdiutil makehybrid -iso -joliet -default-volume-name config-2 -o server-a server-a.config
```

This will create `server-a.iso`. Now create a virtual machine in VirtualBox, for Linux 64-bit 2/3/4, and give it the server-a.vdi as its hard drive. Attach server-a.iso to the virtual CD drive. Start the machine and you should see it start up with CoreOS, with your hostname. You should be able to ssh into it with the private key corresponding to the public key you gave it.

The cloud-config processor puts the SSH key into `/home/core/.ssh/authorized_keys`, and the hostname into `/etc/hostname`, so you can detach the virtual CD-ROM from the system for subsequent boots. It is not needed again, unless it changes for some reason.

# Internals

The OEM disk is on /dev/sdX6, and is mounted at /usr/share/oem. You can put a grub.cfg file there to add kernel parameters, [like this](https://coreos.com/os/docs/latest/other-settings.html):

```
set linux_append="coreos-autologin"
```

which will autologin the console, for debugging purposes.

The root is on /dev/sdX9, and this is where all your state for the server is stored. It's fungible... you can delete everything and reboot, CoreOS will come up in factory fresh state.

For bare metal, your [cloud config file](https://coreos.com/os/docs/latest/cloud-config.html) is stored at /var/lib/coreos-install/user_data and will be processed from there. You can also use Ignition, need to try that next.

The CoreOS distribution is stored on /dev/sdX3 or 4? it is updated and then switched between partitions automatically. It contains the /usr directory which is mounted to /usr and /lib etc.

# Installing MongoDB on CoreOS

Add these lines to your `.bashrc`:

```bash
PATH=$PATH:/usr/local/bin/mongodb
export PATH
```

Use the script `get-mongodb.sh` in this repo to download and install versions of MongoDB.

Put the service file `mongod.service` into `/etc/systemd/system/` and `sudo systemctl daemon-reload` to enable it. Put `mongod.conf.yaml` into your home directory.

Now, you should be able to start and stop the `mongod` service using `systemctl`.
