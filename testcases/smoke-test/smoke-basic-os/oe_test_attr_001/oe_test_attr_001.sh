#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   geyaning
# @Contact   :   geyaning@uniontech.com
# @Date      :   2022-11-18
# @License   :   Mulan PSL v2
# @Desc      :   attr add attributes
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "attr"
    touch testfile
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    setfattr -n user.foo -v bar testfile
    getfattr -n user.foo testfile
    CHECK_RESULT $? 0 0 "Failed to set the EA extended properties"
    attr -lq testfile | grep foo
    CHECK_RESULT $? 0 0 "The newly added property cannot be queried"
    getfattr -d -m ".*"  testfile | grep user.foo
    CHECK_RESULT $? 0 0 "Unable to query user.foo add property"
    getfattr -m. -e hex -d testfile
    CHECK_RESULT $? 0 0 "Unable to display EA properties in hexadecimal"
    getfattr -m. -e base64 -d testfile
    CHECK_RESULT $? 0 0 "Cannot display EA attributes in base64"
    setfattr -x user.foo testfile
    getfattr -n user.foo testfile
    CHECK_RESULT $? 0 1 "Failed to delete attributes"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf testfile
    LOG_INFO "Finish environment cleanup!"
}

main $@
