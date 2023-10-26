#!/bin/bash

# This script is based on the README.md in
# https://github.com/rishucoding/reproduce_isca23_cpu_DLRM_inference. 
# The script does the setup to run the benchmarks in the ISCA 2023 paper:
# Optimizing CPU Performance for Recommendation Systems At-Scale.

# Print instructions to be executed before proceeding to part 2. In particular:
# (1) For `conda init` to take effect, the shell must be closed and reopened.
# (2) `conda activate` is meant to be run in an interactive shell, and might not
#     work properly in a shell script.
echo "########################################################"
echo "IMPORTANT: BEFORE RUNNING DLRM-SETUP-PART2.SH, YOU MUST:"
echo "(1) CLOSE AND REOPEN THE SHELL"
echo "(2) RUN conda activate dlrm_cpu"
echo "########################################################"
sleep 3

# Restore environment variables indicating paths to different directories.
EXPORTS_FILE="dlrm/paths.export"
while read -r LINE
do
    export $LINE
done < "$EXPORTS_FILE"

# Set up env.
conda install astunparse cffi cmake dataclasses future mkl mkl-include ninja \
        pyyaml requests setuptools six typing_extensions -y
conda install -c conda-forge jemalloc gcc=12.1.0 -y
pip install git+https://github.com/mlperf/logging
pip install onnx lark-parser hypothesis tqdm scikit-learn
echo "DLRM-SETUP: FINISHED SETTING UP CONDA ENV"

# Build PyTorch.
cd $BASE_PATH
git clone --recursive -b v1.12.1 https://github.com/pytorch/pytorch
cd pytorch
pip install -r requirements.txt
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
echo CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH >> $BASE_PATH/paths.export
export TORCH_PATH=$(pwd)
echo TORCH_PATH=$TORCH_PATH >> $BASE_PATH/paths.export
python setup.py develop
echo "DLRM-SETUP: FINISHED BUILDLING PYTORCH"

# Clone IPEX.
#
# The instructions in the repository build IPEX at this point, but we need to
# apply a patch before buildling IPEX. Since we'll only clone the repository 
# containing the patch later, hold off on building IPEX for now.
cd $BASE_PATH
git clone --recursive -b v1.12.300 https://github.com/intel/intel-extension-for-pytorch
cd intel-extension-for-pytorch
export IPEX_PATH=$(pwd)
echo IPEX_PATH=$IPEX_PATH >> $BASE_PATH/paths.export
echo "DLRM-SETUP: FINISHED CLONING IPEX"

# Build itt-python.
cd $BASE_PATH
git clone https://github.com/NERSC/itt-python
cd itt-python
export VTUNE_PROFILER_DIR=/opt/intel/oneapi/vtune/latest
echo VTUNE_PROFILER_DIR=$VTUNE_PROFILER_DIR >> $BASE_PATH/paths.export
python setup.py install --vtune=$VTUNE_PROFILER_DIR
echo "DLRM-SETUP: FINISHED BUILDLING ITT-PYTHON"

# Set up DLRM inference test.
cd $BASE_PATH
git clone https://github.com/rishucoding/reproduce_isca23_cpu_DLRM_inference
cd reproduce_isca23_cpu_DLRM_inference
export DLRM_SYSTEM=$(pwd)
echo DLRM_SYSTEM=$DLRM_SYSTEM >> $BASE_PATH/paths.export
git clone -b pytorch-r1.12-models https://github.com/IntelAI/models.git
cd models
export MODELS_PATH=$(pwd)
echo MODELS_PATH=$MODELS_PATH >> $BASE_PATH/paths.export
mkdir -p models/recommendation/pytorch/dlrm/product
# The python scripts will be copied into some directory with the filepath
# .../reproduce_isca23_cpu_DLRM_inference/models/models/recommendation...
#
# The duplication of the 'models' directory is not a mistake. Rather, this is
# meant to match the filepath used in the testing script.
cp $DLRM_SYSTEM/dlrm_patches/dlrm_data_pytorch.py \
    models/recommendation/pytorch/dlrm/product/dlrm_data_pytorch.py
cp $DLRM_SYSTEM/dlrm_patches/dlrm_s_pytorch.py \
    models/recommendation/pytorch/dlrm/product/dlrm_s_pytorch.py
echo "DLRM-SETUP: FINISHED SETTING UP DLRM TEST"

# Apply the IPEX patch and build IPEX.
cd $IPEX_PATH
git apply $DLRM_SYSTEM/dlrm_patches/ipex.patch
python setup.py install     # The oneDNN library throws some errors if we use the flags provided by the original instructions.
echo "DLRM-SETUP: FINISHED BUILDING IPEX"

echo "DLRM-SETUP: DONE!"
