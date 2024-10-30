#!/bin/bash

# 判断本机的CPU架构和操作系统版本
cpu_arch=$(uname -m)
os_version=$(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f 2)
echo "本机CPU架构：$cpu_arch"
echo "本机操作系统版本：$os_version"

# 更新软件包列表
if [[ "$os_version" == *"Ubuntu"* || "$os_version" == *"Debian"* ]]; then
    echo "检测到系统类型为Debian/Ubuntu，正在更新软件包列表..."
    sudo apt update
elif [[ "$os_version" == *"CentOS"* || "$os_version" == *"Red Hat"* || "$os_version" == *"Fedora"* ]]; then
    echo "检测到系统类型为CentOS/Red Hat/Fedora，正在更新软件包列表..."
    sudo yum update -y
else
    echo "无法识别的操作系统类型。"
    exit 1
fi

# 检查并安装unzip
if ! command -v unzip &> /dev/null; then
    echo "unzip未安装，正在安装..."
    if [[ "$os_version" == *"Ubuntu"* || "$os_version" == *"Debian"* ]]; then
        sudo apt install unzip -y
    elif [[ "$os_version" == *"CentOS"* || "$os_version" == *"Red Hat"* || "$os_version" == *"Fedora"* ]]; then
        sudo yum install unzip -y
    fi
else
    echo "unzip已安装"
fi

# 检查 /app/goedge 目录是否存在
if [ ! -d "/app/goedge" ]; then
    sudo mkdir -p /app/goedge
    echo "安装目录创建成功，默认为/app/goedge"
else
    echo "检测到/app/goedge已存在，您可能已经安装过goedge，无需重复安装，脚本已退出！"
    exit 1
fi

# 修改本机hosts屏蔽官方域名
hosts_entries=(
    "127.0.0.1 goedge.cn"
    "127.0.0.1 goedge.cloud"
    "127.0.0.1 dl.goedge.cloud"
    "127.0.0.1 dl.goedge.cn"
    "127.0.0.1 global.dl.goedge.cloud"
    "127.0.0.1 global.dl.goedge.cn"
)

for entry in "${hosts_entries[@]}"; do
    if ! grep -q "$entry" /etc/hosts; then
        echo "$entry" | sudo tee -a /etc/hosts
    fi
done

echo "已成功屏蔽官方域名通信！"

# 下载对应架构程序包
cd /app/goedge
if [[ "$cpu_arch" == "x86_64" ]]; then
    wget https://static-file-global.353355.xyz/goedge/edge-admin-linux-amd64-plus-v1.3.9.zip
    echo "已下载X86架构的安装包"
elif [[ "$cpu_arch" == "aarch64" ]]; then
    wget https://static-file-global.353355.xyz/goedge/edge-admin-linux-arm64-plus-v1.3.9.zip
    echo "已下载ARM架构的安装包"
else
    echo "不支持的CPU架构"
    exit 1
fi

# 解压缩程序包
unzip -o edge-admin-linux-*.zip

# 进入 edge-admin 目录
cd edge-admin

# 启动 edge-admin 主程序
# bin/edge-admin start

# 安装系统服务
# bin/edge-admin service

# 删除 /delop 自带程序包
cd edge-api/deploy
rm -rf *.zip

# 拉取纯净plus版本程序包
wget -O edge-node-linux-amd64-v1.3.9.zip https://static-file-global.353355.xyz/goedge/edge-node-linux-amd64-plus-v1.3.9.zip
wget -O edge-node-linux-arm64-v1.3.9.zip https://static-file-global.353355.xyz/goedge/edge-node-linux-arm64-plus-v1.3.9.zip

# 流程执行完毕，输出管理平台地址及通用注册码
# clear
ipv4_address=$(curl -s ipv4.ip.sb)
echo -e "\033[1;33m执行完毕！请通过浏览器访问 http://$ipv4_address:7788/ 进入管理平台，并依据页面提示完成最后的安装流程！\033[0m"
echo -e "\033[1;33m如果无法访问，请检查是否已在防火墙/安全租中开放7788端口！\033[0m"
