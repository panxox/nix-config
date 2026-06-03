# NixOS + Niri + DMS

基于 [nix-starter-configs](https://github.com/NixOS-Asia/nix-starter-configs) 模板, 使用 **niri** Wayland 合成器 + **DankMaterialShell** 桌面外壳的 NixOS 桌面配置。

## 桌面环境

| 组件 | 软件 | 说明 |
|------|------|------|
| 登录管理器 | dms-greeter | DMS 原生的美观登录界面 |
| Wayland 合成器 | niri | 滚动式平铺, 高效窗口管理 |
| 桌面外壳 | DankMaterialShell (DMS) | 状态栏 / 通知 / 启动器 / 锁屏 / 剪贴板 / 电源菜单 / 动态壁纸 / 自动主题 |
| 终端 | kitty | GPU 加速, Catppuccin Mocha 配色 |
| 终端复用器 | zellij | 现代化 tmux 替代 |
| 启动器 | fuzzel | Wayland 原生应用启动器 |
| Shell | zsh + starship | 语法高亮 / 自动补全 / Catppuccin 提示符 |
| 浏览器 | Firefox | Wayland 原生运行 |
| 输入法 | fcitx5 | 中文拼音, Material Color 皮肤 |

## 预装软件

| 类别 | 软件 |
|------|------|
| 桌面环境 | DMS (dms-greeter + 完整桌面外壳) |
| 合成器 | niri |
| 终端 | kitty, zellij |
| 启动器 | fuzzel |
| 浏览器 | firefox |
| 编辑器 | vscode, neovim |
| 开发语言 | go, rust (rustup + rust-analyzer) |
| 系统工具 | git, curl, wget, btop, fastfetch |
| 剪贴板 | wl-clipboard |
| 输入法 | fcitx5 (拼音 + 维基词典 + Material Color 皮肤) |
| 字体 | Maple Mono NF CN, Sarasa Gothic, Noto CJK Serif/Sans, Nerd Fonts Symbols |

## 项目结构

```
~/nix-config/
├── flake.nix                    # 入口: 声明依赖 (nixpkgs, niri, dms, home-manager)
├── nixos/
│   ├── configuration.nix        # 系统配置: 引导/网络/用户/语言/字体/niri/DMS greeter
│   └── hardware-configuration.nix  # 硬件配置 (nixos-generate-config 生成)
├── home-manager/
│   └── home.nix                 # 用户配置: 软件包/DMS设置/kitty/fuzzel/主题/shell
├── niri/                        # niri 配置文件 (mkOutOfStoreSymlink 链接)
│   ├── config.kdl               # 主配置: 输入/快捷键覆盖/DMS includes
│   └── dms/                     # DMS 生成文件 (`dms setup` 产出)
│       ├── binds.kdl            # 键位绑定 (DMS 管理)
│       ├── colors.kdl           # 动态配色 (DMS 管理)
│       ├── layout.kdl           # 布局: 间距/圆角/边框
│       ├── cursor.kdl           # 光标主题
│       ├── outputs.kdl          # 显示器配置
│       ├── windowrules.kdl      # 窗口规则
│       ├── wpblur.kdl           # 壁纸模糊图层
│       └── alttab.kdl           # Alt+Tab 窗口切换
├── assets/                      # 静态资源 (壁纸/头像)
├── deploy.sh                    # 新机器部署脚本
└── README.md
```

## 快速开始

### 首次构建

```bash
# 1. 生成 flake.lock (锁定依赖版本)
nix flake update

# 2. 重建系统
sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm

# 3. 重启后登录, 初始化 DMS
dms setup
```

### 日常使用

```bash
# 一键重建 (zsh alias, 需先 git commit)
nsw

# 等价于:
sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
```

## 工作流

1. **修改配置** — 编辑 nix 或 kdl 文件
2. **提交** — `git commit` (重建前提交, 避免 flake dirty tree 警告)
3. **重建** — `nsw`
4. **推送** — `git push`

## DMS 快捷键

DMS 接管了以下桌面功能, 无需额外安装独立组件:

| 快捷键 | 功能 | DMS 组件 |
|--------|------|----------|
| `Mod+Space` | 应用启动器 | Spotlight |
| `Alt+Space` | 快速搜索 | Spotlight Bar |
| `Mod+N` | 通知中心 | Notifications |
| `Mod+V` | 剪贴板历史 | Clipboard |
| `Mod+Alt+L` | 锁屏 | Lock Screen |
| `Super+X` | 电源菜单 (关机/重启/休眠) | Power Menu |
| `Mod+,` | DMS 设置 | Settings |
| `Ctrl+Alt+Delete` | 任务管理器 | Process List |
| `Ctrl+Shift+R` | 重命名工作区 | Workspace Rename |
| `Mod+Y` | 浏览壁纸 | Wallpaper Browser |

## 用户自定义快捷键

在 `niri/config.kdl` 中覆盖 DMS 默认值:

| 快捷键 | 功能 |
|--------|------|
| `Mod+Return` | 启动 kitty 终端 |
| `Mod+D` | 启动 fuzzel 启动器 |
| `Mod+1..9` | 切换工作区 1-9 |
| `Mod+H/L` | 聚焦左/右列 |
| `Mod+J/K` | 聚焦下/上窗口 |
| `Mod+Q` | 关闭窗口 |
| `Mod+F` | 最大化列 |
| `Mod+Shift+F` | 全屏窗口 |
| `Mod+Shift+E` | 退出 niri |

## 自定义用户名 / 主机名

编辑 `flake.nix` 顶部的 `let` 绑定:

```nix
let
  username = "panxox";      # ← 改成你的用户名
  hostname = "panxox-vm";   # ← 改成你的主机名
in
```

所有模块自动引用这些变量, 无需手动替换。

## 新机器部署

```bash
# 1. 安装 NixOS 后克隆仓库
git clone <repo-url> ~/nix-config

# 2. 运行部署脚本 (交互式: 生成硬件配置 / 更新用户名等)
cd ~/nix-config && chmod +x deploy.sh && ./deploy.sh

# 3. 设置用户密码
sudo passwd <username>

# 4. 重建系统
sudo nixos-rebuild switch --flake ~/nix-config#<hostname>

# 5. 首次登录后初始化 DMS
dms setup
```

## Niri 配置文件管理

- **`niri/config.kdl`** — 手动维护。包含: 键盘/触控板设置、DMS includes、用户自定义快捷键。
- **`niri/dms/*.kdl`** — 由 `dms setup` 自动生成, DMS 自由写入。git 追踪以便审查变更。
- 修改 DMS 设置后运行 `dms setup` 重新生成, 用 `git diff` 审查后提交。

## 关键设计

1. **DMS 作为统一桌面外壳** — 不需要单独安装 waybar / mako / swaylock / 壁纸守护进程。DMS 与 niri 深度集成, 提供一致体验。
2. **mkOutOfStoreSymlink** — niri 配置通过符号链接指向仓库, 修改直接进 git。DMS 只在 `niri/dms/` 目录写入。
3. **systemd 管理 DMS** — `systemd.enable = true`, DMS 崩溃自动重启。
4. **Catppuccin Mocha 静态配色** — kitty 终端和 starship 提示符使用 Catppuccin Mocha 颜色方案, 不受 DMS 动态主题影响。
5. **DMS 动态主题** — 合成器颜色 / GTK 主题 / 壁纸由 DMS 根据日出日落自动切换亮暗。

## Catppuccin Mocha 颜色参考

| 色值 | 变量名 | 用途 |
|------|--------|------|
| `#1e1e2e` | base | 主背景 |
| `#313244` | surface0 | 表面 / 选中 |
| `#45475a` | surface1 | 边框色 |
| `#585b70` | surface2 | 次表面 |
| `#cdd6f4` | text | 主文字 |
| `#89b4fa` | blue | 强调色 |
| `#b4befe` | lavender | 次要强调 |
| `#a6e3a1` | green | 成功 |
| `#f38ba8` | red | 错误 |
| `#f9e2af` | yellow | 警告 |
| `#94e2d5` | teal | 信息 |
| `#f5e0dc` | rosewater | 光标 |

## 参考

| 资源 | 链接 |
|------|------|
| DMS 文档 | https://danklinux.com/docs/ |
| niri 文档 | https://github.com/YaLTeR/niri |
| NixOS 包搜索 | https://search.nixos.org/packages |
| NixOS 选项搜索 | https://search.nixos.org/options |
| NixOS & Flakes Book (中文) | https://nixos-and-flakes.thiscute.world/zh/ |
| Home Manager 手册 | https://nix-community.github.io/home-manager/ |
| nix-starter-configs | https://github.com/NixOS-Asia/nix-starter-configs |
| NixOS Wiki | https://nixos.wiki/ |
