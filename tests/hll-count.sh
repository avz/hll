#!/bin/sh

SELFDIR=$(dirname "$0")

TESTLOG=/tmp/avz.hll-count.test

rm -f "$TESTLOG"

seq -s '-hll-count-test\n' 0 99 >> $TESTLOG
seq -s '-hll-count-test\n' 0 999999 >> $TESTLOG
seq -s '-hll-count-test\n' 0 99999 >> $TESTLOG
seq -s '-hll-count-test\n' 0 900000 >> $TESTLOG
seq -s '-hll-count-test\n' 0 9999 >> $TESTLOG
seq -s '-hll-count-test\n' 0 32121 >> $TESTLOG
seq -s '-hll-count-test\n' 0 9923 >> $TESTLOG

# wc -l: 2052147
# sort -u | wc -l: 1000000

ERRORS=0

test_count() {
	bits=$1
	expected=$2

	count=$($SELFDIR/../bin/hll-count -b "$bits" < $TESTLOG)

	if [ ! "$count" -eq "$expected" ]; then
		echo "bits=$bits: $expected expected but $count given" 1>&2
		ERRORS=$(($ERRORS + 1))
	fi
}

test_count 4 1103249
test_count 5 1412738
test_count 6 1227009
test_count 7 1124294
test_count 8 1063738
test_count 9 1020269
test_count 10 1009955
test_count 11 986528
test_count 12 984060
test_count 13 975120
test_count 14 969760
test_count 15 987246
test_count 16 997976
test_count 17 999960
test_count 18 1001805
test_count 19 1000120
test_count 20 999507

if [ $ERRORS -gt 0 ]; then
	echo "Errors count: $ERRORS" 1>&2
	exit 1
fi
