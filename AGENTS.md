# NixOS + DMS + Niri 配置

## 项目结构

> 当前版本：2026-06-02

```
~/nix-config/
├── assets/                        # 静态资源
│   ├── avatar.jpg                # 用户头像（可选）
│   ├── wallpaper-dark.png        # 深色模式壁纸
│   └── wallpaper-light.png       # 浅色模式壁纸
├── flake.nix                      # 入口，home-manager + DMS + greetd 集成
├── flake.lock
├── deploy.sh                      # 新机器交互式部署脚本
├── CONFIG.md                      # 完整配置文档（源码 + 设计决策）
├── hosts/panxox-vm/               # 机器专属（硬件驱动 + boot + hostname）
│   ├── default.nix               # imports 系统/home 模块 + boot + hostname + stateVersion
│   ├── gpu.nix                   # GPU 驱动占位（VM 下为空）
│   └── hardware.nix              # 自动生成（磁盘 UUID、内核模块）
├── modules/
│   ├── home/                     # Home Manager 模块（跨机器复用）
│   │   ├── default.nix           # 入口：username、homeDirectory、imports
│   │   ├── packages.nix          # 用户包（CLI 工具、GUI 应用）
│   │   ├── theme.nix             # Qt、fontconfig、xdg.portal、GTK、DMS 主题依赖
│   │   ├── desktop.nix           # DMS 配置、niri symlinks、Catppuccin 桌面应用
│   │   ├── git.nix               # Git 用户配置
│   │   ├── shell.nix             # Zsh + Starship prompt
│   │   └── ssh.nix               # SSH 配置
│   └── system/                   # 通用系统模块（可跨机器复用）
│       ├── config.nix            # my.username / my.hostname 选项定义
│       ├── desktop.nix           # dms-greeter + niri
│       ├── fonts.nix             # 系统级字体
│       ├── i18n.nix              # zh_CN 语言 + fcitx5 中文输入法
│       ├── networking.nix        # NetworkManager
│       ├── nix.nix               # nix.settings + 自动 GC
│       ├── packages.nix          # 系统级包 + unfree 白名单
│       ├── services.nix          # PipeWire、polkit、dconf
│       ├── users.nix             # 用户 + zsh + sudo NOPASSWD
│       └── virtualisation.nix    # VMware guest 支持
└── niri/                          # Niri KDL 配置（mkOutOfStoreSymlink 管理，DMS 可写）
    ├── config.kdl                # 手动维护：input、环境变量、DMS includes、用户覆盖
    └── dms/                      # DMS 生成的文件（dms setup 产出）
        ├── alttab.kdl
        ├── binds.kdl
        ├── colors.kdl
        ├── cursor.kdl
        ├── layout.kdl
        ├── outputs.kdl
        ├── windowrules.kdl
        └── wpblur.kdl
```

## 重建命令

```fish
sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
```

或使用 zsh alias：

```zsh
nsw
```

## 自定义用户名

`flake.nix` 顶部 `let username = "panxox"` 和 `let hostname = "panxox-vm"` 是唯一需要修改的地方。所有系统模块和 Home Manager 配置都引用此变量，无需手动替换。

## 新机器部署

```fish
# 1. 安装 NixOS 后，克隆配置仓库
git clone <repo-url> ~/nix-config

# 2. 运行部署脚本（交互式）
cd ~/nix-config && chmod +x deploy.sh && ./deploy.sh

# 3. 设置密码
sudo passwd <username>

# 4. 重建
sudo nixos-rebuild switch --flake ~/nix-config#<hostname>

# 5. 首次登录后运行 DMS 初始化
dms setup
```

## 工作流程

每次修改配置时按此顺序操作：

1. **修改** — 编辑配置文件
2. **提交** — `git commit` 到本地（在重建前提交，避免 dirty tree 警告）
3. **重建验证** — `sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm`
4. **推送** — `git push`

## 关键设计决策

1. **Niri 配置用 mkOutOfStoreSymlink** — 源自 [DMS issue #1788](https://github.com/AvengeMedia/DankMaterialShell/issues/1788)。使用 `xdg.configFile` + `config.lib.file.mkOutOfStoreSymlink` 指向 `~/nix-config/niri/`。DMS 可自由写入，改动直接进 git。

2. **DMS 用 systemd 管理** — `systemd.enable = true`，不用 `niri.enableSpawn`。DMS 崩溃会自动重启。

3. **Qt 环境变量写 environment.d** — `systemd.user.sessionVariables` 同时设置了 `QT_QPA_PLATFORMTHEME=qt6ct` 和 `QT_QPA_PLATFORMTHEME_QT6=qt6ct`，确保 niri 和 DMS 启动的应用都能拿到正确的 Qt 变量。

4. **DMS 动态主题 + Catppuccin 应用共存** — DMS 管理合成器颜色、GTK 主题和壁纸；waybar/mako/fuzzel/kitty/swaylock 保持独立的 Catppuccin Mocha 静态配色。

5. **字体分两级** — 系统级 `fonts.packages`（greeter 可见）+ 用户级 `home.packages`（fontconfig 使用）。

6. **DMS session 持久化** — `programs.dank-material-shell.session` 声明了壁纸路径、`perModeWallpaper`、地理位置、夜间模式、天气等。壁纸文件通过 `home.file` 拷贝到 `~/.local/share/wallpapers/`。

7. **用户名参数化** — `flake.nix` 的 `let username` 注入到 `my.username`（系统模块）和 `extraSpecialArgs`（Home Manager 模块）。所有模块通过 `${username}` 或 `${config.my.username}` 引用，消除硬编码。

8. **VMware 虚拟化独立模块** — `modules/system/virtualisation.nix` 封装 `virtualisation.vmware.guest.enable`，与机器专属配置解耦。

## Niri 配置文件管理

- `niri/config.kdl` 手动维护，包含 input、环境变量、layer-rules、DMS includes、用户覆盖键绑定
- `niri/dms/*.kdl` 由 `dms setup` 生成
- 需要重新生成时：`dms setup`
- 生成后用 `git diff` 审查，确认后提交

## 桌面应用总览

| 类型 | 应用 | 主题 |
|------|------|------|
| 显示管理器 | dms-greeter | DMS 动态 |
| Wayland 合成器 | niri | DMS 颜色 + 用户覆盖 |
| 桌面外壳 | DankMaterialShell (DMS) | 自动亮暗切换 |
| 状态栏 | waybar | Catppuccin Mocha |
| 通知 | mako | Catppuccin Mocha |
| 启动器 | fuzzel | Catppuccin Mocha |
| 终端 | kitty | Catppuccin Mocha |
| 锁屏 | swaylock | Catppuccin Mocha |
| Shell 提示符 | starship | Catppuccin Mocha |
| GTK 主题 | adw-gtk3 | DMS 动态 |
| Qt 主题 | qt6ct + Breeze | 跟随系统 |

## Catppuccin Mocha 颜色参考

| 变量 | 色值 | 用途 |
|------|------|------|
| `mocha-base` | `1e1e2e` | 主背景色 |
| `mocha-surface0` | `313244` | 表面/选中态 |
| `mocha-text` | `cdd6f4` | 主文字色 |
| `mocha-blue` | `89b4fa` | 强调色 |
| `mocha-lavender` | `b4befe` | 次要强调色 |
| `mocha-teal` | `94e2d5` | 信息色 |
| `mocha-green` | `a6e3a1` | 成功色 |
| `mocha-peach` | `fab387` | 警告色 |
| `mocha-red` | `f38ba8` | 错误色 |
| `mocha-mauve` | `cba6f7` | 特殊色 |
| `mocha-rosewater` | `f5e0dc` | 光标色 |

## 参考

- [DankMaterialShell 文档](https://danklinux.com/docs/)
- [dms-starter 配置](https://github.com/Mooling0602/dms-starter)
- [niri 文档](https://github.com/YaLTeR/niri)
- [NixOS Wiki](https://nixos.wiki/)
