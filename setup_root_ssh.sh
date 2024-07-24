#!/bin/bash

# 1. 设置 root 密码
echo "请设置 root 密码："
sudo passwd root

# 2. 切换到 root 用户并执行接下来的命令
echo "请切换到 root 用户并继续执行以下操作："
echo "输入 'su root' 并输入刚刚设置的 root 密码"

# 提示用户切换到 root 用户
echo "按 Enter 键继续执行后续操作..."
read -r

# 3. 进行 SSH 配置修改
echo "现在执行以下命令："
echo "vi /etc/ssh/sshd_config"

# 修改 /etc/ssh/sshd_config 文件
echo "请修改 /etc/ssh/sshd_config 文件："
echo "找到 #PubkeyAuthentication yes 并修改为 PubkeyAuthentication yes"
echo "找到 #PasswordAuthentication yes 并修改为 PasswordAuthentication yes"
echo "在 PasswordAuthentication yes 后面添加 PermitRootLogin yes"
echo "保存并退出 (按 'Esc' 键，然后输入 ':wq' 并按 Enter 键)"

# 提示用户进行配置
echo "配置完成后，按 Enter 键继续..."
read -r

# 4. 修改 /etc/ssh/sshd_config.d/60-cloudimg-settings.conf 文件
echo "请修改 /etc/ssh/sshd_config.d/60-cloudimg-settings.conf 文件："
echo "找到 PasswordAuthentication no 并修改为 PasswordAuthentication yes"
echo "保存并退出 (按 'Esc' 键，然后输入 ':wq' 并按 Enter 键)"

# 提示用户进行配置
echo "配置完成后，按 Enter 键继续..."
read -r

# 5. 重启 SSH 服务
echo "请执行以下命令以重启 SSH 服务："
echo "sudo systemctl restart sshd"

# 提示用户重启服务
echo "重启服务后，按 Enter 键继续..."
read -r

# 6. 删除指定目录
echo "现在，删除目录 /home/ubuntu/aws-root-login"
echo "请输入以下命令以删除目录："
echo "sudo rm -rf /home/ubuntu/aws-root-login"

# 提示用户删除目录
echo "完成所有步骤后，脚本执行完毕。"
