# cfme_kvm_deploy

A bash script and supporting files to enable quick deployment of CFME appliances into KVM.

Does the following:

* Copies the specified cfme-rhos image to /var/lib/libvirt/images and creates the VM.
* Adds a second disk to the VM for the VMDB.
* Configures eth0 in the appliance using results from getent hosts for the determined host name and the ifcfg-eth0 workdir file.
* Adds ssh public key to authorized_keys for root on the appliance from the workdir file.
* Adds environment files .bashrc .irbrc .inputrc and .vimrc from the workdir files.
* Removes old ssh host key for this host name.
* Configures local VMDB database and starts application.

NOTE: This script expects to be able to find the derived hostname via getent hosts, set that up first.  I put a bunch of cfme## entries into my /etc/hosts file for this, but you could do anything getent hosts can find.
