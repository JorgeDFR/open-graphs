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

### <span style="color:green;">&#10004;</span> Generate panoramic maps

```bash
python script/main_gen_pc.py
```

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

<!--
<span style="color:green;">&#10004;</span>
<span style="color:red;">&#10060;</span>
<span style="color:orange;">&#128221;</span>
-->