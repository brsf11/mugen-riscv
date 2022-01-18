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
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2020/12/29
# @License   :   Mulan PSL v2
# @Desc      :   Test initrd-fs.target restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    touch /etc/initrd-release
    LOG_INFO "Finish environment cleanup!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution initrd-fs.target
    test_reload initrd-fs.target
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    rm -rf /etc/initrd-release
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
