# Niri 滚动式平铺 Wayland 合成器 — 系统级模块
{ pkgs, ... }:

let
  # polkit 认证代理 wrapper，KDL 配置中无法使用 Nix 变量插值，通过此方式解决
  polkit-agent = pkgs.writeShellScriptBin "polkit-agent" ''
    exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
  '';
in
{
  # XServer（SDDM 模块依赖，同时为 XWayland 提供支持）
  services.xserver.enable = true;

  # SDDM 显示管理器（自动检测 niri 的 .desktop 会话文件）
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;   # SDDM 自身运行在 Wayland 模式下
  };

  # Niri 合成器
  programs.niri.enable = true;

  # PipeWire 多媒体框架（屏幕共享 / 投屏必需）
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # dconf（GTK 主题配置生效的必要条件）
  programs.dconf.enable = true;

  # polkit（GUI 提权对话框）
  security.polkit.enable = true;

  # 系统级桌面包（最小化；用户级工具在 desktop.nix 中）
  environment.systemPackages = with pkgs; [
    polkit_gnome
    polkit-agent
    libsForQt5.qt5ct    # 或者写成 pkgs.qt5ct
    pkgs.qt6Packages.qt6ct          # 直接使用 pkgs.qt6ct，或者写成 pkgs.qt6Packages.qt6ct
  ];
}
