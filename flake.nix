# =============================================================================
# NixOS 配置 — niri + DMS 桌面 + 中文输入法 — Flake 版
# =============================================================================
# 基于 niri-flake 合成器 + DankMaterialShell 桌面环境。
# 严格遵循 https://danklinux.com/docs/dankmaterialshell/nixos-flake 文档。
#
# 使用方法:
#   首次构建：nix flake update && sudo nixos-rebuild switch --flake .#panxox-vm
#   日常重建：sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
#   代码格式化：nix fmt
# =============================================================================
{
  description = "NixOS niri + DMS + 中文输入法 config";
  
  nixConfig = {
    substituters = [
      "https://mirror.nju.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    , dgop
    , niri
    , dms-plugin-registry
    , ...
    } @ inputs:
    let
      system = "x86_64-linux";
      username = "panxox";
      hostname = "panxox-vm";
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username hostname; };
        modules = [
          ./nixos/configuration.nix
          niri.nixosModules.niri
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = {
              imports = [
                dms.homeModules.dank-material-shell
                dms.homeModules.niri
                dms-plugin-registry.modules.default
                ./home-manager/home.nix
              ];
            };
            home-manager.extraSpecialArgs = { inherit inputs username hostname; };
          }
        ];
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}
