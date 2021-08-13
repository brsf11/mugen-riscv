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
    ls /opt/name1 && rm -rf /opt/name1
    ls /opt/name2 && rm -rf /opt/name2
    LOG_INFO "End of enviornment preparation"

}
function do_test() {
    LOG_INFO "Start test"
    mkdir /opt/name1
    ls /opt/name1
    CHECK_RESULT $? 0 0 "bulid work_file fail"
    mv /opt/name1 /opt/name2
    ls /opt/name2
    CHECK_RESULT $? 0 0 "modify filename failed"

    mv /opt/name2 /opt/name3
    ls /opt/name3
    CHECK_RESULT $? 0 0 "modify filename failed"

    mv /opt/name3 /opt/name1
    ls /opt/name1
    CHECK_RESULT $? 0 0 ""
    LOG_INFO "Finish test"
}

function post_test(){
    LOG_INFO "start environment cleanup."
    rm -rf /opt/name1
    LOG_INFO "Finish environment cleanup!"
}

main $@
