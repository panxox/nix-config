# =============================================================================
# NixOS 系统配置 — niri + DMS 桌面版
# =============================================================================
# 此文件配置系统级基础设置 + niri 合成器 + DankMaterialShell 桌面环境。
# 用户软件包和 dotfiles 请到 ../home-manager/home.nix 修改。
#
# 可用选项查询: https://search.nixos.org/options
# 可用包查询:   https://search.nixos.org/packages
# 中文教程:     https://nixos-and-flakes.thiscute.world/zh/
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
  imports = [
    # ---- 硬件配置 (由 nixos-generate-config 生成, 不要手动改) ----
    ./hardware-configuration.nix
  ];

  # ===========================================================================
  # 引导
  # ===========================================================================
  boot.loader.systemd-boot.enable = true;       # systemd-boot (UEFI)
  boot.loader.efi.canTouchEfiVariables = true;   # 允许修改 EFI 启动项

  # ---- 内核模块 (VMware 虚拟机音频, 物理机请删除) ----
  boot.kernelModules = [ "snd_hda_intel" "snd_intel8x0" "i2c-dev" ];

  # ===========================================================================
  # Nixpkgs
  # ===========================================================================
  nixpkgs.config.allowUnfree = true;             # 允许非自由软件 (Chrome, VS Code 等)

  # ===========================================================================
  # Nix 自身设置
  # ===========================================================================
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      flake-registry = "";                       # 纯 flake 模式
    };
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # ===========================================================================
  # 网络
  # ===========================================================================
  networking.hostName = hostname;
  networking.networkmanager.enable = true;       # 桌面网络管理

  # ---- 修复 VM 启动时 network-online.target 超时 ----
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = [
        ""
        "${pkgs.networkmanager}/bin/nm-online -s -q --timeout=5"
      ];
    };
  };

  # ===========================================================================
  # 时区 & 语言
  # ===========================================================================
  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT    = "zh_CN.UTF-8";
    LC_MONETARY       = "zh_CN.UTF-8";
    LC_NAME           = "zh_CN.UTF-8";
    LC_NUMERIC        = "zh_CN.UTF-8";
    LC_PAPER          = "zh_CN.UTF-8";
    LC_TELEPHONE      = "zh_CN.UTF-8";
    LC_TIME           = "zh_CN.UTF-8";
  };
  i18n.supportedLocales = [
    "zh_CN.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"                          # 英文留作备用
  ];

  # ---- 键盘布局 ----
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  # ===========================================================================
  # 系统字体
  # ===========================================================================
  fonts.packages = with pkgs; [
    maple-mono.NF-CN                    # 中文等宽 Nerd Font
    sarasa-gothic                       # 更纱黑体
    noto-fonts-cjk-serif                # Noto 宋体
    noto-fonts-cjk-sans                 # Noto 黑体
    noto-fonts-color-emoji              # Emoji
    nerd-fonts.symbols-only             # Nerd Font 图标
  ];
  fonts.fontconfig.enable = true;

  # ===========================================================================
  # 系统服务
  # ===========================================================================
  # ---- 音频 (PipeWire) ----
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # ---- 安全 ----
  security.polkit.enable = true;               # GUI 提权
  programs.dconf.enable = true;                # GTK 配置后端

  # ===========================================================================
  # 显示管理器 — ReGreet (GTK 登录界面, 基于 greetd)
  # ===========================================================================
  # 详见: https://github.com/rharish101/ReGreet
  #
  # 启动链: greetd → cage (Wayland 合成器) → ReGreet (登录界面) → niri-session
  # ReGreet 模块 (programs.regreet) 自动配置 services.greetd, 不需要手动设定。
  programs.regreet = {
    enable = true;

    # cage 参数: -s = VT 切换, -d = 无窗口装饰
    cageArgs = [ "-s" "-d" ];

    # ---- 主题: 暗色 Adwaita, 匹配 Catppuccin Mocha 风格 ----
    theme = {
      name = "Adwaita";
      # package = pkgs.gnome-themes;  # 默认包已含 Adwaita
    };

    font = {
      name = "Maple Mono NF CN";
      size = 14;
    };

    cursorTheme = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
    };

    settings = {
      # 背景纯色 (#1e1e2e = Catppuccin Mocha base)
      background = "#1e1e2e";

      # 问候语
      greeting = "你好！欢迎回来";

      # 环境变量 — Wayland 会话沿用 DMS 的设定
      # environment = { };

      # 重启/关机命令 (无密码)
      commands = {
        reboot = [ "loginctl" "reboot" ];
        poweroff = [ "loginctl" "poweroff" ];
      };
    };

    # 自定义 CSS: 让登录界面更精致
    # extraCss = ''
    #   window { background-color: #1e1e2e; }
    #   label { color: #cdd6f4; }
    # '';
  };

  # ===========================================================================
  # niri — Wayland 滚动平铺合成器 (由 niri-flake 提供)
  # ===========================================================================
  # niri-flake NixOS 模块已在 flake.nix 中导入 (niri.nixosModules.niri)
  # 它会自动处理 programs.niri 和相关配置。
  # DMS 的 niri 集成 (快捷键、配置包含) 在 home-manager/home.nix 中配置。
  programs.niri.enable = true;

  # 禁用 niri-flake 自带的 KDE polkit agent，使用 DMS 内置的 polkit agent 避免冲突
  systemd.user.services.niri-flake-polkit.enable = false;

  # ===========================================================================
  # XDG 桌面 Portal (屏幕共享 / 文件选择器)
  # ===========================================================================
  # niri 模块已配置了基本 portal, 这里补充 GTK portal
  xdg.portal = {
    enable = true;
    config.common.default = [ "gnome" "gtk" ];
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # gnome-keyring 由 programs.niri 启用, 这里额外配置 seahorse
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;            # 密钥管理 GUI

  # (accounts-daemon 由 programs.regreet 模块自动启用)
  # ---- 电源管理 ----
  services.power-profiles-daemon.enable = true;
  hardware.i2c.enable = true;                 # I2C 背光控制

  # ===========================================================================
  # 用户
  # ===========================================================================
  users.users.${username} = {
    isNormalUser = true;
    description = "Developer";
    shell = pkgs.zsh;                            # 默认 Shell
    extraGroups = [ "networkmanager" "wheel" "video" ];
    # 密码哈希: 用 mkpasswd -m yescrypt 生成后填到这里
    # hashedPassword = "...";
  };

  programs.zsh.enable = true;                    # 系统级 Zsh

  # ---- sudo — 免密码 (方便 nixos-rebuild) ----
  security.sudo-rs = {
    enable = true;
    extraRules = [
      {
        users = [ username ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # ===========================================================================
  # 系统级软件包 (所有用户可见, 紧急备用)
  # ===========================================================================
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    fastfetch

    # 桌面增强工具
    dsearch                             # 文件搜索
    cliphist                            # 剪贴板历史
    wl-clipboard                        # Wayland 剪贴板工具
    swappy                              # 截图编辑器
    satty                               # 备选截图编辑器

    # niri 相关工具
    xwayland                            # X11 兼容层
  ];

  # ===========================================================================
  # VMware 虚拟机 (物理机请删除这一行)
  # ===========================================================================
  virtualisation.vmware.guest.enable = true;

  # ===========================================================================
  # 状态版本 — 不要改
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  # ===========================================================================
  system.stateVersion = "26.05";
}
