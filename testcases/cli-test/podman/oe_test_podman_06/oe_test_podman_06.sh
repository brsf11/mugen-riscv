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
# @Date      :   2021/01/11
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in podman package
# ############################################

source "../common/common_podman.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    podman pull postgres:alpine
    podman run --name postgres -e POSTGRES_PASSWORD=secret -d postgres:alpine
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    podman stop postgres
    podman logs -f $(podman ps -aq) | grep logfile
    CHECK_RESULT $?
    podman logs -l 2>&1 | grep LOG
    CHECK_RESULT $?
    podman logs --since 2020-12-31 $(podman ps -aq) 2>&1 | grep $(date '+%Y-%m-%d')
    CHECK_RESULT $?
    podman logs --tail 10 $(podman ps -aq) 2>&1 | wc -l | grep 10
    CHECK_RESULT $?
    podman logs -t $(podman ps -aq) | grep "+08:00"
    CHECK_RESULT $?
    podman start postgres
    podman save -q -o alpine.tar postgres:alpine
    podman import --change CMD=/bin/bash --change ENTRYPOINT=/bin/sh --change LABEL=blue=image alpine.tar image-imported
    CHECK_RESULT $?
    cat alpine.tar | podman import -q --message "importing the alpine.tar tarball" - image-imported
    CHECK_RESULT $?
    podman export -o redis-container.tar $(podman ps -aq)
    CHECK_RESULT $?
    test -f redis-container.tar
    CHECK_RESULT $?
    podman tag $(podman images -q) test && podman images | grep test
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    podman rmi test
    clear_env
    rm -rf $(ls | grep -vE ".sh")
    LOG_INFO "End to restore the test environment."
}

main "$@"
