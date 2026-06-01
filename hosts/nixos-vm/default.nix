{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix                       # 硬件驱动
    ../../modules/desktop/plasma.nix     # 桌面环境
    ../../modules/system/input-method.nix # 中文输入法
  ];

  # 引导加载程序
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "snd_hda_intel" "snd_intel8x0" ];

  # 网络与时区
  networking.hostName = "nixos-vm";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";

  # 虚拟机特化
  virtualisation.vmware.guest.enable = true;
  services.xserver.videoDrivers = [ "vmware" ];


  programs.zsh.enable = true;
  # 用户账户基础定义
  users.users.nixosvm = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Developer Account";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # 系统全局底层包
  environment.systemPackages = with pkgs; [
    vim git curl wget fastfetch
  ];

  # Nix 核心包管理器高级特性
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  system.stateVersion = "26.05";
}
