#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/26
# @License   :   Mulan PSL v2
# @Version   :   1.0
# @Desc      :   public class integration
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function deploy_env() {
    DNF_INSTALL junit
    java_version=$(rpm -qa java* | grep java-.*-openjdk | awk -F '-' '{print $2}')
    DNF_INSTALL "javapackages-tools java-${java_version}-devel xmvn-resolve objectweb-asm3 beust-jcommander log4j"
}

function clear_env() {
    roc=$(ls | grep -v ".sh")
    rm -rf $roc
    DNF_REMOVE
}
