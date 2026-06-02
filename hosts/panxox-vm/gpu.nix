{ config, pkgs, lib, ... }:

{
  # =========================================================================
  # GPU 驱动配置 — 当前为 VM 环境，无需 GPU 驱动
  # =========================================================================
  #
  # 物理机部署时取消注释并修改对应驱动：
  #
  # NVIDIA:
  #   services.xserver.videoDrivers = [ "nvidia" ];
  #   hardware.nvidia = {
  #     modesetting.enable = true;
  #     powerManagement.enable = true;
  #     open = false;
  #     nvidiaSettings = true;
  #     package = config.boot.kernelPackages.nvidiaPackages.stable;
  #   };
  #
  # Intel 集显:
  #   services.xserver.videoDrivers = [ "modesetting" ];
  #
  # AMD:
  #   services.xserver.videoDrivers = [ "amdgpu" ];
}
