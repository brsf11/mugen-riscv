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
#@Date      	:   2021-05-19 09:39:43
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   set max log file rotate
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
source ../common/comlib.sh

function run_test()
{
    LOG_INFO "Start to run test."
    sed -i 's/max_log_file = 8/max_log_file = 1/g' "/etc/audit/auditd.conf"
    sed -i 's/num_logs = 5/num_logs = 2/g' "/etc/audit/auditd.conf"
    rm -rf /var/log/audit/audit.log*
    service auditd restart 
    old_size=$(du -ks /var/log/audit/ | awk '{print $1}')
    old_num=$(find /var/log/audit -name "audit.log*" | wc -l)
    for ((i=0;i<10;i++));do
	    create_logfile
	    new_size=$(du -ks /var/log/audit/ | awk '{print $1}')
	    test $(("$new_size" - "$old_size")) -gt 1024 &&{
		new_num=$(find /var/log/audit -name "audit.log*" | wc -l)
	    	if [ $(("$new_num" - "$old_num")) -ge 1 ]; then
			break
		else
			CHECK_RESULT 1 0 0
			break
		fi
	 }
 	test "$i" -eq 9 &&{
		CHECK_RESULT 1 0 0
	}
    done

    for ((i=0;i<10;i++));do
	    old_time=$(stat /var/log/audit/audit.log |grep "Access" |tail -n 1 | awk '{print $2,$3}')
	    create_logfile
	    new_time=$(stat /var/log/audit/audit.log |grep "Access" |tail -n 1 | awk '{print $2,$3}')
	    log_num=$(find /var/log/audit/ -maxdepth 1 -name "audit.log*" |wc -l)
	    test "$old_time" = "$new_time" && test "$log_num" -eq 1 && {
	    	break
	    }  
   	    test "$i" -eq 9 &&{
	    	CHECK_RESULT 1 1 0
	    }
    done
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    sed -i 's/max_log_file = 1/max_log_file = 8/g' "/etc/audit/auditd.conf"
    sed -i 's/num_logs = 2/num_logs = 5/g' "/etc/audit/auditd.conf"
    service auditd restart
    LOG_INFO "End to restore the test environment."
}

main "$@"
