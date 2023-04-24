#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   chengweibin
# @Contact   :   chengweibin@uniontech.com
# @Date      :   2022-10-21
# @License   :   Mulan PSL v2
# @Desc      :   smoke basic os test-golang
# ############################################
source "$OET_PATH/libs/locallibs/common_lib.sh"


function pre_test(){
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "golang"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    cat > hello.go << EOF
package main

import (
    "fmt"
)

func main() {
    fmt.Println("Hello World! Welcome to Go Lang!")
}
EOF


    go build hello.go
    CHECK_RESULT $? 0 0 "build hello.go failed"

    ./hello | grep "Hello World! Welcome to Go Lang!"
    CHECK_RESULT $? 0 0 "./hello failed"
    LOG_INFO "Finish test!"
}
function post_test(){
    LOG_INFO "start environment cleanup."
    rm -rf hello.go hello
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@
