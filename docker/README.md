# OpenGraphs -- Docker Setup Guide

This guide explains how to configure, build, and run the OpenGraphs
environment using Docker and Docker Compose.

## Configure Dataset Path

Before building the container, edit
**[`docker-compose.yml`](./docker-compose.yml)** and update the dataset
directory mapping to point to your local dataset folder:

```yaml
volumes:
  - /path/to/your/dataset:/home/user/data
```

Replace `/path/to/your/dataset` with the actual path on your machine.

## Build the Docker Image

To build the image defined in the `Dockerfile`, run:

```bash
docker compose build
```

## Start the Docker Container

Start the container in detached mode:

```bash
docker compose up -d
```

> **Note:** In order to enable GUI applications run the following command:
```bash
xhost +local:docker
```

## Access the Running Container

Open an interactive shell inside the container:

```bash
docker exec -it open_graphs bash
```