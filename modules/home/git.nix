{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "panxox";
        email = "2279827640@qq.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
}
