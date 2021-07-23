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
# @Author    	:   wangjingfeng
# @Contact   	:   1136232498@qq.com
# @Date      	:   2020/12/17
# @License      :   Mulan PSL v2
# @Desc      	:   Packaging function of python-wheel
#####################################
from setuptools import setup
from setuptools import find_packages
setup(
    name='wjfpkg',
    version='1.0',
    packages=find_packages(),
    author='wjf008',
    author_email='1136232498@qq.com',
    description = "python-wheel test case use.",
    entry_points = {
        'console_scripts': [
            'wjfexe = wjfpkg.wjf:testwjf',
        ]
    }
)