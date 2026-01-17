#!/bin/bash

# Download FLUX Model Assets.
#
# This script downloads the required FLUX model assets from Hugging Face, including VAE, checkpoint, and text encoder files.
#
# download_if_needed  Download file if it doesn't exist.
#
# Downloads a file from a URL to a local path only if the file doesn't already exist locally.
#
# Parameters:
#   $1 (String)  URL to download from. .
#   $2 (String)  Local file path to save to. .
#
# Returns:
#   0  Download completed or file already exists. .
download_if_needed() {
  url="$1"
  file="$2"
  if [ -f "$file" ]; then
    echo "$file already exists, skipping."
  else
    curl -C - -L -H "Authorization: Bearer $HF_TOKEN" -o "$file" "$url"
  fi
}

download_if_needed "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors" "models/vae/ae.safetensors"
download_if_needed "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors" "models/checkpoints/flux1-dev.safetensors"
download_if_needed "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" "models/text_encoders/clip_l.safetensors"
download_if_needed "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors" "models/text_encoders/t5xxl_fp16.safetensors"