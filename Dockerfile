FROM nvidia/cuda:10.0-cudnn7-devel

# Declare some ARGuments
ARG PYTHON_VERSION=3.7
ARG CONDA_PYTHON_VERSION=3
ARG CONDA_DIR=/opt/conda

#get deps
RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
python3-dev python3-pip git g++ wget make libprotobuf-dev protobuf-compiler libopencv-dev \
libgoogle-glog-dev libboost-all-dev libcaffe-cuda-dev libhdf5-dev libatlas-base-dev

#replace cmake as old version has CUDA variable bugs
RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.tar.gz && \
tar xzf cmake-3.16.0-Linux-x86_64.tar.gz -C /opt && \
rm cmake-3.16.0-Linux-x86_64.tar.gz
ENV PATH="/opt/cmake-3.16.0-Linux-x86_64/bin:${PATH}"

# Install miniconda
# Install miniconda
ENV PATH $CONDA_DIR/bin:$PATH
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda$CONDA_PYTHON_VERSION-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    echo 'export PATH=$CONDA_DIR/bin:$PATH' > /etc/profile.d/conda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm -rf /tmp/* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
#RUN echo “. /opt/conda/etc/profile.d/conda.sh” >> ~/.bashrc && echo “conda activate base” >> ~/.bashrc
#get openpose
WORKDIR /docker_debugv1
RUN git clone https://github.com/ajisetyoko/docker_debugv1.git .

# Create a conda environment to use the h2o4gpu
RUN conda update -n base -c defaults conda && \
    conda env create -f gnc_aji.yml && \
    conda info --envs

# You can add the new created environment to the path
WORKDIR /docker_debugv1/torchlight
RUN activate gcn
RUN python setup.py install
#ENV PATH /opt/conda/envs/gpuenvs/bin:$PATH
# Copy the files in the actual directory from the directory forDocker on our host into the container in the directory /testenv
COPY . /testenv

# Set the working directory to be /testenv
WORKDIR /testenv
