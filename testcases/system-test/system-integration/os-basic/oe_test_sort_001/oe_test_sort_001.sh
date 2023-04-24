#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.


source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    cat  > sort_test.txt  << EOF
big
friend
apple
big
big
big
friend
apple peach
EOF
    cat > sort_test1.txt << EOF
hello
world
EOF
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    res=$(sort -u sort_test.txt | tail -2 | head -1)
    [ "$res" == "big" ]
    CHECK_RESULT $?
    count=$(sort -u sort_test.txt | grep -c big)
    CHECK_RESULT $count 1
    sort -r sort_test.txt | head -1 | grep friend
    CHECK_RESULT $? 0 0 "sort -r failed"
    res=$(sort -m sort_test.txt sort_test1.txt | grep -E "peach|hello" | head -1)
    [ "$res" == "apple peach" ]
    CHECK_RESULT $? 0 0 "sort -m failed"
    res=$(sort -m sort_test.txt sort_test1.txt | grep -E "peach|hello" | tail -1)
    [ "$res" == "hello" ]
    CHECK_RESULT $? 0 0 "sort -m failed"
    sort --help > /dev/null 2>&1
    CHECK_RESULT $? 0 0 "sort help faild"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ./sort_test*
    LOG_INFO "Finish environment cleanup!"
}

main $@
