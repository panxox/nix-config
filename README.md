# NixOS + Niri + DMS

基于 [nix-starter-configs/standard](https://github.com/NixOS-Asia/nix-starter-configs) 模板构建的 NixOS 桌面配置，使用 **niri** 作为 Wayland 合成器，**DankMaterialShell (DMS)** 作为桌面外壳。

## 桌面环境

| 组件 | 软件 | 说明 |
|------|------|------|
| 显示管理器 | dms-greeter | DMS 原生登录界面，直接启动 niri |
| 合成器 | niri | 滚动式平铺 Wayland 合成器 |
| 桌面外壳 | DMS | 状态栏、通知中心、应用启动器、锁屏、剪贴板历史、电源菜单 |
| 终端 | kitty | GPU 加速终端，Catppuccin Mocha 配色 |
| Shell | zsh + starship | 语法高亮、自动补全、Catppuccin 提示符 |
| 输入法 | fcitx5 | 中文拼音 + Material Color 皮肤 |

## 预装软件

| 类别 | 软件 |
|------|------|
| **浏览器** | Google Chrome |
| **编辑器** | VS Code |
| **开发语言** | Go、Rust (rustup + rust-analyzer)、GCC |
| **CLI 工具** | htop、btop、ripgrep、fzf、jq、tmux、zellij、yazi、lazygit、glow |
| **截图** | grim + slurp |
| **字体** | Maple Mono NF CN、Sarasa Gothic、Noto CJK、JetBrains Mono NF、Nerd Fonts Symbols |
| **主题** | Catppuccin Mocha 统一配色、adw-gtk3、Papirus 图标、Catppuccin 光标 |

## 项目结构

```
~/nix-config/
├── flake.nix                         # 入口：inputs、overlays、nixosConfigurations
├── nixos/
│   ├── configuration.nix             # 系统配置（引导、网络、用户、i18n、niri、dms-greeter）
│   └── hardware-configuration.nix    # 硬件配置（nixos-generate-config 生成）
├── home-manager/
│   └── home.nix                      # 用户配置（包、DMS、kitty、主题、shell、git）
├── modules/                          # 可复用模块（预留）
│   ├── nixos/default.nix
│   └── home-manager/default.nix
├── overlays/default.nix              # 自定义 overlays
├── pkgs/default.nix                  # 自定义包
├── niri/                             # Niri 配置文件（mkOutOfStoreSymlink，DMS 可写）
│   ├── config.kdl                    # 主配置（手写）：input、DMS includes、按键覆盖
│   └── dms/                          # DMS 生成的文件（dms setup 产出）
│       ├── alttab.kdl
│       ├── binds.kdl
│       ├── colors.kdl
│       ├── cursor.kdl
│       ├── layout.kdl
│       ├── outputs.kdl
│       ├── windowrules.kdl
│       └── wpblur.kdl
├── assets/                           # 壁纸等静态资源
├── deploy.sh                         # 新机器交互式部署脚本
└── README.md
```

## 快速开始

### 首次构建

```bash
# 生成 flake.lock
nix flake update

# 重建系统
sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
```

### 日常使用 (zsh alias)

```bash
nsw   # = sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
```

### 新机器部署

```bash
# 1. 安装 NixOS 后，克隆仓库
git clone <repo-url> ~/nix-config

# 2. 运行部署脚本（交互式，会生成硬件配置、更新用户名/主机名/Git 配置）
cd ~/nix-config && chmod +x deploy.sh && ./deploy.sh

# 3. 设置密码
sudo passwd <username>

# 4. 重建
sudo nixos-rebuild switch --flake ~/nix-config#<hostname>

# 5. 首次登录后初始化 DMS
dms setup
```

## 工作流

1. **修改** — 编辑配置文件
2. **提交** — `git commit`（在重建前提交，避免 dirty tree 警告）
3. **重建** — `nsw` 或 `sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm`
4. **推送** — `git push`

## DMS 集成

DMS 作为桌面外壳统一接管了以下功能（不再需要独立安装 waybar、mako、swaylock、fuzzel）：

| 功能 | 快捷键 | DMS 组件 |
|------|--------|----------|
| 应用启动器 | `Mod+Space` | Spotlight |
| 快速搜索 | `Alt+Space` | Spotlight Bar |
| 通知中心 | `Mod+N` | Notifications |
| 剪贴板历史 | `Mod+V` | Clipboard |
| 锁屏 | `Mod+Alt+L` | Lock Screen |
| 电源菜单 | `Super+X` | Power Menu |
| DMS 设置 | `Mod+,` | Settings |
| 任务管理器 | `Ctrl+Alt+Delete` | Process List |
| 重命名工作区 | `Ctrl+Shift+R` | Workspace Rename |
| 创建窗口规则 | `Mod+Shift+W` | Window Rules |
| 浏览壁纸 | `Mod+Y` | Wallpaper Browser |
| 笔记 | `Mod+Shift+N` | Notepad |

## 用户自定义快捷键

在 `niri/config.kdl` 中覆盖 DMS 默认值：

| 快捷键 | 功能 |
|--------|------|
| `Mod+Return` | 启动 kitty 终端 |
| `Print` | 全屏截图 |
| `Mod+Print` | 选区截图 |
| `Mod+1..9` | 切换工作区 |
| `Mod+H/L/J/K` | 窗口导航 |
| `Mod+Q` | 关闭窗口 |
| `Mod+Shift+E` | 退出 niri |

## 自定义用户名 / 主机名

编辑 `flake.nix` 顶部：

```nix
let
  username = "panxox";      # ← 改为你的用户名
  hostname = "panxox-vm";   # ← 改为你的主机名
in
```

## Niri 配置文件管理

- **`niri/config.kdl`** — 手动维护：input 设置、DMS includes、用户覆盖键绑定
- **`niri/dms/*.kdl`** — 由 `dms setup` 自动生成
- 修改 DMS 设置后运行 `dms setup` 重新生成
- 生成后用 `git diff` 审查变更，确认后提交

## Catppuccin Mocha 配色

| 色值 | 变量 | 用途 |
|------|------|------|
| `#1e1e2e` | base | 主背景色 |
| `#313244` | surface0 | 表面色 / 选中态 |
| `#cdd6f4` | text | 主文字色 |
| `#89b4fa` | blue | 强调色 |
| `#b4befe` | lavender | 次要强调色 |
| `#a6e3a1` | green | 成功色 |
| `#f38ba8` | red | 错误色 |
| `#94e2d5` | teal | 信息色 |
| `#f5e0dc` | rosewater | 光标色 |

## 关键设计决策

1. **DMS 作为统一桌面外壳** — DMS 提供状态栏、通知、启动器、锁屏、剪贴板，消除多组件维护负担，与 niri 深度集成。
2. **Niri 配置用 mkOutOfStoreSymlink** — `xdg.configFile` + `config.lib.file.mkOutOfStoreSymlink` 指向 `~/nix-config/niri/`，DMS 可自由写入 `dms/` 目录，改动直接进 git。
3. **DMS 用 systemd 管理** — `systemd.enable = true`，崩溃自动重启。
4. **Catppuccin Mocha 统一配色** — kitty 终端、starship 提示符均使用 Catppuccin Mocha 静态配色；DMS 通过 `enableDynamicTheming` 管理合成器颜色和 GTK 主题的动态切换。
5. **字体分两级** — 系统级 `fonts.packages`（greeter 可见）+ 用户级 `home.packages`（fontconfig 使用）。

## 参考

- [DankMaterialShell 文档](https://danklinux.com/docs/)
- [niri 文档](https://github.com/YaLTeR/niri)
- [nix-starter-configs](https://github.com/NixOS-Asia/nix-starter-configs)
- [Home Manager 文档](https://nix-community.github.io/home-manager/)
- [NixOS Wiki](https://nixos.wiki/)
