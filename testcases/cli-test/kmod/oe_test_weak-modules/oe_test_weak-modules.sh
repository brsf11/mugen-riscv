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
# @Desc      :   verify the uasge of weak-modules command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    weak-modules --help
    CHECK_RESULT $?
    extraPath=$(find / -name extra | awk 'NR==2')
    echo $extraPath/catch.ko | weak-modules --add-module --no-initramfs
    CHECK_RESULT $?
    echo $extraPath/catch.ko | weak-modules --add-module --verbose
    CHECK_RESULT $?
    echo $extraPath/catch.ko | weak-modules --remove-modules
    CHECK_RESULT $?
    echo $extraPath/catch.ko | weak-modules --add-kernel
    CHECK_RESULT $?
    echo $extraPath/catch.ko | weak-modules --remove-kernel
    CHECK_RESULT $?
    weak-modules --dry-run --add-kernel
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

main $@
