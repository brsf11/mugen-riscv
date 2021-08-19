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
# @Date      :   2020/10/30
# @License   :   Mulan PSL v2
# @Desc      :   Command line test of security tool package
# ############################################
source "${OET_PATH}"/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environmental preparation."
    cp /etc/sudoers /etc/sudoers-bak
    echo 'test' >/tmp/m_test && echo 'test ' >/tmp/sm_test && echo 'test test2' >/tmp/M_test
    touch /tmp/rm_test
    DNF_INSTALL httpd
    cp /etc/openEuler_security/usr-security.conf /etc/openEuler_security/usr-security.conf-bak
    systemctl stop httpd
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    echo "801@d@/etc/sudoers@%wheel
802@sm@/tmp/sm_test@test @2048
803@m@/tmp/m_test@test @2
804@M@/tmp/M_test@test@test2@value2
805@rm -f@/tmp/rm_test
806@systemctl@httpd.service@start
807@touch @/tmp/touch_test" >>/etc/openEuler_security/usr-security.conf
    /usr/sbin/security-tool.sh -d / -c /etc/openEuler_security/security.conf -u /etc/openEuler_security/usr-security.conf -l /var/log/openEuler-security.log -s
    CHECK_RESULT $?
    [ -e /tmp/rm_test ]
    CHECK_RESULT $? 0 1
    grep '806@systemctl@httpd.service@start' /var/log/openEuler-security.log
    CHECK_RESULT $?
    grep 'test 2' /tmp/m_test && grep 'test 2048' /tmp/sm_test && grep 'test test2value2' /tmp/M_test && grep 'test test2value2' /tmp/M_test && ls /tmp/touch_test
    CHECK_RESULT $?
    systemctl status httpd | grep running
    CHECK_RESULT $?
    echo 'Y' | /usr/sbin/security-tool.sh -d / -c /etc/openEuler_security/security.conf -u /etc/openEuler_security/usr-security.conf -l /var/log/openEuler-security.log >log
    grep 'begin hardening SUER CONF by' log
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    mv /etc/openEuler_security/usr-security.conf-bak /etc/openEuler_security/usr-security.conf -f
    mv /etc/sudoers-bak /etc/sudoers -f
    rm -rf log /tmp/M_test /tmp/m_test /tmp/sm_test /tmp/touch_test
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
