{ config, lib, ... }:

{
  options.my.username = lib.mkOption {
    type = lib.types.str;
    default = "panxox";
    description = "Primary username. Override in flake.nix to change.";
  };

  options.my.hostname = lib.mkOption {
    type = lib.types.str;
    default = "panxox-vm";
    description = "Hostname for machine-specific config guards.";
  };
}
