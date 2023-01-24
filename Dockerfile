FROM nvidia/cuda:11.6.2-base-centos7

LABEL maintainer="Kaichao Wu"

RUN echo hello
RUN \
    sed -i 's/python/python2/' /usr/bin/yum \
    && sed -i 's/python/python2/' /usr/libexec/urlgrabber-ext-down \
    && sed -i 's/python/python2/' /usr/bin/yum-config-manager

# Install python3(miniconda)
RUN \
    cd /tmp \
    && curl -O https://repo.anaconda.com/miniconda/Miniconda3-py39_22.11.1-1-Linux-x86_64.sh \
    # && curl -O https://repo.anaconda.com/miniconda/Miniconda3-py310_22.11.1-1-Linux-x86_64.sh \
    && bash Miniconda3-py39_22.11.1-1-Linux-x86_64.sh -b -p /opt/conda3 \
    && /opt/conda3/bin/conda init \
    && source /root/.bashrc \
    && rm -f /tmp/Miniconda3-py39_22.11.1-1-Linux-x86_64.sh

ENV PATH=/opt/conda3/bin:/opt/conda3/condabin:$PATH

RUN --mount=type=cache,target=/var/cache/yum \
    yum install opencv -y

# Install pytorch
#   REF: https://pytorch.org/get-started/locally/
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip \
    && pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116 \
    && pip install pyyaml opencv-python lpips \
    && strip /opt/conda3/lib/python3.9/site-packages/torch/lib/{libtorch_cpu.so,libtorch_cuda_cu.so}

COPY . /CodeFormer/

# setup venv
# RUN \
#     && conda create -n codeformer python=3.10 -y \
#     && source activate \
#     && conda deactivate \
#     && conda activate codeformer

RUN --mount=type=cache,target=/root/.cache/pip \
    # git clone https://github.com/kaichao/CodeFormer \
    cd /CodeFormer \
    && pip3 install -r requirements.txt \
    && python basicsr/setup.py develop

# # non-root user app, group app
# RUN \
#     addgroup --gid 1001 --system app \
#     && adduser --no-create-home --shell /bin/false --disabled-password --uid 1001 --system --group app
# USER app
