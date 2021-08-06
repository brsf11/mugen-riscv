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
# @Date      :   2021/8/3
# @License   :   Mulan PSL v2
# @Desc      :   Listen for packets that match existing debug nftable rules
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    table_name=sec015
    chain_name=sec015_chain
    nft add table inet $table_name
    nft add chain inet $table_name $chain_name { type filter hook input priority 0 \; }
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    nft add rule inet $table_name $chain_name udp dport 22 accept
    nft --handle list chain inet $table_name $chain_name | grep $chain_name
    CHECK_RESULT $? 0 0 "exec 'nft add rule inet $table_name $chain_name udp dport 22 accept' failed"
    handle_num=$(nft --handle list chain inet $table_name $chain_name | grep udp | awk -F ' ' '{printf $NF}')
    nft replace rule inet $table_name $chain_name handle $handle_num tcp dport 22 meta nftrace set 1 accept
    nft --handle list chain inet $table_name $chain_name | grep 'tcp dport 22 meta nftrace set 1 accept'
    CHECK_RESULT $? 0 0 "exec 'nft replace' failed"
    nft monitor | grep "inet $table_name $chain_name" >monitor_log &
    pid_num=$!
    SSH_CMD "pwd" ${NODE1_IPV4} ${NODE1_PASSWORD} ${NODE1_USER}
    SLEEP_WAIT 10
    kill -9 $pid_num
    [ $(cat monitor_log | wc -l) -gt 0 ]
    CHECK_RESULT $? 0 0 "exec 'nft monitor' failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    nft delete table inet $table_name
    rm -rf monitor_log
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
