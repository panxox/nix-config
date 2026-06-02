{
  description = "NixOS configuration for nixos-vm with niri + DMS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-packages = {
      url = "github:Mooling0602/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      username = "panxox";   # ← 改这里即可替换用户名
      hostname = "panxox-vm";  # ← 改这里即可替换主机名
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${hostname}
          home-manager.nixosModules.home-manager
          {
            my = { inherit username hostname; };
            nixpkgs.overlays = [
              (final: prev: {
                xwayland-satellite = inputs.niri.packages.${final.system}.xwayland-satellite-unstable;
              })
              (final: prev: {
                reasonix = inputs.nix-packages.packages.${final.system}.reasonix;
              })
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = { config, pkgs, ... }: {
              imports = [
                ./modules/home
                inputs.dms.homeModules.dank-material-shell
              ];
            };
            home-manager.extraSpecialArgs = inputs // { inherit username hostname; };
          }
        ];
      };

      # 代码格式化
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      # 开发环境 (nix develop 进入)
      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [
          nil          # Nix LSP 语言服务器
          nixpkgs-fmt  # Nix 代码格式化工具
          statix       # Nix 静态分析 / lint 工具
        ];
      };
    };
}
