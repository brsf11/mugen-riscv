#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   huangrong
# @Contact   :   huang_rong2@hoperun.com
# @Date      :   2022/01/06
# @License   :   Mulan PSL v2
# @Desc      :   resource mapping
# #############################################

source "./common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    iSulad_install
    LOG_INFO "Start to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    isula run -itd --name volume -v vol:/vol:rw,nocopy centos
    CHECK_RESULT $? 0 0 "create container failed"
    expect <<EOF
        spawn isula exec -it volume
        expect {
            "root@localhost*" {
                send "cd /vol\\r"
            }
        }
        expect {
            "root@localhost*" {
                send "echo 'hello world' > test\\r"
            }
        }
        expect {
            "root@localhost*" {
                send "exit\\r"
            }
        }
        expect eof
EOF
    grep "hello world" /var/lib/isulad/volumes/vol/_data/test
    CHECK_RESULT $? 0 0 "resource mapping failed"
    isula run -itd --name volume1 --mount type=volume,src=vol1,dst=/vol1,volume-nocopy=true centos
    CHECK_RESULT $? 0 0 "create container failed"
    expect <<EOF
        spawn isula exec -it volume1
        expect {
            "root@localhost*" {
                send "cd /vol1\\r"
            }
        }
        expect {
            "root@localhost*" {
                send "echo 'hello world' > test\\r"
            }
        }
        expect {
            "root@localhost*" {
                send "exit\\r"
            }
        }
        expect eof
EOF
    grep "hello world" /var/lib/isulad/volumes/vol1/_data/test
    CHECK_RESULT $? 0 0 "resource mapping failed"
    isula run -itd --name volume2 --volumes-from volume --volumes-from volume1 centos
    CHECK_RESULT $? 0 0 "create container failed"
    expect <<EOF
        log_file /tmp/log_volume
        spawn isula exec -it volume2
        expect {
            "root@localhost*" {
                send "grep 'hello world' /vol/test\\r"
            }
        }
        expect {
            "root@localhost*" {
                send "grep 'hello world' /vol1/test\\r"
            }
        }
        expect {
            "root@localhost*" {
                send "exit\\r"
            }
        }
        expect eof
EOF
    test "$(grep -c 'hello world' /tmp/log_volume)" -eq 4
    CHECK_RESULT $? 0 0 "resource mapping failed"
    isula stop volume volume1 volume2
    isula rm volume volume1 volume2
    grep "hello world" /var/lib/isulad/volumes/vol/_data/test
    CHECK_RESULT $? 0 0 "resource mapping failed"
    grep "hello world" /var/lib/isulad/volumes/vol1/_data/test
    CHECK_RESULT $? 0 0 "resource mapping failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    isula rmi centos
    iSulad_remove
    rm -rf /tmp/log_volume
    LOG_INFO "End to restore the test environment"
}

main "$@"
