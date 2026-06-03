# =============================================================================
# NixOS + Niri + DMS 配置入口
# =============================================================================
# 使用方法:
#   首次构建: nix flake update && sudo nixos-rebuild switch --flake .#panxox-vm
#   后续重建: sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
#   代码格式化: nix fmt
# =============================================================================
{
  description = "NixOS + niri + DMS — panxox-vm";

  # ===========================================================================
  # 外部依赖 (Inputs)
  # ===========================================================================
  inputs = {
    # --- Nixpkgs 主仓库 (unstable 分支, 包最新) ---
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # --- Niri Wayland 合成器 ---
    # 提供 niri 本体 + xwayland-satellite (XWayland 桥接)
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- DMS (DankMaterialShell) 桌面外壳 ---
    # 提供 dms-greeter 登录管理器 + 状态栏 / 通知 / 启动器 / 锁屏等
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Home Manager (用户态配置管理) ---
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ===========================================================================
  # 输出 (Outputs)
  # ===========================================================================
  outputs =
    { self
    , nixpkgs
    , home-manager
    , niri
    , dms
    , ...
    } @ inputs:
    let
      # ---- 修改这里即可切换用户 / 主机 ----
      system = "x86_64-linux";
      username = "panxox";
      hostname = "panxox-vm";
    in
    {
      # ---- NixOS 系统配置 ----
      # 构建命令: sudo nixos-rebuild switch --flake .#panxox-vm
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username hostname; };
        modules = [
          ./nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            # ---- xwayland-satellite overlay (niri 依赖) ----
            nixpkgs.overlays = [
              (final: prev: {
                xwayland-satellite =
                  inputs.niri.packages.${final.system}.xwayland-satellite-unstable;
              })
            ];

            # ---- Home Manager 全局设置 ----
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";

            # ---- Home Manager 用户配置 ----
            home-manager.users.${username} = { ... }: {
              imports = [
                (import ./home-manager/home.nix)
                inputs.dms.homeModules.dank-material-shell
              ];
            };

            # ---- 传递参数到 Home Manager ----
            home-manager.extraSpecialArgs = inputs // { inherit username hostname; };
          }
        ];
      };

      # ---- 代码格式化 (nix fmt) ----
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;

      # ---- 开发环境 (nix develop) ----
      # 进入后可使用 nil (LSP) / nixpkgs-fmt / statix (lint) 等工具
      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        packages = with nixpkgs.legacyPackages.${system}; [
          nil          # Nix LSP 语言服务器
          nixpkgs-fmt  # Nix 代码格式化
          statix       # Nix 静态检查
        ];
      };
    };
}
