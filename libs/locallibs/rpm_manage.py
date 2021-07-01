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
# @Date    : 2021-04-22 11:37:36
# @License : Mulan PSL v2
# @Version : 1.0
# @Desc    :
#####################################

import os, sys, subprocess, tempfile, argparse

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_PATH)
import mugen_log
import ssh_cmd


def local_cmd(cmd, conn=None):
    exitcode, output = subprocess.getstatusoutput(cmd)
    return exitcode, output


def rpm_install(pkgs, node=1, tmpfile=""):
    if pkgs is "":
        mugen_log.logging("error", "the following arguments are required:pkgs")
        sys.exit(1)

    localtion = os.environ.get("NODE" + str(node) + "_LOCALTION")
    if localtion == "local":
        conn = None
        func = local_cmd
    else:
        conn = ssh_cmd.pssh_conn(
            os.environ.get("NODE" + str(node) + "_IPV4"),
            os.environ.get("NODE" + str(node) + "_PASSWORD"),
            os.environ.get("NODE" + str(node) + "_SSH_PORT"),
            os.environ.get("NODE" + str(node) + "_USER"),
        )
        func = ssh_cmd.pssh_cmd

    result = func(conn=conn, cmd="dnf --assumeno install " + pkgs)[1]
    if "is already installed" in result and "Nothing to do" in result:
        mugen_log.logging("info", "pkgs:(%s) is already installed" % pkgs)
        return 0, None

    repoCode, repoList = func(
        conn=conn,
        cmd="dnf repolist | awk '{print $NF}' | sed -e '1d;:a;N;$!ba;s/\\n/ /g'",
    )
    if repoCode != 0:
        return repoCode, repoList

    depCode, depList = func(
        conn=conn,
        cmd="dnf --assumeno install "
        + pkgs
        + ' 2>&1 | grep -wE "$(echo '
        + repoList
        + " | sed 's/ /|/g')\" | grep -wE \"$(uname -m)|noarch\" | awk '{print $1}'",
    )
    if depCode != 0:
        return depCode, depList

    exitcode, result = func(conn=conn, cmd="dnf -y install " + pkgs)

    if tmpfile is "":
        tmpfile = tempfile.mkstemp(dir="/tmp")[1]

    with open(tmpfile, "a+") as f:
        for depPkg in depList.split("\n"):
            f.write(depPkg + " ")

    if exitcode == 0:
        result = f.name

    return exitcode, result


def rpm_remove(node=1, pkgs="", tmpfile=""):
    if pkgs is "" and tmpfile is "":
        mugen_log.logging(
            "error", "Packages or package files that need to be removed must be added"
        )
        sys.exit(1)

    localtion = os.environ.get("NODE" + str(node) + "_LOCALTION")
    if localtion == "local":
        conn = None
        func = local_cmd
    else:
        conn = ssh_cmd.pssh_conn(
            os.environ.get("NODE" + str(node) + "_IPV4"),
            os.environ.get("NODE" + str(node) + "_PASSWORD"),
            os.environ.get("NODE" + str(node) + "_SSH_PORT"),
            os.environ.get("NODE" + str(node) + "_USER"),
        )
        func = ssh_cmd.pssh_cmd

    depList = ""
    if tmpfile is not "":
        with open(tmpfile, "r") as f:
            depList = f.read()

    exitcode = func(conn=conn, cmd="dnf -y remove " + pkgs + " " + depList)[0]
    if localtion != "local":
        ssh_cmd.pssh_close(conn)
    return exitcode


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        usage="rpm_manage.py install|remove [-h] [--node NODE] [--pkgs PKG] [--tempfile TEPMFILE]",
        description="manual to this script",
    )
    parser.add_argument(
        "operation", type=str, choices=["install", "remove"], default=None
    )
    parser.add_argument("--node", type=int, default=1)
    parser.add_argument("--pkgs", type=str, default="")
    parser.add_argument("--tempfile", type=str, default="")
    args = parser.parse_args()

    if sys.argv[1] == "install":
        exitcode, output = rpm_install(args.pkgs, args.node, args.tempfile)
        if output is not None:
            print(output)
        sys.exit(exitcode)
    elif sys.argv[1] == "remove":
        exitcode = rpm_remove(args.node, args.pkgs, args.tempfile)
        sys.exit(exitcode)
    else:
        mugen_log.logging(
            "error",
            "usage: rpm_manage.py install|remove [-h] [--node NODE] [--pkg PKG] [--tempfile TEPMFILE]",
        )
        sys.exit(1)
