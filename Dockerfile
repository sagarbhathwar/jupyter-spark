FROM ubuntu:20.04
LABEL Maintainer="Sagar Hathwar <shathwar@ucsd.edu>"
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log

ENV DEBIAN_FRONTEND=noninteractive

# PACKAGES
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        curl \
        git \
        htop \
        openssh-client \
        libpython3.8-dev \
        python3.8 \
        python3-pip \
        subversion \
        unzip \
        nano \
        vim \
        zip \
        rsync \
        openjdk-11-jdk-headless \
        graphviz \
        ant

RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Add java to PATH
ENV PATH="$JAVA_HOME/bin:$PATH"

# HADOOP
ENV HADOOP_VERSION 3.3.2
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
RUN curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x -C /usr/ \
  && rm -rf $HADOOP_HOME/share/doc \
  && chown -R root:root $HADOOP_HOME

# SPARK
ENV SPARK_VERSION 3.2.1
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-without-hadoop
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -sL --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz" \
  | gunzip \
  | tar x -C /usr/ \
  && mv /usr/$SPARK_PACKAGE $SPARK_HOME \
  && chown -R root:root $SPARK_HOME
ENV PYSPARK_PYTHON python3

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
RUN pip3 install --upgrade dask[dataframe]
RUN pip3 install findspark

# install rclone
RUN curl https://rclone.org/install.sh | bash

# hadoop configuration
ADD hadoop/core-site.xml $HADOOP_HOME/etc/hadoop/
ADD hadoop/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
ADD hadoop/init-dfs.sh /root/
ADD hadoop/start-dfs.sh /root/
ADD hadoop/stop-dfs.sh /root/

# exposing port for connection
EXPOSE 8888
EXPOSE 8787
EXPOSE 8788
EXPOSE 4040
EXPOSE 4041

ENV HOME /home
WORKDIR ${HOME}

ADD bootstrap.sh /usr/bin/bootstrap.sh
RUN chmod +x /usr/bin/bootstrap.sh

# Set bash as default shell
ENV SHELL /bin/bash

# Script executed when container starts up
ENTRYPOINT [ "bootstrap.sh" ] 
