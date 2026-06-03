# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
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
    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # Reusable modules from your own flake:
    # inputs.self.nixosModules.example
  ];

  # ===========================================================================
  # Boot loader
  # ===========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel modules (VMware audio support)
  boot.kernelModules = [ "snd_hda_intel" "snd_intel8x0" ];

  # ===========================================================================
  # Nixpkgs
  # ===========================================================================
  nixpkgs = {
    overlays = [
      # Overlays from your own flake exports:
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
    ];
    config = {
      allowUnfree = true;
    };
  };

  # ===========================================================================
  # Nix settings
  # ===========================================================================
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

  # ===========================================================================
  # Networking
  # ===========================================================================
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # Avoid VM boot blocking on network-online.target
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -s -q --timeout=5" ];
    };
  };

  # ===========================================================================
  # Locale & Input method
  # ===========================================================================
  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };
  i18n.supportedLocales = [
    "zh_CN.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];

  # Fcitx5 Chinese input method
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-chinese-addons
      fcitx5-pinyin-zhwiki
      fcitx5-gtk             # GTK app support
      fcitx5-material-color   # Material design skin
    ];
  };

  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  # ===========================================================================
  # System fonts
  # ===========================================================================
  fonts.packages = with pkgs; [
    maple-mono.NF-CN           # Maple Mono Nerd Font (中文等宽)
    sarasa-gothic              # 更纱黑体
    noto-fonts-cjk-serif       # Noto 衬线中文字体
    noto-fonts-cjk-sans        # Noto 无衬线中文字体
    noto-fonts-emoji           # Emoji 支持
    nerd-fonts.jetbrains-mono  # JetBrains Mono Nerd Font
    nerd-fonts.symbols-only    # Nerd Font 图标符号
  ];
  fonts.fontconfig.enable = true;

  # ===========================================================================
  # Services
  # ===========================================================================
  # PipeWire (audio/video)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # PolicyKit (GUI authentication dialogs)
  security.polkit.enable = true;

  # dconf (needed for GTK settings)
  programs.dconf.enable = true;

  # ===========================================================================
  # Niri (Wayland compositor)
  # ===========================================================================
  programs.niri.enable = true;

  # ===========================================================================
  # DMS Greeter — login manager + session starter for niri + DMS
  # ===========================================================================
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/${username}";
  };

  # ===========================================================================
  # Users
  # ===========================================================================
  users.users.${username} = {
    isNormalUser = true;
    description = "Developer Account";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    # Use 'mkpasswd -m yescrypt' to generate, then fill in below:
    # hashedPassword = "...";
  };

  programs.zsh.enable = true;

  security.sudo = {
    enable = true;
    extraRules = [
      {
        users = [ username ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # ===========================================================================
  # System packages
  # ===========================================================================
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    fastfetch
    libsForQt5.qt5ct        # Qt5 theme config
    qt6Packages.qt6ct       # Qt6 theme config
  ];

  # ===========================================================================
  # VMware guest support (remove on physical machine)
  # ===========================================================================
  virtualisation.vmware.guest.enable = true;

  # ===========================================================================
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  # ===========================================================================
  system.stateVersion = "26.05";
}
