# 由 nixos-generate-config 自动生成的硬件配置
# 如需修改，请编辑同目录下的 default.nix 而非此文件
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4242292a-059f-4980-84ff-a4e0a18b2de1";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/CDF2-F4E1";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
