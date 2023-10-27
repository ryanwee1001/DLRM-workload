#!/bin/bash

# This script formats the results from the figure 13 / figure 14 tests.

TESTS=(
    "fig13_RM2_1_low"
    "fig13_RM2_1_med"
    "fig13_RM2_1_high"
    "fig13_RM2_2_low"
    "fig13_RM2_2_med"
    "fig13_RM2_2_high"
    "fig14_RM1_low"
    "fig14_RM1_med"
    "fig14_RM1_high"
)

RESULTS_DIR="results"
RESULTS_FILE="figures-$(date +%m%d)-$(date +%H%M%S).formatted"

mkdir -p $RESULTS_DIR
cd $RESULTS_DIR
for TEST_NAME in ${TESTS[@]};
do
    echo "$TEST_NAME: " >> $RESULTS_FILE
    cat $TEST_NAME*.time | grep "Maximum resident" >> $RESULTS_FILE
    cat $TEST_NAME*.log | grep "Average latency per example" >> $RESULTS_FILE
    cat $TEST_NAME*.log | grep "Total" >> $RESULTS_FILE
    cat $TEST_NAME*.log | grep "Throughput" >> $RESULTS_FILE
    echo "" >> $RESULTS_FILE
done

