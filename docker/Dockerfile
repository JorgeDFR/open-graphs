FROM pytorch/pytorch:2.8.0-cuda12.8-cudnn9-devel

# ---------------------------
# System deps
# ---------------------------
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        sudo git wget nano \
        xterm xauth openssh-server \
        ninja-build libopenblas-dev \
        tmux mate-desktop-environment-core \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------------------------
# Pip packages
# ---------------------------
RUN pip install --no-cache-dir \
        tyro open_clip_torch wandb h5py openai hydra-core distinctipy \
        spacy open3d natsort \
        faiss-cpu \
        accelerate bitsandbytes \
        flash-attn gradio-image-prompter \
        git+https://github.com/baaivision/tokenize-anything.git \
        groundeddino_vl \
        sentence-transformers

# ---------------------------
# Recognize Anything (Tag2Text)
# ---------------------------
RUN git clone https://github.com/xinyu1205/recognize-anything.git /tmp/recognize-anything && \
    pip install --no-cache-dir -r /tmp/recognize-anything/requirements.txt && \
    pip install --no-cache-dir /tmp/recognize-anything && \
    pip install --no-cache-dir \
        timm==1.0.17 \
        transformers==4.50.0 && \
    rm -rf /tmp/recognize-anything

# ---------------------------
# MinkowskiEngine
# ---------------------------
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ARG CUDA_SM_LIST="6.0 6.1 6.2 7.0 7.2 7.5 8.0 8.6 8.9 9.0 12.0"
ENV CMAKE_CUDA_ARCHITECTURES=${CUDA_SM_LIST} \
    TORCH_CUDA_ARCH_LIST=${CUDA_SM_LIST}
RUN git clone https://github.com/CiSong10/MinkowskiEngine.git /tmp/MinkowskiEngine && \
    cd /tmp/MinkowskiEngine && \
    git checkout cuda12-installation && \
    sed -i 's/\bauto __raw = __to_address(__r.get());/auto __raw = std::__to_address(__r.get());/' /usr/include/c++/11/bits/shared_ptr_base.h && \
    python setup.py install --force_cuda --blas=openblas && \
    rm -rf /tmp/MinkowskiEngine

# ---------------------------
# 4DMOS
# ---------------------------
RUN git clone https://github.com/PRBonn/4DMOS.git /tmp/4DMOS && \
    cd /tmp/4DMOS && \
    git checkout v0.1 && \
    python setup.py install && \
    rm -rf /tmp/4DMOS

# ---------------------------
# Create non-root user
# ---------------------------
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=1000
ENV HOME=/home/${USERNAME}

RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
    usermod -aG sudo ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p ${HOME}/workspace

# ---------------------------
# Open-Graphs
# ---------------------------
RUN git clone https://github.com/JorgeDFR/open-graphs.git ${HOME}/workspace/open-graphs

# ---------------------------
# Switch user and set workdir
# ---------------------------
RUN chown -R ${USERNAME}:${USERNAME} ${HOME}
USER ${USERNAME}
WORKDIR ${HOME}/workspace
CMD ["/bin/bash"]
