#!/bin/bash

# Launch ComfyUI for Flux Finetuning.
#
# This script launches the ComfyUI container with all necessary volume mounts for Flux finetuning workflow.

docker run -it \
    --rm \
    --gpus all \
    --ipc=host \
    --net=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    -v $(pwd)/models/vae:/workspace/ComfyUI/models/vae \
    -v $(pwd)/models/loras:/workspace/ComfyUI/models/loras \
    -v $(pwd)/models/checkpoints:/workspace/ComfyUI/models/checkpoints \
    -v $(pwd)/models/text_encoders:/workspace/ComfyUI/models/text_encoders \
    -v $(pwd)/workflows/:/workspace/ComfyUI/user/default/workflows/ \
    flux-comfyui \
    python main.py