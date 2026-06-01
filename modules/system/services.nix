{ config, pkgs, ... }:

{
  # PipeWire 多媒体框架（屏幕共享 / 投屏必需）
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # polkit（GUI 提权对话框）
  security.polkit.enable = true;

  # dconf（GTK 主题配置生效的必要条件）
  programs.dconf.enable = true;
}
