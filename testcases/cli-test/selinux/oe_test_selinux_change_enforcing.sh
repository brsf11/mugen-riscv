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
# @Date      :   2022/05/12
# @License   :   Mulan PSL v2
# @Desc      :   Permanently change to mandatory mode
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    SSH_CMD "cp /etc/selinux/config /etc/selinux/config-bak" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    SSH_CMD "echo 'SELINUX=enforcing
SELINUXTYPE=targeted'>/etc/selinux/config" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SLEEP_WAIT 1
    SSH_CMD "reboot &" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    REMOTE_REBOOT_WAIT 2 15
    SSH_CMD "setsebool -P nfs_export_all_rw off;setsebool -P nfs_export_all_rw on" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SLEEP_WAIT 10
    SSH_CMD "ausearch -m AVC,USER_AVC,SELINUX_ERR,USER_SELINUX_ERR -ts today>/tmp/log.log 2>&1 &" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    SSH_CMD "grep AVC /tmp/log.log" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    SSH_CMD "dmesg | grep SELinux" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    SSH_CMD "mv -f /etc/selinux/config-bak /etc/selinux/config" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "rm -rf /tmp/log.log" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "reboot &" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    REMOTE_REBOOT_WAIT 2 15
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
