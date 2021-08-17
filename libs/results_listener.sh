#!/usr/bin/bash
# Copyright (c) [2021] Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author  : Ethan-Zhang
# @email   : ethanzhang55@outlook.com
# @Date    : 2021-08-10 16:03:00
# @License : Mulan PSL v2
# @Version : 1.0
# @Desc    : listener for results
#####################################

SCRIPT_PATH=$(
	cd "$(dirname "$0")" || exit 1
	pwd
)

INTERVAL=2
SUCCEED=0
FAIL=0

function is_mugen_running() {
	if ps -ef | grep -e 'mugen.sh' | grep -qv 'grep'; then
		return 0
	else
		return 1
	fi
}

function rsync_logs() {
	[[ -z $(rpm -qa | grep rsync) ]] && yum install -y rsync
	echo "$PASSWORD" >/tmp/rsync.password
	chmod 600 /tmp/rsync.password
	rsync -az --port=873 "${SCRIPT_PATH}"/../logs/* "${DEST_USER}"@"${DEST_IP}"::"${DEST_MODULE}"/"${JOB_NAME}" --password-file=/tmp/rsync.password
	return 0
}

function check_results() {
	if [[ -d ${SCRIPT_PATH}/../results/succeed ]]; then
		SUCCEED=$(ls -l "${SCRIPT_PATH}/../results/succeed" | grep '^-' | wc -l)
	else
		SUCCEED=0
	fi
	if [[ -d ${SCRIPT_PATH}/../results/failed ]]; then
		FAIL=$(ls -l "${SCRIPT_PATH}/../results/failed" | grep '^-' | wc -l)
	else
		FAIL=0
	fi
}

function run_listener() {
	while :; do
		if [[ -d ${SCRIPT_PATH}/../results ]]; then
			check_results
		else
			SUCCEED=0
			FAIL=0
		fi

		curl -d "{'job_name': $JOB_NAME, 'succeed': $SUCCEED, 'fail': $FAIL}" -H 'Content-Type: application/json' -X POST "${SERVER_URL}"

		rsync_logs

		sleep ${INTERVAL}s

		if ! is_mugen_running; then
			check_results
			curl -d "{'succeed': $SUCCEED, 'fail': $FAIL}" -H 'Content-Type: application/json' -X POST "${SERVER_URL}"
			break
		fi
	done
}

for ((i = 1; i <= 300; i++)); do
	if is_mugen_running; then
		run_listener
		break
	fi
	sleep 1s
done
