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
#@Author    	:   meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2021-08-03
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test clamonacc(only for clamav version ≥ 0.103.2)
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    DNF_INSTALL "clamav clamav-server"

    echo "/opt" >testlist
    mkdir testdir
    echo "test1" >testdir/testfile1
    echo "test2" >testdir/testfile2
    cp /var/lib/clamav/main.cvd testdir

    mv /etc/clamd.d/scan.conf /etc/clamd.d/scan.conf.bak
    echo "  LogFile /var/log/clamd.scan
            LogFileMaxSize 2M
            LogTime yes
            PidFile /run/clamd.scan/clamd.pid
            DatabaseDirectory /var/lib/clamav
            TCPAddr 0.0.0.0
            TCPSocket 3310
            LocalSocket /run/clamd.scan/clamd.sock
            ScanOnAccess yes
            OnAccessExcludeUname test 
            OnAccessIncludePath /opt" >/etc/clamd.d/scan.conf
    systemctl restart clamd@scan.service
    systemctl restart clamav-clamonacc

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    clamonacc -v
    CHECK_RESULT $? 0 0 "Execute clamonacc -v failed."
    clamonacc -w
    CHECK_RESULT $? 0 0 "Execute clamonacc -w failed."
    clamonacc -W testfile
    CHECK_RESULT $? 0 0 "Execute clamonacc -W testfile failed."
    clamonacc -l clamonacc_log /opt --fdpass
    CHECK_RESULT $? 0 0 "Execute clamonacc -l clamonacc_log /opt --fdpass failed."
    clamonacc --exclude-list=testlist
    CHECK_RESULT $? 0 0 "Execute clamonacc --exclude-list=testlist failed."
    clamonacc --config-file=/etc/clamd.d/scan.conf
    CHECK_RESULT $? 0 0 "Execute clamonacc --config-file=/etc/clamd.d/scan.conf failed."
    clamonacc -p 3:1 -w
    CHECK_RESULT $? 0 0 "Execute clamonacc -p 3:1  -w failed."
    clamonacc --remove
    CHECK_RESULT $? 0 0 "Execute clamonacc --remove failed."
    clamonacc --move testdir /opt
    CHECK_RESULT $? 0 0 "Execute clamonacc --move testdir /opt failed."
    clamonacc --copy testdir /opt
    CHECK_RESULT $? 0 0 "Execute clamonacc --copy testdir /opt failed."
    clamonacc -z
    CHECK_RESULT $? 0 0 "Execute clamonacc -z failed."
    clamonacc --stream
    CHECK_RESULT $? 0 0 "Execute clamonacc --stream failed."

    nohup clamonacc -v -F &
    SLEEP_WAIT 2
    # create a new console to execute cmd to be watched
    SSH_CMD "echo 'test force file' >/opt/test_forcefile" ${NODE1_IPV4} ${NODE1_PASSWORD} ${NODE1_USER}
    SLEEP_WAIT 2
    grep -q "/opt/test_forcefile" nohup.out
    CHECK_RESULT $? 0 0 "Execute clamonacc -F failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    kill -9 $(ps -ef | grep clamonacc | grep -Ev 'grep|bash' | awk '{print $2}')
    rm -rf /etc/clamd.d/scan.conf testlist clamonacc_log testdir nohup.out /opt/test_forcefile
    mv /etc/clamd.d/scan.conf.bak /etc/clamd.d/scan.conf
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
