# cfssh cfscp cfcollect cfgrep and cftail utilities

These tools allow for running commands and copying files and searching log files against multiple CloudForms appliances in an environment based on groups defined in hosts files.

Also, even if you do have pssh or other tools for running commands on multiple systems, the new cfgrep, cfgrep -r, cftail, and cftail -r are worth a look.

Different transport mechanisms are now supported and can be selected by updating the .config file.  By default, Ansible is used since it can work in parallel and is included by default on a CloudForms appliance.  Alternatively, if installed and selected, Parallel SSH can be used and is faster opening connections than Ansible.

**Note that this program can enable you to do things faster, including mistakes, use at your own risk.**

# Command Descriptions:

cfssh (connect to each host in group and run provided commands)

cfscp (copy file TO each host in group)

cfcollect (copy file FROM each host in group)

cfgrep (connect to each host in group and grep log_file for pattern or request_id and associated task_ids and collate all results and display using less)

cftail (Use multitail to tail log_file and optionally grep for pattern or request_id and associated task_ids)

cfstatus (run rake evm:status on each host in group)

cfworkermemcheck (search for memory exceeded messages in automation.log)

# Installation:
Recommended installation as root on the VMDB appliance.
```
ssh root@cfme01
cd
git clone https://github.com/jeffmcutter/cf_shortcuts.git
ln -s cf_shortcuts/cfssh
mkdir bin
ln -s cf_shortcuts/check_ui bin/
echo 'export PATH=$PATH:$HOME/cfssh' >> .bash_profile
. .bash_profile
cfhosts-gen | tee cfssh/cfhosts
# Generate an SSH key if one doesn't already exist.
ssh-keygen
# Accept SSH host keys and copy out public key.
cf-ssh-copy-id
```
Update cfhosts file with appropriate group assignments as desired.

*cftail\* commands require multitail be installed and in the PATH.*

You can get multitail and pssh from EPEL (https://fedoraproject.org/wiki/EPEL).

**-r option can only be used from a ManageIQ/CloudForms VMDB appliance in the region in question.*


# Usages: