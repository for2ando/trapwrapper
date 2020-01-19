# trapwrapper.sh: a bash function library wrapping bash "trap" command.

trap-open() {
  prefix="$1"
  shift
  eval ${prefix}_signals='"$*"'
  eval declare -g -A ${prefix}_cmds='()'
  # Only keys of the ${prefix}_cmds associative array are used. The values are no meaing.
}

trap-close() {
  prefix="$1"
  shift
  eval unset ${prefix}_signals ${prefix}_cmds
}

trap-addcmd() {
  prefix="$1"
  shift
  eval ${prefix}_cmds[$1]=1

}

trap-removecmd() {
  prefix="$1"
  shift
  eval unset ${prefix}_cmds["'$1'"]
}

trap-calltrap() {
  prefix="$1"
  shift
  IFS_BACKUP="$IFS"
  IFS=';'
  eval set \${${prefix}_signals}
  eval trap \${\!${prefix}_cmds[*]} "$@"
  IFS="$IFS_BACKUP"
}
