#!/usr/bin/bash

# Copyright (c) 2020. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2021/01/28
# @License   :   Mulan PSL v2
# @Desc      :   In s2twp, the translation of "芯片面积" uses s2twp to translate "正則表達式"“
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
  LOG_INFO "Start environmental preparation."
  DNF_INSTALL opencc
  LOG_INFO "End of environmental preparation!"
}

function run_test() {
  LOG_INFO "Start executing testcase."
  echo "芯片" | opencc -c s2twp | grep "晶片"
  CHECK_RESULT $?
  echo "芯片面积" | opencc -c s2twp | grep "芯片面積"
  CHECK_RESULT $?
  echo '{
  "name": "Traditional Chinese to Traditional Chinese (Taiwan standard, with phrases)",
  "segmentation": {
    "type": "mmseg",
    "dict": {
      "type": "ocd2",
      "file": "TWPhrases.ocd2"
    }
  },
  "conversion_chain": [{
    "dict": {
      "type": "group",
      "dicts": [{
        "type": "ocd2",
        "file": "TWPhrases.ocd2"
      }, {
        "type": "ocd2",
        "file": "TWVariants.ocd2"
      }]
    }
  }]
}' >/tmp/t2twp.json
  echo "芯片面积" | opencc -c s2t | opencc -c /tmp/t2twp.json | grep "晶片面積"
  CHECK_RESULT $?
  echo "正則" | opencc -c s2twp | grep '正則'
  CHECK_RESULT $?
  echo '正则表达式' | opencc -c s2twp | grep '正則表示式'
  CHECK_RESULT $?
  echo "正則表達式" | opencc -c s2twp | grep '正規表示式'
  CHECK_RESULT $?
  LOG_INFO "Finish testcase execution."
}
function post_test() {
  LOG_INFO "start environment cleanup."
  DNF_REMOVE 1
  rm -rf /tmp/t2twp.json
  LOG_INFO "Finish environment cleanup!"
}
main "$@"
