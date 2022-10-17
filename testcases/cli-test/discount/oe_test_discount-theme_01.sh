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

    discount-theme -V 2>&1 | grep "theme+discount [[:digit:]]*"
    CHECK_RESULT $? 0 0 "Failed to run command: discount-theme -V"

    discount-theme -o ./tmp/test_o.html ./common/test.md
    test -f ./tmp/test_o.html
    CHECK_RESULT $? 0 0 "Failed to run command: discount-theme -o"

    discount-theme -f -o ./tmp/test_f.html ./common/test.md
    test -f ./tmp/test_f.html
    CHECK_RESULT $? 0 0 "Failed to run command: discount-theme -f"

    discount-theme -C 1 -o ./tmp/test_C.html ./common/test.md 
    cat ./tmp/test_C.html 2>&1 | grep "[test]"
    CHECK_RESULT $? 0 0 "Failed to run command: discount-theme -C"

    discount-theme -c-links -o ./tmp/test_c.html ./common/test.md
    cat ./tmp/test_c.html 2>&1 | grep "href"
    CHECK_RESULT $? 1 0 "Failed to run command: discount-theme -c"   

    discount-theme -E -o ./tmp/test_E.html ./common/test.md
    test -f ./tmp/test_E.html
    CHECK_RESULT $? 0 0 "Failed to run command: discount-theme -E"   

    discount-theme -d ./tmp -o ./tmp/test_d.html ./common/test.md
    test -f ./tmp/test_d.html
    CHECK_RESULT $? 0 0 "Failed to run command: discount-theme -d"   

    discount-theme -p test -o ./tmp/test_p.html ./common/test.md
    test -f ./tmp/test_p.html
    CHECK_RESULT $? 0 0 "Failed to run command: discount-theme -p"   

    discount-theme -o ./tmp/test_t.html -t ./common/test.css ./common/test.md
    test -f ./tmp/test_t.html
    CHECK_RESULT $? 0 0 "Failed to run command: discount-theme -t"   

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"