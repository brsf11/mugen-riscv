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
#@Author    	:   meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2021-08-10
#@License   	:   Mulan PSL v2
#@Desc      	:   Check ipsec showhostkey/nss/cavp
#####################################

source ./common/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    SET_CONF
    ADD_CONN
    ipsec rsasigkey &> getkey
    ckaid=$(tail -n 1 getkey | awk '{print $12}')

    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."

    # test ipsec showhostkey
    ipsec showhostkey --version >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec pluto --version failed."
    ipsec showhostkey --dump
    CHECK_RESULT $? 0 0 "Check ipsec pluto --dump failed."
    ipsec showhostkey --list
    CHECK_RESULT $? 0 0 "Check ipsec pluto --list failed."
    ipsec showhostkey --left --ckaid $ckaid --nssdir /var/lib/ipsec/nss <<EOF
test
test
EOF
    CHECK_RESULT $? 0 0 "Check ipsec pluto --left failed."
    ipsec showhostkey --ipseckey --ckaid $ckaid >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec pluto --ipseckey failed."

    # test ipsec nss
    ipsec checknss --nssdir /var/lib/ipsec/nss >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec checknss failed."
    ls /var/lib/ipsec/nss | grep key4.db
    CHECK_RESULT $? 0 0 "Create db file failed."
    ipsec import --nssdir /var/lib/ipsec/nss
    CHECK_RESULT $? 0 0 "Check ipsec import failed."
    rm -f /var/lib/ipsec/nss/*.db
    ipsec initnss >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec initnss failed."

    # test ipsec ipsec cavp
    ipsec cavp -h >/dev/null
    CHECK_RESULT $? 0 0 "Check ipsec cavp help message failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -f getkey
    REVERT_CONF

    LOG_INFO "End to restore the test environment."
}

main "$@"

