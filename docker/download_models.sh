#!/bin/bash
set -euo pipefail

# ===============================
# Configuration
# ===============================
MODELS_FOLDER="$HOME/data/models"

# Hugging Face Token for Llama2 model
# 1. Create account in https://huggingface.co
# 2. Request access to the llama2 model in https://huggingface.co/meta-llama/Llama-2-7b-chat-hf
# 3. Create a access token with read permissions in https://huggingface.co/settings/tokens
HF_TOKEN="hf_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

mkdir -p "$MODELS_FOLDER"

# ===============================
# Prerequisites: Check git lfs and git xet
# ===============================
check_prerequisites() {
  if ! command -v git-lfs &>/dev/null; then
    echo "git-lfs not found. Please install it: https://git-lfs.com/"
    exit 1
  fi

  if ! command -v git-xet &>/dev/null; then
    echo "git-xet not found. Please install it: https://huggingface.co/docs/hub/xet/using-xet-storage#git-xet"
    exit 1
  fi

  git lfs install
  git xet install
}

check_prerequisites

# ===============================
# Helper: Ask user whether to overwrite
# ===============================
confirm_overwrite() {
  local dest="$1"

  if [[ -e "$dest" ]]; then
    echo "File/folder already exists: $dest"
    read -p "Overwrite? (y/N): " answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
      echo "→ Skipping: $dest"
      return 1  # false → do not overwrite
    fi
    echo "→ Overwriting: $dest"
    rm -rf "$dest"
  fi

  return 0  # true → continue
}

# ===============================
# Helper: Download with overwrite confirmation
# ===============================
download() {
  local url="$1"
  local dest="$2"

  if confirm_overwrite "$dest"; then
    echo "Downloading: $url"
    wget -q --show-progress -O "$dest" "$url"
  fi
}

# ===============================
# Helper: Git clone with overwrite confirmation
# ===============================
git_clone_confirm() {
  local repo_url="$1"
  local dest="$2"

  if confirm_overwrite "$dest"; then
    git clone "$repo_url" "$dest"
  fi
}

# ===============================
# Tag2Text
# ===============================
echo
echo "=== Tag2Text ==="
echo
mkdir -p "$MODELS_FOLDER/tag2text"

download \
  "https://huggingface.co/spaces/xinyu1205/Tag2Text/resolve/main/tag2text_swin_14m.pth" \
  "$MODELS_FOLDER/tag2text/tag2text_swin_14m.pth"

# ===============================
# GroundingDINO
# ===============================
echo
echo "=== GroundingDINO ==="
echo
mkdir -p "$MODELS_FOLDER/groundingdino"

download \
  "https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth" \
  "$MODELS_FOLDER/groundingdino/groundingdino_swint_ogc.pth"

download \
  "https://raw.githubusercontent.com/IDEA-Research/GroundingDINO/main/groundingdino/config/GroundingDINO_SwinT_OGC.py" \
  "$MODELS_FOLDER/groundingdino/groundingdino_swint_ogc.py"

# ===============================
# TAP (Tokenize Anything)
# ===============================
echo
echo "=== TAP (Tokenize Anything) ==="
echo
mkdir -p "$MODELS_FOLDER/tokenize-anything"

download \
  "https://huggingface.co/BAAI/tokenize-anything/resolve/main/models/tap_vit_l_v1_0.pkl" \
  "$MODELS_FOLDER/tokenize-anything/tap_vit_l_v1_0.pkl"

download \
  "https://huggingface.co/BAAI/tokenize-anything/resolve/main/concepts/merged_2560.pkl" \
  "$MODELS_FOLDER/tokenize-anything/merged_2560.pkl"


# ===============================
# Llama 2
# ===============================
echo
echo "=== Llama 2 ==="
echo
mkdir -p "$MODELS_FOLDER/llama2"

git_clone_confirm \
  "https://user:${HF_TOKEN}@huggingface.co/meta-llama/Llama-2-7b-chat-hf" \
  "$MODELS_FOLDER/llama2/llama-2-7b-chat-hf"

# ===============================
# SBERT
# ===============================
echo
echo "=== SBERT ==="
echo
mkdir -p "$MODELS_FOLDER/sbert"

git_clone_confirm \
  "https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2" \
  "$MODELS_FOLDER/sbert/all-minilm-l6-v2"

# ===============================
# 4DMOS
# ===============================
echo
echo "=== 4DMOS ==="
echo
mkdir -p "$MODELS_FOLDER/4dmos"

if confirm_overwrite "$MODELS_FOLDER/4dmos/10_scans.ckpt"; then
  download \
    "https://www.ipb.uni-bonn.de/html/projects/4DMOS/10_scans.zip" \
    "$MODELS_FOLDER/4dmos/10_scans.zip"

  unzip -q "$MODELS_FOLDER/4dmos/10_scans.zip" -d "$MODELS_FOLDER/4dmos"
  rm -f "$MODELS_FOLDER/4dmos/10_scans.zip"
fi

echo
echo "=== All Downloads Complete ==="