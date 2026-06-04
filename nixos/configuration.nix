# =============================================================================
# NixOS 系统配置 — 最小化版本
# =============================================================================
# 此文件只配置系统级的基础设置。
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
  boot.kernelModules = [ "snd_hda_intel" "snd_intel8x0" ];

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
  # 显示管理器 — greetd (极简 TTY 自动登录)
  # ===========================================================================
  # 开机后自动登录到 TTY, 你可以手动启动桌面环境。
  # 如果不需要自动登录, 把下面整块注释掉即可回到传统的 TTY 登录。
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = username;
        # 只启动 bash 登录 shell, 不启动任何桌面环境
        command = "${pkgs.bash}/bin/bash -l";
      };
    };
  };

  # ===========================================================================
  # 用户
  # ===========================================================================
  users.users.${username} = {
    isNormalUser = true;
    description = "Developer";
    shell = pkgs.zsh;                            # 默认 Shell
    extraGroups = [ "networkmanager" "wheel" ];
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
