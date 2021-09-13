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
# @Desc      :   Display nftables rule sets, create tables, create chains, insert rules, use anonymous sets
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    table_name=sec008
    chain_name=sec008_chain
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    
    nft add table inet $table_name
    nft list tables | grep $table_name
    CHECK_RESULT $? 0 0 "exec 'nft add table' failed"

    nft add chain inet $table_name $chain_name { type filter hook input priority 0 \; policy accept \; }
    nft list chains | grep $chain_name
    CHECK_RESULT $? 0 0 "exec 'nft add chain' failed"

    nft add rule inet $table_name $chain_name tcp dport 22 accept
    nft list table inet $table_name | grep 22
    CHECK_RESULT $? 0 0 "exec 'nft add rule' failed"
    
    nft add rule inet $table_name $chain_name tcp dport { 80, 443 } accept
    nft list table inet $table_name | grep "80, 443"
    CHECK_RESULT $? 0 0 "exec 'nft list table inet $table_name $chain_name tcp dport { 80, 443 } accept' failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    nft delete table inet $table_name
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
