#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2021/12/31
# @License   :   Mulan PSL v2
# @Desc      :   Only the owner and root administrator of the file have management ACL permissions
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    grep "^example1:" /etc/passwd && userdel -rf example1
    grep "^example2:" /etc/passwd && userdel -rf example2
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    useradd example1
    useradd example2
    passwd example1 <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    passwd example2 <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    touch /home/test1
    echo 'test' >/home/test1
    chown example1:example1 /home/test1
    chmod 700 /home/test1
    su - example1 -c 'setfacl -m u:example2:r  /home/test1'
    su - example2 -c 'cat  /home/test1|grep test'
    CHECK_RESULT  $? 0 0 "Failed to switch 'example2' user to view files"
    su - example2 -c 'setfacl -m u:example2:w  /home/test1'
    CHECK_RESULT $? 0 1 "Switching to 'example2' failed to execute setfacl command"
    su - example2 -c 'echo test2 >/home/test1'
    CHECK_RESULT $? 0 1 "Switching to 'example2' failed to execute echo command"
    setfacl -m u:example2:w /home/test1
    CHECK_RESULT  $? 0 0 "Failed to add a user permission for 'example2'"
    su - example2 -c 'echo test2 >/home/test1'
    CHECK_RESULT  $? 0 0 "Switching to 'example2' failed to execute echo command"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /home/test1
    userdel -rf example1
    userdel -rf example2
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
