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
# @Date      :   2021/02/04
# @License   :   Mulan PSL v2
# @Desc      :   VRRP_ garp_ Interval is set to a value of 0.2, and five groups of gratuitous ARP messages are sent every 120 seconds
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL keepalived
    which firewalld && systemctl stop firewalld
    getenforce | grep Enforcing && setenforce 0
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    echo "global_defs {
       router_id fw-1
       vrrp_garp_master_delay 5
       vrrp_garp_master_repeat 5
       vrrp_garp_lower_prio_delay 5
       vrrp_garp_lower_prio_repeat 5
       vrrp_garp_master_refresh 120
       vrrp_garp_master_refresh_repeat 2
       vrrp_garp_interval 0.2
       vrrp_gna_interval 0.2
}
vrrp_instance VI_11 {
       priority 100
       state MASTER
       interface ${NODE1_NIC}
       virtual_router_id 11
       advert_int 1
       virtual_ipaddress {
        192.168.111.111 dev ${NODE1_NIC} label ${NODE1_NIC}:1
        192.168.111.112 dev ${NODE1_NIC} label ${NODE1_NIC}:2
        192.168.111.113 dev ${NODE1_NIC} label ${NODE1_NIC}:3
        192.168.111.114 dev ${NODE1_NIC} label ${NODE1_NIC}:4
        }
       smtp_alert
}" >/etc/keepalived/keepalived.conf
    tail -f /var/log/messages >/tmp/tmp_mesg &
    systemctl start keepalived
    CHECK_RESULT $?
    SLEEP_WAIT 115
    kill -9 "$(pgrep -f 'tail -f /var/log/messages')"
    test $(grep -c "Sending gratuitous ARP on ${NODE1_NIC} for 192.168.111.111" /tmp/tmp_mesg) -eq 5
    CHECK_RESULT $?
    test $(grep -c "Sending gratuitous ARP on ${NODE1_NIC} for 192.168.111.112" /tmp/tmp_mesg) -eq 5
    CHECK_RESULT $?
    test $(grep -c "Sending gratuitous ARP on ${NODE1_NIC} for 192.168.111.113" /tmp/tmp_mesg) -eq 5
    CHECK_RESULT $?
    test $(grep -c "Sending gratuitous ARP on ${NODE1_NIC} for 192.168.111.114" /tmp/tmp_mesg) -eq 5
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE 1
    rm -rf /etc/keepalived/ /tmp/tmp_mesg
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
