#!/bin/bash
##
# author : Peter Forret <peter@forret.com>
# inspired by http://forum.synology.com/enu/viewtopic.php?f=37&t=30242
##
prog=$(basename $0)
option=$1
### only change below
version=1.0
svc_path=iperf3
svc_name=$(basename "$svc_path")
svc_port=5201

svc_start_cmd="$svc_path -s -D"
svc_check_proc=YES
#svc_check_port=YES

svc_stop_proc="kill -9 $(pidof $svc_name)"
svc_stop_cmd=""

svc_status_proc="pidof $svc_name"
svc_status_port="netstat -l -p | grep $svc_port | cut -c69-"
svc_status_cmd=
# by default, script runs as root. Use run_as to set other user (e.g. admin)
#runas=admin
### only change above
execute="bash -c"
[[ -n "$runas" ]] && execute="su - admin -c "
#set -ex

check_port(){
	[[ -n "$svc_port" ]] && netstat -l -p | grep $svc_port | cut -c69-
}

check_proc(){
	pidof $svc_name
}

case "$option" in
        start)
		[[ -n "$svc_check_proc" ]] && [[ -n $(pidof $svc_name) ]] && (
			pid=$(pidof $svc_name)
			echo "$prog: [$svc_name] is already running (pid $pid)!"
			ps -Af | grep $pid | grep -v grep
			exit 1
			)
		echo "$prog: starting [$svc_name] ..."
        [[ -n "$svc_start_cmd" ]] && $execute "$svc_start_cmd"
        sleep 2
        [[ -n "$svc_status_proc" ]] && echo "# [$svc_name] is running as port $($svc_status_proc)"
        [[ -n "$svc_port" ]] && echo "# [$svc_name] is running on port $(netstat -l -p | grep $svc_port | cut -c69-)"

        ;;

        stop)
		echo "$prog: stopping [$svc_name] ..."
        [[ -n "$svc_stop_proc" ]] && $execute "$svc_stop_proc"
        [[ -n "$svc_stop_cmd" ]] && $execute "$svc_stop_cmd"
        ;;

        status)
        # check for process running
        # check for port opened
        [[ -n "$svc_status_proc" ]] && echo "# [$svc_name] is running as process $($svc_status_proc)"
        [[ -n "$svc_port" ]] && echo "# [$svc_name] is running on port $(netstat -l -p | grep $svc_port | cut -c69-)"
        [[ -n "$svc_status_cmd" ]]  && $svc_status_cmd
        ;;

        *)
cat <<EOF
### $prog $version for service [$svc_name]
------
$prog start : start service $svc_name
$prog stop  : stop service $svc_name
$prog status: show status of service $svc_name
EOF
exit 3

esac
