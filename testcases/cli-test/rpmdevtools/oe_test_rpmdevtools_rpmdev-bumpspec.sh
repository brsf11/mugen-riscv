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
#@Author    	:   caimingxiang
#@Contact   	:   mingxiang@isrc.iscas.ac.cn
#@Date      	:   2022-3-18 19:37:00
#@License   	:   Mulan PSL v2
#@Desc      	:   test rpmdev-bumpspec rpmdev-newinit rpmdev-newspec
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test(){
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "rpmdevtools"

    rpmdev-newspec -o test.spec
    echo "test -f." > file1

    LOG_INFO "End of environmental preparation."
}

function run_test(){
    LOG_INFO "Start testing."

    rpmdev-bumpspec -h | grep 'rpmdev-bumpspec'
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmdev-bumpspec -c "test1" test.spec
    cat test.spec | grep 'test1'
    CHECK_RESULT $? 0 0 "Failed option: -c"
    rpmdev-bumpspec -V test.spec | grep 'test.spec'
    CHECK_RESULT $? 0 0 "Failed option: -V"
    rpmdev-bumpspec -v
    CHECK_RESULT $? 0 0 "Failed option: -v"	
    rpmdev-bumpspec -u test_name\ xxxxxxxxxx@qq.com test.spec
    cat test.spec | grep 'test_name'
    CHECK_RESULT $? 0 0 "Failed option: -u"
    rpmdev-bumpspec -f file1 test.spec
    cat test.spec | grep '^-\ test\ -f.'
    CHECK_RESULT $? 0 0 "Failed option: -f"
    rpmdev-bumpspec -r test.spec
    CHECK_RESULT $? 0 0 "Failed option: -r"
    rpmdev-bumpspec -s release test.spec
    CHECK_RESULT $? 0 0 "Failed option: -s"
    rpmdev-bumpspec -n new_test test.spec
    CHECK_RESULT $? 0 0 "Failed option: -n"

    rpmdev-newinit -v | grep 'rpmdev-newinit' 
    CHECK_RESULT $? 0 0 "Failed options: -v"
    rpmdev-newinit -h | grep 'rpmdev-newinit'
    CHECK_RESULT $? 0 0 "Failed options: -h"
    rpmdev-newinit -o test.init
    test -f ./test.init 
    CHECK_RESULT $? 0 0 "Failted options: -o"

    rpmdev-newspec -o testo.spec
    test -f testo.spec
    CHECK_RESULT $? 0 0 "Failed option: -o"
    rpmdev-newspec -t python -o testt.spec
    cat testt.spec | grep 'python'
    CHECK_RESULT $? 0 0 "Failed option: -t"
    rpmdev-newspec -m -o testm.spec
    cat testm.spec | grep '%{buildroot}'
    CHECK_RESULT $? 0 0 "Failed option: -m"
    rpmdev-newspec -r 4.3 -o testr.spec | grep '4.3'
    CHECK_RESULT $? 0 0 "Failed option: -r"
    rpmdev-newspec -h | grep 'rpmdev-newspec'
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmdev-newspec -v | grep 'rpmdev-newspec'
    CHECK_RESULT $? 0 0 "Failed option: -v"

    LOG_INFO "End to run test."
}

function post_test(){
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf test* file1
    LOG_INFO "End to restore the test environment."
}

main "$@"




