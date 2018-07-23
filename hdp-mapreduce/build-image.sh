#!/bin/bash

#
# Check cmdline args
#
if [ $# -ne 1 ]; then
  echo "ERROR: Must supply hdp version that is installed on this system"
  exit 1
fi

#
# Variables
#
HDP_VERSION="$1"
BUILD_DIR=/tmp/$(basename $0).$(date +%s)
HADOOP_INST_PATH=/usr/hdp/$HDP_VERSION
DOCKER_IMAGE_NAME="local/hdp:$HDP_VERSION"

#
# Display details
#
echo -e "\n#######"
echo "Build Directory: $BUILD_DIR"
echo "HDP Directory: $HADOOP_INST_PATH"
echo "Docker Image Name: $DOCKER_IMAGE_NAME"
echo "#######"

#
# Copy the hadoop install
#
echo -e "\n#######"
echo "Staging HDP version $HDP_VERSION"
mkdir -p $BUILD_DIR/$HDP_VERSION
cp -Rp $HADOOP_INST_PATH/hadoop* $BUILD_DIR/$HDP_VERSION/
cp -Rp $HADOOP_INST_PATH/etc* $BUILD_DIR/$HDP_VERSION/
cp -Rp $HADOOP_INST_PATH/usr* $BUILD_DIR/$HDP_VERSION/
echo "#######"

#
# Create the Dockerfile
#
echo -e "\n#######"
echo "Building HDP version $HDP_VERSION Docker Image"
cat << EOF > $BUILD_DIR/Dockerfile
FROM centos:7

# Update and install packages
RUN yum update -y && yum install -y java-1.8.0-openjdk-devel && yum clean all

# Setup envrionment
RUN mkdir -p /usr/hdp
ENV HADOOP_INST_PATH /usr/hdp/$HDP_VERSION
ENV HADOOP_PREFIX $HADOOP_INST_PATH
ENV HADOOP_COMMON_HOME $HADOOP_INST_PATH/hadoop
ENV HADOOP_HDFS_HOME $HADOOP_INST_PATH/hadoo-hdfs
ENV HADOOP_MAPRED_HOME $HADOOP_INST_PATH/hadoop-mapreduce
ENV HADOOP_YARN_HOME $HADOOP_INST_PATH/hadoop-yarn
ENV HADOOP_CONF_DIR $HADOOP_INST_PATH/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_INST_PATH/etc/hadoop
ENV PATH $PATH:$HADOOP_INST_PATH:$HADOOP_INST_PATH/usr

# Add hdp bits
RUN mkdir -p /usr/hdp
COPY $HDP_VERSION /usr/hdp
EOF

#
# Build the image
#
cd $BUILD_DIR && docker build --no-cache -t $DOCKER_IMAGE_NAME .
echo "#######"
