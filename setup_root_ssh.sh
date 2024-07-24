#!/bin/bash

# 确保脚本以非 root 用户运行
if [ "$(id -u)" -eq "0" ]; then
  echo "请以非 root 用户运行此脚本。"
  exit 1
fi

# 设置 root 密码
echo "设置 root 密码"
sudo passwd root

# 切换到 root 用户并执行配置修改
echo "切换到 root 用户"
sudo bash <<EOF

# 确保脚本以 root 权限运行
echo "脚本开始执行：$(date)"

# 修改 /etc/ssh/sshd_config 文件
echo "修改 /etc/ssh/sshd_config 文件"
# 备份原文件
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 修改配置文件
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
# 在 PasswordAuthentication yes 后增加 PermitRootLogin yes
awk '/^PasswordAuthentication yes$/ {print; print "PermitRootLogin yes"; next}1' /etc/ssh/sshd_config > /etc/ssh/sshd_config.tmp && mv /etc/ssh/sshd_config.tmp /etc/ssh/sshd_config

# 修改 /etc/ssh/sshd_config.d/60-cloudimg-settings.conf 文件
echo "修改 /etc/ssh/sshd_config.d/60-cloudimg-settings.conf 文件"
# 备份原文件
cp /etc/ssh/sshd_config.d/60-cloudimg-settings.conf /etc/ssh/sshd_config.d/60-cloudimg-settings.conf.bak

# 修改配置文件
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

# 重启 SSH 服务
echo "重启 SSH 服务"
if systemctl list-units --type=service | grep -q 'ssh.service'; then
  sudo systemctl restart ssh
  echo "使用 ssh.service 重新启动 SSH 服务"
elif systemctl list-units --type=service | grep -q 'sshd.service'; then
  sudo systemctl restart sshd
  echo "使用 sshd.service 重新启动 SSH 服务"
else
  echo "无法找到 SSH 服务。请检查服务名称。"
  exit 1
fi

# 添加延迟以确保 SSH 服务完全重启
echo "等待 10 秒以确保 SSH 服务完全重启"
sleep 10

# 删除指定目录
echo "删除目录 /home/ubuntu/aws-root-login"
rm -rf /home/ubuntu/aws-root-login
rm -rf /root/aws-root-login

# 脚本结束时间
echo "脚本执行完毕：$(date)"
EOF
