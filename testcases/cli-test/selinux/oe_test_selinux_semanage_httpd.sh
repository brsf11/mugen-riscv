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
# @Desc      :   Modify the HTTP default directory in SELinux
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "setroubleshoot-server httpd"
    test -f /srv/www1 || rm -rf /srv/www1
    rdport=$(GET_FREE_PORT "$NODE1_IPV4")
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    mkdir /srv/www1
    semanage fcontext -a -t httpd_sys_content_t "/srv/www1(/.*)?"
    CHECK_RESULT $?
    restorecon -R -v /srv/www1
    CHECK_RESULT $?
    touch /var/www/html/index1.html
    matchpathcon -V /var/www/html/*
    CHECK_RESULT $?
    restorecon -v /var/www/html/index1.html
    CHECK_RESULT $?
    setsebool -P httpd_can_network_connect_db on
    CHECK_RESULT $?
    getsebool -a | grep ftp
    CHECK_RESULT $?
    semanage port -l | grep http
    CHECK_RESULT $?
    systemctl start httpd
    CHECK_RESULT $?
    systemctl status httpd | grep "running"
    CHECK_RESULT $?
    semanage port -a -t http_port_t -p tcp $rdport
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    semanage port --delete -t ssh_port_t -p tcp $rdport
    semanage fcontext -d -t httpd_sys_content_t "/srv/www1(/.*)?"
    setsebool -P httpd_can_network_connect_db off
    systemctl stop httpd
    rm -rf /var/www/html/index1.html /srv/www1
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
