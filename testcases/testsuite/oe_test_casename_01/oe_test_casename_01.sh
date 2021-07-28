#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   lemon.higgins
#@Contact   	:   lemon.higgins@aliyun.com
#@Date      	:   2020-04-09 09:39:43
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   Take the test ls command as an example
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

# 需要预加载的数据、参数配置
function config_params() {
    LOG_INFO "Start to config params of the case."

    LOG_INFO "No params need to config."

    LOG_INFO "End to config params of the case."
}

# 测试对象、测试需要的工具等安装准备
function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    # output=$(P_SSH_CMD --ip "$NODE2_IPV4" --password "$NODE2_PASSWORD" --cmd "ls")
    output=$(P_SSH_CMD --node "2" --cmd "which vim; which bc")
    echo $output

    DNF_INSTALL "vim-common-2:8.2-1.oe1" 2

    output=$(P_SSH_CMD --node "2" --cmd "which vim; which bc")
    echo $output

    TEST_NIC 1
    TEST_DISK 2

    GET_FREE_PORT ${NODE2_IPV4}

    IS_FREE_PORT 22

    REMOTE_REBOOT 2

    REMOTE_REBOOT_WAIT 2

    LOG_INFO "No pkgs need to install."

    LOG_INFO "End to prepare the test environment."
}

# 测试点的执行
function run_test() {
    LOG_INFO "Start to run test."

    # 测试命令：ls
    ls -CZl -all
    CHECK_RESULT 0

    # 测试/目录下是否存在proc|usr|roor|var|sys|etc|boot|dev目录
    CHECK_RESULT "$(ls / | grep -cE 'proc|usr|roor|var|sys|etc|boot|dev')" 7

    LOG_INFO "End to run test."
}

# 后置处理，恢复测试环境
function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE 2

    LOG_INFO "End to restore the test environment."
}

main "$@"
