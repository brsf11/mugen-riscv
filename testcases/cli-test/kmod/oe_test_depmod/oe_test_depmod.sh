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
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/29
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of depmod command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    depmod --help | grep "-"
    CHECK_RESULT $?
    depmod -V | grep "kmod version"
    CHECK_RESULT $?
    depmod -a
    CHECK_RESULT $?
    depmod -A
    CHECK_RESULT $?
    depmod --config=./
    CHECK_RESULT $?
    symversPath=$(find / -name Module.symvers)
    depmod -e -E $symversPath
    CHECK_RESULT $?
    mapPath=$(find / -name System.map)
    depmod -e -F $mapPath
    CHECK_RESULT $?
    depmod -e -E $symversPath -n
    CHECK_RESULT $?
    depmod -e -E $symversPath -v
    CHECK_RESULT $?
    depmod -e -E $symversPath -w
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

main $@
