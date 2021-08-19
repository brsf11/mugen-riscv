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
# @Author    	:   lemon.higgins
# @Contact   	:   lemon.higgins@aliyun.com
# @Date      	:   2020-11-19 09:39:43
# @License   	:   Mulan PSL v2
# @Desc      	:   Take the test ls command as an example
####################################

test "$(ls / | grep -cE 'proc|usr|roor|var|sys|etc|boot|dev')" -eq 7
