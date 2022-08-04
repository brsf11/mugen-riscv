#!/usr/bin/bash

# Copyright (c) 2022.Huawei Technologies Co.,Ltd.ALL rights reserved.
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
#@Desc      	:   Take the test normal block file
#####################################

source ../common_lib/fsio_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    grep -q "alias rm='rm -i'" /root/.bashrc &&
        grep -q "alias cp='cp -i'" /root/.bashrc &&
        grep -q "alias mv='mv -i'" /root/.bashrc
    CHECK_RESULT $? 0 0 "The alias on system are changed."
    LOG_INFO "Start to run test."
}

main $@

