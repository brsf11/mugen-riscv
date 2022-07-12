#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/11/17
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of ruby command
# ############################################

source "../common/common_ruby.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ruby
    VERSION_ID=$(grep "VERSION_ID" /etc/os-release | awk -F '\"' '{print$2}')
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mkdir hello
    CHECK_RESULT $?
    cp ../common/hello.rb hello/hello2.rb
    CHECK_RESULT $?
    ruby -h | grep -E "Usage: ruby|-"
    CHECK_RESULT $?
    ruby -v | grep "ruby"
    CHECK_RESULT $?
    ruby -0 ../common/main.rb | grep -i "Customer"
    CHECK_RESULT $?
    expect <<EOF
        log_file result
        spawn ruby -a -p ../common/main.rb
        expect "" {send "\r"}
        expect " " {send "\r"}
        expect "" {send "\r"}
        expect " " {send "\r"}
        expect "" {send "\r"}
        expect " " {send "\r"}
        expect " " { send "\03"}
        expect eof
EOF
    grep "Customer id 1" result
    CHECK_RESULT $?
    ruby -c ../common/main.rb | grep "Syntax OK"
    CHECK_RESULT $?
    ruby -C hello hello2.rb | grep "Hello World!"
    CHECK_RESULT $?
    ruby -d ../common/main.rb >runlog 2>&1
    CHECK_RESULT $?
    grep -iE "Customer|Exception|warning" runlog
    CHECK_RESULT $?
    ruby -e 'puts "hello China!"' | grep "hello China!"
    CHECK_RESULT $?
    echo 'matz' >junk
    CHECK_RESULT $?
    ruby -p -i.bak -e '$_.upcase!' junk
    CHECK_RESULT $?
    grep "matz" junk.bak
    CHECK_RESULT $?
    grep "MATZ" junk
    CHECK_RESULT $?
    ruby -I hello ../common/hello.rb | grep "Hello World!"
    CHECK_RESULT $?
    ruby -w -e 'x = 10; print (1 + x)' | grep "11"
    CHECK_RESULT $?
    ruby -l -w -e 'x = 10; print (1 + x)' | grep "11"
    CHECK_RESULT $?
    echo 'matz' | ruby -p -e '$_.tr! "a-z", "A-Z"' | grep "MATZ"
    CHECK_RESULT $?
    ruby -r 'prime' ../common/test.rb | grep -E "2, 3, 5, 7|Hello World!"
    CHECK_RESULT $?
    if [ $VERSION_ID != "22.03" ]; then
       ruby -T1 ../common/hello.rb | grep "Hello World!"
       CHECK_RESULT $?
    fi
    ruby -w -r 'prime' ../common/test.rb >runlog 2>&1
    CHECK_RESULT $?
    grep -E "warning|2, 3, 5, 7|Hello World!" runlog
    CHECK_RESULT $?
    ruby -W2 -r 'prime' ../common/test.rb >runlog 2>&1
    CHECK_RESULT $?
    grep -E "warning|2, 3, 5, 7|Hello World!" runlog
    CHECK_RESULT $?
    ruby -W1 -r 'prime' ../common/test.rb | grep -E "2, 3, 5, 7|Hello World!"
    CHECK_RESULT $?
    ruby -xhello hello2.rb | grep "Hello World!"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    delete_files
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
