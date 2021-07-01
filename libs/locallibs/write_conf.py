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
# @Date    : 2021-04-20 15:13:09
# @License : Mulan PSL v2
# @Version : 1.0
# @Desc    :
#####################################

import sys, os, json, socket, subprocess, argparse

import paramiko

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_PATH)
import mugen_log

NODE_DATA = {"ID": 1}


def write_conf(ip, password, port=22, user="root"):
    if not os.path.exists("/etc/mugen"):
        OET_PATH = os.environ.get("OET_PATH")
        if OET_PATH is None:
            mugen_log.logging("error", "环境变量：OET_PATH不存在，请检查mugen框架.")
            sys.exit(1)

        conf_path = OET_PATH.rstrip("/") + "/" + "conf/env.json"
        os.makedirs(OET_PATH.rstrip("/") + "/" + "conf", exist_ok=True)
    else:
        conf_path = "/etc/mugen/env.json"

    if os.path.exists(conf_path):
        exitcode = subprocess.getstatusoutput("grep " + ip + " " + conf_path)[0]
        if exitcode == 0:
            mugen_log.logging("warn", "当前机器:" + ip + "的相关信息已经录入到配置文件中.")
            sys.exit(0)

        try:
            f = open(conf_path, "r")
            ENV_DATA = json.loads(f.read())
            f.close()

            node_id_list = list()
            for node in ENV_DATA["NODE"]:
                node_id_list.append(node["ID"])
            node_id_list.sort()
            NODE_DATA.update({"ID": node_id_list[-1] + 1})
        except json.decoder.JSONDecodeError as e:
            mugen_log.logging("warn", e)
            ENV_DATA = {"NODE": []}
    else:
        ENV_DATA = {"NODE": []}

    if ip in socket.gethostbyname_ex(socket.gethostname())[-1]:
        NODE_DATA["LOCALTION"] = "local"
    else:
        NODE_DATA["LOCALTION"] = "remote"

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy)
    try:
        ssh.connect(ip, port, user, password)
    except paramiko.ssh_exception.NoValidConnectionsError as e:
        mugen_log.logging("error", e)
        sys.exit(1)

    stdin, stdout, stderr = ssh.exec_command("hostnamectl | grep 'Virtualization: kvm'")
    if stdout.read().decode("utf-8").strip("\n") == "":
        NODE_DATA.update({"MACHINE": "physical"})
    else:
        NODE_DATA["MACHINE"] = "kvm"

    stdin, stdout, stderr = ssh.exec_command("uname -m")
    NODE_DATA["FRAME"] = stdout.read().decode("utf-8").strip("\n")

    stdin, stdout, stderr = ssh.exec_command(
        " ip route | grep " + ip + " | awk '{print $3}'"
    )
    NODE_DATA["NIC"] = stdout.read().decode("utf-8").strip("\n")

    stdin, stdout, stderr = ssh.exec_command(
        "cat /sys/class/net/" + NODE_DATA["NIC"] + "/address"
    )
    NODE_DATA["MAC"] = stdout.read().decode("utf-8").strip("\n")

    NODE_DATA["IPV4"] = ip
    NODE_DATA["USER"] = user
    NODE_DATA["PASSWORD"] = password
    NODE_DATA["SSH_PORT"] = port

    ssh.close()

    if NODE_DATA["MACHINE"] == "kvm":
        NODE_DATA["HOST_IP"] = ""
        NODE_DATA["HOST_USER"] = ""
        NODE_DATA["HOST_PASSWORD"] = ""
        NODE_DATA["HOST_SSH_PORT"] = ""

    if NODE_DATA["MACHINE"] == "physical":
        NODE_DATA["BMC_IP"] = ""
        NODE_DATA["BMC_USER"] = ""
        NODE_DATA["BMC_PASSWORD"] = ""

    ENV_DATA["NODE"].append(NODE_DATA)

    with open(conf_path, "w") as f:
        f.write(json.dumps(ENV_DATA, indent=4))
        mugen_log.logging("info", "配置文件加载完成...")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="manual to this script")
    parser.add_argument("--ip", type=str, default=None)
    parser.add_argument("--password", type=str, default=None)
    parser.add_argument("--port", type=int, default=22)
    parser.add_argument("--user", type=str, default="root")
    args = parser.parse_args()

    write_conf(args.ip, args.password, args.port, args.user)

