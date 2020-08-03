#########################################################################
# File Name: deploy.sh
# Author: xiangcai
# mail: xiangcai@gmail.com
# Created Time: Wed 19 Feb 2020 12:29:13 PM CST
#########################################################################
#!/bin/bash

# ===================run the script with root user=================================
# ==========================开始配置==================================

# 1.docker-compose.yml依赖配置
# zk1暴露的端口
REAL_ZOO1_PORT=2181
REAL_ZOO1_DATA=../data/zoo/zoo1
REAL_ZOO1_LOG=../log/zoo/zoo1
# zk2暴露的端口
REAL_ZOO2_PORT=2182
REAL_ZOO2_DATA=../data/zoo/zoo2
REAL_ZOO2_LOG=../log/zoo/zoo2
# kafka1暴露的端口
REAL_KAFKA1_PORT=9091
REAL_KAFKA1_DATA=../data/kafka/kafka1
REAL_KAFKA1_LOG=../log/kafka/kafka1
# kafka1暴露的端口
REAL_KAFKA2_PORT=9092
REAL_KAFKA2_DATA=../data/kafka/kafka2
REAL_KAFKA2_LOG=../log/kafka/kafka2
# kafka-manager暴露的端口
REAL_MANAGER_PORT=9000

# 是否配置docker加速器   1/0
docker_accelerator=1
# 是否指定pip的下载源
pip_repository=https://pypi.tuna.tsinghua.edu.cn/simple
# 启动的服务
services="mysql redis es es_head"

# ==========================配置结束==================================

# 创建依赖的目录
mkdir -p ../{data,log}/{kafka/{kafka1,kafka2},zoo/{zoo1,zoo2}}


# 声明变量
install_docker_script=./install_docker.sh

if [ -n "$pip_repository" ]
then
    sed -i "s#pip install#pip install -i $pip_repository#g" $install_docker_script
fi


# 检查/安装docker和docker-compose
sh $install_docker_script
if [ -n "$pip_repository" ]
then
    git checkout $install_docker_script
fi

if [ "$docker_accelerator" = 1 ]
then
    echo '{"registry-mirrors":["https://docker.mirrors.ustc.edu.cn"]}' > /etc/docker/daemon.json
    systemctl daemon-reload 
    systemctl restart docker
fi


echo "REAL_ZOO1_PORT=$REAL_ZOO1_PORT
REAL_ZOO1_DATA=$REAL_ZOO1_DATA
REAL_ZOO1_LOG=$REAL_ZOO1_LOG
REAL_ZOO2_PORT=$REAL_ZOO2_PORT
REAL_ZOO2_DATA=$REAL_ZOO2_DATA
REAL_ZOO2_LOG=$REAL_ZOO2_LOG
REAL_KAFKA1_PORT=$REAL_KAFKA1_PORT
REAL_KAFKA1_DATA=$REAL_KAFKA1_DATA
REAL_KAFKA1_LOG=$REAL_KAFKA1_LOG
REAL_KAFKA2_PORT=$REAL_KAFKA2_PORT
REAL_KAFKA2_DATA=$REAL_KAFKA2_DATA
REAL_KAFKA2_LOG=$REAL_KAFKA2_LOG
REAL_MANAGER_PORT=$REAL_MANAGER_PORT
" > .env

# 启动服务
docker-compose up -d $service
# 添加端口到防火墙
firewall-cmd --permanent --add-port=$REAL_ZOO1_PORT/tcp
firewall-cmd --permanent --add-port=$REAL_ZOO2_PORT/tcp
firewall-cmd --permanent --add-port=$REAL_KAFKA1_PORT/tcp
firewall-cmd --permanent --add-port=$REAL_KAFKA2_PORT/tcp
firewall-cmd --permanent --add-port=$REAL_MANAGER_PORT/tcp

# 重新加载防火墙
firewall-cmd --reload

