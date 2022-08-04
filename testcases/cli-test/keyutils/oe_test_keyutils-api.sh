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
# @Author    :   yangchenguang
# @Contact   :   yangchenguang@uniontech.com
# @Date      :   2022/08/02
# @License   :   Mulan PSL v2
# @Desc      :   Test keyutils api
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "keyutils gcc make"
    cp -arf /etc/request-key.conf /etc/request-key.conf.bak
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    pushd ./common
    make
    test -f test_key || exit 1
    echo 'create user mtk:* *   /bin/keyctl instantiate %k %c %S' >>/etc/request-key.conf
    ./test_key user mtk:key1 "Payload data" >tmp.log 2>&1
    key_id=$(cat tmp.log | awk '{print $NF}')
    grep ${key_id} /proc/keys
    CHECK_RESULT $? 0 0 "import key error"
    make clean
    popd
    LOG_INFO "Finish testing!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    mv -f /etc/request-key.conf.bak /etc/request-key.conf
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
