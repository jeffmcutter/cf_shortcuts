# cfssh

Lacking pssh (Parallel SSH), this is a simple shell script to allow for running commands via SSH and copying files with SCP against multiple CloudForms appliances in an environment based on groups defined in hosts files.

SSH keys preferred.

cfssh (SSH to each host in group)

cfscp (SCP file TO each host in group)

cfcollect (SCP file FROM each host in group)

cfgrep (SSH to each host in group and grep log_file for pattern limited by tail)

cfgrep-collate (SSH to each host in group and grep log_file for pattern and collate results)

cfgrep-request (look up tasks associated with request_id and SSH to each host in group and grep log_file for request_id and task_ids and collate results)

**Note that this program can enable you to do things faster, including mistakes, use at your own risk.**

Files can be placed into /root/bin and then cfssh will be in root's PATH.

Update cfhosts file with appropriate hostnames or IP addresses and group assignments.

# Usages:

```
USAGE: cfssh group command args

	Available groups:
	all
	all_no_db
	db
	ui
	workers
	zone1
	zone2

USAGE: cfscp group local_file remote_dest_dir

USAGE: cfcollect group remote_file local_dest_dir

USAGE: cfgrep [-i] group pattern log_file [count]

  For CloudForms logs, log_file can be in the format of evm or evm.log
  For any other files to grep, use /the/full/path/to/file
  -i is optional to ignore case with grep
  count is optional and used with tail to limit the output, default is 3

USAGE: cfgrep-collate [-i] group pattern log_file [count]

  For CloudForms logs, log_file can be in the format of evm or evm.log
  For any other files to grep, use /the/full/path/to/file
  -i is optional to ignore case with grep
  count is optional with cfgrep only and used with tail to limit the output, default is 3

USAGE: cfgrep-request [-i] group request_id [log_file]

  Will grep and collate CloudForms logs for a request_id and all its associated tasks
  log_file is optional and defaults to automation.log

To see matching hosts for a given group, use:

cfgrep <group> list

-h | --help for this usage statement.


To see matching hosts for a given group, use:

cfscp <group> list

-h | --help for this usage statement
```

# Examples:

```
$ cfssh all uptime

*** cfme01 ***
 16:19:34 up  5:43,  0 users,  load average: 3.10, 3.06, 3.09

*** cfme02 ***
 16:19:47 up  1:15,  0 users,  load average: 0.16, 0.07, 0.01

*** cfme03 ***
 16:19:53 up  1:15,  0 users,  load average: 0.07, 0.15, 0.14

$ cfscp all README.md /tmp/

*** cfme01 ***
README.md                                               100% 1020     1.0KB/s   00:00    

*** cfme02 ***
README.md                                               100% 1020     1.0KB/s   00:00    


$ cfcollect all /tmp/README.md /tmp/

*** cfme01 ***
README.md                                               100% 1020     1.0KB/s   00:00    

*** cfme02 ***
README.md                                               100% 1020     1.0KB/s   00:00    

$ ls /tmp/README*
/tmp/README.md-cfme01  /tmp/README.md-pxe01

$ cfgrep test ERROR evm  1

*** cfme30 ***
[----] E, [2017-04-05T20:52:33.973282 #1660:89114c] ERROR -- : /opt/rh/cfme-gemset/gems/awesome_spawn-1.4.1/lib/awesome_spawn.rb:105:in `run!'

```


# Sample cfhosts file:

```
# hostname_or_ip  <white space>	groups to assign host to separated by commas.
#
# Lines starting with a # are ignored.
#
cfmedb01.example.com		db
cfmeui01.example.com		ui
cfmewrk01.example.com		workers,zone1
cfmewrk02.example.com		workers,zone1
cfmewrk03.example.com		workers,zone2
cfmewrk04.example.com		workers,zone2
```
