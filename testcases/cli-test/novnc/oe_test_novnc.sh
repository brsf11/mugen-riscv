#!/user/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    	:   ye mengfei
# @Contact   	:   mengfei@isrc.iscas.ac.cn
# @Date      	:   2022-4-2
# @License   	:   Mulan PSL v2
# @Desc      	:   the test of novnc package
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function config_params() {
    LOG_INFO "Start to config params of the case."
    vncConnPort=$(GET_FREE_PORT "" 5900 5950)
    vncConnName=:$(expr ${vncConnPort} - 5900)
    novncLisPort=$(GET_FREE_PORT)
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "novnc tigervnc-server openssl lsof"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    # start vnc server
    vncserver ${vncConnName}
    IS_FREE_PORT ${vncConnPort} ""
    CHECK_RESULT $? 1 0 "vnc server doesn't start up"

    # --listen --vnc --web
    novnc_server --listen ${novncLisPort} --vnc localhost:${vncConnPort} --web /usr/share/novnc &
    SLEEP_WAIT 3
    curl http://localhost:${novncLisPort}/vnc.html | grep '<title>noVNC</title>'
    CHECK_RESULT $? 0 0 "novnc_server listen Test --listen --vnc --web FAILED."
    kill -9 $(lsof -i:${novncLisPort} -t)

    # --record
    novnc_server --listen ${novncLisPort} --vnc localhost:${vncConnPort} --record novnc_record > novnc_log.txt 2>&1 &
    SLEEP_WAIT 3
    grep 'Recording to' novnc_log.txt
    CHECK_RESULT $? 0 0 "novnc_server record Test --listen --vnc --record FAILED."
    kill -9 $(lsof -i:${novncLisPort} -t)

    # openssl to create cert and key
    echo -e "CN\nProvince\nCity\nOpenEuler\nsigQA\nlocalhost\nroot@localhost\n" |
        openssl req -x509 -nodes -newkey rsa:2048 -keyout self.pem -out self.pem -days 365
    test -f self.pem
    CHECK_RESULT $? 0 0 "openssl fail to create self.pem"

    # --cert --key
    novnc_server --listen ${novncLisPort} --vnc localhost:${vncConnPort} --cert ./self.pem --key ./self.pem &
    SLEEP_WAIT 3
    curl --cacert self.pem https://localhost:${novncLisPort}/vnc.html | grep '<title>noVNC</title>'
    CHECK_RESULT $? 0 0 "novnc_server cert and key Test --listen --vnc --cert --key FAILED."
    kill -9 $(lsof -i:${novncLisPort} -t)

    # --ssl-only
    novnc_server --listen ${novncLisPort} --vnc localhost:${vncConnPort} --cert ./self.pem --key ./self.pem --ssl-only &
    SLEEP_WAIT 3
    curl http://localhost:${novncLisPort}/vnc.html 2>&1 | grep 'Recv failure'
    CHECK_RESULT $? 0 0 "novnc_server ssl-only Test --listen --vnc --cert --key --ssl-only FAILED."
    kill -9 $(lsof -i:${novncLisPort} -t)

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    vncserver -kill ${vncConnName}
    DNF_REMOVE
    rm -rf self.pem novnc_log.txt
    LOG_INFO "End to restore the test environment."
}

main "$@"
