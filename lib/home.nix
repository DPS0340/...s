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

  i18n = (if userConfig.system == "x86_64-linux" || userConfig.system == "aarch64-linux" then
    {
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
      ghidra-bin
    ]
    ++ (
      if userConfig.system == "x86_64-darwin" || userConfig.system == "aarch64-darwin" then
        [
          # macOS-only packages
          iterm2
          karabiner-elements
        ]
      else if userConfig.system == "x86_64-linux" || userConfig.system == "aarch64-linux" then
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
          xrdp
        ]
      else
        [ ]
    );
}
