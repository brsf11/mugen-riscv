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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @modify    :   yang_lijin@qq.com
# @Date      :   2021/05/11
# @License   :   Mulan PSL v2
# @Desc      :   Allow binding to ports less than 1024
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    grep "^example:" /etc/passwd && userdel -rf example
    DNF_INSTALL nc
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    useradd example
    su - example -c "nc -l -p 500 &"
    SLEEP_WAIT 2
    pgrep -f 'nc -l -p 500'
    CHECK_RESULT $? 0 1 "Getting process PID succeeded, but it should fail here"
    setcap 'cap_net_bind_service=+ep' /bin/ncat
    CHECK_RESULT $? 0 0 "Failed to set cap"
    su - example -c "nc -l -p 500 &"
    SLEEP_WAIT 2
    pgrep -f 'nc -l -p 500'
    CHECK_RESULT $? 0 0 "Failed to get process PID"
    kill -9 $(pgrep -f 'nc -l -p 500')
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    setcap -r /bin/ncat
    userdel -rf example
    DNF_REMOVE nc
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
