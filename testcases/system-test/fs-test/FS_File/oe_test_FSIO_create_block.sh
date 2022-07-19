#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   @meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2020-12-02
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test create block file on fs
#####################################

source ../common_lib/fsio_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    point_list=($(CREATE_FS))
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    for i in $(seq 1 $((${#point_list[@]} - 1))); do
        var=${point_list[$i]}
        mknod $var/testBlock b 1 2
        CHECK_RESULT $? 0 0 "Create block file in $var failed."
        ls -l $var | grep testBlock | awk '{print $5,$6}' | grep "1, 2"
        CHECK_RESULT $? 0 0 "The device number of block file in $var is error."
        rm -f $var/testBlock
        CHECK_RESULT $? 0 0 "Delete block file in $var failed."
    done
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    list=$(echo ${point_list[@]})
    REMOVE_FS "$list"
    LOG_INFO "End to restore the test environment."
}

main $@
