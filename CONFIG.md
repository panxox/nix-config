# NixOS 配置文档 — niri + DMS

基于 [DankMaterialShell](https://danklinux.com/) 的 NixOS + niri 桌面配置，参考 [dms-starter](https://github.com/Mooling0602/dms-starter) 架构。

> 生成日期：2026-06-02

## 目录结构

```
~/nixos-config/
├── flake.nix                          # Flake 入口（username/hostname let 绑定在此）
├── flake.lock
├── .gitignore
├── assets/                            # 静态资源
│   ├── avatar.jpg                     # 用户头像（可选）
│   ├── wallpaper-dark.png             # 深色模式壁纸
│   └── wallpaper-light.png            # 浅色模式壁纸
├── hosts/nixos-vm/                    # 机器专属
│   ├── default.nix                    # imports + boot + VMware + hostname + stateVersion
│   └── hardware.nix                   # 自动生成（磁盘 UUID、内核模块）
├── modules/
│   ├── home/                          # Home Manager 模块（跨机器复用）
│   │   ├── default.nix                # 入口：username、homeDirectory、imports
│   │   ├── packages.nix               # 用户包（CLI 工具、GUI 应用）
│   │   ├── theme.nix                  # Qt、fontconfig、xdg.portal、GTK、DMS 主题依赖
│   │   ├── desktop.nix                # DMS 配置、niri 符号链接、Catppuccin 桌面应用
│   │   ├── git.nix                    # Git 用户配置
│   │   └── shell.nix                  # Zsh + Starship prompt
│   └── system/                        # 系统模块（跨机器复用）
│       ├── config.nix                 # my.username/my.hostname 选项定义
│       ├── desktop.nix                # dms-greeter + niri
│       ├── fonts.nix                  # 系统级字体
│       ├── i18n.nix                   # zh_CN 语言 + fcitx5 中文输入法
│       ├── networking.nix             # NetworkManager
│       ├── nix.nix                    # nix.settings + 自动 GC
│       ├── packages.nix               # 系统级包 + 许可证白名单
│       ├── services.nix               # PipeWire + polkit + dconf
│       └── users.nix                  # 用户 nixosvm + zsh + sudo NOPASSWD
└── niri/                              # Niri KDL 配置（mkOutOfStoreSymlink 管理，DMS 可写）
    ├── config.kdl                     # 手动维护：input、环境变量、DMS includes、用户覆盖
    └── dms/                           # DMS 生成的文件（dms setup 产出）
        ├── alttab.kdl
        ├── binds.kdl
        ├── colors.kdl
        ├── cursor.kdl
        ├── layout.kdl
        ├── outputs.kdl
        ├── windowrules.kdl
        └── wpblur.kdl
```

## flake.nix

```nix
{
  description = "NixOS configuration for nixos-vm with niri + DMS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-packages = {
      url = "github:Mooling0602/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      username = "nixosvm";   # ← 改这里即可替换用户名
      hostname = "nixos-vm";  # ← 改这里即可替换主机名
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${hostname}
          home-manager.nixosModules.home-manager
          {
            my = { inherit username hostname; };
            nixpkgs.overlays = [
              (final: prev: {
                xwayland-satellite = inputs.niri.packages.${final.system}.xwayland-satellite-unstable;
              })
              (final: prev: {
                reasonix = inputs.nix-packages.packages.${final.system}.reasonix;
              })
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = { config, pkgs, ... }: {
              imports = [
                ./modules/home
                inputs.dms.homeModules.dank-material-shell
              ];
            };
            home-manager.extraSpecialArgs = inputs // { inherit username hostname; };
          }
        ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [
          nil
          nixpkgs-fmt
          statix
        ];
      };
    };
}
```

## hosts/nixos-vm/default.nix

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/system/config.nix
    ../../modules/system/desktop.nix
    ../../modules/system/fonts.nix
    ../../modules/system/i18n.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix.nix
    ../../modules/system/packages.nix
    ../../modules/system/services.nix
    ../../modules/system/users.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ "snd_hda_intel" "snd_intel8x0" ];

  virtualisation.vmware.guest.enable = true;

  networking.hostName = config.my.hostname;

  system.stateVersion = "26.05";
}
```

## 系统模块

### modules/system/config.nix

```nix
{ config, lib, ... }:

{
  options.my.username = lib.mkOption {
    type = lib.types.str;
    default = "nixosvm";
    description = "Primary username. Override in flake.nix to change.";
  };

  options.my.hostname = lib.mkOption {
    type = lib.types.str;
    default = "nixos-vm";
    description = "Hostname for machine-specific config guards.";
  };
}
```

### modules/system/desktop.nix

```nix
{ config, pkgs, ... }:

{
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/${config.my.username}";
  };

  programs.niri.enable = true;
}
```

### modules/system/services.nix

```nix
{ config, pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  security.polkit.enable = true;

  programs.dconf.enable = true;
}
```

### modules/system/i18n.nix

```nix
{ config, pkgs, ... }:

{
  time.timeZone = "Asia/Shanghai";

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
    "en_US.UTF-8/UTF-8"
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-pinyin-zhwiki
    ];
  };

  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };
}
```

### modules/system/nix.nix

```nix
{ config, pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
```

### modules/system/networking.nix

```nix
{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;
}
```

### modules/system/packages.nix

```nix
{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    # 在此添加需要放行的 unfree 包名
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    fastfetch
    polkit_gnome
    libsForQt5.qt5ct
    qt6Packages.qt6ct
  ];
}
```

### modules/system/users.nix

```nix
{ config, pkgs, ... }:

{
  users.users.${config.my.username} = {
    isNormalUser = true;
    description = "Developer Account";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword = "$y$j9T$dummy-hash-replace-with-real-one$";
  };

  programs.zsh.enable = true;

  security.sudo = {
    enable = true;
    extraRules = [
      {
        users = [ config.my.username ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
```

### modules/system/fonts.nix

```nix
{ config, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    sarasa-gothic
    noto-fonts-cjk-serif
    maple-mono.NF-CN
  ];

  fonts.fontconfig.enable = true;
}
```

## Home Manager 模块

### modules/home/default.nix

```nix
{ config, lib, pkgs, username, ... }:

{
  imports = [
    ./packages.nix
    ./theme.nix
    ./desktop.nix
    ./git.nix
    ./shell.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";
}
```

### modules/home/packages.nix

```nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # CLI 工具
    htop tmux fzf ripgrep btop jq tree file which fastfetch
    # 网络工具
    mtr dnsutils
    # 开发工具
    gcc

    # 效率工具
    lazygit
    glow          # Markdown 阅读器
    zellij        # 终端复用器
    yazi          # 终端文件管理器

    # AI 助手
    reasonix

    # 桌面应用
    kitty         # 终端
    swww          # 壁纸守护进程
    grim slurp    # 截图工具
    wl-clipboard  # 剪贴板
    brightnessctl playerctl  # 媒体/背光控制
    fuzzel        # 启动器
    mako          # 通知
    swaylock      # 锁屏
    waybar        # 状态栏
    nwg-look      # GTK 主题配置

    # 美化
    nerd-fonts.jetbrains-mono
    papirus-icon-theme
    catppuccin-cursors.mochaDark
    fcitx5-material-color
  ];
}
```

### modules/home/theme.nix

```nix
{ config, lib, pkgs, ... }:

{
  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
  };

  systemd.user.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  xdg.portal = {
    enable = true;
    config.common.default = [ "kde" "gtk" ];
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Sarasa UI SC" ];
      serif = [ "Noto Serif CJK SC" ];
      monospace = [ "Maple Mono NF CN" ];
    };
  };

  gtk = {
    enable = true;
    font.name = "Maple Mono NF CN";
    font.size = 11;
  };

  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  home.packages = with pkgs; [
    sarasa-gothic
    noto-fonts-cjk-serif
    maple-mono.NF-CN
    tela-icon-theme
    adw-gtk3              # DMS 动态 GTK 主题依赖
    qt6Packages.qt6ct
    libsForQt5.qt5ct
    kdePackages.breeze
    kdePackages.plasma-integration
  ];
}
```

### modules/home/desktop.nix (核心文件)

此文件包含 **DMS 配置**、**niri 符号链接**、以及全部 **Catppuccin 应用配置**。

#### DMS 配置

```nix
programs.dank-material-shell = {
  enable = true;
  enableDynamicTheming = true;
  enableSystemMonitoring = true;
  systemd.enable = true;

  session = {
    wallpaperPath = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper-dark.png";
    wallpaperPathLight = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper-light.png";
    wallpaperPathDark = "${config.home.homeDirectory}/.local/share/wallpapers/wallpaper-dark.png";
    perModeWallpaper = true;
    perMonitorWallpaper = false;
    wallpaperTransition = "fade";
    wallpaperCyclingEnabled = false;

    latitude = 31.23;
    longitude = 121.47;

    nightModeEnabled = false;
    nightModeTemperature = 4500;
    nightModeAutoEnabled = true;
    nightModeAutoMode = "location";
    nightModeStartHour = 18;
    nightModeEndHour = 6;
    nightModeUseIPLocation = false;

    themeModeAutoEnabled = true;
    themeModeAutoMode = "location";
    themeModeStartHour = 18;
    themeModeEndHour = 6;
    themeModeShareGammaSettings = true;

    weatherLocation = "Shanghai";
    weatherCoordinates = "31.23,121.47";
    weatherHourlyDetailed = true;

    showThirdPartyPlugins = false;
    searchAppActions = true;
    configVersion = 3;
  };
};
```

#### Niri 符号链接（DMS 可写）

```nix
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
```

#### DMS 头像设置服务

```nix
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
```

#### Catppuccin Mocha 主题应用

| 应用 | 配置方式 | 说明 |
|------|---------|------|
| **Waybar** | `programs.waybar` | 状态栏：工作区、窗口标题、时钟、音频、网络、CPU、内存、托盘 |
| **Mako** | `services.mako` | 通知守护进程，右上角弹出，12px 圆角 |
| **Fuzzel** | `programs.fuzzel` | 应用启动器，Mod+D 触发，半透明背景 |
| **Kitty** | `programs.kitty` | 终端仿真器，无标题栏，Catppuccin Mocha 16 色调色板 |
| **Starship** | `programs.starship`（在 shell.nix 中） | Shell 提示符：用户名 + 主机名 + 路径 + git + nix-shell |
| **Swaylock** | `programs.swaylock` | 锁屏，120px 指示圆环，8px 边框，Catppuccin 配色 |

### modules/home/git.nix

```nix
{ config, lib, pkgs, ... }:

{
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
}
```

### modules/home/shell.nix

```nix
{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      nsw = "sudo nixos-rebuild switch --flake $HOME/nixos-config/#nixos-vm";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$username$hostname$directory$git_branch$git_status$nix_shell$line_break$character";

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

      git_status = {
        style = "#eba0ac";
      };

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
}
```

## Niri 配置

### niri/config.kdl

```kdl
// Niri config — managed in flake, symlinked via mkOutOfStoreSymlink
// DMS includes provide: binds, colors, layout, cursor, outputs, windowrules, wpblur

input {
    keyboard {
        xkb_layout "us"
        repeat-delay 600
        repeat-rate 25
        track-layout "global"
    }
    touchpad {
        tap
        natural-scroll
    }
}

screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

// DMS 生成的文件（先 include，这样下面的用户覆盖可以生效）
include "dms/alttab.kdl"
include "dms/binds.kdl"
include "dms/colors.kdl"
include "dms/cursor.kdl"
include "dms/layout.kdl"
include "dms/outputs.kdl"
include "dms/windowrules.kdl"
include "dms/wpblur.kdl"

// ============================================================================
// 用户覆盖（覆盖 DMS 默认值）
// ============================================================================

// 终端：kitty 替代 alacritty
Mod+Return { spawn "kitty"; }

// 启动器：fuzzel 替代 DMS spotlight
Mod+D { spawn "fuzzel"; }

// 截图
Print { spawn "sh" "-c" "grim ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"; }
Mod+Print { spawn "sh" "-c" "slurp | grim -g - ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"; }

// 锁屏：swaylock (Catppuccin 主题)
Mod+Escape { spawn "swaylock" "-f"; }

// DMS 提供 polkit 认证代理，无需额外配置

// swww 壁纸守护进程（用户偏好 — DMS wpblur 层是独立的）
spawn-at-startup {
    command "swww-daemon"
}
```

### DMS 键绑定参考 (niri/dms/binds.kdl)

| 快捷键 | 功能 |
|--------|------|
| `Mod+Space` | DMS Spotlight 应用启动器 |
| `Alt+Space` | DMS Spotlight Bar |
| `Mod+N` | 通知中心 |
| `Mod+V` | 剪贴板管理器 |
| `Mod+M` | 任务管理器 |
| `Mod+Comma` | DMS 设置 |
| `Mod+Alt+L` | DMS 锁屏 |
| `Mod+Y` | 壁纸浏览 |
| `Super+X` | 电源菜单 |
| `Mod+P` | 切换显示配置 |
| `Mod+Shift+W` | 创建窗口规则 |
| `Ctrl+Shift+R` | 重命名工作区 |
| `Mod+1..9` | 切换到工作区 1-9 |
| `Mod+Shift+1..9` | 移动窗口到工作区 1-9 |
| `Mod+H/L` | 聚焦左/右列 |
| `Mod+J/K` | 聚焦下/上窗口 |
| `Mod+Shift+H/L` | 移动列左/右 |
| `Mod+Shift+J/K` | 移动窗口下/上 |
| `Mod+Q` | 关闭窗口 |
| `Mod+F` | 最大化列 |
| `Mod+Shift+F` | 全屏窗口 |
| `Mod+T` | 打开 Alacritty 终端 (DMS 默认) |
| `Mod+Return` | 打开 Kitty 终端 (用户覆盖) |
| `Mod+D` | 打开 Fuzzel 启动器 (用户覆盖) |
| `Mod+Escape` | Swaylock 锁屏 (用户覆盖) |

## 关键设计决策

### 1. Niri 配置用 mkOutOfStoreSymlink

源自 [DMS issue #1788](https://github.com/AvengeMedia/DankMaterialShell/issues/1788)。使用 `xdg.configFile` + `config.lib.file.mkOutOfStoreSymlink` 指向 `~/nixos-config/niri/`。DMS 可自由写入 `niri/dms/*.kdl`，改动直接进 git。不再使用 `programs.niri.settings` 或 `xdg.configFile."niri/config.kdl".text`。

### 2. DMS 用 systemd 管理

`systemd.enable = true`，不用 `niri.enableSpawn`。DMS 崩溃会自动重启。

### 3. Qt 环境变量写 systemd.user.sessionVariables

`QT_QPA_PLATFORMTHEME=qt6ct` 和 `QT_QPA_PLATFORMTHEME_QT6=qt6ct` 通过 `systemd.user.sessionVariables` 设置，确保 niri 和 DMS 启动的应用都能拿到正确的 Qt 变量。

### 4. DMS 动态主题 + Catppuccin 应用共存

| 层面 | 管理者 | 说明 |
|------|--------|------|
| **合成器颜色** | DMS (`colors.kdl`) | 边框、焦点环、阴影、标签指示器 |
| **键绑定** | DMS (`binds.kdl`) + 用户覆盖 | niri 所有快捷键 |
| **壁纸** | DMS (`wpblur.kdl`) + swww | DMS 模糊层 + swww 独立壁纸 |
| **GTK 主题** | DMS (`adw-gtk3`) | 自动亮暗切换 |
| **Qt 主题** | qt6ct | 手动设置，可配合 DMS |
| **Waybar** | Catppuccin 静态 | 独立 CSS 配色 |
| **Mako** | Catppuccin 静态 | 独立配色 |
| **Fuzzel** | Catppuccin 静态 | 独立配色 |
| **Kitty** | Catppuccin 静态 | 独立 16 色调色板 |
| **Swaylock** | Catppuccin 静态 | 独立配色 |

### 5. 字体分两级

- 系统级 `fonts.packages`（greeter 可见）
- 用户级 `home.packages`（fontconfig 使用）

### 6. DMS session 持久化

`programs.dank-material-shell.session` 声明了壁纸路径、`perModeWallpaper`、地理位置、夜间模式、天气等持久化偏好。壁纸文件通过 `home.file` 拷贝到 `~/.local/share/wallpapers/`。

### 7. 用户名参数化

`flake.nix` 的 `let username` 注入到 `my.username`（系统模块）和 `extraSpecialArgs`（Home Manager 模块）。`users.nix`、`desktop.nix`、`home/default.nix` 均通过 `${username}` 或 `${config.my.username}` 引用，消除所有硬编码。

## Niri 配置文件管理

- `niri/config.kdl` — 手动维护，包含 input、DMS includes、用户覆盖键绑定
- `niri/dms/*.kdl` — 由 `dms setup` 生成
- 需要重新生成时：`dms setup`
- 生成后用 `git diff` 审查，确认后提交

## 重建命令

```fish
sudo nixos-rebuild switch --flake ~/nixos-config/#nixos-vm
```

或者使用 zsh alias：

```zsh
nsw
```

## 自定义用户名

编辑 `flake.nix`，修改 `let username` 和 `hostname` 即可：

```nix
outputs = inputs@{ nixpkgs, home-manager, ... }:
  let
    username = "nixosvm";   # ← 改这里即可替换用户名
    hostname = "nixos-vm";  # ← 改这里即可替换主机名
```

所有系统模块和 Home Manager 配置均自动引用此变量，无需其他修改。

## 新机器部署

```fish
# 1. 安装 NixOS 后，克隆配置仓库
git clone <repo-url> ~/nixos-config

# 2. 生成硬件配置
sudo nixos-generate-config --root / --dir ~/nixos-config/hosts/<hostname>

# 3. 创建机器专属 default.nix（参考 hosts/nixos-vm/default.nix）

# 4. 在 flake.nix 中添加 nixosConfigurations.<hostname> 或修改现有

# 5. 修改 flake.nix 中的 username/hostname（若不同）

# 6. 获取依赖
nix flake update

# 7. 重建
sudo nixos-rebuild switch --flake ~/nixos-config/#<hostname>

# 8. 设置密码
sudo passwd <username>

# 9. 首次登录后运行 DMS 初始化
dms setup
```

## Catppuccin Mocha 颜色参考

| 变量 | 色值 | 用途 |
|------|------|------|
| `mocha-base` | `1e1e2e` | 主背景色 |
| `mocha-surface0` | `313244` | 表面/选中态 |
| `mocha-surface1` | `45475a` | 较亮表面 |
| `mocha-overlay0` | `6c7086` | 覆盖层/非活跃文字 |
| `mocha-text` | `cdd6f4` | 主文字色 |
| `mocha-blue` | `89b4fa` | 强调色（蓝色） |
| `mocha-lavender` | `b4befe` | 次要强调色 |
| `mocha-teal` | `94e2d5` | 信息色 |
| `mocha-green` | `a6e3a1` | 成功色 |
| `mocha-peach` | `fab387` | 警告色 |
| `mocha-red` | `f38ba8` | 错误色 |
| `mocha-mauve` | `cba6f7` | 特殊色 |
| `mocha-rosewater`| `f5e0dc` | 光标色 |

## 参考

- [DankMaterialShell 文档](https://danklinux.com/docs/)
- [dms-starter 配置](https://github.com/Mooling0602/dms-starter)
- [niri 文档](https://github.com/YaLTeR/niri)
- [NixOS Wiki](https://nixos.wiki/)
- [Home Manager 手册](https://nix-community.github.io/home-manager/)
