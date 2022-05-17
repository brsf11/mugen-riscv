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
# @Author    :   blackgaryc
# @Contact   :   blackgaryc@gmail.com
# @Date      :   2022/5/17
# @License   :   Mulan PSL v2
# @Desc      :   Test container-exception-logger
# #############################################

source "${OET_PATH}/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "docker-engine wget"
    # read version from file
    . /etc/os-release
    PRETTY_NAME=$(echo $PRETTY_NAME | tr -d '(' | tr -d ')' | tr ' ' -)
    wget -q https://repo.openeuler.org/$PRETTY_NAME/docker_img/$NODE1_FRAME/openEuler-docker.$NODE1_FRAME.tar.xz
    docker load < openEuler-docker.$NODE1_FRAME.tar.xz
    IMAGE_NAME=$(docker images --format "{{.Repository}}:{{.Tag}}")
    # create Dockerfile to build image
    cat <<EOF >Dockerfile
FROM $IMAGE_NAME
RUN yum install -y container-exception-logger && yum clean all
EOF
    # Build an image to avoid repeated installation of container-expeption-logger
    docker build -t openeuler-container-exception-logger .
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # test without any option
    echo without-option-test | docker run --rm -i openeuler-container-exception-logger container-exception-logger 2>&1 | grep "container-exception-logger - without-option-test"
    CHECK_RESULT $? 0 0 "test failed without option"
    # test option --help
    docker run --rm -i openeuler-container-exception-logger container-exception-logger --help 2>&1 | grep "Usage: container-exception-logger"
    CHECK_RESULT $? 0 0 "test failed with option --help"
    # test option --no-tag
    echo option-no-tag-test | docker run --rm -i openeuler-container-exception-logger container-exception-logger --no-tag 2>&1 | grep "option-no-tag-test"
    CHECK_RESULT $? 0 0 "test failed with option --no-tag"
    # test option --tag
    echo option-tag-test | docker run --rm -i openeuler-container-exception-logger container-exception-logger --tag example-tag 2>&1 | grep "example-tag - option-tag-test"
    CHECK_RESULT $? 0 0 "test failed with option --tag"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf Dockerfile openEuler-docker.$NODE1_FRAME.tar.xz
    docker rmi openeuler-container-exception-logger $IMAGE_NAME
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
