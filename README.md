# NixOS 最小化配置

干净简单的 NixOS 配置，没有复杂的桌面环境，开机直接进终端。

## 预装软件

| 类别 | 软件 |
|------|------|
| 终端 | kitty, zellij |
| 浏览器 | firefox |
| 编辑器 | vscode, neovim |
| 启动器 | fuzzel |
| 系统工具 | btop, fastfetch, git, curl, wget |
| 剪贴板 | wl-clipboard |
| 开发语言 | go, rust (rustup + rust-analyzer) |
| 字体 | Maple Mono NF CN, Sarasa Gothic, Noto CJK, Nerd Fonts |
| 显示管理 | greetd (TTY 自动登录) |

## 项目结构

```
~/nix-config/
├── flake.nix                       # 入口: nixpkgs + home-manager
├── nixos/
│   ├── configuration.nix           # 系统配置
│   └── hardware-configuration.nix  # 硬件配置 (自动生成)
├── home-manager/
│   └── home.nix                    # 用户配置 (软件包/shell/git/主题)
└── README.md
```

只有 5 个配置文件，一目了然。

## 使用

### 首次构建

```bash
# 1. 生成锁文件
nix flake update

# 2. 重建
sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
```

### 日常重建

```bash
# 一键 (zsh alias)
nsw

# 或完整命令
sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
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
```

## greetd 自动登录

默认配置了 greetd 开机自动登录到 TTY bash shell。

- 不需要自动登录 → 把 `nixos/configuration.nix` 里的 `services.greetd` 整块删掉
- 想启动桌面环境 → 登录后手动运行你的合成器（niri / sway / hyprland 等）

## 参考

| 资源 | 链接 |
|------|------|
| NixOS 包搜索 | https://search.nixos.org/packages |
| NixOS 选项搜索 | https://search.nixos.org/options |
| NixOS & Flakes Book (中文) | https://nixos-and-flakes.thiscute.world/zh/ |
| Home Manager 手册 | https://nix-community.github.io/home-manager/ |
| NixOS Wiki | https://nixos.wiki/ |
