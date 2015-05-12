# cfssh

Lacking pssh (Parallel SSH), this is a simple shell script to allow for running commands via SSH and copying files with SCP against multiple CloudForms appliances in an environment based on groups defined in hosts files.

SSH keys preferred.

cfssh (SSH to each host in group)

cfscp (SCP file TO each host in group)

cfcollect (SCP file FROM each host in group)

Note that this program can enable you to do things faster, including mistakes, use at your own risk.

Hosts files must be named cfhosts.groupname where groupname is a name for the group of hosts.  Usage provides the list of groups found based upon the files.  Entries in host files may be commented out using # at the beginning of the line.

Files can be placed into /root/bin and then cfssh will be in root's PATH.

Update cfhosts.* files with appropriate hostnames or IP addresses.

# Usages:

USAGE: cfssh group command args

USAGE: cfscp group local_file remote_dest_dir

USAGE: cfcollect group remote_file local_dest_dir

Available groups:

all

no_db

ui

workers

-h | --help for this usage statement



# Examples:

$ cfssh test uptime

*** cfme01 ***

 16:19:34 up  5:43,  0 users,  load average: 3.10, 3.06, 3.09

*** cfme02 ***

 16:19:47 up  1:15,  0 users,  load average: 0.16, 0.07, 0.01

*** cfme03 ***

 16:19:53 up  1:15,  0 users,  load average: 0.07, 0.15, 0.14


$ cfscp test README.md /tmp/

*** cfme01 ***

README.md                                               100% 1020     1.0KB/s   00:00    

*** pxe01 ***

README.md                                               100% 1020     1.0KB/s   00:00    


$ cfcollect test /tmp/README.md /tmp/

*** cfme01 ***

README.md                                               100% 1020     1.0KB/s   00:00    

*** pxe01 ***

README.md                                               100% 1020     1.0KB/s   00:00    

$ ls /tmp/README*

/tmp/README.md-cfme01  /tmp/README.md-pxe01


