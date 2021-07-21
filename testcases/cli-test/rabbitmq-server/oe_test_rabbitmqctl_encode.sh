#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Testing rabbitmq-server command parameters
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL rabbitmq-server
    which firewalld && systemctl stop firewalld
    systemctl restart rabbitmq-server
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    mem_size=$(free -g | grep Mem | awk '{print $2}')
    if [ "${mem_size}" -gt 1 ]; then
        rabbitmqctl set_vm_memory_high_watermark absolute 1G | grep "1G bytes"
        CHECK_RESULT $?
    else
        LOG_INFO "The current environment does not meet the test conditions!"
    fi
    rabbitmqctl set_disk_free_limit 1G | grep "1G bytes"
    CHECK_RESULT $?
    rabbitmqctl set_disk_free_limit mem_relative 2.0 | grep "2.0 times"
    CHECK_RESULT $?
    rabbitmqctl encode '<<"guest">>' mypassphrase | grep "encrypted"
    CHECK_RESULT $?
    encode=$(rabbitmqctl encode '<<"guest">>' mypassphrase | grep encrypted | awk -F "\"" '{print $2}')
    encode_hash=$(rabbitmqctl encode --cipher blowfish_cfb64 --hash sha256 --iterations 10000 '<<"guest">>' mypassphrase | grep encrypted | awk -F "\"" '{print $2}')
    CHECK_RESULT $?
    rabbitmqctl decode "{encrypted, <<\"${encode}\">>}" mypassphrase | grep "guest"
    CHECK_RESULT $?
    rabbitmqctl decode --cipher blowfish_cfb64 --hash sha256 --iterations 10000 \
        "{encrypted,<<\"${encode_hash}\">>}" mypassphrase | grep "guest"
    CHECK_RESULT $?
    rabbitmqctl list_hashes | grep "sha"
    CHECK_RESULT $?
    rabbitmqctl list_ciphers | grep "des"
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop rabbitmq-server
    DNF_REMOVE
    rm -rf /var/lib/rabbitmq/
    kill -9 $(pgrep -u rabbitmq)
    which firewalld && systemctl start firewalld
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
