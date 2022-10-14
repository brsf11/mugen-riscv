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

    pngcrush -save ./common/test.png ./tmp/test_save.png 2>&1 | grep "Ignoring invalid option: -save"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -save"
    test -f ./tmp/test_save.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -save" 

    pngcrush -speed ./common/test.png ./tmp/test_speed.png 2>&1 | grep "Ignoring invalid option: -speed"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -speed"
    test -f ./tmp/test_speed.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -speed" 

    pngcrush -srgb 0 ./common/test.png ./tmp/test_srgb.png 2>&1 | grep "Ignoring invalid option: -srgb"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -srgb"
    test -f ./tmp/test_srgb.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -srgb" 

    pngcrush -ster 0 ./common/test.png ./tmp/test_ster.png 2>&1 | grep "Ignoring invalid option: -ster"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -ster"
    test -f ./tmp/test_ster.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -ster" 

    pngcrush -z 0 ./common/test.png ./tmp/test_z.png 2>&1 | grep "Ignoring invalid option: -z"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -z"
    test -f ./tmp/test_z.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -z" 

    pngcrush -w 32 ./common/test.png ./tmp/test_w.png 2>&1 | grep "Ignoring invalid option: -w"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -w"
    test -f ./tmp/test_w.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -w" 

    pngcrush -warn ./common/test.png ./tmp/test_warn.png
    test -f ./tmp/test_warn.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -warn" 

    pngcrush -zmem 1 ./common/test.png ./tmp/test_zmem.png 2>&1 | grep "Ignoring invalid option: -zmem"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -zmem"
    test -f ./tmp/test_zmem.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -zmem" 

    pngcrush -text b "Text" "test" ./common/test.png ./tmp/test_text.png 2>&1 | grep "Ignoring invalid option: -text"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -text"
    test -f ./tmp/test_text.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -text" 

    pngcrush -ow -v ./common/test.png 2>&1 | grep "pngcrush-" | grep "[[:digit:]]*" 
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -v"
    pngcrush -ow -v ./common/test.png 
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -ow" 


    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf ./tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"