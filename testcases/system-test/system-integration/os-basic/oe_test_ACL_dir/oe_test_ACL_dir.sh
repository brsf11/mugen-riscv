#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   aliceye666
# @Contact   :   yezhifen@uniontech.com
# @Date      :   2022-12-15
# @License   :   Mulan PSL v2
# @Desc      :   Command ACL dir
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    useradd ace
    useradd uos1
    echo ace:deepin12#$ | chpasswd
    echo uos1:deepin12#$ | chpasswd
    chmod 755 /home/uos1
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "start to run test."
    su - uos1 -c "mkdir /home/uos1/test115216"
    su - uos1 -c "chmod 000 /home/uos1/test115216"
    su - uos1 -c "cd /home/uos1/test115216"	
    CHECK_RESULT $? 0 1 "uos can not access dir test115216，please modify"  	
    su - uos1 -c "setfacl -m u:ace:--x /home/uos1/test115216"
    CHECK_RESULT $? 0 0 "setfacl set fail" 
    su - ace -c "cd /home/uos1/test115216"
    CHECK_RESULT $? 0 0 "ace don't access test115216" 
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rf ace
    userdel -rf uos1
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
