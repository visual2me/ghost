#
# Ghost Dockerfile
#
# https://github.com/dockerfile/ghost
#

# Pull base image.
FROM centos
MAINTAINER Tony Wan <visual2me@gmail.com>

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && yum update -y && yum install -y make gcc gcc-c++ git curl tar \
    && cd /tmp && wget http://nodejs.org/dist/node-latest.tar.gz \
    && tar xvzf node-latest.tar.gz && rm -f node-latest.tar.gz && cd node-v* \
    && ./configure && CXX="g++ -Wno-unused-local-typedefs" make \
    && CXX="g++ -Wno-unused-local-typedefs" make install \
    && cd /tmp && rm -rf /tmp/node-v* \
    && npm install -g npm && \
    && npm install -g pm2 && npm install -g gulp

RUN cd /tmp && \
    wget https://ghost.org/zip/ghost-latest.zip && \
    unzip ghost-latest.zip -d /ghost && \
    rm -f ghost-latest.zip && \
    cd /ghost && \
    npm install --production && \
    sed 's/127.0.0.1/0.0.0.0/' /ghost/config.example.js > /ghost/config.js && \
    useradd ghost --home /ghost

# Add files.
ADD start.bash /ghost-start

# Set environment variables.
ENV NODE_ENV production

# Define mountable directories.
VOLUME ["/data", "/ghost-override"]

# Define working directory.
WORKDIR /ghost

# Define default command.
CMD ["bash", "/ghost-start"]

# Expose ports.
EXPOSE 2368
