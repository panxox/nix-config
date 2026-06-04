# =============================================================================
# NixOS KDE 基础配置 — VMware 虚拟机新安装用
# =============================================================================
# 这是一个最小化的 KDE Plasma 6 桌面配置，用于在 VMware 虚拟机上新安装
# NixOS 后直接复制到 /etc/nixos/configuration.nix 使用。
#
# 使用方法:
#   1. nixos-install 完成后进入系统
#   2. 编辑 /etc/nixos/configuration.nix, 替换为本文件内容
#   3. 确保 /etc/nixos/hardware-configuration.nix 存在 (安装器已自动生成)
#   4. 运行: sudo nixos-rebuild switch
#   5. 重启: sudo reboot
#
# 包含:
#   - KDE Plasma 6 桌面环境 (SDDM 显示管理器)
#   - VMware 虚拟机支持
#   - Git / Zsh / sudo
#   - 中文语言支持
#   - Flakes + Nix 命令
# =============================================================================
{ config, pkgs, lib, ... }:

{
  # ---- 导入硬件配置 (由 nixos-generate-config 自动生成) ----
  imports = [
    ./hardware-configuration.nix
  ];

  # ===========================================================================
  # 引导
  # ===========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ===========================================================================
  # Nix 自身设置
  # ===========================================================================
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nixpkgs.config.allowUnfree = true;         # 允许非自由软件

  # ===========================================================================
  # 网络
  # ===========================================================================
  networking.hostName = "panxox-vm";
  networking.networkmanager.enable = true;

  # ===========================================================================
  # 时区 & 语言
  # ===========================================================================
  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT    = "zh_CN.UTF-8";
    LC_MONETARY       = "zh_CN.UTF-8";
    LC_NAME           = "zh_CN.UTF-8";
    LC_NUMERIC        = "zh_CN.UTF-8";
    LC_PAPER          = "zh_CN.UTF-8";
    LC_TELEPHONE      = "zh_CN.UTF-8";
    LC_TIME           = "zh_CN.UTF-8";
  };
  i18n.supportedLocales = [
    "zh_CN.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];

  # ---- 键盘布局 ----
  services.xserver.xkb.layout = "cn";

  # ---- 控制台字体 (显示中文) ----
  console.font = "latarcyrheb-sun32";

  # ===========================================================================
  # KDE Plasma 6 桌面环境
  # ===========================================================================
  services.displayManager.sddm.enable = true;        # SDDM 登录管理器
  services.desktopManager.plasma6.enable = true;     # KDE Plasma 6 桌面

  # ---- 音频 (PipeWire) ----
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # ===========================================================================
  # 用户
  # ===========================================================================
  users.users.panxox = {
    isNormalUser = true;
    description = "panxox";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" ];
    # 首次登录后请用 passwd 设置密码
    # initialPassword = "changeme";
  };

  programs.zsh.enable = true;

  # ===========================================================================
  # sudo — 允许 wheel 组
  # ===========================================================================
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        { command = "ALL"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  # ===========================================================================
  # 系统软件包
  # ===========================================================================
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    fastfetch
  ];

  # ===========================================================================
  # VMware 虚拟机支持
  # ===========================================================================
  virtualisation.vmware.guest.enable = true;

  # ===========================================================================
  # 状态版本 — 不要改
  # ===========================================================================
  system.stateVersion = "26.11";
}
