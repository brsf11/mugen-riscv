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
#@Desc      	:   verification sqlite‘s DEFAULT define  command
#####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test()
{
    LOG_INFO "Start to run test." 
    expect <<-END
    spawn sqlite3 ../common/test.db
    send "CREATE TABLE COMPANY(
          ID INT PRIMARY KEY     NOT NULL,
          NAME           TEXT    NOT NULL,
          AGE            INT     DEFAULT 28
        );\n"
    expect "sqlite>"
    send ".output ../common/output.txt\n"
    expect "sqlite>"
    send "INSERT INTO COMPANY (ID,NAME) VALUES (1, 'Paul' );\n"
    expect "sqlite>"
    send "select *from COMPANY;\n"
    expect "sqlite>"
    send ".quit\n"
    expect eof
    exit
END
    CHECK_RESULT "$(cat ../common/output.txt | grep -cE "28")" 1
    LOG_INFO "End to run test."
}
function post_test()
{
    LOG_INFO "Start to restore the test environment."
    rm -rf ../common/test.db
    rm -rf ../common/output.txt
    LOG_INFO "End to restore the test environment."
}
main "$@"
