#!/bin/bash

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
trap-calltrap t1
trap -p | {
  while read arg1 arg2 arg3 arg4; do
    case "$arg4" in
    EXIT) #0
      echo -n 'test 41 ... '
      test "$arg3" = "'cmd12'" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
      ;;
    SIGHUP) #1
      echo -n 'test 42 ... '
      test "$arg3" = "'cmd12'" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
      ;;
    SIGINT) #2
      echo -n 'test 43 ... '
      test "$arg3" = "'cmd12'" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
      ;;
    SIGQUIT) #3
      echo -n 'test 44 ... '
      test "$arg3" = "'cmd12'" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
      ;;
    SIGTERM) #15
      echo -n 'test 45 ... '
      test "$arg3" = "''" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
      ;;
    ERR) #ERR
      echo -n 'test 46 ... '
      test "$arg3" = "''" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
      ;;
    *)
      ;;
    esac
  done
}


echo -- test of calltrap-2
trap-calltrap t2
trap -p | {
  while read arg1 arg2 arg3 arg4; do
    case "$arg4" in
    EXIT) #0
      echo -n 'test 51 ... '
      test "$arg3" = "'cmd12'" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
      ;;
    SIGHUP) #1
      echo -n 'test 52 ... '
      test "$arg3" = "'cmd12'" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
      ;;
    SIGINT) #2
      echo -n 'test 53 ... '
      test "$arg3" = "'cmd12'" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
      ;;
    SIGQUIT) #3
      echo -n 'test 54 ... '
      test "$arg3" = "'cmd12'" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
      ;;
    SIGTERM) #15
      echo -n 'test 55 ... '
      test "$arg3" = "'cmd23'" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
      ;;
    ERR) #ERR
      echo -n 'test 56 ... '
      test "$arg3" = "'cmd23'" && echo 'Success.' || { echo 'Fail.'; $((nerr++));}
      ;;
    *)
      ;;
    esac
  done
}

trap - $signals1
trap - $signals2

if [ $nerr -eq 0 ]; then
  echo 'All test succeeded.'
  exit 0
else
  echo "$nerr error occured."
  exit 1
fi
