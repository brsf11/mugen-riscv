#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   geyaning
# @Contact   :   geyaning@uniontech.com
# @Date      :   2022.9.16
# @License   :   Mulan PSL v2
# @Desc      :   add case docker_custom-image
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "docker"
    cat > Dockerfile << EOF
FROM centos:latest
RUN touch test
EOF
    LOG_INFO "End of environmental preparation!"

}
function run_test() {
    LOG_INFO "Start testing..."
    docker build -t new_euler:v1.0 .
    CHECK_RESULT $? 0 0 "Failed to create a mirror from Dockerfile"
    docker images | grep new_euler
    CHECK_RESULT $? 0 0 "The image Custom failed"
    docker run new_euler:v1.0 ls test
    CHECK_RESULT $? 0 0 "The container failed to create a file"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf Dockerfile
    LOG_INFO "Finish environment cleanup!"
}

main $@
