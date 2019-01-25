#!/bin/bash
##
# author : Peter Forret <peter@forret.com>
# inspired by https://forum.synology.com/enu/viewtopic.php?f=37&t=30242
# inspired by https://forum.synology.com/enu/viewtopic.php?t=106461
##
prog=$(basename $0)
option=$1
### only change below
##################################################
version=1.2
svc_path=iperf3
svc_name=$(basename "$svc_path")
#only change next one if the service is not clear from the binary name
svc_prettyname=$svc_name
#use if program listens on a port. This will be used to prevent double calls
svc_port=5201
#use if you want program to use a lock file
svc_lockfile=/var/lock/$svc_name.lock
#use if you want program to use a log file
#svc_logfile=/var/log/$svc_name.log

svc_start_cmd="$svc_path -s -D"
svc_stop_cmd=""

# by default, script runs as root. Use run_as to set other user (e.g. admin)
#run_as=admin
##################################################
### only change above
if [[ $UID -ne 0 ]] ; then
	echo "ERROR: you MUST be [root] to run [$prog] for service [$svc_prettyname]" 
	echo "try running: sudo $0 $*" 
	exit 1
fi 
execute="bash -c"
if [[ -n "$run_as" ]] ; then
	[[ -n "$svc_start_cmd" ]] && svc_start_cmd="su - $run_as -c \"$svc_start_cmd\""
	[[ -n "$svc_stop_cmd" ]] && svc_stop_cmd="su - $run_as -c \"$svc_stop_cmd\""
fi

check_port(){
	[[ -n $(netstat -l -n | grep tcp | grep $svc_port) ]]
}

check_proc(){
	[[ -n $(pidof $svc_name) ]] 
}

check_lock(){
	[[ -f "$svc_lockfile" ]]
}

show_status(){
	if [[ -n "$svc_path" ]] ; then
		pid=$(pidof $svc_name)
		if check_proc ; then
			echo "[V] is running as process $pid"
		else
			echo "[X] has NO running process"
		fi
	fi
	if [[ -n "$svc_port" ]] ; then
		if check_port ; then
			echo "[V] is running on port $svc_port"
		else
			echo "[X] has NO listening port"
		fi
	fi
	if [[ -n "$svc_lockfile" ]] ; then
		if [[ -f "$svc_lockfile" ]] ; then
			echo "[V] has lockfile $svc_lockfile"
		else
			echo "[X] has NO lockfile"
		fi
	fi

}

case "$option" in
	start)
		is_running=0
		if [[ -n "$svc_lockfile" ]] ; then
			[[ -f "$svc_lockfile" ]] && is_running=1
		fi
		if [[ -n svc_check_proc ]] ; then
			check_proc && is_running=1
		fi
		if [[ -n svc_check_port ]] ; then
			check_port && is_running=1
		fi
		if [[ $is_running -eq 1 ]] ; then
			echo "$prog: [$svc_name] is already running!"
			show_status
		else
			echo "$prog: starting [$svc_name] ..."
			[[ -n "$svc_start_cmd" ]] && $svc_start_cmd
			if [[ -n "$svc_lockfile" ]] ; then
				echo "Date:	$(date)" > $svc_lockfile
				echo "Uptime: $(uptime)" >> $svc_lockfile
				echo "User: $(whoami)" >> $svc_lockfile
				echo "Script: $(realpath $0)" >> $svc_lockfile
				echo "Command: $svc_start_cmd" >> $svc_lockfile
			fi
			sleep 2
			show_status
		fi
	;;

	stop)
		echo "$prog: stopping [$svc_name] ..."
		[[ -n "$svc_stop_cmd" ]] && $svc_stop_cmd # if graceful shutdown with a command line
		pid=$(pidof $svc_name)
		if [[ -n "$pid" ]] ; then
			echo "$prog: killing process $pid ..."
			kill -9 $pid
		fi
		if [[ -n "$svc_lockfile" ]] ; then
			rm -f $svc_lockfile
		fi
	;;

	install)
		newname=S99$svc_name.sh
		echo "$prog: will install as $newname ..."
		cp $0 /usr/local/etc/rc.d/$newname
		echo "script is added to /usr/local/etc/rc.d/"
	;;

	status)
			show_status
        ;;

	*)
		if [[ -n "$option" ]] ; then
			echo "Unknown option [$option]"
		fi
cat <<EOF
### $prog $version for service [$svc_name]
------
$prog [option] with possible options:
* start : start service $svc_name
* stop  : stop service $svc_name
* status: show status of service $svc_name
* install: install this service on your Synology (so it starts upon reboot) 
EOF
exit 3

esac
