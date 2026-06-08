# NixOS niri + DMS + 中文输入法配置

基于 **niri** (niri-flake) 合成器 + **DankMaterialShell (DMS)** 桌面环境 + **fcitx5** 中文输入法的现代 Wayland 配置。

## 预装软件

| 类别 | 软件 |
|------|------|
| **合成器** | niri (niri-flake — 滚动平铺 Wayland 合成器) |
| **桌面 Shell** | DankMaterialShell (面板/启动器/通知/锁屏/壁纸/剪贴板/...) |
| **中文输入法** | fcitx5 + 中文 addons + rime + pinyin-zhwiki |
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
├── flake.nix                       # 入口：nixpkgs + home-manager + dms + niri-flake
├── nixos/
│   ├── configuration.nix           # 系统配置 (硬件/服务/greetd/用户)
│   └── hardware-configuration.nix  # 硬件配置 (自动生成)
├── home-manager/
│   └── home.nix                    # 用户配置 (DMS/软件包/shell/git/主题/输入法)
├── flake.lock                      # 依赖锁文件 (自动生成)
└── README.md
```

## 使用

### 首次构建

```bash
nix flake update
sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
```

### 首次启动后 — 初始化 DMS

```bash
dms setup
```

### 日常重建

```bash
nsw  # zsh alias
```

## 自定义

`flake.nix` 顶部改两个变量：

```nix
let
  username = "panxox";     # 你的用户名
  hostname = "panxox-vm";  # 你的主机名
in
```

`home-manager/home.nix` 中改 Git 用户信息：

```nix
programs.git.settings.user = {
  name = "panxox";
  email = "your@email.com";
};
```

## 输入法切换

默认快捷键：
- `Ctrl+Space` - 切换中英文
- `Ctrl+Shift` - 切换输入法引擎

## 参考

| 资源 | 链接 |
|------|------|
| NixOS 包搜索 | https://search.nixos.org/packages |
| Home Manager 手册 | https://nix-community.github.io/home-manager/ |
| DMS 文档 | https://danklinux.com/docs/dankmaterialshell/nixos-flake |
| niri-flake | https://github.com/sodiboo/niri-flake |
| fcitx5 for NixOS | https://wiki.nixos.org/wiki/Fcitx5 |
