#!/bin/bash
pname=$(basename "$0")

source ./trapwrapper.sh
source ./basictests.sh
declare -i nerr=0

signals1='EXIT 1 2 3'
signals2='15 ERR'

echo -------- $0 --------

echo -- test of open-1
trap-open t1 $signals1
echo -n 'test 1 ... '
is_simple_variable t1_signals && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 2 ... '
is_set t1_cmds && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 3 ... '
is_associative_array t1_cmds && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 4 ... '
test "$t1_signals" = "$signals1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 5 ... '
test "${#t1_cmds[*]}" -eq 0 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}

echo -- test of open-2
trap-open t2 $signals2
echo -n 'test 6 ... '
is_simple_variable t2_signals && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 7 ... '
is_set t2_cmds && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 8 ... '
is_associative_array t2_cmds && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 9 ... '
test "$t2_signals" = "$signals2" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 10 ... '
test "${#t2_cmds[*]}" -eq 0 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}

echo -- test of add-1
trap-addcmd t1 'cmd11'
echo -n 'test 11 ... '
test "${#t1_cmds[*]}" -eq 1 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 12 ... '
test "${t1_cmds['cmd11']}" = 1 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}

echo -- test of add-2
trap-addcmd t2 'cmd21;cmd22'
echo -n 'test 13 ... '
test "${#t2_cmds[*]}" -eq 1 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 14 ... '
test "${t2_cmds['cmd21;cmd22']}" = 1 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}

echo -- test of add-3
trap-addcmd t1 'cmd12'
echo -n 'test 21 ... '
test "${#t1_cmds[*]}" -eq 2 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 22 ... '
test "${t1_cmds['cmd11']}" = 1 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 23 ... '
test "${t1_cmds['cmd12']}" = 1 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}

echo -- test of add-4
trap-addcmd t2 'cmd23'
echo -n 'test 24 ... '
test "${#t2_cmds[*]}" -eq 2 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 25 ... '
test "${t2_cmds['cmd21;cmd22']}" = 1 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 26 ... '
test "${t2_cmds['cmd23']}" = 1 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}

echo -- test of remove-1
trap-removecmd t1 'cmd11'
echo -n 'test 31 ... '
test "${#t1_cmds[*]}" -eq 1 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 32 ... '
test "${t1_cmds['cmd11']}" = '' && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 33 ... '
test "${t1_cmds['cmd12']}" = 1 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}

echo -- test of remove-2
trap-removecmd t2 'cmd21;cmd22'
echo -n 'test 34 ... '
test "${#t2_cmds[*]}" -eq 1 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 35 ... '
test "${t2_cmds['cmd21;cmd22']}" = '' && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 36 ... '
test "${t2_cmds['cmd23']}" = 1 && echo 'Success.' || { echo 'Fail.'; $((nerr++));}

echo -- test of calltrap-1
trap '' $signals1
trap '' $signals2
traptest() {
  targetsignal=$1
  targetcmds="$2"
  file="$3"
  signalmatch=0
  cmdsmatch=0
  fgrep "$targetsignal" "$file" | while read name opt cmds signal; do
    test "$signal" = "$targetsignal" && {
      test $((++signalmatch)) -ge 2 && return 1
      test "$cmds" = "$targetcmds" && cmdsmatch=1
    }
  done
  return $cmdsmatch
}
tmp1="$(mktemp $pname.XXXXXXXX)"

trap-calltrap t1
trap -p >"$tmp1"
echo -n 'test 41 ... '
traptest EXIT "'cmd12'" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 42 ... '
traptest SIGHUP "'cmd12'" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 43 ... '
traptest SIGINT "'cmd12'" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 44 ... '
traptest SIGQUIT "'cmd12'" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 45 ... '
traptest SIGTERM "''" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 46 ... '
traptest ERR "''" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}

echo -- test of calltrap-2
trap-calltrap t2
trap -p >"$tmp1"
echo -n 'test 51 ... '
traptest EXIT "'cmd12'" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 52 ... '
traptest SIGHUP "'cmd12'" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 53 ... '
traptest SIGINT "'cmd12'" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 54 ... '
traptest SIGQUIT "'cmd12'" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 55 ... '
traptest SIGTERM "'cmd23'" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 56 ... '
traptest ERR "'cmd23'" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}

echo -- test of close-1
trap-close t1
trap -p >"$tmp1"
echo -n 'test 61 ... '
traptest EXIT "''" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 62 ... '
traptest SIGHUP "''" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 63 ... '
traptest SIGINT "''" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 64 ... '
traptest SIGQUIT "''" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 65 ... '
traptest SIGTERM "'cmd23'" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 66 ... '
traptest ERR "'cmd23'" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 67 ... '
is_unset t1_cmds && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 68 ... '
is_unset t1_signals && echo 'Success.' || { echo 'Fail.'; $((nerr++));}

echo -- test of close-2
trap-close t2
echo -n 'test 71 ... '
traptest EXIT "''" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 72 ... '
traptest SIGHUP "''" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 73 ... '
traptest SIGINT "''" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 74 ... '
traptest SIGQUIT "''" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 75 ... '
traptest SIGTERM "''" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 76 ... '
traptest ERR "''" "$tmp1" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 77 ... '
is_unset t2_cmds && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
echo -n 'test 78 ... '
is_unset t2_signals && echo 'Success.' || { echo 'Fail.'; $((nerr++));}

rm -f "$tmp1"
trap - $signals1
trap - $signals2

if [ $nerr -eq 0 ]; then
  echo 'All test succeeded.'
  exit 0
else
  echo "$nerr error occured."
  exit 1
fi
