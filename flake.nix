# =============================================================================
# NixOS 最小化配置 — panxox-vm
# =============================================================================
# 依赖只有 nixpkgs 和 home-manager 两个, 干净简单不出 bug。
#
# 使用方法:
#   首次构建: nix flake update && sudo nixos-rebuild switch --flake .#panxox-vm
#   日常重建: sudo nixos-rebuild switch --flake ~/nix-config#panxox-vm
#   代码格式化: nix fmt
# =============================================================================
{
  description = "NixOS minimal config — panxox-vm";

  # ===========================================================================
  # Inputs — 只需两个外部依赖
  # ===========================================================================
  inputs = {
    # ---- Nixpkgs (unstable 分支, 软件包最新) ----
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ---- Home Manager (用户态包管理) ----
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
