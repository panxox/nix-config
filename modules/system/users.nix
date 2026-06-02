{ config, pkgs, ... }:

{
  users.users.${config.my.username} = {
    isNormalUser = true;
    description = "Developer Account";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    # 使用 mkpasswd -m yescrypt 生成哈希
    hashedPassword = "$6$WeaqIRP7wIn1JnMe$6s2HmjpWE/z/ICp/lyLmiAKSQFNZi0IlkJngLvIE5.DtvoakL.90N4gtSF.dVyJYx2iixJuViJ3eJ6tDXZoyh0";
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
