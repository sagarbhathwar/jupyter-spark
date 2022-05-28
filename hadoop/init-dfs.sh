#!/bin/bash

hdfs namenode -format
echo `hdfs getconf -confKey dfs.datanode.data.dir` | cut -c8- | xargs rm -r
