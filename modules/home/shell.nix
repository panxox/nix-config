{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      # 完美更新别名！指向你家目录里的绝对路径
      nsw = "sudo nixos-rebuild switch --flake $HOME/nix-config/#panxox-vm";
    };
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$line_break"
        "$character"
      ];

      character = {
        success_symbol = "[>](bold #89b4fa)";
        error_symbol = "[>](bold #f38ba8)";
      };

      directory = {
        style = "#b4befe";
        truncation_length = 5;
      };

      git_branch = {
        style = "#fab387";
        symbol = "";
      };

      git_status = {
        style = "#eba0ac";
      };

      username = {
        show_always = true;
        style_user = "#a6e3a1";
        format = "[$user]($style) ";
      };

      hostname = {
        ssh_only = false;
        style = "#89b4fa";
        format = "on [$hostname]($style) ";
      };

      nix_shell = {
        symbol = "";
        style = "#74c7ec";
        format = "via [$symbol]($style) ";
      };
    };
  };
}
