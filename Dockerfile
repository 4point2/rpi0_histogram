FROM arm32v6/alpine

# arguments
ARG OPENCV_VERSION=3.1.0

# dependencies
RUN apk add --no-cache \
    linux-headers \
    gcc \
    g++ \
    git \
    make \
    cmake \
    raspberrypi


# opencv
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
  unzip ${OPENCV_VERSION}.zip && \
  rm -rf ${OPENCV_VERSION}.zip && \
  mkdir -p opencv-${OPENCV_VERSION}/build && \
  cd opencv-${OPENCV_VERSION}/build && \
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
  make -j`nproc` && \
  make install && \
  rm -rf /opencv-${OPENCV_VERSION}

# our app
COPY src/** /app/
RUN mkdir -p /app/build && cd /app/build && cmake .. && \
    make && \
    make install && \
    rm /app -rf

ENTRYPOINT ["/usr/local/bin/opencv_hist"]
CMD ["0"]
