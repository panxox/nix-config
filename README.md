# NixOS Configuration

基于 [DankMaterialShell](https://danklinux.com/) 的 NixOS + niri 桌面配置，参考 [dms-starter](https://github.com/Mooling0602/dms-starter) 架构设计，面向 VMware 虚拟机环境。

## 结构

> 当前版本：2026-06-02

```
├── flake.nix                     # Flake 入口（username let 绑定在此）
├── flake.lock
├── CONFIG.md                     # 完整配置文档（所有文件源码 + 设计决策）
├── hosts/nixos-vm/               # 机器专属
│   ├── default.nix               # imports + boot + VMware guest + hostname + stateVersion
│   └── hardware.nix               # 自动生成
├── modules/
│   ├── home/                     # Home Manager 模块（跨机器复用）
│   │   ├── default.nix           # 入口
│   │   ├── packages.nix          # 用户包
│   │   ├── theme.nix             # Qt、fontconfig、xdg.portal、GTK、DMS 主题依赖
│   │   ├── desktop.nix           # DMS 配置、niri symlinks、Catppuccin 应用
│   │   ├── git.nix               # Git 用户配置
│   │   └── shell.nix             # Zsh + Starship prompt
│   └── system/                   # 系统模块（跨机器复用）
│       ├── config.nix            # my.username/hostname 选项
│       ├── desktop.nix           # dms-greeter + niri
│       ├── fonts.nix             # 系统级字体
│       ├── i18n.nix              # 中文语言、fcitx5 输入法
│       ├── networking.nix        # NetworkManager
│       ├── nix.nix               # nix 调优 + 自动 GC
│       ├── packages.nix          # 系统级包
│       ├── services.nix          # PipeWire、polkit、dconf
│       └── users.nix             # 用户 + sudo
├── assets/                       # 静态资源
│   ├── wallpaper-dark.png
│   └── wallpaper-light.png
└── niri/                         # Niri KDL 配置（DMS 可写）
    ├── config.kdl
    └── dms/
```

## 自定义用户名

编辑 `flake.nix`，修改 `let username` 和 `hostname` 即可：

```nix
outputs = inputs@{ nixpkgs, home-manager, ... }:
  let
    username = "nixosvm";   # ← 改为你的用户名
    hostname = "nixos-vm";  # ← 改为你的主机名
  in
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

# 5. 修改 flake.nix 中的 username/hostname

# 6. 获取依赖
nix flake update

# 7. 重建
sudo nixos-rebuild switch --flake ~/nixos-config/#<hostname>

# 8. 设置密码
sudo passwd <username>

# 9. 首次登录后运行 DMS 初始化
dms setup
```

## 已部署机器的日常使用

```fish
cd ~/nixos-config

# 修改配置 → git commit → 重建 → git push
nsw   # sudo nixos-rebuild switch --flake ~/nixos-config/#nixos-vm
```

## 工作流程

1. **修改** — 编辑配置文件
2. **提交** — `git commit`（在重建前提交，避免 dirty tree 警告）
3. **重建验证** — `sudo nixos-rebuild switch --flake ~/nixos-config/#nixos-vm`
4. **推送** — `git push`

## 桌面应用

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
| AI 助手 | reasonix | — |

## 预装工具

| 类别 | 包 |
|------|-----|
| 终端复用 | zellij, tmux |
| 文件管理 | yazi |
| Git | lazygit |
| Markdown | glow |
| 监控 | btop, htop |
| 网络 | mtr, dnsutils |
| 截图 | grim, slurp |
| 锁屏 | swaylock |
| 启动器 | fuzzel |

## 字体

| 层级 | 用途 | 字体 |
|------|------|------|
| 系统级 | greeter / 全局回退 | Sarasa Gothic, Noto Serif CJK SC, Maple Mono NF CN |
| 用户级 | 等宽 / 终端 | Maple Mono NF CN |
| 用户级 | 无衬线 | Sarasa UI SC |
| 用户级 | 衬线 | Noto Serif CJK SC |

## 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Mod+Return` | Kitty 终端 |
| `Mod+D` | Fuzzel 启动器 |
| `Mod+Space` | DMS Spotlight |
| `Mod+N` | 通知中心 |
| `Mod+V` | 剪贴板管理器 |
| `Mod+M` | 任务管理器 |
| `Mod+Comma` | DMS 设置 |
| `Mod+Escape` | 锁屏 |
| `Mod+Q` | 关闭窗口 |
| `Mod+Shift+E` | 退出 niri |
| `Mod+1..9` | 切换工作区 |
| `Mod+H/L` | 聚焦左/右列 |
| `Mod+J/K` | 聚焦下/上窗口 |
| `Mod+Shift+Slash` | 快捷键提示 |

## 关键设计决策

1. **Niri 配置用 mkOutOfStoreSymlink** — DMS 可自由写入 `niri/dms/`，改动直接进 git。详见 [DMS issue #1788](https://github.com/AvengeMedia/DankMaterialShell/issues/1788)。

2. **DMS 用 systemd 管理** — `systemd.enable = true`，崩溃自动重启。

3. **Qt 环境变量写 environment.d** — `systemd.user.sessionVariables` 设置了 `QT_QPA_PLATFORMTHEME=qt6ct`，确保 niri 和 DMS 启动的应用都能拿到正确的 Qt 变量。

4. **DMS 动态主题 + Catppuccin 应用共存** — DMS 管理合成器颜色、GTK 主题和壁纸；waybar/mako/fuzzel/kitty/swaylock 保持独立的 Catppuccin Mocha 静态配色。

5. **字体分两级** — 系统级 `fonts.packages`（greeter 可见）+ 用户级 `home.packages`（fontconfig 使用）。

6. **用户名参数化** — `flake.nix` 的 `let username` 注入到所有模块，消除硬编码。

## Niri 配置文件管理

- `niri/config.kdl` — 手动维护，包含 input、DMS includes、用户覆盖键绑定
- `niri/dms/*.kdl` — 由 `dms setup` 生成
- 需要重新生成时：`dms setup`
- 生成后用 `git diff` 审查变更，确认后提交

## 参考

- [DankMaterialShell 文档](https://danklinux.com/docs/)
- [dms-starter 配置](https://github.com/Mooling0602/dms-starter)
- [niri 文档](https://github.com/YaLTeR/niri)
- [NixOS Wiki](https://nixos.wiki/)
- [Home Manager 手册](https://nix-community.github.io/home-manager/)
