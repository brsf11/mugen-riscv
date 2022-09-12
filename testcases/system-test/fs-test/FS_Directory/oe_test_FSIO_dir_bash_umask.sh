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
#@Contact   	:   bubble_mt@outlook.com
#@Date      	:   2020-11-28
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test edit umask on /etc/bash
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    cur_date=$(date +%Y%m%d%H%M%S)
    normal="normal"$cur_date
    useradd $normal
    echo $normal | passwd --stdin $normal
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    grep -i -B 1 umask /etc/bashrc | grep 022
    CHECK_RESULT $? 0 0 "The default umask code is not 022."
    su $normal -c "umask" | grep 0022 >/dev/null
    CHECK_RESULT $? 0 0 "The default umask code of user is not 0022."
    echo "umask 227" >> /home/$normal/.bashrc
    source /home/$normal/.bashrc
    su $normal -c "umask" | grep 0227 >/dev/null
    CHECK_RESULT $? 0 0 "The umask code of user doesn't change."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    userdel -r $normal
    LOG_INFO "End to restore the test environment."
}

main $@

