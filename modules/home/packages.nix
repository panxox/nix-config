{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # CLI 工具
    htop
    tmux
    fzf
    ripgrep
    btop
    jq
    tree
    file
    which
    fastfetch

    # 网络工具
    mtr
    dnsutils

    # 开发工具
    gcc

    # 效率工具
    lazygit
    glow          # Markdown 阅读器
    zellij        # 终端复用器
    yazi          # 终端文件管理器

    # AI 助手
    #reasonix

    # ===========================================================================
    # 桌面应用
    # ===========================================================================

    # 终端
    kitty

    # 壁纸守护进程
    awww

    # 截图工具
    grim
    slurp

    # Wayland 剪贴板
    wl-clipboard

    # 媒体 / 背光控制
    brightnessctl
    playerctl

    # 启动器 / 通知 / 锁屏
    fuzzel
    mako
    swaylock

    # 状态栏
    waybar

    # GTK 主题预览 / 配置工具
    nwg-look

    # 字体
    nerd-fonts.jetbrains-mono

    # 图标主题
    papirus-icon-theme

    # 光标主题
    catppuccin-cursors.mochaDark

    # 输入法皮肤
    fcitx5-material-color
  ];
}
