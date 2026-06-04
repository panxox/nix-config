# =============================================================================
# Home Manager 用户配置 — 最小化版本
# =============================================================================
# 系统级设置请到 ../nixos/configuration.nix 修改。
#
# Home Manager 选项: https://nix-community.github.io/home-manager/options.html
# Nix 包搜索:      https://search.nixos.org/packages
# =============================================================================
{
  inputs,
  lib,
  config,
  pkgs,
  username,
  hostname,
  ...
}: {
  # ===========================================================================
  # 基本信息
  # ===========================================================================
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";              # 不要改
  };

  programs.home-manager.enable = true;

  # ===========================================================================
  # 用户软件包
  # ===========================================================================
  # 用 home.packages 装你需要的软件, 每个包一行, 保持干净。
  # 搜索包的名称: https://search.nixos.org/packages
  home.packages = with pkgs; [
    # ---- 终端 ----
    kitty                               # GPU 加速终端模拟器
    zellij                              # 终端复用器 (tmux 替代)

    # ---- 浏览器 ----
    firefox                             # Firefox 浏览器

    # ---- 编辑器 ----
    vscode                              # VS Code
    neovim                              # Neovim 终端编辑器

    # ---- 系统工具 ----
    btop                                # 资源监控
    fastfetch                           # 系统信息

    # ---- Wayland 工具 ----
    wl-clipboard                        # 剪贴板 (wl-copy / wl-paste)
    fuzzel                              # 应用启动器

    # ---- 开发语言 ----
    go                                  # Golang
    rustup                              # Rust 工具链管理器
    rust-analyzer                       # Rust LSP 服务器

    # ---- 字体 (用户级, fontconfig 可见) ----
    maple-mono.NF-CN                    # Maple Mono Nerd Font
    sarasa-gothic                       # 更纱黑体
    noto-fonts-cjk-serif                # Noto 宋体
    nerd-fonts.symbols-only             # Nerd Font 图标

    # ---- 图标主题 ----
    papirus-icon-theme                  # Papirus 图标

    # ---- 光标主题 ----
    catppuccin-cursors.mochaDark        # Catppuccin Mocha 暗色光标
  ];

  # ===========================================================================
  # Shell — Zsh + Starship
  # ===========================================================================
  programs.zsh = {
    enable = true;
    enableCompletion = true;             # 命令补全
    autosuggestion.enable = true;        # 灰色历史提示
    syntaxHighlighting.enable = true;    # 语法高亮

    shellAliases = {
      ll = "ls -l";
      # 一键重建系统 (要先 git commit)
      nsw = "sudo nixos-rebuild switch --flake $HOME/nix-config/#${hostname}";
    };
  };

  # ---- Starship 提示符 ----
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$line_break"
        "$character"
      ];

      character = {
        success_symbol = "[>](bold #89b4fa)";
        error_symbol   = "[>](bold #f38ba8)";
      };

      directory = {
        style = "#b4befe";
        truncation_length = 5;
      };

      git_branch = {
        style = "#fab387";
        symbol = "";
      };
      git_status.style = "#eba0ac";

      username = {
        show_always = true;
        style_user = "#a6e3a1";
        format = "[$user]($style) ";
      };

      hostname = {
        ssh_only = false;
        style = "#89b4fa";
        format = "on [$hostname]($style) ";
      };

      nix_shell = {
        symbol = "";
        style = "#74c7ec";
        format = "via [$symbol]($style) ";
      };
    };
  };

  # ===========================================================================
  # Git
  # ===========================================================================
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "panxox";               # ← 改成你的名字
        email = "2279827640@qq.com";   # ← 改成你的邮箱
      };
      init.defaultBranch = "main";
    };
  };

  # ===========================================================================
  # SSH
  # ===========================================================================
  programs.ssh = {
    enable = true;
    # 按需开启:
    # matchBlocks = {
    #   "github.com" = {
    #     hostname = "github.com";
    #     user = "git";
    #     identityFile = "~/.ssh/id_ed25519";
    #   };
    # };
  };

  # ===========================================================================
  # 主题 — Qt / GTK / fontconfig
  # ===========================================================================
  # ---- Qt ----
  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
  };

  # ---- Wayland 相关环境变量 ----
  systemd.user.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    NIXOS_OZONE_WL = "1";               # Electron 应用走 Wayland
  };

  # ---- XDG Portal (屏幕共享 / 文件选择器) ----
  xdg.portal = {
    enable = true;
    config.common.default = [ "gtk" ];
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ---- Fontconfig (字体回退顺序) ----
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Sarasa UI SC" ];
      serif     = [ "Noto Serif CJK SC" ];
      monospace  = [ "Maple Mono NF CN" ];
    };
  };

  # ---- GTK ----
  gtk = {
    enable = true;
    font = {
      name = "Maple Mono NF CN";
      size = 11;
    };
  };

  # ---- dconf: 偏好暗色 ----
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
