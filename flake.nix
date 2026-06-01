{
  description = "我的现代化模块化 NixOS 配置文件";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # 对应你的主机名
      nixos-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos-vm/default.nix # 加载这台机器的底层系统

          # 整合 Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nixosvm = import ./users/nixosvm/home.nix;
          }
        ];
      };
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
