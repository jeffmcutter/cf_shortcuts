# cfssh cfscp cfcollect cfgrep and cftail utilities

This is a simple tool to allow for running commands via SSH and copying files with SCP against multiple CloudForms appliances in an environment based on groups defined in hosts files.

Also, even if you do have pssh or other tools for running commands on multiple systems, the new cfgrep, cfgrep-collate, cfgrep-request, cftail, and cftail-request are probably worth a look.

All these tools now make use of pssh (Parallel SSH) if installed to speed up execution by running ssh, scp, etc. sessions in parallel.

cfssh (SSH to each host in group and run provided commands)

cfscp (SCP file TO each host in group)

cfcollect (SCP file FROM each host in group)

cfgrep (SSH to each host in group and grep log_file for pattern limited by tail)

cfgrep-collate (SSH to each host in group and grep log_file for pattern and collate results)

cfgrep-request (Look up tasks associated with request_id and SSH to each host in group and grep log_file for request_id and task_ids and collate results)

cftail (Use multitail to tail log_file and optionally grep for pattern)

cftail-request (Look up tasks associated with request_id and use multitail to tail the log_file looking for them)

**Note that this program can enable you to do things faster, including mistakes, use at your own risk.**

Recommended installation as root on the VMDB appliance:
```
cd
git clone https://github.com/jeffmcutter/cf_shortcuts.git
ln -s cf_shortcuts/cfssh
```
Add $HOME/cfssh to your PATH in .bash_profile.

Update cfhosts file with appropriate hostnames or IP addresses and group assignments.

SSH keys preferred.

*cftail\* commands require multitail be installed and in the PATH.*

You can get multitail and pssh from EPEL (https://fedoraproject.org/wiki/EPEL).

**-request commands can only be run from a ManageIQ/CloudForms appliance in the region in question.*


# Usages:
