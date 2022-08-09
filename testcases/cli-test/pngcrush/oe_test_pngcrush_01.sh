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
# @Desc      	:   the test of pngcrush package
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL pngcrush
    test -d tmp || mkdir tmp
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."

    pngcrush -help 2>&1 | grep "usage: pngcrush"
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush --help"
    pngcrush -h 2>&1 | grep "usage: pngcrush"
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -h"

    pngcrush -version 2>&1 | grep "pngcrush [[:digit:]]"
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -version"

    pngcrush -blacken ./common/test.png ./tmp/test_blacken.png 2>&1 | grep "Ignoring invalid option: -blacken"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -blacken"
    test -f ./tmp/test_blacken.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -blacken"

    pngcrush -brute ./common/test.png ./tmp/test_brute.png 2>&1 | grep "Ignoring invalid option: -brute"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -brute"
    test -f ./tmp/test_brute.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -brute"

    pngcrush -check ./common/test.png ./tmp/test_check.png 2>&1 | grep "Ignoring invalid option: -check"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -check"
    test -f ./tmp/test_check.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -check"

    pngcrush -c 0 ./common/test.png ./tmp/test_c.png 2>&1 | grep "Ignoring invalid option: -c"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -c"
    test -f ./tmp/test_c.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -c"
    
    pngcrush -d ./tmp/test_d ./common/test.png 2>&1 | grep "Ignoring invalid option: -d"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -d"
    test -f ./tmp/test_d/test.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -d"
    
    pngcrush -e e.png -n ./common/test.png 2>&1 | grep "Ignoring invalid option: -e"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -e"

    pngcrush -f 0 ./common/test.png ./tmp/test_f.png 2>&1 | grep "Ignoring invalid option: -f"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -f"
    test -f ./tmp/test_f.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -f"

    pngcrush -fix ./common/test.png ./tmp/test_fix.png 2>&1 | grep "Ignoring invalid option: -fix"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -fix"
    test -f ./tmp/test_fix.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -fix"

    pngcrush -force ./common/test.png ./tmp/test_force.png 2>&1 | grep "Ignoring invalid option: -force"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -force"
    test -f ./tmp/test_force.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -force"

    pngcrush -g 0.45455 ./common/test.png ./tmp/test_g.png 2>&1 | grep "Ignoring invalid option: -g"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -g"
    test -f ./tmp/test_g.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -g"

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf ./tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"