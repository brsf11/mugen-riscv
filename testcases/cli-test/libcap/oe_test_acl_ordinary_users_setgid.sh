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
# @modify    :   wangxiaoya@qq.com
# @Date      :   2022/05/06
# @License   :   Mulan PSL v2
# @Desc      :   The setting program allows ordinary users to use the setgid function
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function config_params() {
    LOG_INFO "This test case has no config params to load!"
}

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
    su - example -c 'touch /home/example/test'
    CHECK_RESULT $?
    su - example -c 'chattr +i /home/example/test'
    CHECK_RESULT $? 0 1 "Failed to chattr"
    setcap cap_linux_immutable=eip /usr/bin/chattr
    CHECK_RESULT $?
    su - example -c 'chattr +i /home/example/test'
    CHECK_RESULT $?
    su - example -c 'lsattr /home/example/test' | grep "i\-\-\-\-\-\-\-\-\-e" | grep "/home/example/test"
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    su - example -c 'chattr -i /home/example/test'
    setcap -r /usr/bin/chattr
    userdel -rf example
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
