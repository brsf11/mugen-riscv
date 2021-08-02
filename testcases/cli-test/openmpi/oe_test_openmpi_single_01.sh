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
    test "$(mpiexec --version |
        grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa openmpi | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    mpiexec --allow-run-as-root -h | grep "Usage"
    CHECK_RESULT $?
    mpicc hello.c -o hello
    test -f hello
    CHECK_RESULT $?
    mpiexec --allow-run-as-root -np 4 ./hello 2>&1 | grep "Hello"
    CHECK_RESULT $?
    test "$(mpirun --version |
        grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa openmpi | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    mpirun --allow-run-as-root -h | grep "Usage"
    CHECK_RESULT $?
    mpirun --allow-run-as-root -np 4 ./hello 2>&1 | grep "Hello"
    CHECK_RESULT $?
    ompi-clean -h | grep "ompi-clean \[OPTIONS\]"
    CHECK_RESULT $?
    ompi-dvm --allow-run-as-root -h | grep "Usage"
    CHECK_RESULT $?
    ompi-dvm --allow-run-as-root -V | grep -E "ompi-dvm.*[0-9].[0-9].[0-9]"
    CHECK_RESULT $?
    ompi-ps -h | grep "ompi-ps \[OPTIONS\]"
    CHECK_RESULT $?
    ompi-server -h | grep "Usage"
    CHECK_RESULT $?
    ompi-submit --allow-run-as-root -h | grep "Usage"
    CHECK_RESULT $?
    test "$(ompi-submit --allow-run-as-root -V |
        grep -Eo "[0-9]\.[0-9]\.[0-9]")" == "$(rpm -qa openmpi | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    ompi-top -h | grep "Usage"
    CHECK_RESULT $?
    ompi_info -h | grep "Syntax"
    CHECK_RESULT $?
    test "$(ompi_info -V | grep -Eo "[0-9]\.[0-9]\.[0-9]")" == \
        "$(rpm -qa openmpi | awk -F "-" '{print$2}')"
    CHECK_RESULT $?
    test "$(ompi_info 2>&1 | grep "Open MPI:" |
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
