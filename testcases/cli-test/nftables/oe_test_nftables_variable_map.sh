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
# @Desc      :   Using variable decision mapping in nftable
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    table_name=sec011
    chain_name=sec011_chain
    map_name=sec011_map
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    nft add table ip $table_name
    nft add chain ip $table_name $chain_name { type filter hook input priority 0 \; }
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start executing testcase."
    nft add map ip $table_name $map_name { type ipv4_addr : verdict \; }
    nft add rule $table_name $chain_name ip saddr vmap @${map_name}
    nft add element ip $table_name $map_name { ${NODE1_IPV4} : accept ,${NODE2_IPV4} : drop}
    nft list ruleset | grep "${NODE2_IPV4} : drop"
    CHECK_RESULT $? 0 0 "exec 'nft add element ip' failed"
    nft delete element ip $table_name $map_name { ${NODE2_IPV4} }
    nft list ruleset | grep "${NODE2_IPV4} : drop"
    CHECK_RESULT $? 0 1 "exec 'nft delete element ip' failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    nft delete table ip $table_name
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
