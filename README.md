# DLRM Workload from ISCA 2023 Paper

Based on the instructions in https://github.com/rishucoding/reproduce_isca23_cpu_DLRM_inference

# Setup

To set up the test environment, run:

```bash
./dlrm-setup-part1.sh

# Close and reopen the shell.
# Run: conda activate dlrm_cpu

./dlrm-setup-part2.sh
```

# Usage

To run the DLRM test, run:

```bash
./dlrm-run-tests.sh
```

To reproduce the tests in Figure 13, run:

```bash
./fig13.sh
```

To reproduce the tests in Figure 14, run:

```bash
./fig14.sh
```

To consolidate the results from the Figure 13 / Figure 14 tests into a single file, run:

```bash
./fig-format.sh
```

# Sample results

Sample results can be found in the [results](./results/) directory.

These results were obtained by running the test scripts on an x86_64 machine with 32 cores running `Ubuntu 22.04`.
