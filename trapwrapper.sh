# trapwrapper.sh: a bash function library wrapping bash "trap" command.

# Usage: trap-open TrapName Signal [Signal ...]
# Make a TRAP named '$prefix', and trigger signals are set for its TRAP.
# Commands to be executed on occuring the signals (handler) are not yet
# registered.
trap-open() {
  prefix="$1"
  shift
  eval ${prefix}_signals='"$*"'
  eval declare -g -A ${prefix}_cmds='()'
  # Only keys of the ${prefix}_cmds associative array are used. 
  # The values are no meaning.
}

# Usage: trap-close TrapName
# Dispose a TRAP named '$prefix'.
# The commands to be executed on occuring signals (handler) are cleared,
# and the correspondent variables are unset.
trap-close() {
  prefix="$1"
  shift
  eval set \${${prefix}_signals}    # variable contents are set as $1 $2 ...
  eval trap - "$@"
  eval unset ${prefix}_signals ${prefix}_cmds
}

# Usage: trap-addcmd TrapName HandlerCommand
# For a TRAP named 'prefix', register commands to be executed on occuring
# the signals (handler). But the registered handler is not yet enable
# (enabling it later by using trap-calltrap command.).
trap-addcmd() {
  prefix="$1"
  shift
  eval ${prefix}_cmds[$1]=1
}

# Usage: trap-removecmd TrapName HandlerCommand
# For a TRAP named 'prefix', unregister commands to be executed on occuring
# the signals (handler).
trap-removecmd() {
  prefix="$1"
  shift
  eval unset ${prefix}_cmds["'$1'"]
}

# Usage: trap-calltrap TrapName 
# Enable the registered handler for the signals.
trap-calltrap() {
  prefix="$1"
  shift
  IFS_BACKUP="$IFS"
  IFS=';'
  eval set \${${prefix}_signals}    # variable contents are set as $1 $2 ...
  eval trap "\"\${!${prefix}_cmds[*]}\"" "$@"
  IFS="$IFS_BACKUP"
}
