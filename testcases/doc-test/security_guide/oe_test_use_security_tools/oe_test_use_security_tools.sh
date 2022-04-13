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
# @Date      :   2020/05/29
# @License   :   Mulan PSL v2
# @Desc      :   Reinforce with safety reinforcement tools
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    cp /etc/sudoers /etc/sudoers-bak
    echo 'size' >/tmp/m_test
    echo 'size ' >/tmp/sm_test
    echo 'key key2' >/tmp/M_test
    touch /tmp/rm_test
    DNF_INSTALL httpd
    cp /etc/openEuler_security/usr-security.conf /etc/openEuler_security/usr-security.conf-bak
    systemctl stop httpd
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    echo "801@d@/etc/sudoers@%wheel
802@m@/tmp/m_test@size @2
803@sm@/tmp/sm_test@size @2048
804@M@/tmp/M_test@key@key2@value2
805@systemctl@httpd.service@start
806@rm -f@/tmp/rm_test
807@touch @/tmp/touch_test" >>/etc/openEuler_security/usr-security.conf
    systemctl restart openEuler-security.service
    SLEEP_WAIT 10
    CHECK_RESULT $?
    grep 'size 2' /tmp/m_test && grep 'size 2048' /tmp/sm_test && grep 'key key2value2' /tmp/M_test && grep 'key key2value2' /tmp/M_test && ls /tmp/touch_test
    CHECK_RESULT $?
    ls /tmp/rm_test
    CHECK_RESULT $? 0 1
    grep '807@touch @/tmp/touch_test' /var/log/openEuler-security.log
    CHECK_RESULT $?
    SLEEP_WAIT 1
    systemctl status httpd | grep running
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    mv /etc/sudoers-bak /etc/sudoers -f
    mv /etc/openEuler_security/usr-security.conf-bak /etc/openEuler_security/usr-security.conf -f
    rm -rf /tmp/M_test /tmp/m_test /tmp/sm_test /tmp/touch_test
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
