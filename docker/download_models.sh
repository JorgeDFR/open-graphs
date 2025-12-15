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

# ===============================
# Models Folder & Disk Space Check
# ===============================

# Expected total size of all models (rounded up)
REQUIRED_SPACE_GB=62

check_setup() {
  local target_dir="$1"

  echo "=============================================="
  echo "📂 Models will be installed in: $target_dir"
  echo "💡 Make sure this is the correct folder."
  echo "📦 Total download size       : ~61.8 GB"
  echo "💽 Available disk space      : $(df -h "$target_dir" | awk 'NR==2 {print $4}')"
  echo "🔑 Llama 2 requires a Hugging Face API token"
  echo "   (set in HF_TOKEN variable in the script)"
  echo "=============================================="
  echo

  # Ask user if they want to change the folder
  read -p "Do you want to change the models folder? (y/N): " change_folder
  if [[ "$change_folder" == "y" || "$change_folder" == "Y" ]]; then
    read -p "Enter new path for models folder: " new_path
    if [[ -z "$new_path" ]]; then
      echo "No path entered. Using default: $target_dir"
    else
      target_dir="$new_path"
      mkdir -p "$target_dir"
      echo "Models folder changed to: $target_dir"
    fi
  fi

  # Check disk space (in GB)
  local available_gb
  available_gb=$(df -BG "$target_dir" | awk 'NR==2 {gsub(/G/, "", $4); print $4}')

  if (( available_gb < REQUIRED_SPACE_GB )); then
    echo
    echo "⚠️  WARNING: Not enough disk space!"
    echo "   Required : ~61.8 GB"
    echo "   Available: ${available_gb} GB"
    echo
    read -p "Continue anyway? (y/N): " answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
      echo "Aborting due to insufficient disk space."
      exit 1
    fi
  else
    echo "✅ Sufficient disk space detected."
  fi

  # Export updated folder
  MODELS_FOLDER="$target_dir"
}

check_setup "$MODELS_FOLDER"
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