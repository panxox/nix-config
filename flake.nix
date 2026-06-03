{
  description = "NixOS + niri + DMS configuration for panxox-vm";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Niri (Wayland compositor) — provides xwayland-satellite
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DankMaterialShell — desktop shell built for niri
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , niri
    , dms
    , ...
    } @ inputs:
    let
      system = "x86_64-linux";
      username = "panxox";
      hostname = "panxox-vm";
    in
    {
      # Custom packages — accessible via 'nix build .#<name>'
      packages.${system} = import ./pkgs nixpkgs.legacyPackages.${system};

      # Formatter — 'nix fmt'
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;

      # Custom overlays
      overlays = import ./overlays { inherit inputs; };

      # Reusable NixOS modules (for sharing/upstreaming)
      nixosModules = import ./modules/nixos;

      # Reusable home-manager modules (for sharing/upstreaming)
      homeManagerModules = import ./modules/home-manager;

      # =========================================================================
      # NixOS configuration — 'nixos-rebuild switch --flake .#panxox-vm'
      # =========================================================================
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username hostname; };
        modules = [
          ./nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              (final: prev: {
                xwayland-satellite = inputs.niri.packages.${final.system}.xwayland-satellite-unstable;
              })
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = { ... }: {
              imports = [
                (import ./home-manager/home.nix)
                inputs.dms.homeModules.dank-material-shell
              ];
            };
            home-manager.extraSpecialArgs = inputs // { inherit username hostname; };
          }
        ];
      };

      # =========================================================================
      # Dev shell — 'nix develop' for Nix tooling
      # =========================================================================
      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        packages = with nixpkgs.legacyPackages.${system}; [
          nil          # Nix LSP
          nixpkgs-fmt  # Nix formatter
          statix       # Nix linter
        ];
      };
    };
}
