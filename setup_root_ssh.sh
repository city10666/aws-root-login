#!/bin/bash

# 确保脚本以 root 权限运行
if [ "$(id -u)" -ne "0" ]; then
  echo "此脚本必须以 root 用户身份运行。"
  exit 1
fi

echo "脚本开始执行：$(date)"

# 设置 root 密码
echo "设置 root 密码"
echo -n "请输入新的 root 密码："
passwd root

# 修改 /etc/ssh/sshd_config 文件
echo "修改 /etc/ssh/sshd_config 文件"
# 备份原文件
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 修改配置文件
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
# 在 PasswordAuthentication yes 之后增加 PermitRootLogin yes
grep -q '^PasswordAuthentication yes' /etc/ssh/sshd_config || echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# 修改 /etc/ssh/sshd_config.d/60-cloudimg-settings.conf 文件
echo "修改 /etc/ssh/sshd_config.d/60-cloudimg-settings.conf 文件"
# 备份原文件
cp /etc/ssh/sshd_config.d/60-cloudimg-settings.conf /etc/ssh/sshd_config.d/60-cloudimg-settings.conf.bak

# 修改配置文件
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

# 尝试重启 SSH 服务
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

# 验证服务状态
if systemctl list-units --type=service | grep -q 'ssh.service'; then
  sudo systemctl status ssh
elif systemctl list-units --type=service | grep -q 'sshd.service'; then
  sudo systemctl status sshd
else
  echo "无法找到 SSH 服务。请检查服务状态。"
  exit 1
fi

# 脚本结束时间
echo "脚本执行完毕：$(date)"
