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
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date          :   2021-08-16 14:00:43
#@License   	:   Mulan PSL v2
#@Desc          :   verification djvulibre's commnd
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL djvulibre
    cp ../common/test.pdf ./
    expect <<-END
    spawn any2djvu test.pdf
    expect "]:"
    send "yes\n"
    sleep 10
    expect eof
END
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    test -f test.djvu
    CHECK_RESULT $? 0 0 "Check test.djvu not exist."
    djvused --help >result 2>&1
    grep "Usage: djvused" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check djvused --help failed."
    djvused test.djvu -e output-all >file.dsed
    CHECK_RESULT $? 0 0 "Check djvused -e failed."
    test -f file.dsed
    CHECK_RESULT $? 0 0 "Check file.dsed not exist."
    djvused test.djvu -f file.dsed -s
    CHECK_RESULT $? 0 0 "Check djvused -f failed."
    djvuserve >result 2>&1
    grep "Usage: djvuserve" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check djvuserve help failed."
    djvuserve test.djvu | grep "Location: test.djvu"
    CHECK_RESULT $? 0 0 "Check djvused failed."
    djvutoxml --help >result 2>&1
    grep "Usage: djvutoxml" result && rm -rf result
    CHECK_RESULT $? 0 0 "Check djvutoxml --help failed."
    djvutoxml --with-anno test.djvu djvutoxml
    CHECK_RESULT $? 0 0 "Check djvutoxml --with-anno failed."
    test -f djvutoxml
    CHECK_RESULT $? 0 0 "Check djvutoxml not exist."
    djvutoxml --with-text test.djvu djvutoxml1
    CHECK_RESULT $? 0 0 "Check djvutoxml --with-text failed."
    test -f djvutoxml1
    CHECK_RESULT $? 0 0 "Check djvutoxml1 not exist."
    djvutoxml --page 1 test.djvu djvutoxml2
    CHECK_RESULT $? 0 0 "Check djvutoxml --page failed."
    test -f djvutoxml2
    CHECK_RESULT $? 0 0 "Check djvutoxml2 not exist."
    djvutxt >result 2>&1
    grep "Usage: djvutxt" result && rm -rf result
    CHECK_RESULT $?  0 0 "Check djvutxt failed."
    djvutxt -page=1 test.djvu djvutxt1
    CHECK_RESULT $?  0 0 "Check djvutxt --page failed."
    test -f djvutxt1
    CHECK_RESULT $? 0 0 "Check djvutxt1 not exist."
    djvutxt -detail=char test.djvu djvutxt2
    CHECK_RESULT $? 0 0 "Check djvutxt -detail=char failed."
    test -f djvutxt2
    CHECK_RESULT $? 0 0 "Check djvutxt2 not exist."
    djvutxt -escape test.djvu djvutxt3
    CHECK_RESULT $? 0 0 "Check djvutxt -escape failed."
    test -f djvutxt3
    CHECK_RESULT $? 0 0 "Check djvutxt3 not exist."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf $(ls | grep -v '\.sh')
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
