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
# @Desc      :   Fix SELinux rejections that have been analyzed
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "httpd setroubleshoot-server"
    default_selinux_status=$(getenforce)
    [ "$default_selinux_status" == "Enforcing" ] || setenforce 1
    cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf-bak
    sed -i "s/Listen 80/Listen 3131/g" /etc/httpd/conf/httpd.conf
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    systemctl restart httpd
    sealert -a /var/log/audit/audit.log | grep "[a-z]" >/tmp/prevent_info.txt
    grep "SELinux is preventing httpd from name_bind access on the tcp_socket port 3131" /tmp/prevent_info.txt
    CHECK_RESULT $?
    suggest_infoc=$(grep "ausearch -c" /tmp/prevent_info.txt)
    suggest_infox=$(grep "semodule -X" /tmp/prevent_info.txt)
    if [ -z "${suggest_infoc}" ] || [ -z "${suggest_infox}" ]; then
        RULE_FLAG=1
        auditctl -w /usr/bin/systemctl -p r -k httpd-start
        rm -f /var/lib/setroubleshoot/setroubleshoot.xml
        systemctl restart httpd
        sealert -a /var/log/audit/audit.log | grep "[a-z]" >/tmp/prevent_info.txt
        suggest_infoc=$(grep "ausearch -c" /tmp/prevent_info.txt)
        suggest_infox=$(grep "semodule -X" /tmp/prevent_info.txt)
        test -n "{suggest_infoc}" && test -n "{suggest_infox}"
        CHECK_RESULT $?
    fi
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    mv -f /etc/httpd/conf/httpd.conf-bak /etc/httpd/conf/httpd.conf
    systemctl stop httpd
    DNF_REMOVE
    if [ "$default_selinux_status" == "Enforcing" ]; then
        setenforce 1
    else
        setenforce 0
    fi
    rm -rf /tmp/prevent_info.txt
    [ ${RULE_FLAG} -eq 1 ] && auditctl -w /usr/bin/systemctl -p r -k httpd-start
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
