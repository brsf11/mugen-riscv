#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   Jevons
#@Contact   	:   1557927445@qq.com
#@Date      	:   2021-04-16 11:39:43
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   collect overall user time statistics
#####################################

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
	CHECK_RESULT $? 0 0 "failed"
	starttime=$(date +%T)
	touch /tmp/"${audit_key}"
	rm -rf /tmp/"${audit_key}"
	endtime=$(date +%T)
	auditctl -W /tmp/"${audit_key}" -p rwxa -k "${audit_key}"
	CHECK_RESULT $? 0 0 "second failed"
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
