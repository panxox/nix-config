# =============================================================================
# NixOS 配置 — panxox-vm (niri + DMS 桌面) — Flake 版
# =============================================================================
# 基于 niri-flake 合成器 + DankMaterialShell 桌面环境。
# 严格遵循 https://danklinux.com/docs/dankmaterialshell/nixos-flake 文档。
#
# 使用方法:
#   首次构建: nix flake update && sudo nixos-rebuild switch --flake .#panxox-vm
#   日常重建: sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
#   代码格式化: nix fmt
# =============================================================================
{
  description = "NixOS niri + DMS config — panxox-vm";

  nixConfig = {
    # override the default substituters
    substituters = [
      # cache mirror located in China
      "https://mirror.nju.edu.cn/nix-channels/store"
      # status: https://mirror.sjtu.edu.cn/
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"

      "https://cache.nixos.org"

      # nix community's cache server
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      # nix community's cache server public key
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # ===========================================================================
  # Inputs
  # ===========================================================================
  inputs = {
    # ---- Nixpkgs (稳定分支) ----
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # ---- Home Manager (用户态包管理) ----
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ---- DankMaterialShell (桌面环境) ----
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ---- niri-flake (Wayland 滚动平铺合成器) ----
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ---- DMS 插件注册表 (按需启用插件) ----
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ===========================================================================
  # Outputs
  # ===========================================================================
  outputs =
    { self
    , nixpkgs
    , home-manager
    , dms
    , niri
    , dms-plugin-registry
    , ...
    } @ inputs:
    let
      system = "x86_64-linux";
      username = "panxox";       # ← 改成你的用户名
      hostname = "panxox-vm";    # ← 改成你的主机名
    in
    {
      # ---- NixOS 系统配置 ----
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username hostname; };
        modules = [
          # 本地系统级配置 (硬件、服务、用户)
          ./nixos/configuration.nix

          # niri-flake NixOS 模块 (自动包含 home-manager 子模块)
          # https://github.com/sodiboo/niri-flake
          niri.nixosModules.niri

          # Home Manager (用户态配置)
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = {
              imports = [
                # DMS home-manager 模块 (支持设置/插件/会话管理)
                dms.homeModules.dank-material-shell
                # DMS niri 集成模块 (配置包含、快捷键、自启)
                dms.homeModules.niri
                # DMS 插件注册表模块 (启用社区插件)
                dms-plugin-registry.modules.default
                # 用户级本地配置 (包、shell、主题)
                ./home-manager/home.nix
              ];
            };
            home-manager.extraSpecialArgs = { inherit inputs username hostname; };
          }
        ];
      };

      # ---- nix fmt ----
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}
