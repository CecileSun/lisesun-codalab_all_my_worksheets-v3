FROM lisesun/codalab_autosk_ws:juliov8 
# sklearn0.17, xgboost, etc
# uploaded to hub as: lisesun/codalab_all_my_worksheets:v3

MAINTAINER Lisheng Sun <cecile829@gmail.com>

################## install opencv #############

RUN apt-get install -y cmake

RUN apt-get install -y unzip

RUN cd && wget https://github.com/Itseez/opencv/archive/3.1.0.zip && unzip 3.1.0.zip \

&& cd opencv-3.1.0 \

&& mkdir build && cd build && cmake .. \

&& make -j3 && make install \

&& cd \

&& rm 3.1.0.zip

################### install pandas ####################
RUN pip install pandas

################### install matplotlib.pyplot ###########
RUN apt-get install -y python-matplotlib


################# install caffe cpu ##################
RUN apt-get update && apt-get install -y --no-install-recommends \
	libatlas-base-dev \
    libboost-all-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    libhdf5-serial-dev \
    libleveldb-dev \
    liblmdb-dev \
    libopencv-dev \
    libprotobuf-dev \
    libsnappy-dev \
    protobuf-compiler &&\
rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y tree

# ENV CAFFE_ROOT = /opt/caffe
# WORKDIR $CAFFE_ROOT

# FIXME: clone a specific git tag and use ARG instead of ENV once DockerHub supports this.
ENV CLONE_TAG=master



#RUN git clone -b ${CLONE_TAG} --recursive --depth 1 https://github.com/BVLC/caffe.git . && \
RUN cd /opt && git clone https://github.com/BVLC/caffe.git 

RUN cd /opt/caffe && \
    for req in $(cat python/requirements.txt) pydot; do pip install $req; done && \
    mkdir build && cd build && \
    cmake -DCPU_ONLY=1 .. && \
    make -j"$(nproc)"

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

WORKDIR /workspace
