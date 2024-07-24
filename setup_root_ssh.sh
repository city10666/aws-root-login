#!/bin/bash

# 脚本开始时间
echo "脚本开始执行：$(date)"

# 切换到 root 用户
echo "切换到 root 用户"
sudo -i

# 设置 root 密码
echo "设置 root 密码"
echo "请输入新的 root 密码："
sudo passwd root

# 切换到 root 身份
echo "切换到 root 身份"
su root

# 修改 SSH 配置文件
echo "修改 /etc/ssh/sshd_config 文件"
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# 修改 /etc/ssh/sshd_config.d/60-cloudimg-settings.conf 文件
echo "修改 /etc/ssh/sshd_config.d/60-cloudimg-settings.conf 文件"
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

# 重启 SSH 服务
echo "重启 ssh 服务"
sudo systemctl restart sshd

# 脚本结束时间
echo "脚本执行完毕：$(date)"
