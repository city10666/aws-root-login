#!/bin/bash

# Step 1: 设置 root 用户密码
echo "请输入 root 用户的新密码："
read -s root_password
echo "请再次输入 root 用户的新密码："
read -s root_password_confirm

if [ "$root_password" != "$root_password_confirm" ]; then
    echo "两次输入的密码不一致，请重新运行脚本。"
    exit 1
fi

echo -e "$root_password\n$root_password" | sudo passwd root

# Step 2: 切换到 root 用户并更新 SSH 配置
echo "更新 SSH 配置文件..."
sudo bash <<EOF
# 编辑 /etc/ssh/sshd_config 文件
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 增加 PermitRootLogin
if grep -q "PermitRootLogin" /etc/ssh/sshd_config; then
    sed -i 's/PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
else
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

# 编辑 /etc/ssh/sshd_config.d/60-cloudimg-settings.conf 文件
if [ -f /etc/ssh/sshd_config.d/60-cloudimg-settings.conf ]; then
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
else
    echo "PasswordAuthentication yes" > /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
fi

# 重启 SSH 服务
echo "重启 SSH 服务..."
systemctl restart ssh
EOF

echo "配置完成！请使用新的 root 用户密码登录。"
