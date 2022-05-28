#! /bin/sh
DIRECTORY=/usr/lib/jvm/java-11-openjdk-amd64/
if [ -d "$DIRECTORY" ];
then
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
else
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64/
fi
export JAVA_HOME
cd /root/
chmod +x init-dfs.sh
./init-dfs.sh
hdfs --daemon start namenode
hdfs --daemon start datanode
hdfs --daemon start secondarynamenode

cd /home
jupyter lab --ip="0.0.0.0" --port=8888 --no-browser --allow-root --NotebookApp.password_required='False'