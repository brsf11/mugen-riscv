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
# @Desc      :   common function library for iSulad
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function iSulad_install() {
    DNF_INSTALL iSulad
    sed -i '/registry-mirrors/a\"docker.io"' /etc/isulad/daemon.json
    systemctl restart isulad
}

function iSulad_remove() {
    systemctl stop isulad
    DNF_REMOVE
    rm -rf /etc/isulad
}
