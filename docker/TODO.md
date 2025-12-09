# TODO

## SemanticKitti dataset links

https://s3.eu-central-1.amazonaws.com/avg-kitti/data_odometry_velodyne.zip
https://s3.eu-central-1.amazonaws.com/avg-kitti/data_odometry_color.zip
https://s3.eu-central-1.amazonaws.com/avg-kitti/data_odometry_calib.zip
https://www.semantic-kitti.org/assets/data_odometry_labels.zip


## List of commands to run

### <span style="color:green;">&#10004;</span> Generate caption and features

```bash
python script/main_gen_cap.py
```

### <span style="color:red;">&#10060;</span> Generate panoramic maps

```bash
torchrun --nproc_per_node=1 script/main_gen_pc.py
```

**Error:**

`torch.OutOfMemoryError: CUDA out of memory. Tried to allocate 250.00 MiB. GPU 0 has a total capacity of 15.47 GiB of which 249.75 MiB is free. Including non-PyTorch memory, this process has 14.65 GiB memory in use. Of the allocated memory 14.41 GiB is allocated by PyTorch, and 88.45 MiB is reserved by PyTorch but unallocated. If reserved but unallocated memory is large try setting PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True to avoid fragmentation.  See documentation for Memory Management  (https://pytorch.org/docs/stable/notes/cuda.html#environment-variables)`

### <span style="color:orange;">&#128221;</span> Generate instance-layer scene graph

```bash
python script/build_scenegraph.py
```

### <span style="color:orange;">&#128221;</span> Map Interaction

```bash
python script/visualize.py
```

### <span style="color:orange;">&#128221;</span> Building Hierarchical Graph

```bash
python script/gen_lane.py
```

```bash
python script/gen_all_pc.py
```

```bash
python script/hierarchical_vis.py
```
