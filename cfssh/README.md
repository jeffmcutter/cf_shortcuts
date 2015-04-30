# cfssh

Lacking pssh (Parallel SSH), this is a simple shell script to allow for running commands via SSH on multiple CloudForms appliances in an environment based on groups defined in hosts files.

SSH keys preferred.

Hosts files must be named cfhosts.groupname where groupname is a name for the group of hosts.  Usage provides the list of groups found based upon the files.  Entries in host files may be commented out using # at the beginning of the line.

Files can be placed into /root/bin and then cfssh will be in root's PATH.

Update cfhosts.* files with appropriate hostnames or IP addresses.

USAGE: cfssh group command args

Available groups:

all

no_db

ui

workers

-h | --help for this usage statement

# Example:

$ cfssh test uptime

*** cfme01 ***

 16:19:34 up  5:43,  0 users,  load average: 3.10, 3.06, 3.09

*** cfme02 ***

 16:19:47 up  1:15,  0 users,  load average: 0.16, 0.07, 0.01

*** cfme03 ***

 16:19:53 up  1:15,  0 users,  load average: 0.07, 0.15, 0.14

