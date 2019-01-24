#!/bin/bash
##
# author : Peter Forret <peter@forret.com>
# inspired by http://forum.synology.com/enu/viewtopic.php?f=37&t=30242
##

prog=$(basename $0)
cmd=$1
### only change below
version=1.0
service=iperf3
bin=/bin/iperf3
do_start="$bin -s &"
do_stop="kill $(pidof iperf3)"
runas=admin
### only chnage above
start="bash -c"
[[ -s "$runas" ]] && start="su - admin -c "

case "$cmd" in
        start)
        $start "$do_start"
        ;;

        stop)
        $start "$do_stop"
        ;;

        status)
        # check for process running
        # check for port opened
        ;;

        *)
cat <<EOF
### $prog $version
Usage:
------
$prog start : start service $service
$prog stop  : stop service $service
$prog status: show status of service $service
EOF
exit 3

esac
