# =============================================================================
# NixOS 配置 — panxox-vm (niri + DMS 桌面)
# =============================================================================
# 基于 niri 合成器 + DankMaterialShell 桌面环境的现代 Wayland 配置。
#
# 使用方法:
#   首次构建: nix flake update && sudo nixos-rebuild switch --flake .#panxox-vm
#   日常重建: sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
#   代码格式化: nix fmt
# =============================================================================
{
  description = "NixOS niri + DMS config — panxox-vm";

  # ===========================================================================
  # Inputs
  # ===========================================================================
  inputs = {
    # ---- Nixpkgs (unstable 分支, 软件包最新) ----
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ---- Home Manager (用户态包管理) ----
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ---- DMS 插件注册表 (声明式插件安装) ----
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
          ./nixos/configuration.nix
          dms-plugin-registry.modules.default   # DMS 插件注册表
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./home-manager/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs username hostname; };
          }
        ];
      };

      # ---- nix fmt ----
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}
