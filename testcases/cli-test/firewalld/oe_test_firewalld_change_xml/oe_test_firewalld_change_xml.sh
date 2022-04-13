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
# @Date      :   2022/04/22
# @License   :   Mulan PSL v2
# @Desc      :   Add rules by modifying xml to allow only B's machine to access the http service
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL httpd
    sudo systemctl start httpd
    sudo systemctl start firewalld
    cp /etc/firewalld/zones/public.xml /etc/firewalld/zones/public.xml-bak
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name=\"ssh\"/>
  <service name=\"mdns\"/>
  <service name=\"dhcpv6-client\"/>
  <service name=\"http\"/>
  <rule family=\"ipv4\">
    <source address=\"${NODE2_IPV4}\"/>
    <service name=\"http\"/>
    <accept/>
  </rule>
  <forward/>
</zone>" >/etc/firewalld/zones/public.xml
    sudo firewall-cmd --reload
    CHECK_RESULT $?
    systemctl restart firewalld
    SLEEP_WAIT 2
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo systemctl stop httpd
    DNF_REMOVE
    mv /etc/firewalld/zones/public.xml-bak /etc/firewalld/zones/public.xml -f
    sudo firewall-cmd --reload
    sudo systemctl start firewalld
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
