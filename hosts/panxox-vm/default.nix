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

  # ===========================================================================
  # 引导加载程序
  # ===========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ===========================================================================
  # 内核模块（VMware 音频支持）
  # ===========================================================================
  boot.kernelModules = [ "snd_hda_intel" "snd_intel8x0" ];

  # ===========================================================================
  # 主机名（通过 config.my.hostname 引用）
  # ===========================================================================
  networking.hostName = config.my.hostname;

  # ===========================================================================
  # 状态版本
  # ===========================================================================
  system.stateVersion = "26.05";
}
