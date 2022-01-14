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
# @Date      :   2020/04/25
# @License   :   Mulan PSL v2
# @Desc      :   Adjusted the strategy for sharing nfs and cifs volumes using SELinux booleands
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "policycoreutils-python-utils"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    semanage boolean -l | grep 'nfs' | grep httpd | grep off
    CHECK_RESULT $? 0 0 "Check semanage nfs off failed"
    semanage boolean -l | grep 'cifs' | grep httpd | grep off
    CHECK_RESULT $? 0 0 "Check semanage cifs off failed"
    getsebool -a | grep 'nfs' | grep httpd | grep off
    CHECK_RESULT $? 0 0 "Check getsebool nfs off failed"
    getsebool -a | grep 'cifs' | grep httpd | grep off
    CHECK_RESULT $? 0 0 "Check getsebool cifs off failed"
    setsebool httpd_use_nfs on
    setsebool httpd_use_cifs on
    semanage boolean -l | grep 'nfs' | grep httpd | grep on
    CHECK_RESULT $? 0 0 "Check semanage nfs on failed"
    semanage boolean -l | grep 'cifs' | grep httpd | grep on
    CHECK_RESULT $? 0 0 "Check semanage cifs on failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    setsebool httpd_use_nfs off
    setsebool httpd_use_cifs off
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
