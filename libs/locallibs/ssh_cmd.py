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
 @Date    : 2021-04-21 11:54:57
 @License : Mulan PSL v2
 @Version : 1.0
 @Desc    : 远端命令执行
"""

import os
import sys
import argparse
import paramiko

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_PATH)
import mugen_log


def pssh_conn(
    ip,
    password,
    port=22,
    user="root",
    timeout=None,
    log_level="error",
):
    """和远端建立连接

    Args:
        ip ([str]): 远端ip
        password ([str]): 远端用户密码
        port (int, optional): 远端ssh的端口号. Defaults to 22.
        user (str, optional): 远端用户名. Defaults to "root".
        timeout ([int], optional): ssh的超时时长. Defaults to None.

    Returns:
        [class]: 建立起来的连接
    """
    conn = paramiko.SSHClient()
    conn.set_missing_host_key_policy(paramiko.AutoAddPolicy)
    try:
        conn.connect(ip, port, user, password, timeout=timeout)
    except (
        paramiko.ssh_exception.NoValidConnectionsError,
        paramiko.ssh_exception.AuthenticationException,
        paramiko.ssh_exception.SSHException,
        TypeError,
        AttributeError,
    ) as e:
        mugen_log.logging(log_level, "Failed to connect the remote machine:%s." % ip)
        mugen_log.logging(log_level, e)
        return 519

    return conn


def pssh_cmd(conn, cmd):
    """远端命令执行

    Args:
        conn ([class]): 和远端建立连接
        cmd ([str]): 需要执行的命令

    Returns:
        [list]: 错误码，命令执行结果
    """
    if conn == 519:
        return 519, ""
    stdin, stdout, stderr = conn.exec_command(cmd, timeout=None)

    exitcode = stdout.channel.recv_exit_status()

    if exitcode == 0:
        output = stdout.read().decode("utf-8").strip("\n")
    else:
        output = stderr.read().decode("utf-8").strip("\n")

    return exitcode, output


def pssh_close(conn):
    """关闭和远端的连接

    Args:
        conn ([class]): 和远端的连接
    """
    if conn != 519:
        conn.close()


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="manual to this script")
    parser.add_argument("--cmd", type=str, default=None, required=True)
    parser.add_argument("--node", type=int, default=2)
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

    conn = pssh_conn(args.ip, args.password, args.port, args.user, args.timeout)
    exitcode, output = pssh_cmd(conn, args.cmd)
    pssh_close(conn)

    print(output)

    sys.exit(exitcode)
