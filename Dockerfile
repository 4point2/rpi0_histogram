FROM arm32v6/alpine

RUN \
    apk add --no-cache \
        linux-headers \
        gcc \
        g++ \
        git \
        make \
        cmake \
        raspberrypi \
        v4l-utils \
        python3

ENV OPENCV_VERSION=3.1.0

RUN mkdir /work && cd /work && \
  wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
  unzip ${OPENCV_VERSION}.zip && \
  rm -rf ${OPENCV_VERSION}.zip

RUN mkdir -p /work/opencv-${OPENCV_VERSION}/build && \
  cd /work/opencv-${OPENCV_VERSION}/build && \
  cmake \
  -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D WITH_FFMPEG=NO \
  -D WITH_IPP=NO \
  -D WITH_OPENEXR=NO \
  -D WITH_TBB=YES \
  -D BUILD_EXAMPLES=NO \
  -D BUILD_ANDROID_EXAMPLES=NO \
  -D INSTALL_PYTHON_EXAMPLES=NO \
  -D BUILD_DOCS=NO \
  -D BUILD_opencv_python2=NO \
  -D BUILD_opencv_python3=NO \
  .. && \
  make && \
  make install && \
  rm -rf /work/opencv-${OPENCV_VERSION} 

COPY src/** /work/app/
RUN cd /work/app/ && \ 
    cmake && \
    make && \
    make install && \
    rm /work -rf 

CMD ["/usr/local/bin/opencv_hist", "0"]
