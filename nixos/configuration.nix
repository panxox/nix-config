# =============================================================================
# NixOS 系统配置 (configuration.nix)
# =============================================================================
# 此文件配置系统级别的设置: 引导、网络、用户、语言、字体、niri、DMS 等。
# 用户级别的软件和桌面配置在 ../home-manager/home.nix 中。
#
# 查找可用的 NixOS 选项:
#   https://search.nixos.org/options
# 查找可用的 Nix 包:
#   https://search.nixos.org/packages
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
    # ---- 硬件配置 (由 nixos-generate-config 自动生成, 请勿手动修改) ----
    ./hardware-configuration.nix
  ];

  # ===========================================================================
  # 引导加载程序 (Boot Loader)
  # ===========================================================================
  # 使用 systemd-boot (推荐用于 UEFI 系统)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ---- 内核模块 (VMware 虚拟机音频支持, 物理机可删除) ----
  boot.kernelModules = [ "snd_hda_intel" "snd_intel8x0" ];

  # ===========================================================================
  # Nixpkgs 配置
  # ===========================================================================
  nixpkgs.config.allowUnfree = true;   # 允许安装非自由软件 (如 Chrome, VS Code)

  # ===========================================================================
  # Nix 设置
  # ===========================================================================
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;        # 自动优化存储
      flake-registry = "";               # 禁用全局 registry (纯 flake 模式)
    };
    channel.enable = false;              # 禁用 channel, 只用 flake
    gc = {
      automatic = true;                  # 自动垃圾回收
      dates = "weekly";                  # 每周执行
      options = "--delete-older-than 7d"; # 删除 7 天前的旧版本
    };
  };

  # ===========================================================================
  # 网络
  # ===========================================================================
  networking.hostName = hostname;        # 主机名 (来自 flake.nix)
  networking.networkmanager.enable = true;

  # ---- 修复 VM 启动时 network-online.target 阻塞超时 ----
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -s -q --timeout=5" ];
    };
  };

  # ===========================================================================
  # 时区 & 语言 & 输入法
  # ===========================================================================
  time.timeZone = "Asia/Shanghai";

  # ---- 系统语言: 中文 UTF-8 ----
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };
  i18n.supportedLocales = [
    "zh_CN.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"                # 保留英文 locale 以防某些程序需要
  ];

  # ---- 键盘布局: 中文 ----
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  # ---- Fcitx5 中文输入法 (拼音) ----
  # 系统级启用; 皮肤和附加组件在 home-manager/home.nix 中安装
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;       # Wayland 原生支持
    fcitx5.addons = with pkgs; [
      fcitx5-chinese-addons             # 中文输入 (拼音/双拼/五笔等)
      fcitx5-pinyin-zhwiki              # 拼音维基词典
      fcitx5-gtk                        # GTK 应用输入支持
      fcitx5-material-color             # Material Design 皮肤 (美化)
    ];
  };

  # ===========================================================================
  # 字体 (系统级, greeter 可见)
  # ===========================================================================
  fonts.packages = with pkgs; [
    # ---- 等宽字体 ----
    maple-mono.NF-CN                    # Maple Mono Nerd Font (带图标的中文等宽字体)

    # ---- 中文字体 ----
    sarasa-gothic                       # 更纱黑体
    noto-fonts-cjk-serif                # Noto 宋体 (衬线)
    noto-fonts-cjk-sans                 # Noto 黑体 (无衬线)

    # ---- 图标与 Emoji ----
    noto-fonts-emoji                    # Emoji
    nerd-fonts.symbols-only             # Nerd Font 图标符号
  ];
  fonts.fontconfig.enable = true;

  # ===========================================================================
  # 系统服务
  # ===========================================================================
  # ---- PipeWire (音频/视频) ----
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;         # 实时音频权限

  # ---- PolicyKit (GUI 提权认证) ----
  security.polkit.enable = true;

  # ---- dconf (GTK 配置后端) ----
  programs.dconf.enable = true;

  # ===========================================================================
  # Niri (Wayland 合成器)
  # ===========================================================================
  programs.niri.enable = true;

  # ===========================================================================
  # DMS Greeter (登录管理器)
  # ===========================================================================
  # dms-greeter 替代传统的 greetd/sddm, 提供美观的登录界面
  # 启动后自动进入 niri + DMS 桌面环境
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";            # 指定合成器为 niri
    configHome = "/home/${username}";    # 用户配置目录
  };

  # ===========================================================================
  # 用户
  # ===========================================================================
  users.users.${username} = {
    isNormalUser = true;
    description = "Developer";
    shell = pkgs.zsh;                    # 默认 Shell: Zsh
    extraGroups = [
      "networkmanager"                   # 允许管理网络连接
      "wheel"                            # 允许使用 sudo
    ];
    # 密码哈希 (用 mkpasswd -m yescrypt 生成后填入):
    # hashedPassword = "...";
  };

  # ---- 系统级 Zsh 支持 ----
  programs.zsh.enable = true;

  # ---- sudo 配置 (免密码, 方便 nixos-rebuild) ----
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
  # 系统级软件包 (所有用户可见)
  # ===========================================================================
  environment.systemPackages = with pkgs; [
    vim                                 # 基础文本编辑器 (紧急备用)
    git                                 # 版本控制
    curl                                # HTTP 客户端
    wget                                # 下载工具
    fastfetch                           # 系统信息展示
  ];

  # ===========================================================================
  # 虚拟化 (VMware 虚拟机支持)
  # ===========================================================================
  # 物理机部署时请删除下面这行
  virtualisation.vmware.guest.enable = true;

  # ===========================================================================
  # 状态版本 (请勿修改, 除非你清楚它的用途)
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  # ===========================================================================
  system.stateVersion = "26.05";
}
