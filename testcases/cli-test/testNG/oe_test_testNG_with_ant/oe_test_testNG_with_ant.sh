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
#@Date          :   2020/4/29
#@License       :   Mulan PSL v2
#@Desc          :   testNG integration ant
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function config_params() {
    LOG_INFO "Start to config params of the case."

    ant_path="/tmp/test/ant"
    mkdir -p "${ant_path}"
    antlib_path="${ant_path}/lib"
    mkdir -p "${antlib_path}"
    antsrc_path="${ant_path}/src"
    mkdir -p "${antsrc_path}"
    cp ../common/TExpBase.java "${antsrc_path}"
    cp build.xml "${ant_path}"
    cp ../common/TExpBase.xml "${ant_path}"

    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    if ! java -version; then
        java_version=$(dnf list | grep "java-1.8.*-openjdk" | awk -F '-' '{print $2}' | sed -n '1p')
        DNF_INSTALL "java-${java_version}-openjdk java-${java_version}-openjdk-devel testng beust-jcommander ant"
    else
        DNF_INSTALL "testng beust-jcommander ant"
    fi
    testng_jar=$(rpm -ql testng | grep testng.jar)
    jcommander_jar=$(rpm -ql beust-jcommander | grep beust-jcommander.jar)
    cp "${testng_jar}" "${antlib_path}"
    cp "${jcommander_jar}" "${antlib_path}"

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    ant -f "${ant_path}/build.xml" | grep "run: 2, Failures: 0, Skips: 0"
    CHECK_RESULT $? 0 0 "testng execution use case failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf /tmp/test
    DNF_REMOVE

    LOG_INFO "End to restore the test environment."
}

main "$@"
