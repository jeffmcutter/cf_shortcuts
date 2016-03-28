# .bashrc
#
# Author: Kevin Morey <kmorey@redhat.com>
# License: GPL v3
#
# Updates and mods by <jcutter@redhat.com>
#
# Description: /root/.bashrc to setup CloudForms aliases on the appliance. 
#

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

VMDB=/var/www/miq/vmdb

# Set to false on non-dev environments to prevent accidentally clearing log files.
DEV=true

# User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep --color'

# Directory aliases
alias vmdb='cd $VMDB'
alias lib='cd /var/www/miq/lib'
alias log='cd $VMDB/log'

# Tail aliases
alias auto='tail -f $VMDB/log/automation.log'
alias evm='tail -f $VMDB/log/evm.log'
alias aws='tail -f $VMDB/log/aws.log'
alias foglog='tail -f $VMDB/log/fog.log'
alias rhevm='tail -f $VMDB/log/rhevm.log'
alias prod='tail -f $VMDB/log/production.log'
alias policy='tail -f $VMDB/log/policy.log'
alias pglog='tail -f /opt/rh/postgresql92/root/var/lib/pgsql/data/pg_log/postgresql.log'

# Less aliases
alias lauto='less +F $VMDB/log/automation.log'
alias levm='less +F $VMDB/log/evm.log'
alias laws='less +F $VMDB/log/aws.log'
alias lfoglog='less +F $VMDB/log/fog.log'
alias lrhevm='less +F $VMDB/log/rhevm.log'
alias lprod='less +F $VMDB/log/production.log'
alias lpolicy='less +F $VMDB/log/policy.log'
alias lpglog='less +F /opt/rh/postgresql92/root/var/lib/pgsql/data/pg_log/postgresql.log'

if [ "$DEV" == "true" ]
then

  # Clean logging aliases
  alias clean="echo Cleaned: `date` > $VMDB/log/automation.log;echo Cleaned: `date` > $VMDB/log/evm.log;echo Cleaned: `date` > $VMDB/log/production.log;echo;echo;echo;echo;echo;echo Logs cleaned...;echo"
  alias clean_evm="echo Cleaned: `date` > $VMDB/log/evm.log"
  alias clean_aws="echo Cleaned: `date` > $VMDB/log/aws.log"
  alias clean_rhevm="echo Cleaned: `date` > $VMDB/log/rhevm.log"
  alias clean_fog="echo Cleaned: `date` > $VMDB/log/fog.log"
  alias clean_auto="echo Cleaned: `date` > $VMDB/log/automation.log"
  alias clean_prod="echo Cleaned: `date` > $VMDB/log/production.log"
  alias clean_policy="echo Cleaned: `date` > $VMDB/log/policy.log"
  alias clean_pgsql="echo Cleaned: `date` > /opt/rh/postgresql92/root/var/lib/pgsql/data/pg_log/postgresql.log"

fi

# Black Console
alias black_console="LOCK_CONSOLE=false /bin/appliance_console"

# Rails Console
#alias railsc="cd $VMDB;echo '\$evm = MiqAeMethodService::MiqAeService.new(MiqAeEngine::MiqAeWorkspaceRuntime.new)'; script/rails c"
alias railsc="pushd $VMDB && bin/rails c && popd"

# kill provision job.
function kill_prov {
  vmdb
  script/rails r tools/kill_provision.rb $1
  cd - > /dev/null 2>&1
}


# Application Status
#alias status='echo "EVM Status:";service evmserverd status;echo " ";echo "HTTP Status:";service httpd status'
alias status='pushd $VMDB && rake evm:status && popd'

# Ignore duplicate history commands
export HISTCONTROL=ignoredups

# Omit if not to your tastes.
set -o vi
