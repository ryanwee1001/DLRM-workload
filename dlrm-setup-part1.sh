#!/bin/bash

# This script is based on the README.md in
# https://github.com/rishucoding/reproduce_isca23_cpu_DLRM_inference. 
# The script does the setup to run the benchmarks in the ISCA 2023 paper:
# Optimizing CPU Performance for Recommendation Systems At-Scale.

# All setup will be done in this directory, relative to the directory that
# this script is located in.
BASE_DIRECTORY_NAME="dlrm"

# Set up base directory.
rm -rf $BASE_DIRECTORY_NAME
mkdir -p $BASE_DIRECTORY_NAME
cd $BASE_DIRECTORY_NAME
export BASE_PATH=$(pwd)
echo "DLRM-SETUP: FINISHED SETTING UP BASE DIRECTORY"

# $BASE_PATH/paths.export will contain all env variables related to filepaths.
echo BASE_PATH=$BASE_PATH >> $BASE_PATH/paths.export   

# Install Intel Vtune.
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
echo "deb https://apt.repos.intel.com/oneapi all main" | \
        sudo tee /etc/apt/sources.list.d/oneAPI.list
sudo apt update
sudo apt -y install cmake intel-oneapi-vtune numactl python3-pip
sudo apt --fix-broken -y install
source /opt/intel/oneapi/vtune/latest/env/vars.sh
echo "DLRM-SETUP: FINISHED INSTALLING VTUNE"

# Run vtune.
#
# It might be a good idea to read the stdout and check that the script below
# actually passes the Memory, Architecture, and Hardware tests. It's okay if
# the GPU tests fail, since we won't be running anything on a GPU.
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope > /dev/null
echo 0 | sudo tee /proc/sys/kernel/kptr_restrict > /dev/null
echo 0 | sudo tee /proc/sys/kernel/perf_event_paranoid > /dev/null
vtune-self-checker.sh 
echo "DLRM-SETUP: FINISHED RUNNING VTUNE"
echo ""
echo ""
echo "#########################################################"
echo "IMPORTANT: YOU MIGHT WANT TO CHECK THE OUTPUT FILE LISTED"
echo "ABOVE TO ENSURE THAT ALL VTUNE TESTS PASS"
echo "#########################################################"
sleep 5

# Install conda. This follows the instructions at 
# https://docs.conda.io/projects/miniconda/en/latest/
cd $BASE_PATH
mkdir -p miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
        -O miniconda3/miniconda.sh
/usr/bin/bash miniconda3/miniconda.sh -b -u -p miniconda3
rm -rf miniconda3/miniconda.sh
miniconda3/bin/conda init zsh
miniconda3/bin/conda init bash
miniconda3/bin/conda create --name dlrm_cpu python=3.9 ipython -y
echo "DLRM-SETUP: FINISHED INSTALLING CONDA"

# Print instructions to be executed before proceeding to part 2. In particular:
# (1) For `conda init` to take effect, the shell must be closed and reopened.
# (2) `conda activate` is meant to be run in an interactive shell, and might not
#     work properly in a shell script.
echo ""
echo ""
echo "########################################################"
echo "IMPORTANT: BEFORE RUNNING DLRM-SETUP-PART2.SH, YOU MUST:"
echo "(1) CLOSE AND REOPEN THE SHELL"
echo "(2) RUN conda activate dlrm_cpu"
echo "########################################################"
