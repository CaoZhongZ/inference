#!/bin/bash

source run_common.sh

dockercmd=docker
if [ $device == "gpu" ]; then
    runtime="--runtime=nvidia"
fi


OUTPUT_DIR=`pwd`/output/$name
mkdir -p $OUTPUT_DIR

image=mlperf-infer-imgclassify-$device
docker build  -t $image -f Dockerfile.$device .
opts="--profile $profile $common_opt --model $model_path --dataset-path $DATA_DIR \
    --output $OUTPUT_DIR/results.json $extra_args $EXTRA_OPS"

docker run $runtime -e opts="$opts" \
    -v $DATA_DIR:$DATA_DIR -v $MODEL_DIR:$MODEL_DIR -v `pwd`:/mlperf \
    -v $OUTPUT_DIR:/output -v /proc:/host_proc \
    -t $image:latest /mlperf/run_helper.sh 2>&1 | tee $OUTPUT_DIR/output.txt
