#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/12/28
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of tpm_mkuuid,tpm_mkaik,tpm_loadkey,tpm_getpcrhash,tpm_updatepcrhash,tpm_getquote,tpm_verifyquote and tpm_unloadkey command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "tpm-tools tpm-quote-tools trousers cmake make gcc-c++ gmp-devel"
    wget https://github.com/PeterHuewe/tpm-emulator/archive/v0.7.5.zip
    unzip v0.7.5.zip
    test -d tpm-emulator-0.7.5 && cd tpm-emulator-0.7.5
    if [ "${NODE1_FRAME}"x == "aarch64"x ]; then
        sed -i "s/\$(shell uname -m)/arm64/g" tpmd_dev/linux/Makefile
    else
        sed -i "s/\$(shell uname -m)/x86/g" tpmd_dev/linux/Makefile
    fi
    sed -i "s/-Wall -Werror/-Wall -Wno-error/g" tpmd_dev/linux/Makefile
    mkdir build && cd build
    cmake .. && make && make install
    tpmd deactivated
    tpmd clear
    modprobe tpmd_dev
    nohup tpmd -d -f clear >/dev/null 2>&1 &
    SLEEP_WAIT 10
    if [ -z "$(pgrep -f 'tpmd -d')" ]; then
        rm -rf /var/run/tpm/tpmd_socket:0
        nohup tpmd -d -f clear >/dev/null 2>&1 &
        SLEEP_WAIT 10
        pgrep -f 'tpmd -d'
    fi
    if [ -n "$(pgrep -f 'tcsd -e')" ]; then
        kill -9 $pid_tcsd
    else
        nohup tcsd -e -f >/dev/null 2>&1 &
        SLEEP_WAIT 10
        pgrep -f 'tcsd -e'
    fi
    tpm_version | grep -i "[0-9a-z]"
    tpm_getpubek | grep -i "[0-9a-z\!():,_]"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    tpm_mkuuid -h >helpinfo 2>&1
    CHECK_RESULT $?
    grep -E "Usage: tpm_mkuuid|-" helpinfo
    CHECK_RESULT $?
    tpm_mkuuid -v >versioninfo 2>&1
    CHECK_RESULT $?
    grep "TPM Quote Tools.*[0-9]" versioninfo
    CHECK_RESULT $?
    tpm_mkuuid uuidfile
    CHECK_RESULT $?
    grep -a '.*' uuidfile
    CHECK_RESULT $?
    tpm_mkaik -h >helpinfo 2>&1
    CHECK_RESULT $?
    grep -E "Usage: tpm_mkaik|-" helpinfo
    CHECK_RESULT $?
    tpm_mkaik -v >versioninfo 2>&1
    CHECK_RESULT $?
    grep "TPM Quote Tools.*[0-9]" versioninfo
    CHECK_RESULT $?
    tpm_loadkey -h >helpinfo 2>&1
    CHECK_RESULT $?
    grep -E "Usage: tpm_loadkey|-" helpinfo
    CHECK_RESULT $?
    tpm_loadkey -v >versioninfo 2>&1
    CHECK_RESULT $?
    grep "TPM Quote Tools.*[0-9]" versioninfo
    CHECK_RESULT $?
    tpm_getpcrhash -h >helpinfo 2>&1
    CHECK_RESULT $?
    grep -E "Usage: tpm_getpcrhash|-" helpinfo
    CHECK_RESULT $?
    tpm_getpcrhash -v >versioninfo 2>&1
    CHECK_RESULT $?
    grep "TPM Quote Tools.*[0-9]" versioninfo
    CHECK_RESULT $?
    tpm_updatepcrhash -h >helpinfo 2>&1
    CHECK_RESULT $?
    grep -E "Usage: tpm_updatepcrhash|-" helpinfo
    CHECK_RESULT $?
    tpm_updatepcrhash -v >versioninfo 2>&1
    CHECK_RESULT $?
    grep "TPM Quote Tools.*[0-9]" versioninfo
    CHECK_RESULT $?
    tpm_getquote -h >helpinfo 2>&1
    CHECK_RESULT $?
    grep -E "Usage: tpm_getquote|-" helpinfo
    CHECK_RESULT $?
    tpm_getquote -v >versioninfo 2>&1
    CHECK_RESULT $?
    grep "TPM Quote Tools.*[0-9]" versioninfo
    CHECK_RESULT $?
    tpm_verifyquote -h >helpinfo 2>&1
    CHECK_RESULT $?
    grep -E "Usage: tpm_verifyquote|-" helpinfo
    CHECK_RESULT $?
    tpm_verifyquote -v >versioninfo 2>&1
    CHECK_RESULT $?
    grep "TPM Quote Tools.*[0-9]" versioninfo
    CHECK_RESULT $?
    tpm_unloadkey -h >helpinfo 2>&1
    CHECK_RESULT $?
    grep -E "Usage: tpm_unloadkey|-" helpinfo
    CHECK_RESULT $?
    tpm_unloadkey -v >versioninfo 2>&1
    CHECK_RESULT $?
    grep "TPM Quote Tools.*[0-9]" versioninfo
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    kill -9 $(pgrep -f 'tpmd -d')
    kill -9 $(pgrep -f 'tcsd -e')
    currentDir=$(
        cd "$(dirname $0)" || exit 1
        pwd
    )
    currentName=$(echo $currentDir | awk -F '/' '{print $NF}')
    test "$currentName"x = "build"x && cd ../../ && {
        rm -rf $(ls | grep -v ".sh")
    }
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
