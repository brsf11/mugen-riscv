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
# @Desc      :   Test openwsmand.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL openwsman-server
    expect <<EOF
        spawn /etc/openwsman/owsmangencert.sh --force
        expect {
            "Country Name" { send "CN\\r"; exp_continue }
            "State or Province Name" { send "jiangsu\\r"; exp_continue } 
            "Locality Name" { send "nanjing\\r"; exp_continue }
            "Organization Name" { send "company\\r"; exp_continue }
            "Organizational Unit Name" { send "section\\r"; exp_continue }
            "server name" { send "ssl.oe.tld\\r"; exp_continue }
            "Email Address" { send "test@test.com\\r"; exp_continue }
        }
        expect eof
EOF
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution openwsmand.service
    test_reload openwsmand.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop openwsmand.service
    rm -rf /etc/openwsman/servercert.pem /etc/openwsman/serverkey.pem
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
