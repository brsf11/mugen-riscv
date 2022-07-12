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
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-11-3
#@License       :   Mulan PSL v2
#@Desc          :   osc build
#####################################

source "common/common_osc.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    deploy_env
    EXECUTE_T="120m"
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "osc build"
    osc checkout $branches_path | grep 'revision'
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    osc branch openEuler:Mainline chrpath $branches_path chrpath | grep 'branched package'
    CHECK_RESULT $?
    cd $branches_path || exit 1
    osc up
    CHECK_RESULT $?
    cd chrpath || exit 1
    osc setlinkrev | grep 'revision'
    CHECK_RESULT $?
    SLEEP_WAIT 5
    osc up -S
    CHECK_RESULT $?
    rename _service:tar_scm: '' _service:tar_scm:*
    CHECK_RESULT $?
    rm -f _service
    expect <<-END
        log_file testlog
        set timeout 1800
        spawn osc build chrpath.spec standard_${NODE1_FRAME}
        expect "?"
        send "1\\n"
        expect "?"
        send "1\\n"
        expect eof
        exit
END
    grep '/root/osc/buildroot/home/abuild/rpmbuild/SRPMS' testlog
    CHECK_RESULT $?
    osc buildconfig chrpath | grep 'chrpath'
    CHECK_RESULT $?
    osc rebuild $branches_path chrpath | grep 'ok'
    CHECK_RESULT $?
    osc restartbuild $branches_path chrpath | grep 'ok'
    CHECK_RESULT $?
    expect <<-END
        log_file testlog1
        spawn osc updatepacmetafromspec
        expect "Write?"
        send "y\\n"
        expect eof
        exit
END
    grep 'package' testlog1
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f testlog*
    cd .. || exit 1
    osc rdelete $branches_path chrpath -m "delete package_chrpath" --force
    rm -rf /root/osc/
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
