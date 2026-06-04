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
    noto-fonts-emoji                    # Emoji
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
  # 显示管理器 — greetd 自动登录到 niri
  # ===========================================================================
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = username;
        # 直接启动 niri 会话 (niri-session 处理 systemd 集成)
        command = "${pkgs.niri}/bin/niri-session";
      };
    };
  };

  # 确保 greetd 在 niri 退出后重新登录
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVTDisallocate = true;
  };

  # ===========================================================================
  # niri — Wayland 滚动平铺合成器
  # ===========================================================================
  programs.niri = {
    enable = true;
    # 使用 nixpkgs unstable 中的最新 niri 包
    # package = pkgs.niri;
  };

  # ===========================================================================
  # DankMaterialShell — 完整的桌面 Shell
  # ===========================================================================
  programs.dms-shell = {
    enable = true;

    # --- systemd 自启动 (绑定到 niri.service) ---
    systemd = {
      enable = true;
      target = "niri.service";
      restartIfChanged = true;
    };

    # --- 功能开关 ---
    enableSystemMonitoring = true;      # 系统监控 (CPU/GPU/内存/磁盘/网络)
    enableVPN = true;                   # VPN 管理
    enableDynamicTheming = true;        # 动态取色 (matugen)
    enableAudioWavelength = true;       # 音频可视化 (cava)
    enableCalendarEvents = true;        # 日历集成 (khal)
    enableClipboardPaste = true;        # 剪贴板历史粘贴 (wtype)

    # --- DMS 插件 ---
    plugins = {
      # 从插件注册表启用插件 (ID 可在插件商店找到)
      # 示例: dockerManager.enable = true;
      # 见 https://github.com/AvengeMedia/dms-plugin-registry
    };
  };

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

  # ---- AccountsService (用户画像) ----
  services.accounts-daemon.enable = true;

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
  security.sudo = {
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

    # DMS 生态增强工具 (DMS 模块已自动安装 dgop/matugen/cava/khal/wtype)
    dsearch                             # 文件搜索 (DMS 未自动包含)
    cliphist                            # 剪贴板历史
    wl-clipboard                        # Wayland 剪贴板工具
    swappy                              # 截图编辑器 (DMS 推荐)
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
