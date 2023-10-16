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
# conda install astunparse cffi cmake dataclasses future mkl mkl-include ninja pyyaml requests setuptools six typing_extensions -y
# conda install -c conda-forge jemalloc gcc=12.1.0 -y
# pip install git+https://github.com/mlperf/logging
# pip install onnx lark-parser hypothesis tqdm scikit-learn
# echo "DLRM-SETUP: FINISHED SETTING UP CONDA ENV"

# Build PyTorch.
cd $BASE_PATH
git clone --recursive -b v1.12.1 https://github.com/pytorch/pytorch
cd pytorch/third_party/pybind11
git checkout tags/v2.7.0    # pybind 2.6.2 has some build errors
cd ../..
pip install -r requirements.txt
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
echo CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH >> $BASE_PATH/paths.export
export TORCH_PATH=$(pwd)
echo TORCH_PATH=$TORCH_PATH >> $BASE_PATH/paths.export
python setup.py develop
echo "DLRM-SETUP: FINISHED BUILDLING PYTORCH"

# # # Clone IPEX.
# # #
# # # The instructions in the repository build IPEX at this point, but we need to
# # # apply a patch before buildling IPEX. Since we'll only clone the repository 
# # # containing the patch later, hold off on building IPEX for now.
cd $BASE_PATH
git clone --recursive -b v1.13.100+cpu https://github.com/intel/intel-extension-for-pytorch   # build errors due to deprecated cmake
pip install torch   # Not in the original instructions
cd intel-extension-for-pytorch
export IPEX_PATH=$(pwd)
# pip install torch-cluster==1.5.9 -f https://data.pyg.org/whl/torch-1.8.1+cu102.html
echo IPEX_PATH=$IPEX_PATH >> $BASE_PATH/paths.export
sudo apt install -y g++
sudo apt --fix-broken -y install
REL_WITH_DEB_INFO=1 USE_NATIVE_ARCH=1 CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" \
        python setup.py install
echo "DLRM-SETUP: FINISHED CLONING IPEX"

# # Build itt-python.
# # cd $BASE_PATH
# # git clone https://github.com/NERSC/itt-python
# # cd itt-python
# # export VTUNE_PROFILER_DIR=/opt/intel/oneapi/vtune/latest
# # echo VTUNE_PROFILER_DIR=$VTUNE_PROFILER_DIR >> $BASE_PATH/paths.export
# # python setup.py install --vtune=$VTUNE_PROFILER_DIR
# # echo "DLRM-SETUP: FINISHED BUILDLING ITT-PYTHON"

# # # Set up DLRM inference test.
# # cd $BASE_PATH
# # # # git clone https://github.com/rishucoding/reproduce_isca23_cpu_DLRM_inference
# # cd reproduce_isca23_cpu_DLRM_inference
# # export DLRM_SYSTEM=$(pwd)
# # # echo DLRM_SYSTEM=$DLRM_SYSTEM >> $BASE_PATH/paths.export
# # # # git clone -b pytorch-r1.12-models https://github.com/IntelAI/models.git
# # cd models
# # export MODELS_PATH=$(pwd)
# # cd ../..
# # echo MODELS_PATH=$MODELS_PATH >> $BASE_PATH/paths.export
# # cp $DLRM_SYSTEM/dlrm_patches/dlrm_data_pytorch.py models/recommendation/pytorch/dlrm/product/dlrm_data_pytorch.py
# # cp $DLRM_SYSTEM/dlrm_patches/dlrm_s_pytorch.py models/recommendation/pytorch/dlrm/product/dlrm_s_pytorch.py
# # echo "DLRM-SETUP: FINISHED SETTING UP DLRM TEST"
# sleep 2
# # # Apply the IPEX patch and build IPEX.
# # cd $IPEX_PATH
# # echo $DLRM_SYSTEM
# # git apply $DLRM_SYSTEM/dlrm_patches/ipex.patch
# # REL_WITH_DEB_INFO=1 USE_NATIVE_ARCH=1 CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=1" python setup.py install
# # echo "DLRM-SETUP: FINISHED BUILDING IPEX"
# # # python -m pip install intel_extension_for_pytorch

# # echo "DLRM-SETUP: DONE!