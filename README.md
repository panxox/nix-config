# NixOS niri + DMS 配置

基于 **niri** (niri-flake) 合成器 + **DankMaterialShell (DMS)** 桌面环境的现代 Wayland 配置。
开机自动登录到 niri 桌面，DMS 提供完整的桌面体验。

## 预装软件

| 类别 | 软件 |
|------|------|
| **合成器** | niri (niri-flake — 滚动平铺 Wayland 合成器) |
| **桌面 Shell** | DankMaterialShell (面板/启动器/通知/锁屏/壁纸/剪贴板/...) |
| **终端** | kitty, zellij |
| **浏览器** | firefox |
| **编辑器** | vscode, neovim |
| **系统监控** | dgop (DMS 集成) |
| **文件搜索** | dsearch (DMS 集成) |
| **开发语言** | go, rust (rustup + rust-analyzer) |
| **字体** | Maple Mono NF CN, Sarasa Gothic, Noto CJK, Nerd Fonts |
| **显示管理** | greetd + ReGreet (GTK 登录界面) → niri 自动登录 |

## 项目结构

```
~/nix-config/
├── flake.nix                       # 入口: nixpkgs + home-manager + dms + niri-flake + dms-plugin-registry
├── nixos/
│   ├── configuration.nix           # 系统配置 (硬件/服务/greetd/用户)
│   └── hardware-configuration.nix  # 硬件配置 (自动生成)
├── home-manager/
│   └── home.nix                    # 用户配置 (DMS/软件包/shell/git/主题/环境变量)
├── flake.lock                      # 依赖锁文件 (自动生成)
└── README.md
```

只有 5 个配置文件，一目了然。

## 架构说明

### 模块组合 (flake.nix)

```
NixOS 系统 (nixpkgs.lib.nixosSystem)
├── nixos/configuration.nix          ← 系统级: 硬件、引导、网络、greetd、音频
├── niri.nixosModules.niri           ← niri-flake NixOS 模块 (含 HM 子模块)
└── home-manager.nixosModules.hm
    └── home-manager.users.panxox
        ├── dms.homeModules.dank-material-shell  ← DMS 桌面环境
        ├── dms.homeModules.niri                 ← DMS niri 集成 (配置包含/自启)
        ├── dms-plugin-registry.modules.default   ← 插件注册表
        └── ./home-manager/home.nix              ← 用户软件包/shell/主题
```

### 启动链

```
systemd boot → greetd → cage (Wayland 合成器) → ReGreet (GTK 登录界面) → niri-session → DMS (由 niri 自动启动)
```

### 关键差异 (相对于旧版 dms-plugin-registry)

| 旧版 | 新版 (本配置) |
|------|---------------|
| `dms-plugin-registry` flake | `DankMaterialShell/stable` flake |
| `programs.dms-shell` | `programs.dank-material-shell` |
| `dms-plugin-registry.modules.default` + systemd 自启 | `dms.homeModules.dank-material-shell` + NixOS 级 |
| systemd 管理 DMS 生命周期 | niri 管理 DMS 生命周期 (`niri.enableSpawn`) |
| niri 来自 nixpkgs | niri 来自 `niri-flake` (sodiboo/niri-flake) |
| niri 单独配置 | niri-flake HM 子模块自动处理配置包含 |

## 使用

### 首次构建

```bash
# 1. 生成锁文件 (首次拉取所有 flake 输入)
nix flake update

# 2. 重建
sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
```

### 首次启动后 — 初始化 DMS

```bash
# 生成 DMS 默认配置 (niri 键位、颜色、布局等)
dms setup

# 查看 DMS 状态
systemctl --user status dms
```

### 日常重建

```bash
# 一键 (zsh alias)
nsw

# 或完整命令
sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
```

### DMS 常用命令

```bash
dms-restart                    # 重启 DMS
dms-logs                       # 查看 DMS 日志
dms ipc call spotlight toggle  # 打开启动器 (Mod+Space)
dms ipc call settings toggle   # 打开设置
dms doctor                     # 系统诊断
```

## 工作流

1. 编辑配置 → 2. `git commit` → 3. `nsw` 重建 → 4. `git push`

## 自定义

`flake.nix` 顶部改两个变量即可：

```nix
let
  username = "panxox";     # ← 你的用户名
  hostname = "panxox-vm";  # ← 你的主机名
in
```

`home-manager/home.nix` 中改 Git 用户信息：

```nix
programs.git = {
  settings = {
    user = {
      name = "panxox";              # ← 你的名字
      email = "2279827640@qq.com";  # ← 你的邮箱
    };
  };
};
```

## 新机器部署

```bash
# 1. 安装完 NixOS, 克隆仓库
git clone <repo-url> ~/nix-config

# 2. 编辑 flake.nix 改 username / hostname
# 3. 编辑 home-manager/home.nix 改 git 信息

# 4. 生成硬件配置
sudo nixos-generate-config --root / --dir ~/nix-config/nixos

# 5. 设置密码
sudo passwd <username>

# 6. 生成密码哈希 (可选)
mkpasswd -m yescrypt

# 7. 重建
sudo nixos-rebuild switch --flake ~/nix-config#<hostname>

# 8. 初始化 DMS 配置
dms setup
```

## 桌面概览

| 快捷键 | 功能 |
|--------|------|
| `Mod+Space` | 应用启动器 (Spotlight) |
| `Mod+V` | 剪贴板历史 |
| `Mod+M` | 任务管理器 |
| `Mod+,` | 设置 |
| `Mod+N` | 通知中心 |
| `Mod+Y` | 浏览壁纸 |
| `Mod+Alt+L` | 锁定屏幕 |
| `Mod+Shift+Return` | 全屏截图 |
| 音量键 | 音量控制 |
| 亮度键 | 亮度控制 |

## DMS 插件

DMS 支持社区插件，通过 `home-manager/home.nix` 的 `programs.dank-material-shell.plugins` 声明式安装。
插件列表见: https://github.com/AvengeMedia/dms-plugin-registry

## 参考

| 资源 | 链接 |
|------|------|
| NixOS 包搜索 | https://search.nixos.org/packages |
| NixOS 选项搜索 | https://search.nixos.org/options |
| NixOS & Flakes Book (中文) | https://nixos-and-flakes.thiscute.world/zh/ |
| Home Manager 手册 | https://nix-community.github.io/home-manager/ |
| DMS 文档 (Flake 安装) | https://danklinux.com/docs/dankmaterialshell/nixos-flake |
| niri-flake | https://github.com/sodiboo/niri-flake |
| niri Wiki | https://github.com/YaLTeR/niri/wiki |
| NixOS Wiki | https://nixos.wiki/ |
