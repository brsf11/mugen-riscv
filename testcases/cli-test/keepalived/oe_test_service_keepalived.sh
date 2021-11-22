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
# @Desc      :   Test keepalived.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL keepalived
    mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.bak
    eth_name=$(ip route | grep "${NODE1_IPV4}" | awk '{print $3}')
    echo "global_defs {
   notification_email {
       root@localhost
   }
   smtp_server 127.0.0.1
   router_id N1
}
vrrp_instance VI_1 {
    state MASTER
    interface ${eth_name}
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
}" >>/etc/keepalived/keepalived.conf
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution keepalived.service
    systemctl start keepalived.service
    sed -i 's\ExecStart=/usr/sbin/keepalived\ExecStart=/usr/sbin/keepalived -D\g' /usr/lib/systemd/system/keepalived.service
    systemctl daemon-reload
    systemctl reload keepalived.service
    CHECK_RESULT $? 0 0 "keepalived.service reload failed"
    systemctl status keepalived.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "keepalived.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/keepalived -D\ExecStart=/usr/sbin/keepalived\g' /usr/lib/systemd/system/keepalived.service
    systemctl daemon-reload
    systemctl reload keepalived.service
    mv -f /etc/keepalived/keepalived.bak /etc/keepalived/keepalived.conf
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
