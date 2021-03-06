# Android Dockerfile
# Heavily inspired by https://github.com/uber-common/android-build-environment

FROM ubuntu:16.04

MAINTAINER Francois Stephany & Benjamin Baudoux "francois@tamere.eu, baudouxbenjamin@gmail.com"

# Sets language to UTF8 : this works in pretty much all cases
ENV LANG en_US.UTF-8
# RUN locale-gen $LANG

ENV DOCKER_ANDROID_LANG en_US
ENV DOCKER_ANDROID_DISPLAY_NAME ci-docker

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

# Update apt-get
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update
RUN apt-get dist-upgrade -y

# Installing packages
RUN apt-get install -y \
  autoconf \
  build-essential \
  bzip2 \
  curl \
  gcc \
  git \
  groff \
#   lib32stdc++6 \
#   lib32z1 \
#   lib32z1-dev \
#   lib32ncurses5 \
#   lib32bz2-1.0 \
  libc6-dev \
  libgmp-dev \
  libmpc-dev \
  libmpfr-dev \
  libxslt-dev \
  libxml2-dev \
  m4 \
  make \
  ncurses-dev \
  ocaml \
  openssh-client \
  pkg-config \
  python-software-properties \
  rsync \
  software-properties-common \
  unzip \
  wget \
  zip \
  zlib1g-dev \
  --no-install-recommends

# Install Java
RUN apt-add-repository ppa:openjdk-r/ppa
RUN apt-get update
RUN apt-get -y install openjdk-8-jdk

# Clean Up Apt-get
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean

# Install Android SDK
RUN wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
RUN unzip sdk-tools-linux-3859397.zip -d android-sdk-linux
RUN mv android-sdk-linux /usr/local/android-sdk
RUN rm sdk-tools-linux-3859397.zip

ENV ANDROID_COMPONENTS platform-tools,android-2,build-tools-26.0.3,build-tools-27.0.3

# Install Android tools
RUN echo y | /usr/local/android-sdk/tools/android update sdk --filter "${ANDROID_COMPONENTS}" --no-ui -a

# Install Android NDK
RUN wget https://dl.google.com/android/repository/android-ndk-r16b-linux-x86_64.zip
RUN unzip android-ndk-r16b-linux-x86_64.zip
RUN mv android-ndk-r16b /usr/local/android-ndk
RUN rm android-ndk-r16b-linux-x86_64.zip

# Environment variables
ENV ANDROID_HOME /usr/local/android-sdk
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV ANDROID_NDK_HOME /usr/local/android-ndk

ENV PATH ${INFER_HOME}/bin:${PATH}
ENV PATH $PATH:$ANDROID_SDK_HOME/tools
ENV PATH $PATH:$ANDROID_SDK_HOME/platform-tools
ENV PATH $PATH:$ANDROID_NDK_HOME

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Accept Android Licenses
RUN mkdir "${ANDROID_HOME}/licenses"
RUN echo "8933bad161af4178b1185d1a37fbf41ea5269c55" >> "${ANDROID_HOME}/licenses/android-sdk-license"
RUN echo "d56f5187479451eabf01fb78af6dfcb131a6481e" >> "${ANDROID_HOME}/licenses/android-sdk-license"
RUN echo "84831b9409646a918e30573bab4c9c91346d8abd" >> "${ANDROID_HOME}/licenses/android-sdk-preview-license"

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms4096m -Xmx4096m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

# Cleaning
RUN apt-get clean

# Fix permissions
RUN chmod -R a+rx $ANDROID_HOME $ANDROID_SDK_HOME $ANDROID_NDK_HOME

# Creating project directories prepared for build when running
# `docker run`
ENV PROJECT /project
RUN mkdir $PROJECT
WORKDIR $PROJECT

RUN echo "sdk.dir=$ANDROID_HOME" > local.properties
