{ config, pkgs, userConfig, ... }:

{
  home.username = userConfig.username;
  home.homeDirectory = (if userConfig.system == "x86_64-darwin" || userConfig.system == "aarch64-darwin" then "/Users/${userConfig.username}"
    else if userConfig.system == "x86_64-linux" || userConfig.system == "aarch64-linux" then "/home/${userConfig.username}"
    # Assuming windows based system
    else "C:\\Users\\${userConfig.username}");
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;  # 폰트 설정 활성화
  home.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
}