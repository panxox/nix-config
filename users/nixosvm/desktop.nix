# Niri 桌面美化 — Catppuccin Mocha (蓝色强调色)
# 聚合全部用户级桌面 ricing 配置
{ config, lib, pkgs, ... }:

let
  # ===========================================================================
  # Catppuccin Mocha 颜色调色板
  # ===========================================================================
  mocha-base     = "1e1e2e";
  mocha-mantle   = "181825";
  mocha-crust    = "11111b";
  mocha-surface0 = "313244";
  mocha-surface1 = "45475a";
  mocha-surface2 = "585b70";
  mocha-overlay0 = "6c7086";
  mocha-overlay1 = "7f849c";
  mocha-overlay2 = "9399b2";
  mocha-subtext0 = "a6adc8";
  mocha-subtext1 = "bac2de";
  mocha-text     = "cdd6f4";
  mocha-lavender = "b4befe";
  mocha-blue     = "89b4fa";
  mocha-sapphire = "74c7ec";
  mocha-sky      = "89dceb";
  mocha-teal     = "94e2d5";
  mocha-green    = "a6e3a1";
  mocha-yellow   = "f9e2af";
  mocha-peach    = "fab387";
  mocha-maroon   = "eba0ac";
  mocha-red      = "f38ba8";
  mocha-mauve    = "cba6f7";
  mocha-pink     = "f5c2e7";
  mocha-flamingo = "f2cdcd";
  mocha-rosewater = "f5e0dc";

  font-name = "JetBrainsMono Nerd Font";
  font-size = "12";
in
{
  # ===========================================================================
  # Niri 合成器配置文件部署
  # ===========================================================================
  xdg.configFile."niri/config.kdl".source =
    ../../modules/desktop/niri-config.kdl;

  # ===========================================================================
  # 截图目录自动创建
  # ===========================================================================
  home.activation.createScreenshotDir =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/Pictures/screenshots"
    '';

  # ===========================================================================
  # GTK 主题（Catppuccin Mocha Blue + Papirus 图标 + Catppuccin 光标）
  # ===========================================================================
  gtk = {
    enable = true;

    theme = {
      name = "catppuccin-mocha-blue-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        variant = "mocha";
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 24;
    };

    font = {
      name = font-name;
      size = 11;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # dconf: 强制 libadwaita / GNOME 应用使用深色模式
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  # ===========================================================================
  # Qt 主题（通过环境变量 + qt5ct / qt6ct 配置工具）
  # ===========================================================================
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "kvantum";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };

  # ===========================================================================
  # 字体
  # ===========================================================================
  fonts.fontconfig.enable = true;

  # ===========================================================================
  # Waybar（状态栏）
  # ===========================================================================
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [{
      layer = "top";
      position = "top";
      height = 32;

      modules-left = [
        "niri/workspaces"
        "niri/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "tray"
      ];

      "niri/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "一";
          "2" = "二";
          "3" = "三";
          "4" = "四";
          "5" = "五";
          "6" = "六";
          "7" = "七";
          "8" = "八";
          "9" = "九";
        };
      };

      "niri/window" = {
        format = "{title}";
        max-length = 80;
      };

      clock = {
        format = "{:%m-%d %H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      pulseaudio = {
        format = " {icon} {volume}% ";
        format-muted = "  MUTE ";
        format-icons = {
          default = [ " " " " " " ];
        };
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "pavucontrol";
      };

      network = {
        format-wifi = " {essid} ({signalStrength}%) ";
        format-ethernet = " {ipaddr} ";
        format-disconnected = "  NO NET ";
        tooltip-format = "{ifname}: {ipaddr}";
      };

      cpu = {
        format = " {usage}% ";
      };

      memory = {
        format = " {percentage}% ";
      };

      tray = {
        spacing = 10;
      };
    }];

    style = ''
      * {
        font-family: "${font-name}", monospace;
        font-size: ${font-size};
        min-height: 0;
      }

      window#waybar {
        background-color: #${mocha-base};
        color: #${mocha-text};
        border-bottom: 2px solid #${mocha-surface0};
        transition-property: background-color;
        transition-duration: .3s;
      }

      #workspaces button {
        padding: 0 6px;
        background-color: transparent;
        color: #${mocha-overlay0};
        border: none;
        border-radius: 0;
      }

      #workspaces button.active {
        color: #${mocha-blue};
        border-bottom: 2px solid #${mocha-blue};
      }

      #workspaces button:hover {
        background-color: #${mocha-surface0};
        color: #${mocha-text};
      }

      #workspaces button.urgent {
        color: #${mocha-red};
      }

      #window {
        padding: 0 10px;
        color: #${mocha-subtext1};
        font-weight: 500;
      }

      #clock {
        padding: 0 12px;
        color: #${mocha-lavender};
        font-weight: bold;
      }

      #pulseaudio {
        padding: 0 10px;
        color: #${mocha-teal};
      }

      #pulseaudio.muted {
        color: #${mocha-red};
      }

      #network {
        padding: 0 10px;
        color: #${mocha-green};
      }

      #cpu {
        padding: 0 8px;
        color: #${mocha-peach};
      }

      #memory {
        padding: 0 8px;
        color: #${mocha-mauve};
      }

      #tray {
        padding: 0 8px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #${mocha-red};
      }
    '';
  };

  # ===========================================================================
  # Mako（通知守护进程）
  # ===========================================================================
  services.mako = {
    enable = true;
    defaultTimeout = 5000;
    ignoreTimeout = false;
    maxVisible = 5;
    layer = "overlay";
    anchor = "top-right";
    width = 400;
    height = 150;
    margin = "10";
    padding = "15";
    borderSize = 2;
    borderRadius = 12;
    backgroundColor = "#${mocha-base}";
    borderColor = "#${mocha-blue}";
    textColor = "#${mocha-text}";
    extraConfig = ''
      [urgency=low]
      border-color=#${mocha-surface0}

      [urgency=high]
      border-color=#${mocha-red}
      background-color=#${mocha-surface0}
      default-timeout=0
    '';
  };

  # ===========================================================================
  # Fuzzel（应用启动器）
  # ===========================================================================
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "${font-name}:size=13";
        prompt = "\"Run > \"";
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
        background = "${mocha-base}ff";
        text = "${mocha-text}ff";
        prompt = "${mocha-blue}ff";
        placeholder = "${mocha-overlay0}ff";
        input = "${mocha-text}ff";
        match = "${mocha-blue}ff";
        selection = "${mocha-surface0}ff";
        selection-text = "${mocha-text}ff";
        selection-match = "${mocha-blue}ff";
        border = "${mocha-surface0}ff";
      };
      border = {
        width = 2;
        radius = 12;
      };
    };
  };

  # ===========================================================================
  # Kitty（终端仿真器）— Catppuccin Mocha 配色
  # ===========================================================================
  programs.kitty = {
    enable = true;
    font = {
      name = font-name;
      size = 12;
    };
    settings = {
      # 前景 / 背景
      foreground = "#${mocha-text}";
      background = "#${mocha-base}";
      selection_foreground = "#${mocha-text}";
      selection_background = "#${mocha-surface2}";

      # 常规颜色 (0-7)
      color0  = "#${mocha-surface1}";
      color1  = "#${mocha-red}";
      color2  = "#${mocha-green}";
      color3  = "#${mocha-yellow}";
      color4  = "#${mocha-blue}";
      color5  = "#${mocha-pink}";
      color6  = "#${mocha-teal}";
      color7  = "#${mocha-subtext1}";

      # 亮色 (8-15)
      color8  = "#${mocha-surface2}";
      color9  = "#${mocha-red}";
      color10 = "#${mocha-green}";
      color11 = "#${mocha-yellow}";
      color12 = "#${mocha-blue}";
      color13 = "#${mocha-pink}";
      color14 = "#${mocha-teal}";
      color15 = "#${mocha-subtext0}";

      # 光标
      cursor = "#${mocha-rosewater}";
      cursor_text_color = "#${mocha-base}";

      # 标签栏
      active_tab_foreground = "#${mocha-base}";
      active_tab_background = "#${mocha-blue}";
      inactive_tab_foreground = "#${mocha-overlay0}";
      inactive_tab_background = "#${mocha-surface0}";
      tab_bar_background = "#${mocha-crust}";

      # 行为
      confirm_os_window_close = 0;
      window_padding_width = 8;
      hide_window_decorations = "yes";
    };
  };

  # ===========================================================================
  # Starship（Shell 提示符美化）
  # ===========================================================================
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
        success_symbol = "[>](bold #${mocha-blue})";
        error_symbol = "[>](bold #${mocha-red})";
      };

      directory = {
        style = "#${mocha-lavender}";
        truncation_length = 5;
      };

      git_branch = {
        style = "#${mocha-peach}";
        symbol = "";
      };

      git_status = {
        style = "#${mocha-maroon}";
      };

      username = {
        show_always = true;
        style_user = "#${mocha-green}";
        format = "[$user]($style) ";
      };

      hostname = {
        ssh_only = false;
        style = "#${mocha-blue}";
        format = "on [$hostname]($style) ";
      };

      nix_shell = {
        symbol = "";
        style = "#${mocha-sky}";
        format = "via [$symbol]($style) ";
      };
    };
  };

  # ===========================================================================
  # Swaylock（屏幕锁定）— Catppuccin Mocha 配色
  # ===========================================================================
  programs.swaylock = {
    enable = true;
    settings = {
      color = mocha-base;
      font = font-name;
      "font-size" = 24;
      "indicator-radius" = 120;
      "indicator-thickness" = 8;
      "line-color" = mocha-surface0;
      "inside-color" = mocha-base;
      "inside-clear-color" = mocha-base;
      "inside-ver-color" = mocha-base;
      "inside-wrong-color" = mocha-base;
      "key-hl-color" = mocha-blue;
      "bs-hl-color" = mocha-red;
      "ring-color" = mocha-surface1;
      "ring-clear-color" = mocha-green;
      "ring-ver-color" = mocha-blue;
      "ring-wrong-color" = mocha-red;
      "text-color" = mocha-text;
      "text-clear-color" = mocha-text;
      "text-ver-color" = mocha-text;
      "text-wrong-color" = mocha-text;
    };
  };

  # ===========================================================================
  # 用户级桌面包
  # ===========================================================================
  home.packages = with pkgs; [
    # 终端
    kitty

    # 壁纸守护进程
    swww

    # 截图工具
    grim
    slurp

    # Wayland 剪贴板
    wl-clipboard

    # 媒体 / 背光控制
    brightnessctl
    playerctl

    # 启动器 / 通知 / 锁屏（主题已在各自模块中配置）
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
  ];
}
