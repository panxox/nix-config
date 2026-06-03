# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
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
  # ===========================================================================
  # Catppuccin Mocha 颜色调色板
  # ===========================================================================
  mocha-base      = "1e1e2e";
  mocha-mantle    = "181825";
  mocha-crust     = "11111b";
  mocha-surface0  = "313244";
  mocha-surface1  = "45475a";
  mocha-surface2  = "585b70";
  mocha-overlay0  = "6c7086";
  mocha-overlay1  = "7f849c";
  mocha-overlay2  = "9399b2";
  mocha-subtext0  = "a6adc8";
  mocha-subtext1  = "bac2de";
  mocha-text      = "cdd6f4";
  mocha-lavender  = "b4befe";
  mocha-blue      = "89b4fa";
  mocha-sapphire  = "74c7ec";
  mocha-sky       = "89dceb";
  mocha-teal      = "94e2d5";
  mocha-green     = "a6e3a1";
  mocha-yellow    = "f9e2af";
  mocha-peach     = "fab387";
  mocha-maroon    = "eba0ac";
  mocha-red       = "f38ba8";
  mocha-mauve     = "cba6f7";
  mocha-pink      = "f5c2e7";
  mocha-flamingo  = "f2cdcd";
  mocha-rosewater = "f5e0dc";

  font-name = "Maple Mono NF CN";
  font-size = "12";
in {
  # Import reusable home-manager modules:
  # inputs.self.homeManagerModules.example

  # ===========================================================================
  # Home
  # ===========================================================================
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
  };

  # Enable home-manager itself
  programs.home-manager.enable = true;

  # ===========================================================================
  # Nixpkgs (user-level)
  # ===========================================================================
  nixpkgs = {
    overlays = [
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
    ];
    config = {
      allowUnfree = true;
    };
  };

  # ===========================================================================
  # User packages
  # ===========================================================================
  home.packages = with pkgs; [
    # --- CLI 工具 ---
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

    # --- 网络工具 ---
    mtr
    dnsutils

    # --- 效率工具 ---
    lazygit
    glow            # Markdown 终端阅读器
    zellij          # 终端复用器
    yazi            # 终端文件管理器

    # --- 终端 ---
    kitty           # 终端模拟器

    # --- 截图 ---
    grim            # 截图
    slurp           # 选区截图
    wl-clipboard    # Wayland 剪贴板

    # --- 媒体 / 硬件控制 ---
    brightnessctl   # 亮度控制
    playerctl       # 媒体播放控制

    # --- 浏览器 ---
    google-chrome

    # --- 编辑器 / IDE ---
    vscode

    # --- 开发语言 ---
    go               # Golang
    rustup            # Rust 工具链管理
    rust-analyzer     # Rust LSP
    gcc               # C 编译器

    # --- 字体 ---
    maple-mono.NF-CN
    sarasa-gothic
    noto-fonts-cjk-serif
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only

    # --- 图标主题 ---
    papirus-icon-theme

    # --- 光标主题 ---
    catppuccin-cursors.mochaDark

    # --- GTK 主题 (DMS 动态主题依赖) ---
    adw-gtk3

    # --- 输入法皮肤 ---
    fcitx5-material-color

    # --- Qt 主题 ---
    libsForQt5.qt5ct
    qt6Packages.qt6ct

    # --- KDE 主题支持 (DMS 动态主题依赖) ---
    kdePackages.breeze
  ];

  # ===========================================================================
  # DMS (DankMaterialShell) — 桌面外壳
  # ===========================================================================
  programs.dank-material-shell = {
    enable = true;
    enableDynamicTheming = true;
    enableSystemMonitoring = true;
    systemd.enable = true;

    session = {
      # 壁纸
      wallpaperPath = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper-dark.png";
      wallpaperPathLight = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper-light.png";
      wallpaperPathDark = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper-dark.png";
      perModeWallpaper = true;
      perMonitorWallpaper = false;
      wallpaperTransition = "fade";
      wallpaperCyclingEnabled = false;

      # 地理位置 (Shanghai)
      latitude = 31.23;
      longitude = 121.47;

      # 夜间模式
      nightModeEnabled = false;
      nightModeTemperature = 4500;
      nightModeAutoEnabled = true;
      nightModeAutoMode = "location";
      nightModeStartHour = 18;
      nightModeEndHour = 6;
      nightModeUseIPLocation = false;

      # 自动主题切换
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
  # Niri 配置符号链接 (mkOutOfStoreSymlink — DMS 可写)
  # ===========================================================================
  xdg.configFile = let niriDir = "${config.home.homeDirectory}/nix-config/niri"; in {
    "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/config.kdl";
    "niri/dms/alttab.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/alttab.kdl";
    "niri/dms/binds.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/binds.kdl";
    "niri/dms/colors.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/colors.kdl";
    "niri/dms/cursor.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/cursor.kdl";
    "niri/dms/layout.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/layout.kdl";
    "niri/dms/outputs.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/outputs.kdl";
    "niri/dms/windowrules.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/windowrules.kdl";
    "niri/dms/wpblur.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/wpblur.kdl";
  };

  # ===========================================================================
  # 壁纸文件
  # ===========================================================================
  home.file.".local/share/wallpapers/wallpaper-dark.png".source =
    ../assets/wallpaper-dark.png;
  home.file.".local/share/wallpapers/wallpaper-light.png".source =
    ../assets/wallpaper-light.png;

  # 截图目录
  home.activation.createScreenshotDir =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/Pictures/Screenshots"
    '';

  # ===========================================================================
  # DMS 头像设置 (systemd oneshot + 重试)
  # ===========================================================================
  systemd.user.services.dms-set-avatar = {
    Unit = {
      Description = "Set DMS profile avatar after DMS starts";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "dms-set-avatar" ''
        for i in $(seq 1 30); do
          if ${dms.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/dms ipc profile setImage $HOME/nix-config/assets/avatar.jpg 2>&1 | grep -q SUCCESS; then
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
  # Kitty (终端模拟器) — Catppuccin Mocha
  # ===========================================================================
  programs.kitty = {
    enable = true;
    font = {
      name = font-name;
      size = 12;
    };
    settings = {
      foreground = "#${mocha-text}";
      background = "#${mocha-base}";
      selection_foreground = "#${mocha-text}";
      selection_background = "#${mocha-surface2}";

      color0  = "#${mocha-surface1}";
      color1  = "#${mocha-red}";
      color2  = "#${mocha-green}";
      color3  = "#${mocha-yellow}";
      color4  = "#${mocha-blue}";
      color5  = "#${mocha-pink}";
      color6  = "#${mocha-teal}";
      color7  = "#${mocha-subtext1}";
      color8  = "#${mocha-surface2}";
      color9  = "#${mocha-red}";
      color10 = "#${mocha-green}";
      color11 = "#${mocha-yellow}";
      color12 = "#${mocha-blue}";
      color13 = "#${mocha-pink}";
      color14 = "#${mocha-teal}";
      color15 = "#${mocha-subtext0}";

      cursor = "#${mocha-rosewater}";
      cursor_text_color = "#${mocha-base}";

      active_tab_foreground = "#${mocha-base}";
      active_tab_background = "#${mocha-blue}";
      inactive_tab_foreground = "#${mocha-overlay0}";
      inactive_tab_background = "#${mocha-surface0}";
      tab_bar_background = "#${mocha-crust}";

      confirm_os_window_close = 0;
      window_padding_width = 8;
      hide_window_decorations = "yes";
    };
  };

  # ===========================================================================
  # Shell — Zsh + Starship
  # ===========================================================================
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      nsw = "sudo nixos-rebuild switch --flake $HOME/nix-config/#${hostname}";
    };
  };

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
        error_symbol = "[>](bold #f38ba8)";
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
        name = "panxox";
        email = "2279827640@qq.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  # ===========================================================================
  # SSH
  # ===========================================================================
  programs.ssh = {
    enable = true;
    # matchBlocks = {
    #   "github.com" = {
    #     hostname = "github.com";
    #     user = "git";
    #     identityFile = "~/.ssh/id_ed25519";
    #   };
    # };
  };

  # ===========================================================================
  # Theme — Qt, GTK, fontconfig, XDG portal
  # ===========================================================================
  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
  };

  # Environment variables for Qt/Wayland
  systemd.user.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    NIXOS_OZONE_WL = "1";  # Force Electron apps to use Wayland
  };

  # XDG Portal (screensharing, file picker)
  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [ "kde" "gtk" ];
      };
    };
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  # Fontconfig
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Sarasa UI SC" ];
      serif = [ "Noto Serif CJK SC" ];
      monospace = [ "Maple Mono NF CN" ];
    };
  };

  # GTK: DMS 通过 adw-gtk3 提供动态亮暗切换
  gtk = {
    enable = true;
    font = {
      name = "Maple Mono NF CN";
      size = 11;
    };
  };

  # dconf: 默认偏好深色模式（DMS 会动态切换）
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
