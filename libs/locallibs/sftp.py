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
 @Date    : 2021-04-21 16:14:27
 @License : Mulan PSL v2
 @Version : 1.0
 @Desc    : 文件传输
"""

import os
import sys
import stat
import re
import paramiko
import argparse
import subprocess

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_PATH)
import mugen_log
import ssh_cmd


def get_remote_file(sftp, remote_dir, remote_file=None):
    """获取对端文件

    Args:
        sftp (class): 和对端建立连接
        remote_dir ([str]): 远端需要传输的文件所在的目录
        remote_file ([str], optional): 远端需要传输的文件. Defaults to None.

    Returns:
        [list]: 文件列表
    """
    all_file = list()

    remote_dir = remote_dir.rstrip("/")

    dir_files = sftp.listdir_attr(remote_dir)
    for d_f in dir_files:
        if remote_file is not None and re.match(remote_file, d_f.filename) is None:
            continue

        _name = remote_dir + "/" + d_f.filename
        if stat.S_ISDIR(d_f.st_mode):
            all_file.extend(get_remote_file(sftp, _name))
        else:
            all_file.append(_name)

    return all_file


def psftp_get(conn, remote_dir, remote_file="", local_dir=os.getcwd()):
    """获取远端文件

    Args:
        conn ([class]): 和远端建立连接
        remote_dir ([str]): 远端需要传输的文件所在的目录
        remote_file ([str], optional): 远端需要传输的文件. Defaults to None.
        local_dir ([str], optional): 本地存放文件的目录. Defaults to os.getcwd().
    """
    if conn == 519:
        sys.exit(519)

    sftp = paramiko.SFTPClient.from_transport(conn.get_transport())

    if ssh_cmd.pssh_cmd(conn, "test -d " + remote_dir)[0]:
        mugen_log.logging("error", "remote dir:%s does not exist" % remote_dir)
        conn.close()
        sys.exit(1)

    all_file = list()
    if remote_file == "":
        all_file = get_remote_file(sftp, remote_dir)
    else:
        if ssh_cmd.pssh_cmd(conn, "test -f " + remote_file)[0]:
            mugen_log.logging("error", "remote file:%s does not exist" % remote_file)
            conn.close()
            sys.exit(1)

        all_file = get_remote_file(sftp, remote_dir, remote_file)

    for f in all_file:
        if remote_file == "":
            storage_dir = remote_dir.split("/")[-1]
            storage_path = os.path.join(
                local_dir, storage_dir + os.path.dirname(f).split(storage_dir)[-1]
            )
            if not os.path.exists(storage_path):
                os.makedirs(storage_path)
            sftp.get(f, os.path.join(storage_path, f.split("/")[-1]))
        else:
            sftp.get(f, os.path.join(local_dir, f.split("/")[-1]))
        mugen_log.logging("info", "start to get file:%s......" % f)

    conn.close()


def get_local_file(local_dir, local_file=None):
    """获取本地文件列表

    Args:
        local_dir ([str]): 本地文件所在的目录
        local_file ([str], optional): 本地需要传输的文件. Defaults to None.

    Returns:
        [list]: 文件列表
    """
    all_file = list()

    local_dir = local_dir.rstrip("/")

    dir_files = os.listdir(local_dir)
    for d_f in dir_files:
        if local_file is not None and re.match(local_file, d_f) is None:
            continue

        _name = local_dir + "/" + d_f
        if os.path.isdir(_name):
            all_file.extend(get_local_file(_name))
        else:
            all_file.append(_name)

    return all_file


def psftp_put(conn, local_dir=os.getcwd(), local_file="", remote_dir=""):
    """将本地文件传输到远端

    Args:
        conn ([class]): 和远端建立连接
        local_dir ([str]): 本地文件所在的目录
        local_file ([str], optional): 本地需要传输的文件. Defaults to None.
        remote_dir (str, optional): 远端存放文件的目录. Defaults to 根目录.
    """
    if conn == 519:
        sys.exit(519)

    sftp = paramiko.SFTPClient.from_transport(conn.get_transport())

    if subprocess.getstatusoutput("test -d " + local_dir)[0]:
        mugen_log.logging("error", "local dir:%s does not exist" % local_dir)
        conn.close()
        sys.exit(1)

    all_file = list()
    if local_file == "":
        all_file = get_local_file(local_dir)
    else:
        if subprocess.getstatusoutput("test -f " + local_file)[0]:
            mugen_log.logging("error", "local file:%s does not exist" % local_file)
            conn.close()
            sys.exit(1)
        all_file = get_local_file(local_dir, local_file)

    if remote_dir == "":
        remote_dir = ssh_cmd.pssh_cmd(conn, "pwd")[1]

    for f in all_file:
        if local_file == "":
            storage_dir = local_dir.split("/")[-1]
            storage_path = os.path.join(
                remote_dir, storage_dir + os.path.dirname(f).split(storage_dir)[-1]
            )
            if ssh_cmd.pssh_cmd(conn, "test -d " + storage_path)[0]:
                ssh_cmd.pssh_cmd(conn, "mkdir -p " + storage_path)
            sftp.put(f, os.path.join(storage_path, f.split("/")[-1]))
        else:
            sftp.put(f, os.path.join(remote_dir, f.split("/")[-1]))
        mugen_log.logging("info", "start to put file:%s......" % f)

    conn.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="manual to this script")
    parser.add_argument("operation", type=str, choices=["get", "put"], default=None)
    parser.add_argument(
        "--remotedir", type=str, default=None, help="Must be an absolute path"
    )
    parser.add_argument("--node", type=int, default=2)
    parser.add_argument("--remotefile", type=str, default="")
    parser.add_argument("--localdir", type=str, default=os.getcwd())
    parser.add_argument("--localfile", type=str, default="")
    parser.add_argument("--ip", type=str, default=None)
    parser.add_argument("--password", type=str, default=None)
    parser.add_argument("--port", type=int, default=22)
    parser.add_argument("--user", type=str, default="root")
    parser.add_argument("--timeout", type=int, default=None)
    args = parser.parse_args()

    if args.node is not None:
        args.ip = os.environ.get("NODE" + str(args.node) + "_IPV4")
        args.password = os.environ.get("NODE" + str(args.node) + "_PASSWORD")
        args.port = os.environ.get("NODE" + str(args.node) + "_SSH_PORT")
        args.user = os.environ.get("NODE" + str(args.node) + "_USER")

        if (
            args.ip is None
            or args.password is None
            or args.port is None
            or args.user is None
        ):
            mugen_log.logging(
                "error",
                "You need to check the environment configuration file to see if this node information exists.",
            )
            sys.exit(1)

    conn = ssh_cmd.pssh_conn(args.ip, args.password, args.port, args.user, args.timeout)

    if sys.argv[1] == "get":
        psftp_get(conn, args.remotedir, args.remotefile, args.localdir)
    elif sys.argv[1] == "put":
        psftp_put(conn, args.localdir, args.localfile, args.remotedir)
    else:
        mugen_log.logging("error", "the following arguments are required:get|put")
        sys.exit(1)
