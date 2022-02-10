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
# @Date      :   2020/7/17
# @License   :   Mulan PSL v2
# @Desc      :   Allow kill signals to be sent to processes that do not belong to you
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    grep "^example:" /etc/passwd && userdel -rf example
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    useradd example
    passwd example <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    top &
    top_pid=$!
    setcap cap_kill=eip /bin/kill
    CHECK_RESULT $? 0 0 "Failed to set cap"
    su - example <<EOF1
    expect << EOF
    spawn /bin/kill -9 $top_pid
    expect eof
EOF
EOF1
    CHECK_RESULT $? 0 0 "Failed to kill process"
    ps -aux | grep top | grep $top_pid | grep -v 'grep'
    CHECK_RESULT $? 0 1 "The viewing process succeeded, but it should fail here"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    setcap -r /bin/kill
    userdel -rf example
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
