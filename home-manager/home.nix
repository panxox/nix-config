# =============================================================================
# Home Manager 用户配置 — niri + DMS 桌面 + 中文输入法
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
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
    enableNixpkgsReleaseCheck = false;
  };

  programs.home-manager.enable = true;

  # ===========================================================================
  # DankMaterialShell — 桌面环境
  # ===========================================================================
  programs.dank-material-shell = {
    enable = true;

    niri = {
      enableSpawn = true;
      enableKeybinds = false;
      includes = {
        enable = true;
        override = true;
        originalFileName = "hm";
        filesToInclude = [
          "alttab" "binds" "colors" "cursor"
          "layout" "outputs" "windowrules" "wpblur"
        ];
      };
    };

    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;

    dgop.package = inputs.dgop.packages.${pkgs.system}.default;

    session = { isLightMode = false; };
    settings = {
      theme = "dark";
      dynamicTheming = true;
    };

    clipboardSettings = {
      maxHistory = 50;
      maxEntrySize = 5242880;
      autoClearDays = 1;
      clearAtStartup = false;
      disablePersist = true;
    };

    plugins = {};

    appOverrides = {
      firefox = { extraFlags = "--ozone-platform=wayland"; };
      vscode = { extraFlags = "--ozone-platform=wayland --enable-wayland-ime"; };
    };
  };

  # ===========================================================================
  # 用户软件包
  # ===========================================================================
  home.packages = with pkgs; [
    # 终端
    kitty
    zellij

    # 浏览器
    firefox

    # 编辑器
    vscode
    neovim

    # 系统工具
    fastfetch

    # 开发语言
    go
    rustup

    # 字体
    maple-mono.NF-CN
    sarasa-gothic
    noto-fonts-cjk-serif
    nerd-fonts.symbols-only

    # 图标主题
    papirus-icon-theme

    # 光标主题
    catppuccin-cursors.mochaDark

    # GTK 主题
    adw-gtk3

    # 中文输入法
    fcitx5
    fcitx5-chinese-addons
    fcitx5-rime
    fcitx5-pinyin-zhwiki
    fcitx5-gtk
    fcitx5-qt
    fcitx5-configtool
  ];

  # ===========================================================================
  # 中文输入法配置
  # ===========================================================================
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-chinese-addons
      fcitx5-rime
      fcitx5-pinyin-zhwiki
      fcitx5-gtk
      fcitx5-qt
    ];
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
      dms-restart = "systemctl --user restart dms";
      dms-logs = "journalctl --user -u dms -f";
      dms-setup = "dms setup";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$username" "$hostname" "$directory" "$git_branch"
        "$git_status" "$nix_shell" "$line_break" "$character"
      ];

      character = {
        success_symbol = "[>](bold #89b4fa)";
        error_symbol   = "[>](bold #f38ba8)";
      };

      directory = { style = "#b4befe"; truncation_length = 5; };
      git_branch = { style = "#fab387"; symbol = ""; };
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
      init.defaultBranch = "main";
    };
  };

  # ===========================================================================
  # SSH
  # ===========================================================================
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

  # ===========================================================================
  # 主题 — Qt / GTK / fontconfig
  # ===========================================================================
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "kvantum";
  };

  systemd.user.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    GDK_BACKEND = "wayland";
    SDL_VIDEO_DRIVER = "wayland";
    DMS_SCREENSHOT_EDITOR = "swappy";
  };

  gtk = {
    enable = true;
    font = {
      name = "Maple Mono NF CN";
      size = 11;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Sarasa UI SC" ];
      serif     = [ "Noto Serif CJK SC" ];
      monospace  = [ "Maple Mono NF CN" ];
    };
  };
}
