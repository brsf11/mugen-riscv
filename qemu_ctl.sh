#!/usr/bin/bash
# Copyright (c) [2022] Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author  : saarloos
# @email   : 9090-90-90-9090@163.com
# @Date    : 2022-05-20 15:41:00
# @License : Mulan PSL v2
# @Version : 1.0
# @Desc    :
#####################################

OET_PATH=$(
    cd "$(dirname "$0")" || exit 1
    pwd
)
export OET_PATH

con_op=""
br_name="testbr0"
rem_br=0
for i in $*; do
    if [ $rem_br -eq 1 ]; then
        br_name="$i"
        rem_br=0
    fi
    if [[ $i == "--br_name" ]]; then
        rem_br=1
    fi
    if [[ $i == "start" || $i == "stop" && -z con_op ]]; then
        con_op=$i
    fi
done

br_conf="/etc/qemu/bridge.conf"
br_conf1="/usr/local/etc/qemu/bridge.conf"
br_conf_bak="/etc/qemu/bridge.conf.bak"
br_conf1_bak="/usr/local/etc/qemu/bridge.conf.bak"

if [[ $con_op == "start" ]]; then
    if [[ ! -e $con_op ]]; then
        mkdir -p /etc/qemu/
        mkdir -p /usr/local/etc/qemu/
    fi

    if [ -e $br_conf ]; then
        cp $br_conf $br_conf_bak
    fi

    if [ -e $br_conf1 ]; then
        cp $br_conf1 $br_conf1_bak
    fi

    echo "allow ${br_name}" >> $br_conf
    echo "allow ${br_name}" >> $br_conf1

    brctl addbr ${br_name}
    ifconfig ${br_name} up
fi

python3 ${OET_PATH}/libs/locallibs/qemu_ctl.py "$@"

if [[ $con_op == "stop" ]]; then
    if [ -e $br_conf_bak ]; then
        cp $br_conf_bak $br_conf
        rm -rf $br_conf_bak
    fi
    if [ -e $br_conf1_bak ]; then
        cp $br_conf1_bak $br_conf1
        rm -rf $br_conf1_bak
    fi
fi