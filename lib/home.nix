{ config, lib, pkgs, userConfig, extraPackages, ... }:

let

  homeDirectory = if userConfig.system == "x86_64-darwin" || userConfig.system
  == "aarch64-darwin" then
    "/Users/${userConfig.username}"
  else if userConfig.system == "x86_64-linux" || userConfig.system
  == "aarch64-linux" then
    "/home/${userConfig.username}"
    # Assuming windows based system
  else
    "C:\\Users\\${userConfig.username}";

in {
  home.username = userConfig.username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  xdg = (if userConfig.system == "x86_64-linux" || userConfig.system
  == "aarch64-linux" then {
    # See https://discourse.nixos.org/t/partly-overriding-a-desktop-entry/20743
    desktopEntries = {
      "com.google.chrome" = {
        name = "Google Chrome";
        exec =
          "${homeDirectory}/.nix-profile/bin/google-chrome -- --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3 %u";
        terminal = false;
        type = "Application";
        categories = [ "Application" "Network" "WebBrowser" ];
        mimeType = [ "text/html" "text/xml" ];
      };
      "brave-browser" = {
        name = "Brave";
        exec =
          "${homeDirectory}/.nix-profile/bin/brave -- --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3 %u";
        terminal = false;
        type = "Application";
        categories = [ "Application" "Network" "WebBrowser" ];
        mimeType = [ "text/html" "text/xml" ];
      };
      "code" = {
        name = "Visual Studio Code";
        exec =
          "${homeDirectory}/.nix-profile/bin/vscode -- --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3 %u";
        terminal = false;
        type = "Application";
        categories = [ "Application" ];
        mimeType = [ "text/html" "text/xml" ];
      };
      "slack" = {
        name = "Slack";
        exec =
          "${homeDirectory}/.nix-profile/bin/slack -- --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3 %u";
        terminal = false;
        type = "Application";
        categories = [ "Application" ];
        mimeType = [ "text/html" "text/xml" ];
      };
      "discord" = {
        name = "Discord";
        exec =
          "${homeDirectory}/.nix-profile/bin/discord -- --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3 %u";
        terminal = false;
        type = "Application";
        categories = [ "Application" ];
        mimeType = [ "text/html" "text/xml" ];
      };
      "obsidian" = {
        name = "Obsidian";
        exec =
          "${homeDirectory}/.nix-profile/bin/obsidian -- --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3 %u";
        terminal = false;
        type = "Application";
        categories = [ "Application" "Network" "WebBrowser" ];
        mimeType = [ "text/html" "text/xml" ];
      };
    };
  } else
    { });

  i18n = (if userConfig.system == "x86_64-linux" || userConfig.system
  == "aarch64-linux" then {
    inputMethod = {
      enable = true;
      type = "kime";
      kime.extraConfig = ''
        daemon:
          modules:
          - Xim
          - Wayland
          - Indicator
        indicator:
          icon_color: White
        log:
          global_level: DEBUG
        engine:
          translation_layer: null
          default_category: Latin
          global_category_state: false
          global_hotkeys:
            M-C-Backslash:
              behavior: !Mode Math
              result: ConsumeIfProcessed 
            C-Space:
              behavior: !Toggle
              - Hangul
              - Latin
              result: Consume
            S-Space:
              behavior: !Toggle
              - Hangul
              - Latin
              result: Consume
            M-C-E:
              behavior: !Mode Emoji
              result: ConsumeIfProcessed
            Esc:
              behavior: !Switch Latin
              result: Bypass
            Muhenkan:
              behavior: !Toggle
              - Hangul
              - Latin
              result: Consume
            AltR:
              behavior: !Toggle
              - Hangul
              - Latin
              result: Consume
            ControlR:
              behavior: !Toggle
              - Hangul
              - Latin
              result: Consume
            Hangul:
              behavior: !Toggle
              - Hangul
              - Latin
              result: Consume
          category_hotkeys:
            Hangul:
              # ControlR:
              #   behavior: !Mode Hanja
              #   result: Consume
              HangulHanja:
                behavior: !Mode Hanja
                result: Consume
              F9:
                behavior: !Mode Hanja
                result: ConsumeIfProcessed
          mode_hotkeys:
            Math:
              Enter:
                behavior: Commit
                result: ConsumeIfProcessed
              Tab:
                behavior: Commit
                result: ConsumeIfProcessed
            Hanja:
              Enter:
                behavior: Commit
                result: ConsumeIfProcessed
              Tab:
                behavior: Commit
                result: ConsumeIfProcessed
            Emoji:
              Enter:
                behavior: Commit
                result: ConsumeIfProcessed
              Tab:
                behavior: Commit
                result: ConsumeIfProcessed
          candidate_font: Noto Sans CJK KR
          xim_preedit_font:
          - Noto Sans CJK KR
          - 15.0
          latin:
            layout: Qwerty
            preferred_direct: true
          hangul:
            layout: dubeolsik
            word_commit: false
            preedit_johab: Needed
            addons:
              all: []
              # - ComposeChoseongSsang
              dubeolsik:
              - TreatJongseongAsChoseong
      '';
    };
  } else
    { });

  home.packages = with pkgs;
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
      fastfetch
      youtube-music
    ] ++ (if userConfig.system == "x86_64-darwin" || userConfig.system
    == "aarch64-darwin" then [
      # macOS-only packages
      iterm2
      karabiner-elements
      brave
      vscode
      slack
      discord
    ] else if userConfig.system == "x86_64-linux" || userConfig.system
    == "aarch64-linux" then [
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
    ] else
      [ ]);
}
