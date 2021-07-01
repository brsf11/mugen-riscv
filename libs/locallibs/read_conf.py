# -*- coding: utf-8 -*-
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
# @Date    : 2021-04-20 17:08:33
# @License : Mulan PSL v2
# @Version : 1.0
# @Desc    :
#####################################

import sys, os, json, argparse

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_PATH)
import mugen_log

NODE_ITEM = [
    "LOCALTION",
    "MACHINE",
    "FRAME",
    "USER",
    "PASSWORD",
    "SSH_PORT",
    "NIC",
    "IPV4",
    "MAC",
    "HOST_IP",
    "HOST_USER",
    "HOST_PASSWORD",
    "BMC_IP",
    "BMC_USER",
    "BMC_PASSWORD",
]


def parse_json():
    if not os.path.exists("/etc/mugen"):
        OET_PATH = os.environ.get("OET_PATH")
        if OET_PATH is None:
            mugen_log.logging("error", "环境变量：OET_PATH不存在，请检查mugen框架.")
            return 1

        conf_path = OET_PATH.rstrip("/") + "/" + "conf/env.json"
    else:
        conf_path = "/etc/mugen/env.json"

    if not os.path.exists(conf_path):
        mugen_log.logging("error", "环境配置文件不存在，请先配置环境信息.")
        sys.exit(1)

    try:
        with open(conf_path, "r") as f:
            return json.loads(f.read())
    except json.decoder.JSONDecodeError as e:
        mugen_log.logging(e)
        sys.exit(1)


def read_configure():
    env_data = parse_json()

    env_var = ""
    for node in env_data["NODE"]:
        for item in NODE_ITEM:
            if node["MACHINE"] == "kvm" and "BMC" in item:
                continue
            if node["MACHINE"] == "physical" and "HOST" in item:
                continue

            env_var += (
                "export NODE"
                + str(node["ID"])
                + "_"
                + item
                + "="
                + str(node[item])
                + "\n"
            )
    return env_var


def node_num():
    env_data = parse_json()

    node_list = list()
    for node_data in env_data["NODE"]:
        node_list.append(node_data["ID"])

    return sorted(node_list)[-1]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="manual to this script")
    parser.add_argument(
        "operation", type=str, choices=["env-var", "node-num"], default=None
    )
    args = parser.parse_args()

    if args.operation == "env-var":
        print(read_configure())
    elif args.operation == "node-num":
        print(node_num())
