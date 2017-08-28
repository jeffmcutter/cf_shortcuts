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
## cfssh
```

DESCRIPTION: ssh and run command with args

USAGE: cfssh [-g group] [-s] command args

DETAILS:

  -s to run serially

AVAILABLE GROUPS (default is all):

  all
  all_no_db
  db
  ui
  workers
  zone1
  zone2

To see matching hosts for a given group, use:

cfssh [-q] -g <group> list
  -q to suppress header

```
## cfscp
```

DESCRIPTION: push files out using scp

USAGE: cfscp [-g group] [-s] local_file remote_dest_dir

DETAILS:
 
  Only one file is supported at a time

  -s to run serially

AVAILABLE GROUPS (default is all):

  all
  all_no_db
  db
  ui
  workers
  zone1
  zone2

To see matching hosts for a given group, use:

cfscp [-q] -g <group> list
  -q to suppress header

```
## cfcollect
```

DESCRIPTION: pull files in using scp

USAGE: cfcollect [-g group] [-s] remote_file local_dest_dir

DETAILS:
 
  Wildcards are accepted for remote_file but should only match one file
 
  local_files are appended with remote hostname

  -s to run serially

AVAILABLE GROUPS (default is all):

  all
  all_no_db
  db
  ui
  workers
  zone1
  zone2

To see matching hosts for a given group, use:

cfcollect [-q] -g <group> list
  -q to suppress header

```
## cfgrep
```

DESCRIPTION: grep log_file for pattern and show last count number of lines

USAGE: cfgrep [-g group] [-s] [-a] [-c count] [-i] pattern [log_file]

DETAILS:

  -i is optional to ignore case with grep

  pattern may be specified as a regex suitable for egrep taking care to prevent the shell from interpretation
  pattern may be specified as 'nogrep' to have no grep or use cat instead of grep

  log_file is optional and defaults to automation.log
    For CloudForms logs, log_file can be in the format of evm or evm.log
    For any other files, use /the/full/path/to/file
 
  -c count is optional and used with tail to limit the output, default is 3
  To show all lines specify -c all

  -a can be used to also grep archived logs

  -s to run serially

AVAILABLE GROUPS (default is all):

  all
  all_no_db
  db
  ui
  workers
  zone1
  zone2

To see matching hosts for a given group, use:

cfgrep [-q] -g <group> list
  -q to suppress header

```
## cfgrep-collate
```

DESCRIPTION: grep log_file for pattern and collate all results and display using less

USAGE: cfgrep-collate [-g group] [-s] [-a] [-i] [-o outputfile] pattern [log_file]

DETAILS:

  -i is optional to ignore case with grep

  pattern may be specified as a regex suitable for egrep taking care to prevent the shell from interpretation
  pattern may be specified as 'nogrep' to have no grep or use cat instead of grep

  -o outputfile can be used to save output to outputfile

  log_file is optional and defaults to automation.log
    For CloudForms logs, log_file can be in the format of evm or evm.log
    For any other files, use /the/full/path/to/file

  -a can be used to also grep archived logs

  -s to run serially

AVAILABLE GROUPS (default is all):

  all
  all_no_db
  db
  ui
  workers
  zone1
  zone2

To see matching hosts for a given group, use:

cfgrep-collate [-q] -g <group> list
  -q to suppress header

```
## cfgrep-request
```

DESCRIPTION: grep log_file for request_id and all its associated tasks and collate all results and display with less

USAGE: cfgrep-request [-g group] [-s] [-a] [-o outputfile] request_id [log_file]

DETAILS:

  commas in request_id will automatically be stripped

  -o outputfile can be used to save output to outputfile

  log_file is optional and defaults to automation.log
    For CloudForms logs, log_file can be in the format of evm or evm.log
    For any other files, use /the/full/path/to/file

  -a can be used to also grep archived logs

  -s to run serially

AVAILABLE GROUPS (default is all):

  all
  all_no_db
  db
  ui
  workers
  zone1
  zone2

To see matching hosts for a given group, use:

cfgrep-request [-q] -g <group> list
  -q to suppress header

```
## cftail
```

DESCRIPTION: multitail and optionally grep pattern

USAGE: cftail [-g group] [-s] [-i] [-l] pattern [log_file]

DETAILS:

  -i is optional to ignore case with grep

  pattern may be specified as a regex suitable for egrep taking care to prevent the shell from interpretation
  pattern may be specified as 'nogrep' to have no grep or use cat instead of grep

  log_file is optional and defaults to automation.log
    For CloudForms logs, log_file can be in the format of evm or evm.log
    For any other files, use /the/full/path/to/file

  -l can be used to place output in separate window panes, by default output is merged

  In multitail:
    Move around the buffer similar to less by pressing 'b'
    Exit whatever context you are in by pressing 'q'

  -s to run serially

AVAILABLE GROUPS (default is all):

  all
  all_no_db
  db
  ui
  workers
  zone1
  zone2

To see matching hosts for a given group, use:

cftail [-q] -g <group> list
  -q to suppress header

```
## cftail-request
```

DESCRIPTION: multitail and grep request_id and all its associated tasks

USAGE: cftail-request [-g group] [-s] [-l] request_id [log_file]

DETAILS:

  commas in request_id will automatically be stripped

  log_file is optional and defaults to automation.log
    For CloudForms logs, log_file can be in the format of evm or evm.log
    For any other files, use /the/full/path/to/file

  -l can be used to place output in separate window panes, by default output is merged

  In multitail:
    Move around the buffer similar to less by pressing 'b'
    Exit whatever context you are in by pressing 'q'

  -s to run serially

AVAILABLE GROUPS (default is all):

  all
  all_no_db
  db
  ui
  workers
  zone1
  zone2

To see matching hosts for a given group, use:

cftail-request [-q] -g <group> list
  -q to suppress header

```


# Examples:
## cfssh
```
$ cfssh all uptime

*** cfme01 ***
 16:19:34 up  5:43,  0 users,  load average: 3.10, 3.06, 3.09

*** cfme02 ***
 16:19:47 up  1:15,  0 users,  load average: 0.16, 0.07, 0.01

*** cfme03 ***
 16:19:53 up  1:15,  0 users,  load average: 0.07, 0.15, 0.14
```
## cfscp
```
$ cfscp all README.md /tmp/

*** cfme01 ***
README.md                                               100% 1020     1.0KB/s   00:00    

*** cfme02 ***
README.md                                               100% 1020     1.0KB/s   00:00    
```
## cfcollect
```
$ cfcollect all /etc/hostname /tmp/

*** cfme1 ***
hostname                                                100%   22    39.2KB/s   00:00    

*** cfme2 ***
hostname                                                100%    6     9.0KB/s   00:00    

*** cfme3 ***
hostname                                                100%    6     9.5KB/s   00:00    

$ ls /tmp/*hostname*
/tmp/hostname-cfme1  /tmp/hostname-cfme2  /tmp/hostname-cfme3
```
## cfgrep
```

$ cfgrep test ERROR evm  1

*** cfme30 ***
[----] E, [2017-04-05T20:52:33.973282 #1660:89114c] ERROR -- : /opt/rh/cfme-gemset/gems/awesome_spawn-1.4.1/lib/awesome_spawn.rb:105:in `run!'

```
## cfgrep-collate
```
$ cfgrep-collate all "MiqEventHandler#log_status" evm

*** cfme1 ***

*** cfme2 ***

*** cfme3 ***

*** collating results ***

[cfme1] [----] I, [2017-08-11T19:06:20.698103 #2949:b81140]  INFO -- : Q-task_id([log_status]) MIQ(MiqEventHandler#log_status) [Event Handler] Worker ID [1000000001071], PID [2922], GUID [c0f9c28a-7ed6-11e7-8b18-525400431635], Last Heartbeat [2017-08-11 23:06:19 UTC], Process Info: Memory Usage [310091776], Memory Size [652206080], Proportional Set Size: [203949000], Memory % [3.01], CPU Time [735.0], CPU % [0.09], Priority [27]
[cfme2] [----] I, [2017-08-11T19:06:25.187956 #2765:623130]  INFO -- : Q-task_id([log_status]) MIQ(MiqEventHandler#log_status) [Event Handler] Worker ID [1000000002270], PID [2756], GUID [f99103f2-7eda-11e7-a70f-5254003dad57], Last Heartbeat [2017-08-11 23:06:14 UTC], Process Info: Memory Usage [338751488], Memory Size [672755712], Proportional Set Size: [235704000], Memory % [3.28], CPU Time [726.0], CPU % [0.11], Priority [27]
[cfme1] [----] I, [2017-08-11T19:11:22.361405 #2949:b81140]  INFO -- : Q-task_id([log_status]) MIQ(MiqEventHandler#log_status) [Event Handler] Worker ID [1000000001071], PID [2922], GUID [c0f9c28a-7ed6-11e7-8b18-525400431635], Last Heartbeat [2017-08-11 23:11:14 UTC], Process Info: Memory Usage [310091776], Memory Size [652206080], Proportional Set Size: [203977000], Memory % [3.01], CPU Time [785.0], CPU % [0.09], Priority [27]
[cfme2] [----] I, [2017-08-11T19:11:24.019597 #2765:623130]  INFO -- : Q-task_id([log_status]) MIQ(MiqEventHandler#log_status) [Event Handler] Worker ID [1000000002270], PID [2756], GUID [f99103f2-7eda-11e7-a70f-5254003dad57], Last Heartbeat [2017-08-11 23:11:21 UTC], Process Info: Memory Usage [338751488], Memory Size [672755712], Proportional Set Size: [235704000], Memory % [3.28], CPU Time [774.0], CPU % [0.12], Priority [27]
```
## cfgrep-request
```
$ cfgrep-request all 1,000,000,000,088

*** looking for tasks associated with request_id: 1000000000088 ***

*** looking for request_id: 1000000000088 and task_ids: 1000000000088 ***

*** cfme1 ***

*** cfme2 ***

*** cfme3 ***

*** collating results ***

[cfme2] [----] I, [2017-08-11T19:30:25.616820 #2773:3e3f758]  INFO -- : Q-task_id([service_template_provision_task_1000000000087]) Instantiating [/System/Process/REQUEST?MiqProvisionRequest%3A%3Amiq_provision_request=1000000000088&MiqRequest%3A%3Amiq_request=1000000000088&MiqServer%3A%3Amiq_server=1000000000001&User%3A%3Auser=1000000000001&message=get_vmname&object_name=REQUEST&request=UI_PROVISION_INFO&vmdb_object_type=miq_provision_request]
[cfme2] [----] I, [2017-08-11T19:30:25.664169 #2773:3e3f758]  INFO -- : Q-task_id([service_template_provision_task_1000000000087]) Updated namespace [/System/Process/REQUEST?MiqProvisionRequest%3A%3Amiq_provision_request=1000000000088&MiqRequest%3A%3Amiq_request=1000000000088&MiqServer%3A%3Amiq_server=1000000000001&User%3A%3Auser=1000000000001&message=get_vmname&object_name=REQUEST&request=UI_PROVISION_INFO&vmdb_object_type=miq_provision_request  ManageIQ/System]
...
```
## cftail
```
$ cftail all "ERROR|WARN" evm

Running: multitail -L "ssh cfme1 tail -f /var/www/miq/vmdb/log/evm.log \| egrep \"ERROR\|WARN\" | sed -e 's/^/[cfme1] /'" -L "ssh cfme2 tail -f /var/www/miq/vmdb/log/evm.log \| egrep \"ERROR\|WARN\" | sed -e 's/^/[cfme2] /'" -L "ssh cfme3 tail -f /var/www/miq/vmdb/log/evm.log \| egrep \"ERROR\|WARN\" | sed -e 's/^/[cfme3] /'"

[cfme1] [----] E, [2017-08-11T18:22:56.974519 #2939:b81140] ERROR -- : <RHEVM> Ovirt::Service#resource_get: class = Errno::EHOSTUNREACH, message=Failed to open TCP connection to rhvm1.hemlockhill.org:443 (No route to host - connect(2) for "rhvm1.hemlockhill.org" port 443), URI=https://rhvm1.hemlockhill.org/ovirt-engine/api
[cfme1] [----] W, [2017-08-11T18:22:56.975316 #2939:b81140]  WARN -- : MIQ(ManageIQ::Providers::Redhat::InfraManager#verify_credentials_for_rhevm) Failed to open TCP connection to rhvm1.hemlockhill.org:443 (No route to host - connect(2) for "rhvm1.hemlockhill.org" port 443)
[cfme1] [----] W, [2017-08-11T18:22:56.975570 #2939:b81140]  WARN -- : MIQ(ManageIQ::Providers::Redhat::InfraManager#authentication_check_no_validation) type: [:default] for [1000000000002] [rhvm1] Validation failed: unreachable, Failed to open TCP connection to rhvm1.hemlockhill.org:443 (No route to host - connect(2) for "rhvm1.hemlockhill.org" port 443)
[cfme1] [----] W, [2017-08-11T18:22:56.976243 #2939:b81140]  WARN -- : MIQ(AuthUseridPassword#validation_failed) [ExtManagementSystem] [1000000000002], previously valid on: 2017-04-19 04:48:07 UTC, previous status: [Unreachable]
[cfme1] [----] W, [2017-08-11T18:22:56.981000 #2931:b81140]  WARN -- : MIQ(ManageIQ::Providers::Vmware::InfraManager#verify_credentials) #<Errno::EHOSTUNREACH: No route to host - connect(2) for "vcenter1.hemlockhill.org" port 443 (vcenter1.hemlockhill.org:443)>
[cfme1] [----] W, [2017-08-11T18:22:56.981450 #2931:b81140]  WARN -- : MIQ(ManageIQ::Providers::Vmware::InfraManager#authentication_check_no_validation) type: ["default"] for [1000000000001] [vcenter1] Validation failed: unreachable, No route to host - connect(2) for "vcenter1.hemlockhill.org" port 443 (vcenter1.hemlockhill.org:443)
[cfme1] [----] W, [2017-08-11T18:22:56.982164 #2931:b81140]  WARN -- : MIQ(AuthUseridPassword#validation_failed) [ExtManagementSystem] [1000000000001], previously valid on: 2017-04-19 04:59:44 UTC, previous status: [Unreachable]
[cfme2] [----] W, [2017-08-11T18:36:44.479653 #2738:623130]  WARN -- : MIQ(ManageIQ::Providers::Foreman::ConfigurationManager::RefreshParser#configuration_profile_inv_to_hashes) hostgroup cloudforms missing: location
[cfme2] [----] W, [2017-08-11T18:36:44.479934 #2738:623130]  WARN -- : MIQ(ManageIQ::Providers::Foreman::ConfigurationManager::RefreshParser#configuration_profile_inv_to_hashes) hostgroup openstack missing: location

```
## cftail-request
```
$ cftail-request all 1,000,000,000,088

*** looking for tasks associated with request_id: 1000000000088 ***

*** looking for request_id: 1000000000088 and task_ids: 1000000000088 ***

Running: multitail -L "ssh cfme1 tail -f /var/www/miq/vmdb/log/automation.log \| egrep \"1000000000088\|1000000000088\" | sed -e 's/^/[cfme1] /'" -L "ssh cfme2 tail -f /var/www/miq/vmdb/log/automation.log \| egrep \"1000000000088\|1000000000088\" | sed -e 's/^/[cfme2] /'" -L "ssh cfme3 tail -f /var/www/miq/vmdb/log/automation.log \| egrep \"1000000000088\|1000000000088\" | sed -e 's/^/[cfme3] /'"

[cfme2] [----] I, [2017-08-11T19:31:06.042900 #2765:623130]  INFO -- : Q-task_id([miq_provision_request_1000000000088]) Followed  Relationship [miqaedb:/infrastructure/VM/Provisioning/Profile/EvmGroup-super_administrator#get_vmname]
[cfme2] [----] I, [2017-08-11T19:31:06.043258 #2765:623130]  INFO -- : Q-task_id([miq_provision_request_1000000000088]) Followed  Relationship [miqaedb:/System/Request/UI_PROVISION_INFO#create]
[cfme2] [----] I, [2017-08-11T19:31:09.194610 #2773:623130]  INFO -- : Q-task_id([miq_provision_1000000000088]) Instantiating [/System/Process/AUTOMATION?MiqProvision%3A%3Amiq_provision=1000000000088&MiqServer%3A%3Amiq_server=1000000000001&User%3A%3Auser=1000000000001&object_name=AUTOMATION&request=vm_provision&vmdb_object_type=miq_provision]

```
# Sample cfhosts file:

```
# This file is a sample.  See cfhosts-gen script to generate this file by querying the VMDB.
#
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
