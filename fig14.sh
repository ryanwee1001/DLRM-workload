#!/bin/bash

# This script is a modified version of https://github.com/rishucoding/reproduce_isca23_cpu_DLRM_inference/blob/main/scripts/fig14/1core/normal_run_1c.sh

echo "###############################################"
echo "IMPORTANT: BEFORE RUNNING THIS SCRIPT, YOU MUST"
echo "RUN conda activate dlrm_cpu"
echo "###############################################"
sleep 3

# Restore environment variables indicating paths to different directories.
EXPORTS_FILE="dlrm/paths.export"
while read -r LINE
do
    export $LINE
done < "$EXPORTS_FILE"

export LD_PRELOAD=$CONDA_PREFIX/lib/libiomp5.so:$CONDA_PREFIX/lib/libjemalloc.so
export MALLOC_CONF="oversize_threshold:1,background_thread:true,metadata_thp:auto,dirty_decay_ms:9000000000,muzzy_decay_ms:9000000000"
export KMP_AFFINITY=verbose,granularity=fine,compact,1,0
export KMP_BLOCKTIME=1
export OMP_NUM_THREADS=1
PyGenTbl='import sys; rows,tables=sys.argv[1:3]; print("-".join([rows]*int(tables)))'
PyGetCore='import sys; c=int(sys.argv[1]); print(",".join(str(2*i) for i in range(c)))'
PyGetHT='import sys; c=int(sys.argv[1]); print(",".join(str(2*i + off) for off in (0, 48) for i in range(c)))'

# Change line 441 of dlrm_s_pytorch.py from:
#
#   dlrm = ipex.optimize(dlrm, dtype=torch.float, inplace=True, auto_kernel_selection=True)
#
# to:
#
#   dlrm = ipex.optimize(dlrm, dtype=torch.float, inplace=True) # auto_kernel_selection=True)
#
# This change is needed to prevent the following error:
#
#   $BASE_PATH/miniconda3/envs/dlrm_cpu/lib/python3.9/site-packages/intel_extension_for_pytorch/frontend.py:262
#       UserWarning: Conv BatchNorm folding failed during the optimize process.
#       warnings.warn("Conv BatchNorm folding failed during the optimize process.")
#
# Based on the IPEX documentation at
# https://intel.github.io/intel-extension-for-pytorch/cpu/latest/tutorials/features.html,
# auto kernel selection is a feature that enables users to tune for better
# performance. So turning it off should not affect any functionality.
sed -i '441s/, auto/) # auto/1' \
        $MODELS_PATH/models/recommendation/pytorch/dlrm/product/dlrm_s_pytorch.py

NUM_BATCH=10000 # Change this to modify runtime and max RSS
BS=64
RESULTS_DIR=results
RESULTS_NAME=$(date +%m%d)-$(date +%H%M%S)
INSTANCES=1
EXTRA_FLAGS=
GDB='gdb --args'
DLRM_SYSTEMS=$DLRM_SYSTEM

mkdir -p $RESULTS_DIR

# RM1, low
TOP_MLP=768-384-1
BOT_MLP=2048-2048-256-64
EMBS='64,500000,32,80'
TEST_NAME=fig14_RM1_low
for e in $EMBS; do
    IFS=','; set -- $e; EMB_DIM=$1; EMB_ROW=$2; EMB_TBL=$3; EMB_LS=$4; unset IFS;
    EMB_TBL=$(python -c "$PyGenTbl" "$EMB_ROW" "$EMB_TBL")
    DATA_GEN="prod,$DLRM_SYSTEMS/datasets/reuse_low/table_500K.txt,$EMB_ROW"
    C=$(python -c "$PyGetCore" "$INSTANCES")
    /usr/bin/time -vo $RESULTS_DIR/$TEST_NAME.$RESULTS_NAME.time numactl -C $C -m 0 $CONDA_PREFIX/bin/python -u $MODELS_PATH/models/recommendation/pytorch/dlrm/product/dlrm_s_pytorch.py --data-generation=$DATA_GEN --round-targets=True --learning-rate=1.0 --arch-mlp-bot=$BOT_MLP --arch-mlp-top=$TOP_MLP --arch-sparse-feature-size=$EMB_DIM --max-ind-range=40000000 --numpy-rand-seed=727 --ipex-interaction --inference-only --num-batches=$NUM_BATCH --data-size 100000000 --num-indices-per-lookup=$EMB_LS --num-indices-per-lookup-fixed=True --arch-embedding-size=$EMB_TBL --print-freq=10 --print-time --mini-batch-size=$BS --share-weight-instance=$INSTANCES $EXTRA_FLAGS | tee -a $RESULTS_DIR/$TEST_NAME.$RESULTS_NAME.log
done

# RM1, med
TOP_MLP=768-384-1
BOT_MLP=2048-2048-256-64
EMBS='64,500000,32,80'
TEST_NAME=fig14_RM1_med
for e in $EMBS; do
    IFS=','; set -- $e; EMB_DIM=$1; EMB_ROW=$2; EMB_TBL=$3; EMB_LS=$4; unset IFS;
    EMB_TBL=$(python -c "$PyGenTbl" "$EMB_ROW" "$EMB_TBL")
    DATA_GEN="prod,$DLRM_SYSTEMS/datasets/reuse_medium/table_500K.txt,$EMB_ROW"
    C=$(python -c "$PyGetCore" "$INSTANCES")
    /usr/bin/time -vo $RESULTS_DIR/$TEST_NAME.$RESULTS_NAME.time numactl -C $C -m 0 $CONDA_PREFIX/bin/python -u $MODELS_PATH/models/recommendation/pytorch/dlrm/product/dlrm_s_pytorch.py --data-generation=$DATA_GEN --round-targets=True --learning-rate=1.0 --arch-mlp-bot=$BOT_MLP --arch-mlp-top=$TOP_MLP --arch-sparse-feature-size=$EMB_DIM --max-ind-range=40000000 --numpy-rand-seed=727 --ipex-interaction --inference-only --num-batches=$NUM_BATCH --data-size 100000000 --num-indices-per-lookup=$EMB_LS --num-indices-per-lookup-fixed=True --arch-embedding-size=$EMB_TBL --print-freq=10 --print-time --mini-batch-size=$BS --share-weight-instance=$INSTANCES $EXTRA_FLAGS | tee -a $RESULTS_DIR/$TEST_NAME.$RESULTS_NAME.log
done

# RM1, high
TOP_MLP=768-384-1
BOT_MLP=2048-2048-256-64
EMBS='64,500000,32,80'
TEST_NAME=fig14_RM1_high
for e in $EMBS; do
    IFS=','; set -- $e; EMB_DIM=$1; EMB_ROW=$2; EMB_TBL=$3; EMB_LS=$4; unset IFS;
    EMB_TBL=$(python -c "$PyGenTbl" "$EMB_ROW" "$EMB_TBL")
    DATA_GEN="prod,$DLRM_SYSTEMS/datasets/reuse_high/table_500K.txt,$EMB_ROW"
    C=$(python -c "$PyGetCore" "$INSTANCES")
    /usr/bin/time -vo $RESULTS_DIR/$TEST_NAME.$RESULTS_NAME.time numactl -C $C -m 0 $CONDA_PREFIX/bin/python -u $MODELS_PATH/models/recommendation/pytorch/dlrm/product/dlrm_s_pytorch.py --data-generation=$DATA_GEN --round-targets=True --learning-rate=1.0 --arch-mlp-bot=$BOT_MLP --arch-mlp-top=$TOP_MLP --arch-sparse-feature-size=$EMB_DIM --max-ind-range=40000000 --numpy-rand-seed=727 --ipex-interaction --inference-only --num-batches=$NUM_BATCH --data-size 100000000 --num-indices-per-lookup=$EMB_LS --num-indices-per-lookup-fixed=True --arch-embedding-size=$EMB_TBL --print-freq=10 --print-time --mini-batch-size=$BS --share-weight-instance=$INSTANCES $EXTRA_FLAGS | tee -a $RESULTS_DIR/$TEST_NAME.$RESULTS_NAME.log
done
