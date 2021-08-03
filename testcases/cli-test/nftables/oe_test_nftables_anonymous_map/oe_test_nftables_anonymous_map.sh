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
# @Date      :   2021/08/03
# @License   :   Mulan PSL v2
# @Desc      :   Use anonymous mapping in nftable
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    table_name=sec010
    tcp_chain=tcp_packets_010
    udp_chain=udp_packets_010
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    nft add table inet $table_name
    nft add chain inet $table_name $tcp_chain
    nft add rule inet $table_name $tcp_chain counter
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    nft --handle list chain inet $table_name $tcp_chain | grep "chain $tcp_chain"
    CHECK_RESULT $? 0 0 "exec 'nft add rule inet $table_name $tcp_chain counter' failed"
    nft add chain inet $table_name $udp_chain
    nft add rule inet $table_name $udp_chain counter
    nft --handle list chain inet $table_name $udp_chain | grep "chain $udp_chain"
    CHECK_RESULT $? 0 0 "exec 'nft add rule inet $table_name $udp_chain counter' failed"
    nft add chain inet $table_name incoming_traffic { type filter hook input priority 0 \; }
    nft --handle list chain inet $table_name incoming_traffic | grep "chain incoming_traffic"
    CHECK_RESULT $? 0 0 "exec 'nft add chain inet $table_name incoming_traffic' failed"
    nft add rule inet $table_name incoming_traffic ip protocol vmap {tcp : jump $tcp_chain, udp : jump $udp_chain }
    nft list table inet $table_name | grep "ip protocol vmap { tcp : jump tcp_packets_010, udp : jump udp_packets_010 }"
    CHECK_RESULT $? 0 0 "exec 'nft add rule inet $table_name incoming_traffic ip protocol vmap {tcp : jump $tcp_chain, udp : jump $udp_chain }' failed"
    CHECK_RESULT $(nft list table inet $table_name | grep "counter packets" | wc -l) 2 0 "add tcp && udp failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    nft delete table inet $table_name
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
