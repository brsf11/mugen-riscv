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
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date          :   2021-10-27 09:00:43
#@License   	:   Mulan PSL v2
#@Desc          :   verification fastdfs's commnd
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function Pre_Test() {
    DNF_INSTALL "fastdfs* libfdfsclient net-tools"
    cp /etc/fdfs/client.conf.sample ./client.conf
    cp /etc/fdfs/storage.conf.sample ./storage.conf
    cp /etc/fdfs/tracker.conf.sample ./tracker.conf
    mkdir -p /tmp/guochenyang/1 /tmp/guochenyang/2 /tmp/guochenyang/3
    sed -i '/base_path/s/\/home\/yuqing\/fastdfs/\/tmp\/guochenyang\/1/g' ./client.conf
    sed -i '/tracker_server =/d' ./client.conf
    sed -i "21atracker_server =${NODE1_IPV4}" ./client.conf
    sed -i '/base_path/s/\/home\/yuqing\/fastdfs/\/tmp\/guochenyang\/2/g' ./tracker.conf
    sed -i '/thread_stack_size/s/256KB/1024KB/g' ./tracker.conf
    sed -i '/base_path/s/\/home\/yuqing\/fastdfs/\/tmp\/guochenyang\/3/g' ./storage.conf
    sed -i '/store_path0/s/\/home\/yuqing\/fastdfs/\/tmp\/guochenyang\/3/g' ./storage.conf
    sed -i '/tracker_server =/d' ./storage.conf
    sed -i "144atracker_server =${NODE1_IPV4}" ./storage.conf
    echo "hello" >./test1.txt
    echo "world" >./test2.txt
}

function Post_Test() {
    rm -rf ./client.conf ./storage.conf ./tracker.conf /tmp/guochenyang
    DNF_REMOVE
}
main "$@"
