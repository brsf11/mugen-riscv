#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

###################################
#@Author    :   qinhaiqi
#@Contact   :   2683064908@qq.com
#@Date      :   2022/2/03
#@License   :   Mulan PSL v2
#@Desc      :   Test "crontabs" command
###################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    touch test.sh
    chmod +x test.sh
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run testcase:oe_test_crontabs."
    systemctl start crond
    CHECK_RESULT $? 0 0 "Failed : start"
    systemctl restart crond
    CHECK_RESULT $? 0 0 "Failed : restart"
    systemctl stop crond
    CHECK_RESULT $? 0 0 "Failed : stop"
    systemctl status crond | grep "dead"
    CHECK_RESULT $? 0 0 "Failed : status"
    systemctl start crond
    echo "* * * * * /bin/ls" > /var/spool/cron/root
    CHECK_RESULT $? 0 0 "Failed option: -e"               
    crontab -u root -l 2>&1 | grep "/bin/ls"
    CHECK_RESULT $? 0 0 "Failed option: -l"
    run-parts --test . 2>&1 | grep "test.sh"
    CHECK_RESULT $? 0 0 "Failed option: run-parts --test"
    run-parts --list . 2>&1 | grep "crontabs.sh"
    CHECK_RESULT $? 0 0 "Failed option: run-parts --list"
    crontab -x proc /var/spool/cron/root 2>&1 | grep "enabled" 
    CHECK_RESULT $? 0 0 "Failed option: -x"
    crontab -u root -l -s 2>&1
    CHECK_RESULT $? 0 0 "Failed option: -s"
    crontab -u root -r 2>&1 
    CHECK_RESULT $? 0 0 "Failed option: -r"
    echo y | crontab -u root -r -i 2>&1 | grep "no" 
    CHECK_RESULT $? 0 0 "Failed option: -i"
    crontab -n $NODE1_IPV4 2>&1 
    CHECK_RESULT $? 0 0 "Failed option: -n"
    crontab -c 2>&1 | grep "$NODE1_IPV4"
    CHECK_RESULT $? 0 0 "Failed option: -c"  
    crontab -V 2>&1 | grep "[[:digit:]]*"  
    CHECK_RESULT $? 0 0 "Failed option: -V"
    LOG_INFO "End to run testcase:oe_test_crontabs."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm  test.sh
    LOG_INFO "End to restore the test environment."
}

main "$@"
