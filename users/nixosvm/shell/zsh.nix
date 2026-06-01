{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ll = "ls -l";
      # 完美更新别名！指向你家目录里的绝对路径
      nsw = "sudo nixos-rebuild switch --flake /home/nixosvm/nixos-config/#nixos-vm";
    };
  };

  # 现代化 Git 语法
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
