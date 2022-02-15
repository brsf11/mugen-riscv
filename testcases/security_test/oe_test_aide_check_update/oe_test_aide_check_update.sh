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
# @modify    :   yang_lijin@qq.com
# @Date      :   2021/05/11
# @License   :   Mulan PSL v2
# @Desc      :   Install ADIDE, AIDE integrity check, AIDE library update
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL aide
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    aide --init | grep "Number of entries"
    CHECK_RESULT $? 0 0 "exec 'aide --init' failed"
    mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz -f
    aide --check | grep "Number of entries:"
    CHECK_RESULT $? 0 0 "exec 'aide --check' failed"
    aide --update | grep "New AIDE database written to /var/lib/aide/aide.db.new.gz"
    CHECK_RESULT $? 0 0 "exec 'aide --update' failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf /var/lib/aide/aide.db.*
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
