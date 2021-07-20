#!/bin/bash
source ${OET_PATH}/libs/locallibs/common_lib.sh
AUDIT_PATH=$(find /etc -name auditd.conf)

function create_logfile(){
	auditctl -w /home/auditd_test -p rwxa
	for((j=0;j<500;j++));do
		touch /home/auditd_test > /dev/null
		chmod 777 /home/auditd_test > /dev/null
		rm -rf /home/auditd_test > /dev/null
	done
	auditctl -W /home/auditd_test -p rwxa
}
function search_log(){
	audit_key=$1
	auditctl -w /tmp/"${audit_key}" -p rwxa -k "${audit_key}"
	CHECK_RESULT $?
	starttime=$(date +%T)
	touch /tmp/"${audit_key}"
	rm -rf /tmp/"${audit_key}"
	endtime=$(date +%T)
	auditctl -W /tmp/"${audit_key}" -p rwxa -k "${audit_key}"
	CHECK_RESULT $?
	for((i=0;i<10;i++));do
		ausearch -k "${audit_key}" -ts "${starttime}" -te "${endtime}"
		if [[ $? -ne 0 ]];then
			SLEEP_WAIT 1
		else
			break
		fi
	done
	if [[ $i -eq 10 ]];then
		return 1
	fi
}
