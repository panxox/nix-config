{ config, pkgs, ... }:

{
  users.users.${config.my.username} = {
    isNormalUser = true;
    description = "Developer Account";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    # 使用 mkpasswd -m yescrypt 生成哈希
    hashedPassword = "$y$j9T$dummy-hash-replace-with-real-one$";
  };

  programs.zsh.enable = true;

  security.sudo = {
    enable = true;
    extraRules = [
      {
        users = [ config.my.username ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
