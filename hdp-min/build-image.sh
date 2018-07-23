#!/bin/bash

#
# Variables
#
BUILD_DIR=/tmp/$(basename $0).$(date +%s)
DOCKER_IMAGE_NAME="local/hdp:current"
HADOOP_INST_PATH=/usr/hdp/current
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-8.b10.el7_5.x86_64
JAVA_BIN=$JAVA_HOME/bin

#
# Display details
#
echo -e "\n#######"
echo "Build Dir: $BUILD_DIR"
echo "Docker Image Name: $DOCKER_IMAGE_NAME"
echo "#######"

#
# Create the Dockerfile
#
echo -e "\n#######"
mkdir -p $BUILD_DIR
echo "Building HDP Docker Image"
cat << EOF > $BUILD_DIR/Dockerfile
FROM centos:7

# Update and install packages
RUN yum update -y && yum install -y java-1.8.0-openjdk-devel && yum clean all

# Setup envrionment
ENV JAVA_HOME $JAVA_HOME
ENV HADOOP_INST_PATH $HADOOP_INST_PATH
ENV HADOOP_PREFIX $HADOOP_INST_PATH
ENV HADOOP_COMMON_HOME $HADOOP_INST_PATH/hadoop-client
ENV HADOOP_HDFS_HOME $HADOOP_INST_PATH/hadoo-hdfs-client
ENV HADOOP_MAPRED_HOME $HADOOP_INST_PATH/hadoop-mapreduce-client
ENV HADOOP_YARN_HOME $HADOOP_INST_PATH/hadoop-yarn-client
ENV HADOOP_CONF_DIR /etc/hadoop/conf
ENV YARN_CONF_DIR /etc/hadoop/conf
ENV PATH $PATH:$HADOOP_INST_PATH:$HADOOP_INST_PATH/usr:$JAVA_HOME:$JAVA_BIN
EOF

#
# Build the image
#
cd $BUILD_DIR && docker build --no-cache -t $DOCKER_IMAGE_NAME .
echo "#######"
