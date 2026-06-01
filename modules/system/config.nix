{ config, lib, ... }:

{
  options.my.username = lib.mkOption {
    type = lib.types.str;
    default = "nixosvm";
    description = "Primary username. Override in flake.nix to change.";
  };

  options.my.hostname = lib.mkOption {
    type = lib.types.str;
    default = "nixos-vm";
    description = "Hostname for machine-specific config guards.";
  };
}
