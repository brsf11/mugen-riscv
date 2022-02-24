#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   shangyingjie
# @Contact   :   yingjie@isrc.iscas.ac.cn
# @Date      :   2022/2/28
# @License   :   Mulan PSL v2
# @Desc      :   Test zerofree
# #############################################

source "../common/common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    fill_value=6
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL zerofree
    mkdir ./testmnt ./images
    dd if=/dev/zero of=./images/fs.img bs=1M count=1024
    mkfs.ext3 -F ./images/fs.img
    mount ./images/fs.img ./testmnt
    yes abcdefghijklmnopqrstuvwxyz0123456789 >./testmnt/largefile
    rm ./testmnt/largefile
    umount ./testmnt
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    cp --sparse=always ./images/fs.img ./images/sparsed.img
    sparsed_size="$(du ./images/sparsed.img | awk '{print $1}')"
    zerofree -n ./images/fs.img
    CHECK_RESULT $? 0 0 "Failed to use option: -n"
    cp --sparse=always ./images/fs.img ./images/zerofreed_n_sparsed.img
    zerofreed_n_sparsed_size="$(du ./images/zerofreed_n_sparsed.img | awk '{print $1}')"
    [ "$sparsed_size" -eq "$zerofreed_n_sparsed_size" ]
    CHECK_RESULT $? 0 0 "Failed to achieve expect result, option: -n"
    zerofree -v ./images/fs.img | grep -E '*/*/*'
    CHECK_RESULT $? 0 0 "Failed to use option: -v"
    cp --sparse=always ./images/fs.img ./images/zerofreed_sparsed.img
    CHECK_RESULT $? 0 0 "Failed to achieve expect result, option: -v"
    zerofreed_sparsed_size="$(du ./images/zerofreed_sparsed.img | awk '{print $1}')"
    [ "$zerofreed_sparsed_size" -lt "$sparsed_size" ]
    CHECK_RESULT $? 0 0 "Failed to use basic funtion."
    zerofree -f $fill_value ./images/fs.img
    CHECK_RESULT $? 0 0 "Failed to use option: -f"
    cp --sparse=always ./images/fs.img ./images/zerofreed_f_sparsed.img
    zerofreed_f_sparsed_size="$(du ./images/zerofreed_f_sparsed.img | awk '{print $1}')"
    [ "$zerofreed_f_sparsed_size" -gt "$zerofreed_sparsed_size" ]
    CHECK_RESULT $? 0 0 "Failed to achieve expect result, option: -f"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf ./testmnt ./images
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
