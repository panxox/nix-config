{ config, pkgs, ... }:

{
  imports = [
    ./shell/zsh.nix # 引入抽离出去的终端配置
  ];

  home.username = "nixosvm";
  home.homeDirectory = "/home/nixosvm";
  programs.home-manager.enable = true;

  # 用户独享的软件，比如以后想装的 vscode, chrome 等可以放这里
  home.packages = with pkgs; [
    htop tmux fzf ripgrep
    fcitx5-material-color 
  ];

  # 强行给所有 GUI 软件注入 fcitx5 输入法环境变量
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx5";
    QT_IM_MODULE = "fcitx5";
    XMODIFIERS = "@im=fcitx5";
    SDL_IM_MODULE = "fcitx5";
  };

  home.stateVersion = "26.05";
}
