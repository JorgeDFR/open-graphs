#!/bin/bash
set -euo pipefail

cd "$HOME/workspace"

echo "Select what you want to run:"
echo "1) Generate data"
echo "2) Visualize SceneGraph"
echo "3) Visualize Hierarchical SceneGraph"
read -rp "Enter choice [1-3]: " choice

case "$choice" in
  1)
    echo "Running data generation..."
    python open-graphs/script/main_gen_cap.py
    python open-graphs/script/main_gen_pc.py
    python open-graphs/script/build_scenegraph.py
    python open-graphs/script/gen_lane.py
    python open-graphs/script/gen_all_pc.py
    ;;
  2)
    echo "Running SceneGraph visualization..."
    python open-graphs/script/visualize.py
    ;;
  3)
    echo "Running Hierarchical SceneGraph visualization..."
    python open-graphs/script/hierarchical_vis.py
    ;;
  *)
    echo "Invalid choice. Please enter 1, 2, or 3."
    exit 1
    ;;
esac
