#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Test remote-veritysetup.target restart
# #############################################

source "../common/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    test_execution remote-veritysetup.target
    test_reload remote-veritysetup.target
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    systemctl stop remote-veritysetup.target
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
