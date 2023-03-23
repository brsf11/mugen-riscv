#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/06/14
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of libuser
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cp /etc/libuser.conf /etc/libuser.conf.bak
    sed -i 's/crypt_style =.*/crypt_style = sha256/' /etc/libuser.conf
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    luseradd ltestuser
    CHECK_RESULT $? 0 0 "Failed to execute luseradd"
    echo -e "${NODE1_PASSWORD}\n${NODE1_PASSWORD}" | lpasswd ltestuser
    CHECK_RESULT $? 0 0 "Failed to execute lpasswd"
    grep user /etc/shadow | grep '\$5\$'
    CHECK_RESULT $? 0 0 "Failed to display user"
    expect <<EOF1
        log_file testlog
        spawn ssh ltestuser@${NODE1_IPV4}
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "assword:" {
                send "${NODE1_PASSWORD}\\r"
            }
        }
        expect {
            "]*" {
                exit\\r"
            }
        }
        expect eof
EOF1
    grep "ltestuser@" testlog
    CHECK_RESULT $? 0 0 "Failed to display ltestuser"
    sed -i 's/crypt_style =.*/crypt_style = sm3/' /etc/libuser.conf
    CHECK_RESULT $? 0 0 "Failed to execute sed"
    if grep -iE "SP3|22.03" /etc/os-release; then
        id -u testuser || useradd testuser
        CHECK_RESULT $? 0 0 "Failed to execute useradd"
        echo -e "${NODE1_PASSWORD}\n${NODE1_PASSWORD}" | lpasswd testuser
        CHECK_RESULT $? 0 0 "Failed to execute lpasswd testuser"
        grep user /etc/shadow | grep '\$sm3\$'
        CHECK_RESULT $? 0 0 "Failed to display sm3"
        rm -rf testlog
        expect <<EOF1
            log_file testlog
            spawn ssh testuser@${NODE1_IPV4}
            expect {
                "*yes/no*" {
                    send "yes\\r"
                }
            }
            expect {
                "assword:" {
                    send "${NODE1_PASSWORD}\\r"
                }
            }
            expect {
                "]*" {
                    exit\\r"
                }
            }
            expect eof
EOF1
        grep -C 10 "testuser@" testlog | grep -i "welcome to"
        CHECK_RESULT $? 0 0 "Failed to display testuser"
    fi
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    mv -f /etc/libuser.conf.bak /etc/libuser.conf
    luserdel -r ltestuser
    userdel -rf testuser
    rm -rf testlog
    LOG_INFO "End to restore the test environment."
}

main "$@"
