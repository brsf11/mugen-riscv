#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wanxiaofei_wx5323714
# @Contact   :   wanxiaofei4@huawei.com
# @Date      :   2020-08-02
# @License   :   Mulan PSL v2
# @Desc      :   verification openjdk‘s command
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL java-1.8.0-openjdk*
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    jsadebugd -help | grep Usage
    CHECK_RESULT $?
    jstack -h 2>&1 | grep Usage
    jrunscript &
    jstack_pid=$! && exit
    jstack -m ${jstack_pid} 2>&1 | grep 'Debugger attached successfully'
    CHECK_RESULT $?
    jstat -help | grep Usage
    CHECK_RESULT $?
    jstat -gc ${jstack_pid} | grep 'S0C' | grep 'S1C' | grep 'S0U'
    CHECK_RESULT $?
    kill -9 ${jstack_pid}
    echo "grant codebase \"file:\${java.home}/../lib/tools.jar\" {
    permission java.security.AllPermission;
 };" >jstatd.all.policy
    jstatd -J-Djava.security.policy=jstatd.all.policy &
    jstatd_pid=$!
    SLEEP_WAIT 3
    jps -l 127.0.0.1 | grep '[0-9] sun.tools'
    CHECK_RESULT $?
    kill -9 ${jstatd_pid}
    jstatd -help 2>&1 | grep usage
    CHECK_RESULT $?
    keytool -help 2>&1 | grep 'Commands'
    keytool -genkey -alias testuser -keypass testuser -keyalg RSA -keysize 1024 -validity 365 -keystore \
        ./testuser.keystore -storepass 123456 -dname "CN=testuser, OU=xx公司, O=xx协会, L=湘潭, ST=湖南, C=中国"
    CHECK_RESULT $?
    find ./testuser.keystore
    CHECK_RESULT $?
    keytool -list -v -keystore ./testuser.keystore -storepass 123456
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Need't to restore the tet environment."
    DNF_REMOVE
    rm -rf jstatd.all.policy testuser.keystore
    LOG_INFO "End to restore the test environment."
}

main "$@"
