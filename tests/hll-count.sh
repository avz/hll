#!/bin/sh

SELFDIR=$(dirname "$0")

TESTLOG=/tmp/avz.hll-count.test

rm -f "$TESTLOG"

seq -s '-hll-count-test:' 0 99 | tr : '\n' >> $TESTLOG
seq -s '-hll-count-test:' 0 999999 | tr : '\n' >> $TESTLOG
seq -s '-hll-count-test:' 0 99999 | tr : '\n' >> $TESTLOG
seq -s '-hll-count-test:' 0 900000 | tr : '\n' >> $TESTLOG
seq -s '-hll-count-test:' 0 9999 | tr : '\n' >> $TESTLOG
seq -s '-hll-count-test:' 0 32121 | tr : '\n' >> $TESTLOG
seq -s '-hll-count-test:' 0 9923 | tr : '\n' >> $TESTLOG

# wc -l: 2052147
# sort -u | wc -l: 1000000

ERRORS=0

almost_equal() {
	real=$1
	expected=$2
	percent=$3

	min=$(($expected * (100 - $percent) / 100))
	max=$(($expected * (100 + $percent) / 100))

	test "$real" -ge "$min" -a "$real" -le "$max"
}

test_count() {
	bits=$1
	expected_count=$2
	expected_hash=$3

	result=$($SELFDIR/../bin/hll-count -d -b "$bits" < $TESTLOG)

	hash=$(echo "$result" | cut -d' ' -f1)
	count=$(echo "$result" | cut -d' ' -f2)

	if ! almost_equal "$count" "$expected_count" 2; then
		echo "bits=$bits: count $expected_count expected but $count given" 1>&2
		ERRORS=$(($ERRORS + 1))
	fi

	if [ ! "$hash" -eq "$expected_hash" ]; then
		echo "bits=$bits: hash $expected_hash expected but $hash given" 1>&2
		ERRORS=$(($ERRORS + 1))
	fi
}

test_count 4 1103249 596423999
test_count 5 1412738 1985856639
test_count 6 1227010 133366178
test_count 7 1124294 2975110038
test_count 8 1063738 3756456334
test_count 9 1020270 2227760783
test_count 10 1009955 2097733064
test_count 11 986528 2297798794
test_count 12 984061 962787301
test_count 13 975120 2698402778
test_count 14 969761 4090902387
test_count 15 987246 3745929533
test_count 16 997976 879953779
test_count 17 999960 160211267
test_count 18 1001805 2936371152
test_count 19 1000120 1575531669
test_count 20 999507 3050768488

if [ $ERRORS -gt 0 ]; then
	echo "Errors count: $ERRORS" 1>&2
	exit 1
fi
