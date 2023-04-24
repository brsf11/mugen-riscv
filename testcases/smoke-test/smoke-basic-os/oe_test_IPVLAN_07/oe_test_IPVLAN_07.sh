#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   dingjiao
#@Contact   	:   15829797643@163.com
#@Date      	:   2022-07-06
#@License   	:   Mulan PSL v2
#@Desc      	:   The ipvlan driver is unloaded and loaded normally
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    lsmod | grep ipvlan
    CHECK_RESULT $? 1 0 "ipvlan is not loaded: failed!"
    modprobe ipvlan
    CHECK_RESULT $? 0 0 "Modprobe ipvlan: failed!"
    lsmod | grep ipvlan
    CHECK_RESULT $? 0 0 "Load ipvlan: failed!"
    modinfo ipvlan | grep -E "filename|alias|description|author|license|srcversion|depends|retpoline|intree|name|vermagic|sig_id|signer|sig_key|sig_hashalgo|signature"
    CHECK_RESULT $? 0 0 "Display ipvlan mode info: failed!"
    rmmod ipvlan
    CHECK_RESULT $? 0 0 "Remove ipvlan mode: failed!"
    lsmod | grep ipvlan
    CHECK_RESULT $? 1 0 "ipvlan is not loaded after lsmod: failed!"
    LOG_INFO "End to run test."
}

main "$@"
