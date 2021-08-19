#!/usr/bin/python3

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    	:   lemon.higgins
# @Contact   	:   lemon.higgins@aliyun.com
# @Date      	:   2020-04-09 09:39:43
# @License   	:   Mulan PSL v2
# @Desc      	:   Take the test ls command as an example
#####################################


import os, sys, subprocess

LIBS_PATH = os.environ.get("OET_PATH") + "/libs/locallibs"
sys.path.append(LIBS_PATH)
import ssh_cmd

ret = 0

cmd_status = subprocess.getstatusoutput("ls -CZl --all")[0]
if cmd_status != 0:
    ret += 1
dir_num = subprocess.getoutput("ls / | grep -cE 'proc|usr|roor|var|sys|etc|boot|dev'")
if dir_num != "7":
    ret += 1
conn = ssh_cmd.pssh_conn(os.environ.get("NODE2_IPV4"), os.environ.get("NODE2_PASSWORD"))
exitcode, output = ssh_cmd.pssh_cmd(conn, "ls")
ssh_cmd.pssh_close(conn)
if exitcode != 0:
    ret += 1
else:
    if output != "test":
        ret += 1

sys.exit(ret)

