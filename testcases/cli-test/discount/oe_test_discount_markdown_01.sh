# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    	:   zu binshuo
# @Contact   	:   binshuo@isrc.iscas.ac.cn
# @Date      	:   2022-7-15
# @License   	:   Mulan PSL v2
# @Desc      	:   the test of discount package
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL discount
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."

    markdown --version 2>&1 | grep "discount [[:digit:]]*"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown --version"

    markdown -V 2>&1 | grep "discount [[:digit:]]*"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -V"

    markdown -VV 2>&1 | grep "discount [[:digit:]]*"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -VV"

    markdown -b test_b ./common/test.md 2>&1 | grep "test_b"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -b"

    markdown -base test_b ./common/test.md 2>&1 | grep "test_b"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -base"

    markdown -d ./common/test.md 2>&1 | grep "source"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -d"     

    markdown -debug ./common/test.md 2>&1 | grep "source"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -debug"

    markdown -f-links ./common/test.md 2>&1 | grep "href"
    CHECK_RESULT $? 1 0 "Failed to run command: markdown -f"   

    markdown -n ./common/test.md
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -n"

    markdown -S ./common/test.md 2>&1 | grep "<style>"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -S"

    markdown -style ./common/test.md 2>&1 | grep "<style>"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -style"

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"