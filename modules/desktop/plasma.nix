{ pkgs, ... }:

{
  # 1. 启用 X11 图形服务（现代桌面环境底层仍需要它的部分组件）
  services.xserver.enable = true;

  # 2. 启用 SDDM 现代登录管理器
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # 强制让 SDDM 运行在 Wayland 模式下，对高分屏缩放极佳
  };

  # 3. 启用完美的 KDE Plasma 6 桌面环境
  services.desktopManager.plasma6.enable = true;

  # 4. 像素级微调：针对 KDE 虚拟机的必备优化包
  environment.systemPackages = with pkgs; [
    kdePackages.kate          # KDE 官方文本编辑器（以备不时之需）
    kdePackages.ark           # 强力的图形解压工具
    kdePackages.spectacle     # 功能极度强大的自带截图工具
    
    # PipeWire 多媒体框架的 KDE 集成，用于音频/视频流处理
    # (剪贴板共享、文件拖拽、分辨率自适应由 virtualisation.vmware.guest.enable 提供)
    kdePackages.kpipewire
  ];

  # 5. 屏蔽掉一些 KDE 自带的无用“大件”（根据程序员审美，保持系统纯净）
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa                     # 音乐播放器（我们写代码一般用不到）
    gwenview                  # 自带看图软件（如果喜欢可以留着，不习惯可以排除）
  ];
}
