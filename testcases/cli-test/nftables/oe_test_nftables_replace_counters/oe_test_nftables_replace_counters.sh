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
# @Author    :   yanglijin
# @Contact   :   yang_lijin@qq.com
# @Date      :   2021/08/03
# @License   :   Mulan PSL v2
# @Desc      :   replace rules to add counters
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    table_name=example_table
    chain_name=example_chain
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    nft add table inet $table_name
    nft add chain inet $table_name $chain_name { type filter hook input priority 0 \; policy accept \; }
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    nft add rule inet $table_name $chain_name tcp dport ssh accept
    nft --handle list chain inet $table_name $chain_name | grep "tcp dport 22 accept"
    CHECK_RESULT $? 0 0 "exec 'nft add rule inet $table_name $chain_name tcp dport ssh accept' failed"
    
    handle_num=$(nft --handle list chain inet $table_name $chain_name | grep tcp | awk -F ' ' '{printf $NF}')
    nft replace rule inet $table_name $chain_name handle $handle_num tcp dport 22 counter accept
    nft --handle list chain inet $table_name $chain_name | grep -E 'tcp dport [0-9]+ counter packets [0-9]+ bytes [0-9]+ accept'
    CHECK_RESULT $? 0 0 "exec 'nft replace rule inet $table_name $chain_name handle 2 tcp dport 22 counter accept' failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    nft delete table inet $table_name
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
