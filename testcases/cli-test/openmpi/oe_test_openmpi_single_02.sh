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
#@Author    	:   doraemon2020
#@Contact   	:   xcl_job@163.com
#@Date      	:   2020-11-20
#@License   	:   Mulan PSL v2
#@Desc      	:   command test openmpi single
#####################################
source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "openmpi openmpi-devel"
    mpi_path=$(whereis openmpi | awk '{print$2}')
    {
        echo "PATH=$PATH:${mpi_path}/bin"
        echo "LD_LIBRARY_PATH=${mpi_path}/lib"
    } >>$HOME/.bash_profile
    source $HOME/.bash_profile
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    orte-clean -h | grep "ompi-clean \[OPTIONS\]"
    CHECK_RESULT $?
    orte-dvm --allow-run-as-root -h | grep "Usage"
    CHECK_RESULT $?
    test "$(orte-dvm --allow-run-as-root -V |
        grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa openmpi | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    orte-top -h | grep "Usage"
    CHECK_RESULT $?
    orte-ps -h | grep "ompi-ps \[OPTIONS\]"
    CHECK_RESULT $?
    orte-server -h | grep "Usage"
    CHECK_RESULT $?
    orte-submit --allow-run-as-root -h | grep "Usage"
    CHECK_RESULT $?
    test "$(orte-submit --allow-run-as-root -V |
        grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa openmpi | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    orte-top -h | grep "Usage"
    CHECK_RESULT $?
    orted -h 2>&1 | grep "Usage"
    CHECK_RESULT $?
    orterun --allow-run-as-root -h | grep "Usage"
    CHECK_RESULT $?
    test "$(orterun --allow-run-as-root -V |
        grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa openmpi | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    oshmem_info -h | grep "Syntax"
    CHECK_RESULT $?
    test "$(oshmem_info -V |
        grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa openmpi | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    oshrun --allow-run-as-root -h | grep "Usage"
    CHECK_RESULT $?
    test "$(oshrun --allow-run-as-root -V |
        grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa openmpi | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    shmemrun --allow-run-as-root -h | grep "Usage"
    CHECK_RESULT $?
    test "$(shmemrun --allow-run-as-root -V |
        grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa openmpi | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./hello
    sed -i "/openmpi/d" $HOME/.bash_profile
    source $HOME/.bash_profile
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
