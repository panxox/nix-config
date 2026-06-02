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

# 1. 创建机器目录
echo "==> 创建 hosts/$HOSTNAME/"
mkdir -p "hosts/$HOSTNAME"

# 2. 生成硬件配置
echo "==> 生成 hardware.nix"
sudo nixos-generate-config --root / --dir "hosts/$HOSTNAME"
# 重命名 hardware-configuration.nix → hardware.nix（与项目约定一致）
if [ -f "hosts/$HOSTNAME/hardware-configuration.nix" ]; then
  mv "hosts/$HOSTNAME/hardware-configuration.nix" "hosts/$HOSTNAME/hardware.nix"
fi

# 3. 写入 default.nix
echo "==> 生成 default.nix"
STATE_VERSION="$(nixos-version 2>/dev/null | cut -d. -f1-2 || echo '26.05')"
cat > "hosts/$HOSTNAME/default.nix" << NIXEOF
{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./gpu.nix
    ../../modules/system/config.nix
    ../../modules/system/desktop.nix
    ../../modules/system/fonts.nix
    ../../modules/system/i18n.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix.nix
    ../../modules/system/packages.nix
    ../../modules/system/services.nix
    ../../modules/system/users.nix
    ../../modules/system/virtualisation.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "$HOSTNAME";

  system.stateVersion = "$STATE_VERSION";
}
NIXEOF

# 4. 创建 gpu.nix 占位
echo "==> 创建 gpu.nix 占位（请按实际 GPU 修改）"
cat > "hosts/$HOSTNAME/gpu.nix" << NIXEOF
{ config, pkgs, lib, ... }:

{
  # =========================================================================
  # GPU 驱动配置 — 请根据实际硬件修改
  # =========================================================================
  #
  # NVIDIA 示例:
  #   services.xserver.videoDrivers = [ "nvidia" ];
  #   hardware.nvidia = {
  #     modesetting.enable = true;
  #     powerManagement.enable = true;
  #     open = false;
  #     nvidiaSettings = true;
  #     package = config.boot.kernelPackages.nvidiaPackages.stable;
  #   };
  #
  # Intel 集显示例:
  #   services.xserver.videoDrivers = [ "modesetting" ];
  #
  # AMD 示例:
  #   services.xserver.videoDrivers = [ "amdgpu" ];
  #
  # 虚拟机（无需 GPU 驱动）保持此文件为空即可。
}
NIXEOF

# 5. 移除旧模板机器目录（如果存在）
for old_host in panxox-vm; do
  if [ -d "hosts/$old_host" ] && [ "$old_host" != "$HOSTNAME" ]; then
    echo "==> 移除模板 hosts/$old_host/"
    rm -rf "hosts/$old_host"
  fi
done

# 6. 更新 flake.nix
echo "==> 更新 flake.nix (username/hostname)"
sed -i "s/username = \"[^\"]*\"/username = \"$USERNAME\"/" flake.nix
sed -i "s/hostname = \"[^\"]*\"/hostname = \"$HOSTNAME\"/" flake.nix

# 7. 更新 Git 配置
echo "==> 更新 Git 配置"
sed -i "s/name = \"[^\"]*\"/name = \"$GIT_NAME\"/" modules/home/git.nix
sed -i "s/email = \"[^\"]*\"/email = \"$GIT_EMAIL\"/" modules/home/git.nix

# 8. 更新 shell.nix 中的 nsw alias
echo "==> 更新 nsw alias"
sed -i "s/#[^\"]*/#$HOSTNAME\"/" modules/home/shell.nix

echo ""
echo "=== 部署准备完成 ==="
echo ""
echo "后续步骤:"
echo "  1. 检查 git diff 确认变更"
echo "  2. 生成密码哈希: mkpasswd -m yescrypt"
echo "  3. 将哈希填入 modules/system/users.nix 的 hashedPassword"
echo "  4. 重建: sudo nixos-rebuild switch --flake ~/nix-config#$HOSTNAME"
echo "  5. 首次登录后运行: dms setup"
echo ""
