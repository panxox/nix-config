{ config, lib, pkgs, ... }:

{
  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
  };

  systemd.user.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [ "kde" "gtk" ];
      };
    };
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Sarasa UI SC" ];
      serif = [ "Noto Serif CJK SC" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };

  # GTK: DMS 通过 adw-gtk3 提供动态亮暗切换
  gtk = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
  };

  # dconf: 默认偏好深色模式（DMS 会动态切换）
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  home.packages = with pkgs; [
    # Fonts
    sarasa-gothic
    noto-fonts-cjk-serif
    maple-mono.NF-CN

    # Icon theme
    tela-icon-theme

    # GTK theme (DMS 动态主题依赖)
    adw-gtk3

    # Qt theming
    qt6Packages.qt6ct
    libsForQt5.qt5ct
    kdePackages.breeze
    kdePackages.plasma-integration
  ];
}
