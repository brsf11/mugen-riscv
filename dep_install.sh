#!/usr/bin/bash
# Copyright (c) [2021] Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author  : lemon-higgins
# @email   : lemon.higgins@aliyun.com
# @Date    : 2021-04-23 16:08:22
# @License : Mulan PSL v2
# @Version : 1.0
# @Desc    :
#####################################

usage() {
    printf "Usage:  sh dep_install.sh [options]\n
    -e: install addtitional dependencies qemu for remote testing\n
    -g shell_file: run shell file to set crocess compiliation, if have run srcipt must use source\n
    -h: print this usage info\n
    \n"
}

common_dep(){
    yum install expect psmisc -y
    yum install make -y
    yum install iputils -y
    pip3 install six || yum install python3-six -y
    pip3 install paramiko==2.7.2 || yum install python3-paramiko -y
}

qemu_dep(){
    echo "install qemu"
    yum install bridge-utils -y
    qemu-system-aarch64 --version && qemu-system-arm --version
    if [ $? -eq 0 ]; then
        return 0
    fi
    yum install qemu-system-aarch64 qemu-system-arm -y
    if [ $? -ne 0 ]; then
        echo "ERROR: qemu not install, you need install it youself."
        return 1
    fi
}

run_name=$0
in_qemu=0
run_shell=""

check_option(){
    had_g=0
    for opt in "$@"; do
        if [[ $opt == "-h" ]]; then
            usage
            return 0
        elif [[ $opt == "-e" ]]; then
            in_qemu=1
        elif [[ $opt == "-g" ]]; then
            had_g=1
            check_name=${run_name##*/}
            if [[ $check_name == "dep_install.sh" ]]; then
                echo "ERROR: run with crocess compiliation, must use 'source' to run script"
                return 1
            fi
        elif [ $had_g -eq 1 ]; then
            run_shell=$opt
        else
            usage
            return 1
        fi
    done

    if [[ had_g -eq 1 && run_shell == "" ]]; then
        echo "ERROR: -g parameter need"
        usage
        return 1
    fi
    return 0
}

main(){
    check_option $@
    if [ $? -ne 0 ]; then
        return 1
    fi

    common_dep
    if [ $? -ne 0 ]; then
        return 1
    fi

    if [ $in_qemu -eq 1 ]; then
        qemu_dep
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi

    if [ $run_shell ]; then
        source $run_shell
        if [ $? -ne 0 ]; then
            echo "ERROR: run crocess compiliation file $run_shell fail"
            return 1
        fi
    fi

    return 0
}

main $@
