# =============================================================================
# Home Manager 用户配置 — niri + DMS 桌面版
# =============================================================================
# 系统级设置请到 ../nixos/configuration.nix 修改。
# DMS 桌面环境在此配置。
#
# Home Manager 选项: https://nix-community.github.io/home-manager/options.html
# Nix 包搜索:      https://search.nixos.org/packages
# DMS 选项:         https://github.com/AvengeMedia/DankMaterialShell/blob/stable/distro/nix/options.nix
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
    enableNixpkgsReleaseCheck = false;   # nixpkgs 与 HM release 可能有微小版本偏移, 忽略检查
  };

  programs.home-manager.enable = true;

  # 禁用 niri-flake 自带的 polkit agent，使用 DMS 内置的 polkit agent 避免冲突
  systemd.user.services.niri-flake-polkit.enable = false;

  # ===========================================================================
  # DankMaterialShell — 桌面环境
  # ===========================================================================
  # DMS home-manager 模块和 niri 集成模块已在 flake.nix 中导入。
  # 详见: https://danklinux.com/docs/dankmaterialshell/nixos-flake
  programs.dank-material-shell = {
    enable = true;

    # --- DMS 自启方式: 由 niri 管理 (而非 systemd) ---
    # 注意: 不要同时启用 systemd.enable 和 niri.enableSpawn，会产生两个 DMS 实例。
    # systemd.enable = false;  (默认值)
    niri = {
      enableSpawn = true;                # niri 启动时自动启动 DMS
      # niri.includes 默认启用，处理配置包含 (niri config.kdl 包含 DMS 生成的文件)
    };

    # --- 功能开关 ---
    enableSystemMonitoring = true;      # 系统监控 (CPU/GPU/内存/磁盘/网络)
    enableVPN = true;                   # VPN 管理
    enableDynamicTheming = true;        # 动态取色 (matugen)
    enableAudioWavelength = true;       # 音频可视化 (cava)
    enableCalendarEvents = true;        # 日历集成 (khal)
    enableClipboardPaste = true;        # 剪贴板历史粘贴 (wtype)

    # --- DMS 插件 (来自插件注册表) ---
    plugins = {
      # 从插件注册表启用插件 (ID 可在插件商店找到)
      # 示例: dockerManager.enable = true;
      # 见 https://github.com/AvengeMedia/dms-plugin-registry
    };
  };

  # ===========================================================================
  # 用户软件包
  # ===========================================================================
  # 注意: DMS 已经自带了启动器、剪贴板、通知、壁纸、锁屏等功能,
  # 所以不再需要 fuzzel 等独立工具。
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
    fastfetch                           # 系统信息

    # ---- 开发语言 ----
    go                                  # Golang
    rustup                              # Rust 工具链管理器 (含 rust-analyzer)

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
      # DMS 快捷命令
      dms-restart = "systemctl --user restart dms";
      dms-logs = "journalctl --user -u dms -f";
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
    enableDefaultConfig = false;       # 新版 HM 不再自动注入默认值, 关掉弃用警告
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
    platformTheme.name = "gtk3";
    style.name = "kvantum";
  };

  # ---- Wayland 相关环境变量 (DMS 推荐配置) ----
  systemd.user.sessionVariables = {
    # Qt Wayland
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Electron Wayland
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # GDK (GTK) 后端
    GDK_BACKEND = "wayland";

    # SDL
    SDL_VIDEO_DRIVER = "wayland";

    # DMS 截图编辑器
    DMS_SCREENSHOT_EDITOR = "swappy";
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

  # ---- Fontconfig (字体回退顺序) ----
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Sarasa UI SC" ];
      serif     = [ "Noto Serif CJK SC" ];
      monospace  = [ "Maple Mono NF CN" ];
    };
  };
}
