FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y wget build-essential lcov curl cmake gcovr libssl-dev \
      git python-cheetah libuv1-dev ninja-build adb

# Install the Android NDK
RUN mkdir -p /tmp/android-ndk && \
    cd /tmp/android-ndk && \
    wget -q http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin -O android-ndk.bin && \
    chmod a+x ./android-ndk.bin && sync && ./android-ndk.bin && \
    mv ./android-ndk-r10e /opt/android-ndk && \
    chmod -R a+rX /opt/android-ndk && \
    rm -rf /tmp/android-ndk

ENV ANDROID_NDK_PATH /opt/android-ndk
