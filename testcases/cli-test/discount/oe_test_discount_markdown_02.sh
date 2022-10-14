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
    test -d tmp || mkdir tmp
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."

    markdown -o ./tmp/test.html ./common/test.md
    test -f ./tmp/test.html
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -o"

    markdown -E test_e ./common/test.md 2>&1 | grep "test_e"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -E"

    markdown -5 ./common/test.md 2>&1 | grep '<p><section>test_h5'
    CHECK_RESULT $? 1 0 "Failed to run command: markdown -5"

    markdown -html5 ./common/test.md 2>&1 | grep '<p><section>test_h5'
    CHECK_RESULT $? 1 0 "Failed to run command: markdown -html5"

    markdown -T ./common/test.md 2>&1 | grep '<li><a href="#test_T">test'
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -T"

    markdown -toc ./common/test.md 2>&1 | grep '<li><a href="#test_toc">test'
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -toc"

    markdown -F 1 ./common/test.md 2>&1 | grep "<a>"
    CHECK_RESULT $? 1 0 "Failed to run command: markdown -F"  

    markdown -G ./common/test.md 2>&1 | grep "test&lt;"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -G"
    
    markdown -s '#test' 2>&1 | grep "<h1>"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -s"

    markdown -t '*test*' 2>&1 | grep "<em>"
    CHECK_RESULT $? 0 0 "Failed to run command: markdown -t"

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"