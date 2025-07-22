{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

{
  home.username = userConfig.username;
  home.homeDirectory =
    if userConfig.system == "x86_64-darwin" || userConfig.system == "aarch64-darwin" then
      "/Users/${userConfig.username}"
    else if userConfig.system == "x86_64-linux" || userConfig.system == "aarch64-linux" then
      "/home/${userConfig.username}"
    # Assuming windows based system
    else
      "C:\\Users\\${userConfig.username}";

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true; # 폰트 설정 활성화
  home.packages =
    with pkgs;
    [
      nerd-fonts.symbols-only
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      coreutils-full
      opentofu
      openssh
      ansible
      fira-code
      zsh
      zplug
      zinit
      eza
      ctags
      neovim
      neovide
      nvimpager
      tldr
      gh
      bat
      neofetch
      curl
      wget
      thefuck
      nodejs
      gcc
      libiconv
      fzf
      gnupg
      go
      obsidian
      kubectl
      kubectx
      rustup
      vscode
      jetbrains-mono
      wezterm
      lazygit
      k9s
      git
      rclone
      unixtools.nettools
      awscli2
      yq-go
      jq
      tmux
      lsof
      kubernetes-helm
      zip
      unzip
      imgcat
      python312Full
      python312Packages.uv
      pyenv
      micromamba
      nixfmt-rfc-style
      direnv
      opentofu
      zoxide
      htop
      slack
      pure-prompt
      libxcrypt
      brave
      kubetail
      windsurf
      wireshark
      code-cursor
      clamav
    ]
    ++ (
      if system == "x86_64-darwin" || system == "aarch64-darwin" then
        [
          # macOS-only packages
          iterm2
          karabiner-elements
        ]
      else if system == "x86_64-linux" || system == "aarch64-linux" then
        [
          # Linux-only packages
          chromium
          jetbrains.idea-ultimate
          kime
          google-chrome
          firefox
          xclip # Clipboard
          glibc
          playonlinux
        ]
      else
        [ ]
    );
}
