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
#@Author        :   wss1235
#@Contact       :   2115994138@qq.com
#@Date          :   2021-07-11 15:01:00
#@License       :   Mulan PSL v2
#@Version       :   1.0
#@Desc          :   command test attr
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    touch test && ln -s test test.lnk
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    attr -s "oe" -V "top" test | grep top
    CHECK_RESULT $? 0 0 "add attr failed"
    attr -g "oe" test | grep top
    CHECK_RESULT $? 0 0 "get attr failed"
    attr -l test | grep oe
    CHECK_RESULT $? 0 0 "list attr failed"
    attr -r oe test
    CHECK_RESULT $? 0 0 "remove attr failed"
    attr -Lq -s "oe" -V "top" test.lnk
    CHECK_RESULT $? 0 0 "add attr by link failed"
    attr -Rq -s "oe" -V "betop" test
    CHECK_RESULT $? 0 0 "add attr by root failed"
    attr -Sq -s "oe" -V "beentop" test
    CHECK_RESULT $? 0 0 "add attr by securty failed"
    setfattr -n user.oe -v extra -h test
    CHECK_RESULT $? 0 0 "set attr failed"
    getfattr -hRLP -n user.oe -d test
    CHECK_RESULT $? 0 0 "get attr failed"
    setfattr -x user.oe -h test
    CHECK_RESULT $? 0 0 "remove attr failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f test.lnk test
    LOG_INFO "End to restore the test environment."
}

main "$@"

