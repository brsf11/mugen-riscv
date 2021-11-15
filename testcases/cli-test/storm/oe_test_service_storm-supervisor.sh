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
# @Desc      :   Test storm-supervisor.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "storm apache-zookeeper"
    echo "storm.zookeeper.servers:
      - \"127.0.0.1\"
nimbus.host: \"127.0.0.1\"
storm.local.dir: \"/etc/storm/data\"
ui.port: 8080
supervisor.slotd.ports :
      - 6700
      - 6701
      - 6702
      - 6703
" >/etc/storm/storm.yaml
    systemctl start zookeeper.service
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution storm-supervisor.service
    test_reload storm-supervisor.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop zookeeper.service
    systemctl stop storm-supervisor.service
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
