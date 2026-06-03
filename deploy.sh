#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "=== NixOS 新机器部署 ==="
echo ""

read -rp "主机名 (hostname): " HOSTNAME
read -rp "用户名: " USERNAME
read -rp "Git 用户名: " GIT_NAME
read -rp "Git 邮箱: " GIT_EMAIL

echo ""
echo "--- 即将进行的操作 ---"
echo "主机名:   $HOSTNAME"
echo "用户名:   $USERNAME"
echo "Git:      $GIT_NAME <$GIT_EMAIL>"
echo "仓库路径: $REPO_ROOT"
echo ""
read -rp "确认? [y/N] " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "已取消"; exit 0; }

cd "$REPO_ROOT"

# 1. 生成硬件配置
echo "==> 生成 hardware-configuration.nix"
sudo nixos-generate-config --root / --dir nixos
mv -f nixos/hardware-configuration.nix nixos/hardware-configuration.nix 2>/dev/null || true

# 2. 更新 flake.nix 中的用户名 / 主机名
echo "==> 更新 flake.nix"
sed -i "s/username = \"[^\"]*\"/username = \"$USERNAME\"/" flake.nix
sed -i "s/hostname = \"[^\"]*\"/hostname = \"$HOSTNAME\"/" flake.nix

# 3. 更新 Git 配置
echo "==> 更新 home-manager/home.nix 中的 Git 信息"
sed -i "s/name = \"[^\"]*\"/name = \"$GIT_NAME\"/" home-manager/home.nix
sed -i "s/email = \"[^\"]*\"/email = \"$GIT_EMAIL\"/" home-manager/home.nix

echo ""
echo "=== 部署准备完成 ==="
echo ""
echo "后续步骤:"
echo "  1. 检查 git diff 确认变更"
echo "  2. 生成密码哈希: mkpasswd -m yescrypt"
echo "  3. 将哈希填入 nixos/configuration.nix 的 hashedPassword 字段"
echo "  4. 重建系统: sudo nixos-rebuild switch --flake ~/nix-config#$HOSTNAME"
echo "  5. 首次登录后初始化 DMS: dms setup"
echo ""
