# Docker image for react native.

FROM node:4.1.1

MAINTAINER Maxime Demolin <akbarova.armia@gmail.com>


# Setup environment variables
ENV PATH $PATH:node_modules/.bin

RUN echo "deb http://cdn-fastly.deb.debian.org/debian/ jessie main" > /etc/apt/sources.list && \
	echo "deb-src http://cdn-fastly.deb.debian.org/debian/ jessie main" >> /etc/apt/sources.list && \
	echo "deb http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list && \
	echo "deb-src http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list && \
	echo "deb http://ftp.de.debian.org/debian jessie main" >> /etc/apt/sources.list && \
	echo "deb-src http://ftp.de.debian.org/debian jessie main" >> /etc/apt/sources.list && \
	cat /etc/apt/sources.list

# Install Java
RUN apt-get -o Acquire::Check-Valid-Until=false update -qy && \
	apt-get install -qy --no-install-recommends python-dev default-jdk

# Install Android SDK

## Set correct environment variables.
ENV ANDROID_SDK_FILE android-sdk_r24.4.1-linux.tgz
ENV ANDROID_SDK_URL http://dl.google.com/android/$ANDROID_SDK_FILE

## Install 32bit support for Android SDK
RUN dpkg --add-architecture i386 && \
    apt-get -o Acquire::Check-Valid-Until=false update -q -y && \
    apt-get install -qy --no-install-recommends libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386


## Install SDK
ENV ANDROID_HOME /usr/local/android-sdk-linux
RUN cd /usr/local && \
    wget $ANDROID_SDK_URL && \
    tar -xzf $ANDROID_SDK_FILE && \
    export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools && \
    chgrp -R users $ANDROID_HOME && \
    chmod -R 0775 $ANDROID_HOME && \
    rm $ANDROID_SDK_FILE

# Install android tools and system-image.
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/23.0.1
RUN (while true ; do sleep 5; echo y; done) | android update sdk --no-ui --force --all --filter platform-tools,android-23,build-tools-23.0.1,extra-android-support,extra-android-m2repository,sys-img-x86_64-android-23,extra-google-m2repository


# Install node modules

## Install yarn
RUN npm install -g yarn

## Install react native
RUN npm install -g react-native-cli@1.0.0
RUN npm install -g n
RUN n latest
RUN yarn global add expo-cli
RUN npm install -g awsmobile-cli
RUN npm install --save aws-amplify
RUN npm install --save aws-amplify-react-native

## Clean up when done
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    npm cache clear --force


# Install watchman
RUN git clone https://github.com/facebook/watchman.git
RUN cd watchman && git checkout v4.7.0 && ./autogen.sh && ./configure && make && make install
RUN rm -rf watchman

# User creation
ENV USERNAME dev

RUN adduser --disabled-password --gecos '' $USERNAME

# Add Tini
ENV TINI_VERSION v0.10.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

USER $USERNAME

# Set workdir
# You'll need to run this image with a volume mapped to /home/dev (i.e. -v $(pwd):/home/dev) or override this value
WORKDIR /home/$USERNAME/app

# Tell gradle to store dependencies in a sub directory of the android project
# this persists the dependencies between builds
ENV GRADLE_USER_HOME /home/$USERNAME/app/android/gradle_deps

ENV REACT_NATIVE_PACKAGER_HOSTNAME 192.168.99.100

##############################
# end test modifications -sm #
##############################

ENTRYPOINT ["/tini", "--"]
