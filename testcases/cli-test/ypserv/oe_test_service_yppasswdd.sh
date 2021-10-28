#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Test yppasswdd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "ypbind ypserv"
    host_name=$(hostname)
    systemctl start ypserv
    systemctl start yppasswdd
    nisdomainname ${host_name}
    echo "NISDOMAIN=${host_name}" >>/etc/sysconfig/network
    echo "* : * : * : none" >>/etc/ypserv.conf
    sed -i "s/YPPASSWDD_ARGS=/YPPASSWDD_ARGS='--port 1012'/g" /etc/sysconfig/yppasswdd
    touch {/etc/netgroup,/etc/publickey}
    echo -e "004" | /usr/lib64/yp/ypinit -m
    systemctl restart ypserv
    systemctl restart yppasswdd
    echo "domain ${host_name} server ${host_name}" >>/etc/yp.conf
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution yppasswdd.service
    test_reload yppasswdd.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i "/^NISDOMAIN=${host_name}$/d" /etc/sysconfig/network
    sed -i '$d' /etc/ypserv.conf
    sed -i "s/YPPASSWDD_ARGS='--port 1012'/YPPASSWDD_ARGS=/g" /etc/sysconfig/yppasswdd
    sed -i "/^domain ${host_name} server ${host_name}$/d" /etc/yp.conf
    systemctl stop ypserv
    systemctl stop yppasswdd
    systemctl stop ypbind.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
