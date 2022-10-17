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
# @Desc      :   Resource Restriction - Configure the Cgroup path
# #############################################

source "./common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    iSulad_install
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    container_names=$(isula run -tid --cgroup-parent /cgroup123 --system-container busybox)
    container_pid=$(isula inspect -f "{{json .State.Pid}}" "${container_names}")
    grep "cgroup123" /proc/"${container_pid}"/cgroup
    CHECK_RESULT $? 0 0 "configure the Cgroup path failed"
    sed -i '/use-decrypted-key/a\"cgroup-parent": "/cgroup456",' /etc/isulad/daemon.json
    systemctl restart isulad
    container_names1=$(isula run -tid busybox)
    container_pid1=$(isula inspect -f "{{json .State.Pid}}" "${container_names1}")
    grep "cgroup456" /proc/"${container_pid1}"/cgroup
    CHECK_RESULT $? 0 0 "configure the Cgroup path failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    isula stop "${container_names}" "${container_names1}"
    isula rm "${container_names}" "${container_names1}"
    isula rmi busybox
    iSulad_remove
    LOG_INFO "End to restore the test environment."
}

main "$@"
