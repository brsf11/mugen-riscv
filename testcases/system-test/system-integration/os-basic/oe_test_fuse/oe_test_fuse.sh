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
# @Author    :   liuyafei1
# @Contact   :   liuyafei@uniontech.com
# @Date      :   2022-11-29
# @License   :   Mulan PSL v2
# @Desc      :   fuse function verification  
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    DNF_INSTALL fuse
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start testing..."
    mkdir /home/test
    test -d /home/test
    CHECK_RESULT $? 0 0 "The test is not exit "
    mount -t fusectl none /home/test
    CHECK_RESULT $? 0 0 "The fuse test is fail"
    mount | grep fusectl
    CHECK_RESULT $? 0 0 "The relust is abnormal"
    umount /home/test
    CHECK_RESULT $? 0 0 "The umount test is fail"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    export LANG=${OLD_LANG}
    DNF_REMOVE
    rm -rf /home/test
    LOG_INFO "End to restore the test environment."
}

main $@


