#!/usr/bin/env bash
set -xe

testdir=$(readlink -f $(dirname $0))
SPDKCLI_BUILD_DIR=$(readlink -f $testdir/../..)
spdkcli_job="python3 $SPDKCLI_BUILD_DIR/test/spdkcli/spdkcli_job.py"
. $SPDKCLI_BUILD_DIR/test/common/autotest_common.sh

function on_error_exit() {
	set +e
	killprocess $spdk_tgt_pid
	rm -f $testdir/${MATCH_FILE} $testdir/spdkcli_details_vhost.test /tmp/sample_aio
	print_backtrace
	exit 1
}

function run_spdk_tgt() {
	$SPDKCLI_BUILD_DIR/app/spdk_tgt/spdk_tgt -m 0x3 -p 0 -s 1024 &
	spdk_tgt_pid=$!
	waitforlisten $spdk_tgt_pid
}

function check_match() {
	python3 $SPDKCLI_BUILD_DIR/scripts/spdkcli.py ll > $testdir/${MATCH_FILE}
	$SPDKCLI_BUILD_DIR/test/app/match/match -v $testdir/${MATCH_FILE}.match
	rm -f $testdir/${MATCH_FILE}
}
