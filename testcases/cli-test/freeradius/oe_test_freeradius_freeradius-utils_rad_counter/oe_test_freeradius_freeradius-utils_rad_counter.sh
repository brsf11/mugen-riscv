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
#@Author        :   wangjingfeng
#@Contact       :   1136232498@qq.com
#@Date          :   2020/12/24
#@License       :   Mulan PSL v2
#@Desc          :   freeradius-utils command parameter automation use case
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    DNF_INSTALL "freeradius freeradius-utils"
    ln -s /etc/raddb/mods-available/counter /etc/raddb/mods-enabled/counter
    systemctl start radiusd
    SLEEP_WAIT 2

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    rad_counter --file /etc/raddb/db.daily --user test
    CHECK_RESULT $? 0 0 "rad_counter --user execution failed."
    rad_counter --file /etc/raddb/db.daily --match ^te
    CHECK_RESULT $? 0 0 "rad_counter --match execution failed."
    rad_counter --file /etc/raddb/db.daily --reset 1
    CHECK_RESULT $? 0 0 "rad_counter --reset execution failed."
    rad_counter --help | grep -i "usage"
    CHECK_RESULT $? 0 0 "rad_counter --help execution failed."
    rad_counter --file /etc/raddb/db.daily --hours 1
    CHECK_RESULT $? 0 0 "rad_counter --hours execution failed."
    rad_counter --file /etc/raddb/db.daily --minutes 1
    CHECK_RESULT $? 0 0 "rad_counter --minutes execution failed."
    rad_counter --file /etc/raddb/db.daily --seconds 1
    CHECK_RESULT $? 0 0 "rad_counter --seconds execution failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    systemctl stop radiusd
    DNF_REMOVE
    rm -rf /etc/raddb
    rm -rf /var/log/radius

    LOG_INFO "End to restore the test environment."
}

main "$@"
