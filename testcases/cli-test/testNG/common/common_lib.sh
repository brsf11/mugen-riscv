#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

####################################
#@Author        :   wangjingfeng
#@Contact       :   1136232498@qq.com
#@Date          :   2020/07/05
#@License       :   Mulan PSL v2
#@Desc          :   testNG public methods about annotations
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_env() {
    if ! java -version; then
        java_version=$(dnf list | grep "java-1.8.*-openjdk" | awk -F '-' '{print $2}' | sed -n '1p')
        DNF_INSTALL "java-${java_version}-openjdk java-${java_version}-openjdk-devel testng beust-jcommander"
    else
        DNF_INSTALL "testng beust-jcommander"
    fi
    testng_jar=$(rpm -ql testng | grep testng.jar)
    jcommander_jar=$(rpm -ql beust-jcommander | grep beust-jcommander.jar)
    export CLASSPATH=${testng_jar}:${jcommander_jar}:.
}

function clean_env() {
    unset CLASSPATH
    rm -rf ./*.class
    rm -rf ./test-output
    DNF_REMOVE
}
