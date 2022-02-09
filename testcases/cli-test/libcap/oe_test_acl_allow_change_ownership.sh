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
# @Desc      :   allow to change the ownership of the file
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
    touch /tmp/test
    ls -l /tmp/test | grep 'root root'
    CHECK_RESULT $? 0 0 "Failed to view '/tmp/test' document and obtain 'root root' field"
    su - example -c 'chown example:example /tmp/test'
    CHECK_RESULT $? 0 1 "Switching example user to change the file owner succeeded, but it should fail here"
    setcap cap_chown=eip /bin/chown
    CHECK_RESULT $? 0 0 "Failed to set cap"
    su - example -c 'chown example:example /tmp/test'
    CHECK_RESULT $? 0 0 "Failed to switch example user to change file owner"
    ls -l /tmp/test | grep 'example example'
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /tmp/test
    setcap -r /bin/chown
    userdel -rf example
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
