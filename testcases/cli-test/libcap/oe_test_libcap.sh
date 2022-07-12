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
#@Date      	:   2021-11-01
#@License   	:   Mulan PSL v2
#@Desc      	:   Check libcap
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    cur_date=$(date +%Y%m%d%H%M%S)
    user="test"$cur_date
    useradd $user
    uid=$(cat /etc/passwd | grep $user | cut -d ':' -f 3)
    gid=$(cat /etc/passwd | grep $user | cut -d ':' -f 4)
    cp /usr/bin/ping ./

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    capsh --help
    CHECK_RESULT $? 0 0 "Check capsh --help failed."
    capsh --caps="cap_net_raw+eip cap_setpcap,cap_setuid,cap_setgid+ep" --keep=1 --user=$user --addamb=cap_net_raw -- -c "ping -c1 127.0.0.1"
    CHECK_RESULT $? 0 0 "Check capsh ping local failed."

    capsh --user=$user -- -c "whoami" | grep $user
    CHECK_RESULT $? 0 0 "Check capsh --user failed."
    capsh --uid=$uid -- -c "whoami" | grep $user
    CHECK_RESULT $? 0 0 "Check capsh --uid failed."
    capsh --gid=$gid -- -c "whoami" | grep "root"
    CHECK_RESULT $? 0 0 "Check capsh --gid failed."

    capsh --mode=NOPRIV -- -c "whoami" | grep "root"
    CHECK_RESULT $? 0 0 "Check capsh --mode failed."
    setcap cap_net_raw,cap_net_admin=eip ./ping
    CHECK_RESULT $? 0 0 "Check setcap failed."
    getcap ./ping | grep "cap_net_admin,cap_net_raw.eip"
    CHECK_RESULT $? 0 0 "Check getcap failed."
    setcap -r ./ping
    CHECK_RESULT $? 0 0 "Check setcap -r failed."
    getcap ./ping | grep "cap_net_raw,cap_net_admin=eip"
    CHECK_RESULT $? 1 0 "Check getcap after revert failed."
    getpcaps --help
    CHECK_RESULT $? 0 0 "Check capsh --help failed."
    getpcaps --usage
    CHECK_RESULT $? 0 0 "Check capsh --usage failed."
    getpcaps --verbose
    CHECK_RESULT $? 0 0 "Check capsh --verbose failed."
    getpcaps --ugly
    CHECK_RESULT $? 0 0 "Check capsh --ugly failed."
    getpcaps --legacy
    CHECK_RESULT $? 0 0 "Check capsh --legacy failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    userdel $user
    rm -r ./ping

    LOG_INFO "End to restore the test environment."
}

main "$@"
