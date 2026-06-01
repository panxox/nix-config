{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    # 在此添加需要放行的 unfree 包名
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    fastfetch
    polkit_gnome
    libsForQt5.qt5ct
    qt6Packages.qt6ct
  ];
}
