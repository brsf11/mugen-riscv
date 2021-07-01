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
# @Date    : 2021-04-20 19:17:45
# @License : Mulan PSL v2
# @Version : 1.0
# @Desc    :
#####################################

import sys, os, json, re, argparse

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_PATH)
import mugen_log


def suite_path(suite):
    oet_path = os.environ.get("OET_PATH")
    if oet_path is None:
        mugen_log.logging("error", "环境变量：OET_PATH不存在，请检查mugen框架.")
        sys.exit(1)
    suite_json = (
        os.environ.get("OET_PATH").rstrip("/") + "/suite2cases/" + suite + ".json"
    )
    if not os.path.exists(suite_json):
        mugen_log.logging("error", "无法找到测试套的json文件:%s." % suite_json)
        sys.exit(1)

    try:
        with open(suite_json, "r") as f:
            suite_data = json.loads(f.read())
        if suite_data["path"] is None:
            mugen_log.logging("error", "json文件:%s中没有path值." % suite_json)
            sys.exit(1)

        oet = re.match(r'^"?\${?OET_PATH}?"?', suite_data["path"])
        if oet is not None:
            return suite_data["path"].replace(oet.group(), os.environ.get("OET_PATH"))
        else:
            return suite_data["path"]

    except json.decoder.JSONDecodeError as e:
        mugen_log.logging("error", e)
        sys.exit(1)
    except KeyError as e:
        mugen_log.logging("error", "A key:%s error specifying JSON data" % e)
        sys.exit(1)


def suite_cases(suite):
    oet_path = os.environ.get("OET_PATH")
    if oet_path is None:
        mugen_log.logging("error", "环境变量：OET_PATH不存在，请检查mugen框架.")
        sys.exit(1)
    suite_json = (
        os.environ.get("OET_PATH").rstrip("/") + "/suite2cases/" + suite + ".json"
    )
    if not os.path.exists(suite_json):
        mugen_log.logging("error", "无法找到测试套的json文件:%s." % suite_json)
        sys.exit(1)

    try:
        with open(suite_json, "r") as f:
            suite_data = json.loads(f.read())
        if suite_data["cases"] is None:
            mugen_log.logging("error", "json文件:%s中没有cases值." % suite_json)
            sys.exit(1)

        case_list = ""
        for case_data in suite_data["cases"]:
            case_list += case_data["name"] + "\n"
        return case_list.rstrip("\n")

    except json.decoder.JSONDecodeError as e:
        mugen_log.logging("error", e)
        sys.exit(1)
    except KeyError as e:
        mugen_log.logging("error", "A key:%s error specifying JSON data" % e)
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="manual to this script")
    parser.add_argument("--suite", type=str, default=None)
    parser.add_argument("--key", type=str, choices=["path", "cases-name"], default=None)
    args = parser.parse_args()

    if args.key == "path":
        print(suite_path(args.suite))
    elif args.key == "cases-name":
        print(suite_cases(args.suite))
    else:
        mugen_log.logging(
            "error", "Other key value fetching is not currently supported."
        )
