# NixOS + Niri + DMS 配置

## 项目结构

> 基于 [nix-starter-configs/standard](https://github.com/NixOS-Asia/nix-starter-configs) 模板构建
> 当前版本：2026-06-03

```
~/nix-config/
├── flake.nix                         # 入口：inputs (nixpkgs, niri, dms, home-manager)、overlays、nixosConfigurations
├── nixos/
│   ├── configuration.nix             # 系统配置（引导、网络、用户、i18n、fcitx5、dms-greeter、niri）
│   └── hardware-configuration.nix    # 硬件配置（nixos-generate-config 生成）
├── home-manager/
│   └── home.nix                      # 用户配置（包、DMS 桌面外壳、kitty 终端、shell、主题、git）
├── modules/
│   ├── nixos/default.nix             # 可复用 NixOS 模块（预留）
│   └── home-manager/default.nix      # 可复用 home-manager 模块（预留）
├── overlays/default.nix              # 自定义 overlays (additions + modifications)
├── pkgs/default.nix                  # 自定义包
├── niri/                              # Niri 配置文件（mkOutOfStoreSymlink，DMS 可写）
│   ├── config.kdl                    # 主配置（手写）：input、DMS includes、用户按键覆盖
│   └── dms/                          # DMS 生成的文件（dms setup 产出，git 追踪）
│       ├── alttab.kdl
│       ├── binds.kdl
│       ├── colors.kdl
│       ├── cursor.kdl
│       ├── layout.kdl
│       ├── outputs.kdl
│       ├── windowrules.kdl
│       └── wpblur.kdl
├── assets/                           # 静态资源（壁纸、头像）
├── deploy.sh                         # 新机器交互式部署脚本
└── README.md
```

## 重建命令

```bash
sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
```

或使用 zsh alias：

```bash
nsw
```

## 自定义用户名 / 主机名

`flake.nix` 顶部 `let username = "panxox"` 和 `let hostname = "panxox-vm"` 是唯一需要修改的地方。所有配置均通过 `extraSpecialArgs` 传递这些变量。

## 新机器部署

```bash
# 1. 安装 NixOS 后，克隆配置仓库
git clone <repo-url> ~/nix-config

# 2. 运行部署脚本（交互式）
cd ~/nix-config && chmod +x deploy.sh && ./deploy.sh

# 3. 设置密码
sudo passwd <username>

# 4. 重建
sudo nixos-rebuild switch --flake ~/nix-config#<hostname>

# 5. 首次登录后初始化 DMS
dms setup
```

## 工作流程

1. **修改** — 编辑配置文件
2. **提交** — `git commit`（在重建前提交，避免 dirty tree 警告）
3. **重建验证** — `sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm`
4. **推送** — `git push`

## DMS 接管的功能（不再需要独立组件）

| 功能 | 之前 | 现在 |
|------|------|------|
| 状态栏 | waybar | DMS 内置 |
| 通知 | mako | DMS Notifications |
| 应用启动器 | fuzzel | DMS Spotlight |
| 锁屏 | swaylock | DMS Lock Screen |
| 剪贴板 | wl-clipboard (手动) | DMS Clipboard Manager |
| 壁纸 | swaybg/swww | DMS Dynamic Wallpaper |
| 登录界面 | greetd | dms-greeter |

## 桌面应用总览

| 类型 | 应用 | 主题 |
|------|------|------|
| 显示管理器 | dms-greeter | DMS 动态 |
| Wayland 合成器 | niri | DMS 动态颜色 |
| 桌面外壳 | DankMaterialShell (DMS) | 自动亮暗切换 |
| 终端 | kitty | Catppuccin Mocha |
| Shell 提示符 | starship | Catppuccin Mocha |
| GTK 主题 | adw-gtk3 | DMS 动态切换 |
| Qt 主题 | qt6ct | 跟随系统 |
| 输入法 | fcitx5 | Material Color 皮肤 |

## 预装开发工具

| 类别 | 包 |
|------|-----|
| 浏览器 | google-chrome |
| 编辑器 | vscode |
| Go | go |
| Rust | rustup + rust-analyzer |
| C | gcc |
| Git | lazygit, git |
| 终端复用 | zellij, tmux |
| 文件管理 | yazi |
| 搜索 | ripgrep, fzf |
| 监控 | btop, htop |
| Markdown | glow |
| JSON | jq |
| 网络 | mtr, dnsutils |
| 截图 | grim + slurp |

## DMS 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Mod+Space` | Spotlight 应用启动器 |
| `Alt+Space` | Spotlight Bar 快速搜索 |
| `Mod+N` | 通知中心 |
| `Mod+V` | 剪贴板管理器 |
| `Mod+Alt+L` | 锁屏 |
| `Super+X` | 电源菜单 |
| `Mod+,` | DMS 设置 |
| `Ctrl+Alt+Delete` | 任务管理器 |
| `Mod+Y` | 浏览壁纸 |

## Niri 用户覆盖快捷键

在 `config.kdl` 中定义，覆盖 DMS 默认：

| 快捷键 | 功能 |
|--------|------|
| `Mod+Return` | 启动 kitty |
| `Print` | 全屏截图 |
| `Mod+Print` | 选区截图 |

## 关键设计决策

1. **DMS 统一桌面外壳** — DMS 内置状态栏、通知、启动器、锁屏、剪贴板，与 niri 深度集成，消除多组件维护负担。
2. **Niri 配置用 mkOutOfStoreSymlink** — `xdg.configFile` + `config.lib.file.mkOutOfStoreSymlink` 指向 `~/nix-config/niri/`。DMS 可自由写入 `niri/dms/`，改动直接进 git。详见 [DMS issue #1788](https://github.com/AvengeMedia/DankMaterialShell/issues/1788)。
3. **DMS 用 systemd 管理** — `systemd.enable = true`，崩溃自动重启；头像设置通过 systemd oneshot service 延迟执行。
4. **DMS 动态主题 + Catppuccin 静态配色共存** — DMS 管理合成器颜色、GTK 主题和壁纸的动态亮暗切换；kitty 终端和 starship 提示符保持独立的 Catppuccin Mocha 静态配色。
5. **字体分两级** — 系统级 `fonts.packages`（greeter 可见）+ 用户级 `home.packages`（fontconfig 使用）。
6. **用户名参数化** — `flake.nix` 的 `let username`/`hostname` 通过 `specialArgs` 注入所有模块，消除硬编码。
7. **Qt 环境变量写 sessionVariables** — `systemd.user.sessionVariables` 设置 `QT_QPA_PLATFORMTHEME=qt6ct`，确保所有 Wayland 应用拿到正确的 Qt 变量。

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

## Niri 配置文件管理

- `niri/config.kdl` — 手动维护：input 设置、DMS includes、用户覆盖键绑定
- `niri/dms/*.kdl` — 由 `dms setup` 生成，DMS 自动管理
- 首次启动或修改 DMS 设置后运行 `dms setup`
- 生成后用 `git diff` 审查变更，确认后提交

## 参考

- [DankMaterialShell 文档](https://danklinux.com/docs/)
- [dms-starter 配置](https://github.com/Mooling0602/dms-starter)
- [nix-starter-configs](https://github.com/NixOS-Asia/nix-starter-configs)
- [niri 文档](https://github.com/YaLTeR/niri)
- [Home Manager 文档](https://nix-community.github.io/home-manager/)
- [NixOS Wiki](https://nixos.wiki/)
