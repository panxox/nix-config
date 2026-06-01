{ config, lib, pkgs, dms, ... }:

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
  # DMS (DankMaterialShell) 配置
  # ===========================================================================
  programs.dank-material-shell = {
    enable = true;
    enableDynamicTheming = true;
    enableSystemMonitoring = true;
    systemd.enable = true;

    session = {
      # WALLPAPER
      wallpaperPath = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper-dark.png";
      wallpaperPathLight = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper-light.png";
      wallpaperPathDark = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper-dark.png";
      perModeWallpaper = true;
      perMonitorWallpaper = false;
      wallpaperTransition = "fade";
      wallpaperCyclingEnabled = false;

      # LOCATION (Shanghai)
      latitude = 31.23;
      longitude = 121.47;

      # NIGHT MODE
      nightModeEnabled = false;
      nightModeTemperature = 4500;
      nightModeAutoEnabled = true;
      nightModeAutoMode = "location";
      nightModeStartHour = 18;
      nightModeEndHour = 6;
      nightModeUseIPLocation = false;

      # AUTO THEME
      themeModeAutoEnabled = true;
      themeModeAutoMode = "location";
      themeModeStartHour = 18;
      themeModeEndHour = 6;
      themeModeShareGammaSettings = true;

      # WEATHER
      weatherLocation = "Shanghai";
      weatherCoordinates = "31.23,121.47";
      weatherHourlyDetailed = true;

      # MISC
      showThirdPartyPlugins = false;
      searchAppActions = true;
      configVersion = 3;
    };
  };

  # ===========================================================================
  # Niri 配置符号链接 (mkOutOfStoreSymlink — DMS 可写)
  # ===========================================================================
  xdg.configFile = let niriDir = "${config.home.homeDirectory}/nixos-config/niri"; in {
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
  home.file.".local/share/wallpapers/wallpaper-dark.png".source = ../../assets/wallpaper-dark.png;
  home.file.".local/share/wallpapers/wallpaper-light.png".source = ../../assets/wallpaper-light.png;

  # ===========================================================================
  # 截图目录自动创建
  # ===========================================================================
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
          if ${dms.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/dms ipc profile setImage $HOME/nixos-config/assets/avatar.jpg 2>&1 | grep -q SUCCESS; then
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
  # Waybar（状态栏）— Catppuccin Mocha
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
  # Mako（通知守护进程）— Catppuccin Mocha
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
  # Fuzzel（应用启动器）— Catppuccin Mocha
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
}
