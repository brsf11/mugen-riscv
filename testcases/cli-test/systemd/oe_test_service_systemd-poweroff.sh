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
# @Desc      :   Test systemd-poweroff.service restart
# #############################################

source "../common/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    LOG_INFO "systemd-poweroff.service  is a system service that is pulled in by halt.target and is responsible for the actual system halt. "
    test_oneshot systemd-poweroff.service 'inactive (dead)'
    LOG_INFO "Finish test!"
}

main "$@"
