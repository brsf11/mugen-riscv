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
#@Date      	:   2020-07-02 09:00:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification sqlite‘s UPPER/LOWER/LENGTH function
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    version=$(sqlite3 -version | awk '{print $1}')
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    expect <<-END
    spawn sqlite3 ./test.db
    send "CREATE TABLE COMPANY(
        ID INT PRIMARY KEY     NOT NULL,
        NAME    TEXT    NOT NULL,
        AGE     INT     NOT NULL,
        ADDRESS CHAR(50),
        SALARY  REAL    CHECK(SALARY > 0)
        );\n"
    expect "sqlite>"
    send ".read ../common/insert.txt\n"
    expect "sqlite>"
    send ".output ./output.txt\n"
    expect "sqlite>"
    send "SELECT upper(name) FROM COMPANY WHERE ID = 6;\n"
    expect "sqlite>"
    send "SELECT lower(name) FROM COMPANY WHERE ID = 6;\n"
    expect "sqlite>"
    send "SELECT length(name) FROM COMPANY WHERE ID = 6;\n"
    expect "sqlite>"
    send "SELECT sqlite_version() AS 'SQLite Version';\n"
    expect "sqlite>"
    send ".quit\n"
    expect eof
END
    CHECK_RESULT "$(awk 'NR==1' ./output.txt | grep -cE 'KIM')" 1
    CHECK_RESULT "$(awk 'NR==2' ./output.txt | grep -cE 'kim')" 1
    CHECK_RESULT "$(awk 'NR==3' ./output.txt)" 3
    CHECK_RESULT "$(awk 'NR==4' ./output.txt)" $version
    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf ./test.db ./output.txt
    LOG_INFO "End to restore the test environment."
}
main "$@"
