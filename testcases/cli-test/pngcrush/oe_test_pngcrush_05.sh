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

    pngcrush -zitxt b "test" "test" "test" "test" ./common/test.png ./tmp/test_zitxt.png 2>&1 | grep "Ignoring invalid option: -zitxt"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -zitxt"
    test -f ./tmp/test_zitxt.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -zitxt" 

    pngcrush -trns 1 1 1 1 1 ./common/test.png ./tmp/test_trns.png 2>&1 | grep "Ignoring invalid option: -trns"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -trns"
    test -f ./tmp/test_trns.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -trns" 

    pngcrush -itxt b "test" "test" "test" "test" ./common/test.png ./tmp/test_itxt.png 2>&1 | grep "Ignoring invalid option: -itxt"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -itxt"
    test -f ./tmp/test_itxt.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -itxt" 

    pngcrush -iccp 1 "test" ./common/test.png ./common/test.png ./tmp/test_iccp.png 2>&1 | grep "Ignoring invalid option: -iccp"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -iccp"
    test -f ./tmp/test_iccp.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -iccp" 

    echo -ne '\n' 2>&1 | pngcrush -p -n ./common/test.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -p" 

    pngcrush -loco ./common/test.png 2>&1 | grep "Ignoring invalid option: -loco"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -loco"

    pngcrush -mng ./tmp/test.mng ./common/test.png 2>&1 | grep "Ignoring invalid option: -mng"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -mng"

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf ./tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"