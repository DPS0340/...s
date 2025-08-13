{
  config,
  lib,
  pkgs,
  userConfig,
  extraPackages,
  ...
}:

let

homeDirectory = 
    if userConfig.system == "x86_64-darwin" || userConfig.system == "aarch64-darwin" then
      "/Users/${userConfig.username}"
    else if userConfig.system == "x86_64-linux" || userConfig.system == "aarch64-linux" then
      "/home/${userConfig.username}"
    # Assuming windows based system
    else
      "C:\\Users\\${userConfig.username}";

in

{
  home.username = userConfig.username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  # See https://discourse.nixos.org/t/partly-overriding-a-desktop-entry/20743
  xdg.desktopEntries = {
    google-chrome = {
      name = "google-chrome";
      exec = "${homeDirectory}/.nix-profile/bin/google-chrome -- --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3 %u";
      terminal = false;
      type = "Application";
      categories = [ "Application" "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" ];
    };
    brave = {
      name = "brave";
      exec = "${homeDirectory}/.nix-profile/bin/brave -- --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3 %u";
      terminal = false;
      type = "Application";
      categories = [ "Application" "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" ];
    };
    vscode = {
      name = "vscode";
      exec = "${homeDirectory}/.nix-profile/bin/vscode -- --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3 %u";
      terminal = false;
      type = "Application";
      categories = [ "Application" ];
      mimeType = [ "text/html" "text/xml" ];
    };
    slack = {
      name = "slack";
      exec = "${homeDirectory}/.nix-profile/bin/slack -- --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3 %u";
      terminal = false;
      type = "Application";
      categories = [ "Application" ];
      mimeType = [ "text/html" "text/xml" ];
    };
    discord = {
      name = "discord";
      exec = "${homeDirectory}/.nix-profile/bin/discord -- --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3 %u";
      terminal = false;
      type = "Application";
      categories = [ "Application" ];
      mimeType = [ "text/html" "text/xml" ];
    };
  };

  i18n = (if userConfig.system == "x86_64-linux" || userConfig.system == "aarch64-linux" then
    {
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          waylandFrontend = true;
          addons = with pkgs; [
            fcitx5-gtk
            fcitx5-hangul
          ];
          settings = {
            inputMethod = {
              GroupOrder."0" = "Default";
              "Groups/0" = {
                Name = "Default";
                "Default Layout" = "us";
                DefaultIM = "keyboard-us";
              };
              "Groups/0/Items/0".Name = "keyboard-us";
              "Groups/0/Items/1".Name = "hangul";
            };
          };
        };
      };
    }
  else { });

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
      nixfmt-classic
      direnv
      opentofu
      zoxide
      htop
      pure-prompt
      libxcrypt
      kubetail
      windsurf
      wireshark
      code-cursor
      clamav
      ghidra-bin
      cmctl
      mkpasswd
      mc
      google-chrome
      brave
      vscode
      slack
      discord
    ]
    ++ (
      if userConfig.system == "x86_64-darwin" || userConfig.system == "aarch64-darwin" then
        [
          # macOS-only packages
          iterm2
          karabiner-elements
          brave
          vscode
          slack
          discord
        ]
      else if userConfig.system == "x86_64-linux" || userConfig.system == "aarch64-linux" then
        [
          # Linux-only packages
          chromium
          jetbrains.idea-ultimate
          kime
          firefox
          xclip # Clipboard
          glibc
          playonlinux
          xrdp
          extraPackages.wiremix.packages.${userConfig.system}.default
          tor-browser
        ]
      else
        [ ]
    );
}
