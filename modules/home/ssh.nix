{ config, lib, pkgs, ... }:

{
  # =========================================================================
  # SSH 客户端配置
  # 在此添加 Host 别名、密钥路径等
  # =========================================================================
  programs.ssh = {
    enable = true;
    # matchBlocks = {
    #   "github.com" = {
    #     hostname = "github.com";
    #     user = "git";
    #     identityFile = "~/.ssh/id_ed25519";
    #   };
    # };
  };
}
