#!/bin/sh

SELFDIR=$(dirname "$0")

TESTLOG=/tmp/avz.hll-count.test

rm -f "$TESTLOG"

seq 0 99 >> $TESTLOG
seq 0 999999 >> $TESTLOG
seq 0 99999 >> $TESTLOG
seq 0 900000 >> $TESTLOG
seq 0 9999 >> $TESTLOG
seq 0 32121 >> $TESTLOG
seq 0 9923 >> $TESTLOG

# wc -l: 2052147
# sort -u | wc -l: 1000000

ERRORS=0

almost_equal() {
	real=$1
	expected=$2
	delta=$3

	min=$(($expected * (1000 - $delta) / 1000))
	max=$(($expected * (1000 + $delta) / 1000))

	test "$real" -ge "$min" -a "$real" -le "$max"
}

test_count() {
	bits=$1
	expected_count=$2
	expected_hash=$3

	result=$($SELFDIR/../bin/hll-count -d -b "$bits" < $TESTLOG)

	hash=$(echo "$result" | cut -d' ' -f1)
	count=$(echo "$result" | cut -d' ' -f2)

	if [ 'generate' = '' ]; then
		echo test_count $bits $count $hash
	else
		if ! almost_equal "$count" "$expected_count" 1; then
			echo "bits=$bits: count $expected_count expected but $count given" 1>&2
			ERRORS=$(($ERRORS + 1))
		fi

		if [ ! "$hash" -eq "$expected_hash" ]; then
			echo "bits=$bits: hash $expected_hash expected but $hash given" 1>&2
			ERRORS=$(($ERRORS + 1))
		fi
	fi
}

test_count 4 971275 1449433227
test_count 5 1184174 1428984302
test_count 6 1156086 223517797
test_count 7 975103 3375047953
test_count 8 1003361 1098260576
test_count 9 994144 1411594926
test_count 10 969885 2580248892
test_count 11 999800 4085949792
test_count 12 998459 3226586891
test_count 13 1018742 2509337006
test_count 14 1011393 620697087
test_count 15 1007837 2192380712
test_count 16 1005185 3647273428
test_count 17 1003818 249692169
test_count 18 1005777 3364646580
test_count 19 999562 3771204784
test_count 20 1000288 3106131572

rm "$TESTLOG"

if [ $ERRORS -gt 0 ]; then
	echo "Errors count: $ERRORS" 1>&2
	exit 1
fi
