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
#@Author    	:   wangqing
#@Contact   	:   wangqing@uniontech.com
#@Date      	:   2021-08-10
#@License   	:   Mulan PSL v2
#@Desc      	:   Test cracklib command
#####################################

source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    cat >"test-data" <<EOF
antzer
G@ndalf
neulinger
lantzer
Pa\$\$w0rd
PaS\$W0rd
Pas\$w0rd
Pas\$W0rd
Pa\$sw0rd
Pa\$sW0rd
EOF

    cat >"format-data" <<EOF
antzer
g@ndalf
lantzer
neulinger
pa\$\$w0rd
pa\$sw0rd
pas\$w0rd
EOF
    echo -e "2948_Obaym-" >pw_dict.new

    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    ### test: cracklib-check
    LOG_INFO "Test: cracklib-check"
    LOG_INFO "cracklib: Test a very simple password"
    echo -e "test" | cracklib-check | grep -q "too short"
    CHECK_RESULT $? 0 0 "cracklib-check failed..."

    LOG_INFO "cracklib: Test a simple/dictionary password"
    echo -e "testing" | cracklib-check | grep -q "dictionary"
    CHECK_RESULT $? 0 0 "cracklib-check failed..."

    LOG_INFO "cracklib: Testing simplistic password"
    echo -e "1234_abc" | cracklib-check | grep -q 'simplistic'
    CHECK_RESULT $? 0 0 "cracklib-check failed..."

    LOG_INFO "cracklib: Testing a complicated password"
    echo -e "2948_Obaym-" | cracklib-check | grep -q "OK"
    CHECK_RESULT $? 0 0 "cracklib-check failed..."

    ### test: cracklib-format
    LOG_INFO "Test: cracklib-format"
    cracklib-format test-data >format-dict
    CHECK_RESULT $? 0 0 "cracklib-foramt failed..."
    diff format-data format-dict >/dev/null
    CHECK_RESULT $? 0 0 "cracklib-foramt result error..."

    ### test: mkdict
    LOG_INFO "Test: mkdict"
    cracklib-format test-data >mkdict
    CHECK_RESULT $? 0 0 "mkdict failed..."
    diff format-data mkdict >/dev/null
    CHECK_RESULT $? 0 0 "mkdict result error..."

    ### test: cracklib-packer
    LOG_INFO "Test: cracklib-packer"
    cracklib-format test-data | cracklib-packer words
    CHECK_RESULT $? 0 0 "cracklib-packer failed..."
    [ -f words.hwm -a -f words.pwd -a -f words.pwi ]
    CHECK_RESULT $? 0 0 "cracklib-packer error: data is not exist..."

    ### test: packer
    LOG_INFO "Test: packer"
    cracklib-format test-data | packer packers
    CHECK_RESULT $? 0 0 "packer failed..."
    [ -f packers.hwm -a -f packers.pwd -a -f packers.pwi ]
    CHECK_RESULT $? 0 0 "packer error: data is not exist..."

    ### test: cracklib-unpacker
    LOG_INFO "Test: cracklib-unpacker"
    cracklib-unpacker words >unpacker-data
    CHECK_RESULT $? 0 0 "cracklib-unpacker failed..."
    diff format-data unpacker-data >/dev/null
    CHECK_RESULT $? 0 0 "cracklib-unpacker result error..."

    ### test: create-cracklib-dict
    LOG_INFO "Test: create-cracklib-dict"
    cracklib-unpacker /usr/share/cracklib/pw_dict >pw_dict.orig
    CHECK_RESULT $? 0 0 "Failed to backup original data..."

    create-cracklib-dict pw_dict.new
    CHECK_RESULT $? 0 0 "create-cracklib-dict failed..."
    echo -e "2948_Obaym-" | cracklib-check | grep -q "dictionary"
    CHECK_RESULT $? 0 0 "create-cracklib-dict error..."

    create-cracklib-dict pw_dict.orig
    CHECK_RESULT $? 0 0 "create-cracklib-dict failed..."
    echo -e "2948_Obaym-" | cracklib-check | grep -q "OK"
    CHECK_RESULT $? 0 0 "create-cracklib-dict error..."

    ### test: create-cracklib-dict -o
    create-cracklib-dict -o output test-data
    CHECK_RESULT $? 0 0 "create-cracklib-dict option --output failed..."
    [ -f output.hwm -a -f output.pwd -a -f output.pwi ]
    CHECK_RESULT $? 0 0 "cracklib-packer error: data is not exist..."

    ### test: create-cracklib-dict -h
    create-cracklib-dict -h | grep -q "This help output"
    CHECK_RESULT $? 0 0 "create-cracklib-dict option --help failed..."

    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f "pw_dict.orig" "pw_dict.new" "test-data" "format-data" "unpacker-data" "format-dict"
    rm -f "output.hwm" "output.pwd" "output.pwi" "packer.hwm" "packers.pwd" "packers.pwi" "words.hwm" "words.pwd" "words.pwi"
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
