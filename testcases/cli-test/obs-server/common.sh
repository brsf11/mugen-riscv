#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2021/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Test obsstoragesetup.service restart
# #############################################

source "../common/common_lib.sh"

function env_pre() {
    flag=false
    if [ $(getenforce | grep Enforcing) ]; then
        setenforce 0
        flag=true
    fi
    DNF_INSTALL "mariadb-server obs-api obs-server"
    mv /etc/my.cnf /etc/my.bak
    systemctl start mariadb
    echo 'create database api_production;' | mysql
    systemctl start obssrcserver
    sed -i 's/OBS_API_AUTOSETUP="no"/OBS_API_AUTOSETUP="yes"/g' /etc/sysconfig/obs-server
    systemctl start obsapisetup
}

function env_post() {
    systemctl stop mariadb obssrcserver obsapisetup
    sed -i 's/OBS_API_AUTOSETUP="yes"/OBS_API_AUTOSETUP="no"/g' /etc/sysconfig/obs-server
    DNF_REMOVE
    mv /etc/my.bak /etc/my.cnf
    rm -rf /var/lib/mysql/*
    if [ ${flag} = 'true' ]; then
        setenforce 1
    fi
}
