# =============================================================================
# NixOS 系统配置 — niri + DMS 桌面 + 中文输入法
# =============================================================================
{
  inputs,
  lib,
  config,
  pkgs,
  username,
  hostname,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "snd_hda_intel" "snd_intel8x0" "i2c-dev" ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      flake-registry = "";
    };
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = [
        ""
        "${pkgs.networkmanager}/bin/nm-online -s -q --timeout=5"
      ];
    };
  };

  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT    = "zh_CN.UTF-8";
    LC_MONETARY       = "zh_CN.UTF-8";
    LC_NAME           = "zh_CN.UTF-8";
    LC_NUMERIC        = "zh_CN.UTF-8";
    LC_PAPER          = "zh_CN.UTF-8";
    LC_TELEPHONE      = "zh_CN.UTF-8";
    LC_TIME           = "zh_CN.UTF-8";
  };
  i18n.supportedLocales = [
    "zh_CN.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];

  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  fonts.packages = with pkgs; [
    maple-mono.NF-CN
    sarasa-gothic
    noto-fonts-cjk-serif
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
  ];
  fonts.fontconfig.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  security.polkit.enable = true;
  programs.dconf.enable = true;

  programs.regreet = {
    enable = true;
    cageArgs = [ "-s" "-d" ];
    theme = { name = "Adwaita"; };
    font = {
      name = "Maple Mono NF CN";
      size = 14;
    };
    cursorTheme = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
    };
    settings = {
      background = "#1e1e2e";
      greeting = "你好！欢迎回来";
      commands = {
        reboot = [ "loginctl" "reboot" ];
        poweroff = [ "loginctl" "poweroff" ];
      };
    };
  };

  programs.niri.enable = true;
  systemd.user.services.niri-flake-polkit.enable = false;

  xdg.portal = {
    enable = true;
    config.common.default = [ "gnome" "gtk" ];
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  services.power-profiles-daemon.enable = true;
  hardware.i2c.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    description = "Developer";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  programs.zsh.enable = true;

  security.sudo-rs = {
    enable = true;
    extraRules = [{
      users = [ username ];
      commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
    }];
  };

  environment.systemPackages = with pkgs; [
    vim git curl wget fastfetch
    dsearch cliphist wl-clipboard swappy satty xwayland
  ];

  virtualisation.vmware.guest.enable = true;

  system.stateVersion = "26.05";
}
