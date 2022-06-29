#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   zhangyili2
#@Contact   	:   yili@isrc.iscas.ac.cn
#@Date      	:   2022-05-19 09:39:43
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test for acpid-option
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh


function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    DNF_INSTALL "acpid"

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    ! acpi_listen -v | grep "invalid option" && acpi_listen -v | grep "acpid-[0-9]*.*"
    CHECK_RESULT $? 0 0 "Failed option: -v"

    ! acpi_listen --version | grep "invalid option" && acpi_listen --version | grep "acpid-[0-9]*.*"
    CHECK_RESULT $? 0 0 "Failed option: --version"

    ! acpi_listen -h 2>&1 | grep "invalid option" && acpi_listen -h 2>&1 | grep "Usage: acpi_listen \[OPTIONS\]"
    CHECK_RESULT $? 0 0 "Failed option: -h"

    ! acpi_listen --help 2>&1 | grep "invalid option" && acpi_listen --help 2>&1 | grep "Usage: acpi_listen \[OPTIONS\]"
    CHECK_RESULT $? 0 0 "Failed option: --help"


    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
