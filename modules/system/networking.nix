{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  # 避免 VM 启动时 NetworkManager 长时间阻塞 network-online.target
  # 默认会等所有连接完成，VM 中常因接口变化导致 2 分钟超时
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -s -q --timeout=5" ];
    };
  };
}
