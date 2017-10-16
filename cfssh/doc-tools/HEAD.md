# cfssh cfscp cfcollect cfgrep and cftail utilities

These tools allow for running commands and copying files and searching log files against multiple CloudForms appliances in an environment based on groups defined in hosts files.

Also, even if you do have pssh or other tools for running commands on multiple systems, the new cfgrep, cfgrep-collate, cfgrep-request, cftail, and cftail-request are probably worth a look.

Different transport mechanisms are now supported and can be selected by updating the .config file.  By default, Ansible is used since it can work in parallel and is included by default on a CloudForms appliance.  Alternatively, if installed and selected, Parallel SSH can be used and is faster opening connections than Ansible.

**Note that this program can enable you to do things faster, including mistakes, use at your own risk.**

# Command Descriptions:

cfssh (SSH to each host in group and run provided commands)

cfscp (SCP file TO each host in group)

cfcollect (SCP file FROM each host in group)

cfgrep (SSH to each host in group and grep log_file for pattern limited by tail)

cfgrep-collate (SSH to each host in group and grep log_file for pattern and collate results)

cfgrep-request (Look up tasks associated with request_id and SSH to each host in group and grep log_file for request_id and task_ids and collate results)

cftail (Use multitail to tail log_file and optionally grep for pattern)

cftail-request (Look up tasks associated with request_id and use multitail to tail the log_file looking for them)

# Installation:
Recommended installation as root on the VMDB appliance.
```
ssh root@cfme01
cd
yum -y install git
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

**-request commands can only be run from a ManageIQ/CloudForms appliance in the region in question.*


# Usages:
