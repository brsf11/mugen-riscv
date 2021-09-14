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
# @Modify    :   yang_lijin@qq.com
# @Date      :   2020/04/25
# @License   :   Mulan PSL v2
# @Desc      :   Customize SELinux strategy for apache http server in non-standard configuration
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "httpd policycoreutils-python-utils setroubleshoot-server"
    cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf-bak
    sed -i "s/Listen 80/Listen 3131/g" /etc/httpd/conf/httpd.conf
    sed -i '/DocumentRoot/s/www/test_www/g' /etc/httpd/conf/httpd.conf
    sed -i '/Directory/s/www/test_www/g' /etc/httpd/conf/httpd.conf
    cp /var/www /var/test_www -rf
    cp /usr/share/httpd/noindex/index.html /var/test_www/html
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    systemctl restart httpd
    systemctl status httpd 2>&1 | grep "Failed to start The Apache HTTP Server"
    CHECK_RESULT $? 0 0 "Check httpd status failed"
    semanage port -a -t http_port_t -p tcp 3131
    semanage fcontext -a -e /var/www /var/test_www
    restorecon -Rv /var/
    chmod 777 -R /var/test_www
    systemctl restart httpd
    wget localhost:3131/index.html
    CHECK_RESULT $? 0 0 "Check wget failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    mv -f /etc/httpd/conf/httpd.conf-bak /etc/httpd/conf/httpd.conf
    semanage fcontext -d -e /var/www /var/test_www
    semanage port --delete -t ssh_port_t -p tcp 3131
    systemctl restart httpd
    DNF_REMOVE
    rm -rf /var/test_www index.html /home/http_status.txt
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
