#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #######################################################
# @Author    :   chentao
# @Contact   :   chentao@uniontech.com
# @Date      :   2021-08-10
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-mv
# #######################################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test(){
    LOG_INFO "Start environment preparation"
    ls /tmp/name1 && rm -rf /tmp/name1
    ls /tmp/name2 && rm -rf /tmp/name2
    LOG_INFO "End of enviornment preparation"

}
function do_test() {
    LOG_INFO "Start test"
    mkdir /tmp/name1
    ls /tmp/name1
    CHECK_RESULT $?
    mv /tmp/name1 /tmp/name2
    ls /tmp/name2
    CHECK_RESULT $?

    mv /tmp/name2 /tmp/name3
    ls /tmp/name3
    CHECK_RESULT $?

    mv /tmp/name3 /tmp/name1
    ls /tmp/name1
    CHECK_RESULT $?
    LOG_INFO "Finish test"
}

function post_test(){
    LOG_INFO "start environment cleanup."
    rm -rf /tmp/name1
    LOG_INFO "Finish environment cleanup!"
}

main $@
