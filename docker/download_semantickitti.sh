#!/bin/bash
set -euo pipefail

# ===================================
# Configuration
# ===================================
DATA_FOLDER="$HOME/data"

URLS=(
  "https://s3.eu-central-1.amazonaws.com/avg-kitti/data_odometry_velodyne.zip"
  "https://s3.eu-central-1.amazonaws.com/avg-kitti/data_odometry_color.zip"
  "https://s3.eu-central-1.amazonaws.com/avg-kitti/data_odometry_calib.zip"
  "https://www.semantic-kitti.org/assets/data_odometry_labels.zip"
)

# ===============================
# Models Folder & Disk Space Check
# ===============================

# Expected total size of all models (rounded up)
REQUIRED_SPACE_GB=166

check_setup() {
  local target_dir="$1"

  echo "=============================================="
  echo "📂 Dataset will be installed in: $target_dir"
  echo "💡 Make sure this is the correct folder."
  echo "📦 Total download size       : ~165.2 GB"
  echo "💽 Available disk space      : $(df -h "$target_dir" | awk 'NR==2 {print $4}')"
  echo "=============================================="
  echo

  # Ask user if they want to change the folder
  read -p "Do you want to change the dataset folder? (y/N): " change_folder
  if [[ "$change_folder" == "y" || "$change_folder" == "Y" ]]; then
    read -p "Enter new path for dataset folder: " new_path
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
    echo "   Required : ~165.2 GB"
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
  DATA_FOLDER="$target_dir"
}

check_setup "$DATA_FOLDER"

DATASET_FOLDER="$DATA_FOLDER/SemanticKitti"
TMP_FOLDER="$DATA_FOLDER/tmp"

# ===================================
# Overwrite confirmation
# ===================================
confirm_overwrite() {
  echo "Checking main dataset folder..."
  if [[ -e "$DATASET_FOLDER" ]]; then
    echo "Dataset folder already exists: $DATASET_FOLDER"
    read -p "Overwrite whole dataset folder? (y/N): " answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
      echo "→ Aborting."
      return 1
    fi
    echo "→ Overwriting entire dataset folder."
    rm -rf "$DATASET_FOLDER"
  fi
  return 0
}

# ===================================
# Download
# ===================================
download() {
  local url="$1"
  local dest="$2"

  echo "Downloading: $url"
  wget -q --show-progress -O "$dest" "$url"
}

# ===================================
# Helper: merge extracted content
# ===================================
merge_dataset_component() {
  local src_root="$1"

  # Expected path inside zip:
  #   data_odometry_xxx/dataset/sequences/*
  local sequences_path
  sequences_path=$(find "$src_root" -type d -path "*/dataset/sequences" | head -n 1)

  if [[ -z "$sequences_path" ]]; then
    echo "ERROR: Could not find 'dataset/sequences' inside $src_root"
    exit 1
  fi

  echo "Merging sequences from: $sequences_path"
  rsync -a --remove-source-files "$sequences_path/" "$DATASET_FOLDER/sequences/"
}

# ===================================
# Main Loop – Download & integrate dataset
# ===================================
echo
echo "=== Downloading and Assembling SemanticKITTI Dataset ==="
echo

if confirm_overwrite; then
  mkdir -p "$DATASET_FOLDER/sequences"
  mkdir -p "$TMP_FOLDER"

  for url in "${URLS[@]}"; do
    filename=$(basename "$url")
    zipfile="$TMP_FOLDER/$filename"

    echo
    echo "=== Processing: $filename ==="
    echo

    # 1. Download zip
    download "$url" "$zipfile"

    # 2. Extract to temporary directory
    extract_dir="$TMP_FOLDER/extract_${filename%.*}"
    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"

    echo "Unzipping..."
    unzip -q "$zipfile" -d "$extract_dir"
    rm -f "$zipfile"

    # 3. Merge sequences into final SemanticKitti/sequences folder
    merge_dataset_component "$extract_dir"
    rm -rf "$extract_dir"

  done
  rm -rf "$TMP_FOLDER"
fi

echo
echo "=== SemanticKITTI Dataset Download & Assembly Complete ==="
echo "Final dataset located at: $DATASET_FOLDER"