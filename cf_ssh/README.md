# cf_ssh

Lacking pssh (Parallel SSH), this is a simple shell script to allow for running commands via SSH on multiple CloudForms appliances in an environment based on groups defined in hosts files.

SSH keys preferred.

Hosts files must be named cf_hosts.groupname where groupname is a name for the group of hosts.  Usage provides the list of groups found based upon the files.  Entries in host files may be commented out using # at the beginning of the line.

USAGE: cf_ssh group command args

Available groups:
all
no_db
ui
workers

-h | --help for this usage statement

