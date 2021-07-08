# -*- coding: utf-8 -*-
"""
 Copyright (c) [2021] Huawei Technologies Co.,Ltd.ALL rights reserved.
 This program is licensed under Mulan PSL v2.
 You can use it according to the terms and conditions of the Mulan PSL v2.
          http://license.coscl.org.cn/MulanPSL2
 THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 See the Mulan PSL v2 for more details.

 @Author  : lemon-higgins
 @email   : lemon.higgins@aliyun.com
 @Date    : 2021-04-22 10:52:19
 @License : Mulan PSL v2
 @Version : 1.0
 @Desc    : 测试设备名获取
"""

import os
import sys
import subprocess
import argparse

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_PATH)
import ssh_cmd
import mugen_log
import rpm_manage


def get_test_nic(node=1):
    """获取可测试使用的网卡

    Args:
        node (int, optional): 节点号. Defaults to 1.

    Returns:
        [str]: 网卡名
    """
    if os.environ.get("NODE" + str(node) + "_LOCALTION") == "local":
        tmpfile = rpm_manage.rpm_install(pkgs="lshw")[1]

        output = subprocess.getoutput(
            "lshw -class network | grep -A 5 'description: Ethernet interface' | grep 'logical name:' | awk '{print $NF}' | grep -v '"
            + os.environ.get("NODE" + str(node) + "_NIC")
            + "'"
        ).replace("\n", " ")

        if tmpfile is not None:
            rpm_manage.rpm_remove(tmpfile=tmpfile)
    else:
        tmpfile = rpm_manage.rpm_install(pkgs="lshw", node=2)[1]

        conn = ssh_cmd.pssh_conn(
            os.environ.get("NODE" + str(node) + "_IPV4"),
            os.environ.get("NODE" + str(node) + "_PASSWORD"),
            os.environ.get("NODE" + str(node) + "_SSH_PORT"),
            os.environ.get("NODE" + str(node) + "_USER"),
        )

        output = ssh_cmd.pssh_cmd(
            conn,
            "lshw -class network | grep -A 5 'description: Ethernet interface' | grep 'logical name:' | awk '{print $NF}' | grep -v '"
            + os.environ.get("NODE" + str(node) + "_NIC")
            + "'",
        )[1].replace("\n", " ")

        ssh_cmd.pssh_close(conn)

        if tmpfile is not None:
            rpm_manage.rpm_remove(node=2, tmpfile=tmpfile)

    return output


def get_test_disk(node=1):
    """获取可测试使用的网卡

    Args:
        node (int, optional): 节点号. Defaults to 1.

    Returns:
        [str]: 磁盘名称
    """
    if os.environ.get("NODE" + str(node) + "LOCALTION") == "local":
        used_disk = subprocess.getoutput(
            "lsblk -l | grep -e '/.*\|\[.*\]' | awk '{print $1}' | tr -d '[0-9]' | uniq | sed -e ':a;N;$!ba;s/\\n/ /g'"
        )

        test_disk = subprocess.getoutput(
            "lsblk -n | grep -v '└─.*\|"
            + used_disk.replace(" ", "\|")
            + "' | awk '{print $1}' | sed -e ':a;N;$!ba;s/\\n/ /g'"
        )
    else:
        conn = ssh_cmd.pssh_conn(
            os.environ.get("NODE" + str(node) + "_IPV4"),
            os.environ.get("NODE" + str(node) + "_PASSWORD"),
            os.environ.get("NODE" + str(node) + "_SSH_PORT"),
            os.environ.get("NODE" + str(node) + "_USER"),
        )
        used_disk = ssh_cmd.pssh_cmd(
            conn,
            "lsblk -l | grep -e '/.*\|\[.*\]' | awk '{print $1}' | tr -d '[0-9]' | uniq | sed -e ':a;N;$!ba;s/\\n/ /g'",
        )[1]
        test_disk = ssh_cmd.pssh_cmd(
            conn,
            "lsblk -n | grep -v '└─.*\|"
            + used_disk.replace(" ", "\|")
            + "' | awk '{print $1}' | sed -e ':a;N;$!ba;s/\\n/ /g'",
        )[1]

    return test_disk


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="manual to this script")
    parser.add_argument("--node", type=int, default=1)
    parser.add_argument("--device", type=str, choices=["nic", "disk"], default="nic")
    args = parser.parse_args()

    if args.drive == "nic":
        print(get_test_nic(args.node))
    elif args.drive == "disk":
        print(get_test_disk(args.node))
    else:
        mugen_log.logging(
            "warn",
            "No other test driven acquisition is provided at this time, you can issue to us for follow-up.",
        )
        sys.exit(1)
