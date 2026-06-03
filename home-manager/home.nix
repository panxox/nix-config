# =============================================================================
# Home Manager 用户配置 (home.nix)
# =============================================================================
# 此文件配置用户级别的软件包和桌面环境。
# 系统级别的配置在 ../nixos/configuration.nix 中。
#
# 查找可用的 Home Manager 选项:
#   https://nix-community.github.io/home-manager/options.html
# =============================================================================
{
  inputs,
  lib,
  config,
  pkgs,
  username,
  hostname,
  dms,
  ...
}: let
  # ---- 默认字体 ----
  font-name = "Maple Mono NF CN";        # 主等宽字体
  font-size = "12";
in {
  # ===========================================================================
  # Home 基本信息
  # ===========================================================================
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";              # 请勿修改, 除非你清楚它的用途
  };

  programs.home-manager.enable = true;   # 让 home-manager 管理自身

  # ===========================================================================
  # Nixpkgs 用户级配置
  # ===========================================================================
  nixpkgs.config.allowUnfree = true;     # 允许 Chrome、VS Code 等非自由软件

  # ===========================================================================
  # 用户软件包
  # ===========================================================================
  home.packages = with pkgs; [
    # ---- 终端 ----
    kitty                               # GPU 加速终端模拟器
    zellij                              # 终端复用器

    # ---- 启动器 (DMS 内置 Spotlight, fuzzel 作为备选) ----
    fuzzel                              # Wayland 原生应用启动器

    # ---- 浏览器 ----
    firefox                             # Firefox (Wayland 原生)

    # ---- 编辑器 / IDE ----
    vscode                              # VS Code
    neovim                              # Neovim 终端编辑器

    # ---- 系统监控 ----
    btop                                # 资源监控 (比 htop 更美观)

    # ---- 剪贴板 (Wayland) ----
    wl-clipboard                        # wl-copy / wl-paste 命令行剪贴板

    # ---- 开发语言 ----
    go                                  # Golang
    rustup                              # Rust 工具链管理器
    rust-analyzer                       # Rust LSP

    # ---- 字体 (用户级, fontconfig 可见) ----
    maple-mono.NF-CN                    # Maple Mono Nerd Font (中文等宽)
    sarasa-gothic                       # 更纱黑体 (无衬线中文)
    noto-fonts-cjk-serif                # Noto 宋体 (衬线中文)
    nerd-fonts.symbols-only             # Nerd Font 图标符号

    # ---- 图标主题 ----
    papirus-icon-theme                  # Papirus 图标 (DMS 可用)

    # ---- 光标主题 ----
    catppuccin-cursors.mochaDark        # Catppuccin Mocha 暗色光标

    # ---- 主题依赖 (DMS 动态亮暗切换所需) ----
    adw-gtk3                            # libadwaita GTK3 主题
    kdePackages.breeze                  # Breeze 主题 (Qt/KDE 应用美化)
  ];

  # ===========================================================================
  # DMS (DankMaterialShell) 桌面外壳
  # ===========================================================================
  # DMS 提供: 状态栏 / 通知中心 / Spotlight 启动器 / 锁屏 /
  #          剪贴板管理器 / 电源菜单 / 动态壁纸 / 自动主题切换
  # 文档: https://danklinux.com/docs/
  programs.dank-material-shell = {
    enable = true;

    # ---- 动态主题 (DMS 自动生成配色方案) ----
    enableDynamicTheming = true;

    # ---- 系统监控小组件 ----
    enableSystemMonitoring = true;

    # ---- 用 systemd 管理 DMS (崩溃自动重启) ----
    systemd.enable = true;

    # ---- 会话设置 ----
    session = {
      # 壁纸路径 (assets 目录中的图片)
      wallpaperPath = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper-dark.png";
      wallpaperPathLight = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper-light.png";
      wallpaperPathDark = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper-dark.png";

      # 壁纸行为
      perModeWallpaper = true;           # 亮暗模式使用不同壁纸
      perMonitorWallpaper = false;       # 多显示器共用壁纸
      wallpaperTransition = "fade";      # 壁纸切换过渡效果
      wallpaperCyclingEnabled = false;   # 不自动轮换壁纸

      # 地理位置 (上海, 用于天气和日出日落计算)
      latitude = 31.23;
      longitude = 121.47;

      # 夜间模式
      nightModeEnabled = false;          # 默认不开启夜间模式
      nightModeTemperature = 4500;       # 夜间色温 (K)
      nightModeAutoEnabled = true;       # 自动切换夜间模式
      nightModeAutoMode = "location";    # 根据地理位置日出日落
      nightModeStartHour = 18;
      nightModeEndHour = 6;
      nightModeUseIPLocation = false;

      # 自动主题 (根据日出日落切换亮暗)
      themeModeAutoEnabled = true;
      themeModeAutoMode = "location";
      themeModeStartHour = 18;
      themeModeEndHour = 6;
      themeModeShareGammaSettings = true;

      # 天气
      weatherLocation = "Shanghai";
      weatherCoordinates = "31.23,121.47";
      weatherHourlyDetailed = true;

      # 其他
      showThirdPartyPlugins = false;
      searchAppActions = true;
      configVersion = 3;
    };
  };

  # ===========================================================================
  # Niri 配置符号链接
  # ===========================================================================
  # 使用 mkOutOfStoreSymlink 让 DMS 可以写入 niri/dms/ 目录
  # niri/config.kdl 为手写, niri/dms/ 由 dms setup 生成
  xdg.configFile = let
    niriDir = "${config.home.homeDirectory}/nix-config/niri";
  in {
    # ---- 手写主配置 ----
    "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/config.kdl";

    # ---- DMS 生成的文件 (初始模板, dms setup 会覆盖) ----
    "niri/dms/alttab.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/alttab.kdl";
    "niri/dms/binds.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/binds.kdl";
    "niri/dms/colors.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/colors.kdl";
    "niri/dms/cursor.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/cursor.kdl";
    "niri/dms/layout.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/layout.kdl";
    "niri/dms/outputs.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/outputs.kdl";
    "niri/dms/windowrules.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/windowrules.kdl";
    "niri/dms/wpblur.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/wpblur.kdl";
  };

  # ===========================================================================
  # 壁纸文件 (从 assets/ 拷贝到 ~/.local/share/wallpapers/)
  # ===========================================================================
  home.file.".local/share/wallpapers/wallpaper-dark.png".source =
    ../assets/wallpaper-dark.png;
  home.file.".local/share/wallpapers/wallpaper-light.png".source =
    ../assets/wallpaper-light.png;

  # ===========================================================================
  # DMS 头像设置 (systemd oneshot + 重试)
  # ===========================================================================
  # 等 DMS 启动后自动设置用户头像
  systemd.user.services.dms-set-avatar = {
    Unit = {
      Description = "Set DMS profile avatar after DMS starts";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "dms-set-avatar" ''
        for i in $(seq 1 30); do
          if ${dms.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/dms \
            ipc profile setImage $HOME/nix-config/assets/avatar.jpg 2>&1 | \
            grep -q SUCCESS; then
            exit 0
          fi
          sleep 1
        done
        exit 1
      ''}";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # ===========================================================================
  # Kitty 终端模拟器
  # ===========================================================================
  # Catppuccin Mocha 配色方案
  programs.kitty = {
    enable = true;
    font = {
      name = font-name;
      size = 12;
    };
    settings = {
      # ---- 基本外观 ----
      foreground = "#cdd6f4";            # mocha-text
      background = "#1e1e2e";            # mocha-base
      selection_foreground = "#cdd6f4";
      selection_background = "#585b70";  # mocha-surface2

      # ---- 16 色调色板 ----
      # 常规色 (0-7)
      color0  = "#45475a";    # mocha-surface1
      color1  = "#f38ba8";    # mocha-red
      color2  = "#a6e3a1";    # mocha-green
      color3  = "#f9e2af";    # mocha-yellow
      color4  = "#89b4fa";    # mocha-blue
      color5  = "#f5c2e7";    # mocha-pink
      color6  = "#94e2d5";    # mocha-teal
      color7  = "#bac2de";    # mocha-subtext1

      # 亮色 (8-15)
      color8  = "#585b70";    # mocha-surface2
      color9  = "#f38ba8";    # mocha-red
      color10 = "#a6e3a1";    # mocha-green
      color11 = "#f9e2af";    # mocha-yellow
      color12 = "#89b4fa";    # mocha-blue
      color13 = "#f5c2e7";    # mocha-pink
      color14 = "#94e2d5";    # mocha-teal
      color15 = "#a6adc8";    # mocha-subtext0

      # ---- 光标 ----
      cursor = "#f5e0dc";               # mocha-rosewater
      cursor_text_color = "#1e1e2e";    # mocha-base

      # ---- 标签栏 ----
      active_tab_foreground = "#1e1e2e";
      active_tab_background = "#89b4fa";
      inactive_tab_foreground = "#6c7086";
      inactive_tab_background = "#313244";
      tab_bar_background = "#11111b";

      # ---- 窗口行为 ----
      confirm_os_window_close = 0;       # 关闭时不确认
      window_padding_width = 8;
      hide_window_decorations = "yes";   # Wayland 下隐藏标题栏
    };
  };

  # ===========================================================================
  # Fuzzel 应用启动器
  # ===========================================================================
  # 作为 DMS Spotlight 的备选 (Mod+D 启动)
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "${font-name}:size=13";
        prompt = "\"Run: \"";
        icon-theme = "Papirus-Dark";
        terminal = "kitty";
        width = 50;
        line-height = 28;
        horizontal-pad = 12;
        vertical-pad = 8;
        inner-pad = 6;
        layer = "overlay";
      };
      colors = {
        background = "1e1e2eff";
        text = "cdd6f4ff";
        prompt = "89b4faff";
        placeholder = "6c7086ff";
        input = "cdd6f4ff";
        match = "89b4faff";
        selection = "313244ff";
        selection-text = "cdd6f4ff";
        selection-match = "89b4faff";
        border = "313244ff";
      };
      border = {
        width = 2;
        radius = 12;
      };
    };
  };

  # ===========================================================================
  # Shell: Zsh + Starship
  # ===========================================================================
  programs.zsh = {
    enable = true;
    enableCompletion = true;            # 命令补全
    autosuggestion.enable = true;       # 历史建议 (灰色提示)
    syntaxHighlighting.enable = true;   # 语法高亮

    shellAliases = {
      ll = "ls -l";
      # 一键重建系统 (需要先 git commit)
      nsw = "sudo nixos-rebuild switch --flake $HOME/nix-config/#${hostname}";
    };
  };

  # ---- Starship 提示符 (Catppuccin 风格) ----
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
        success_symbol = "[>](bold #89b4fa)";  # mocha-blue
        error_symbol = "[>](bold #f38ba8)";    # mocha-red
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
        name = "panxox";                # ← 改成你的名字
        email = "2279827640@qq.com";    # ← 改成你的邮箱
      };
      init.defaultBranch = "main";
    };
  };

  # ===========================================================================
  # SSH
  # ===========================================================================
  programs.ssh = {
    enable = true;
    # 按需添加 GitHub 等主机配置:
    # matchBlocks = {
    #   "github.com" = {
    #     hostname = "github.com";
    #     user = "git";
    #     identityFile = "~/.ssh/id_ed25519";
    #   };
    # };
  };

  # ===========================================================================
  # 主题: Qt / GTK / fontconfig / XDG Portal
  # ===========================================================================
  # ---- Qt 主题 ----
  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
  };

  # ---- 环境变量 (Qt / Electron 在 Wayland 下正常运行) ----
  systemd.user.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    NIXOS_OZONE_WL = "1";               # 强制 Electron 应用使用 Wayland
  };

  # ---- XDG Portal (屏幕共享 / 文件选择器) ----
  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [ "kde" "gtk" ];     # DMS 主题依赖 KDE portal
      };
    };
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  # ---- Fontconfig (字体回退顺序) ----
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Sarasa UI SC" ];             # 无衬线: 更纱黑体
      serif = [ "Noto Serif CJK SC" ];            # 衬线: Noto 宋体
      monospace = [ "Maple Mono NF CN" ];         # 等宽: Maple Mono
    };
  };

  # ---- GTK 主题 (DMS 通过 adw-gtk3 动态切换亮暗) ----
  gtk = {
    enable = true;
    font = {
      name = "Maple Mono NF CN";
      size = 11;
    };
  };

  # ---- dconf: 默认暗色模式 (DMS 会动态切换) ----
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
