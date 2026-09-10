{ inputs, config, lib, pkgs, userConfig, targets, ... }:

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

  # GTK from Nix cannot discover kime through the host distribution's cache.
  kimeGtk3Cache = pkgs.runCommand "kime-gtk3-immodules.cache" { } ''
    ${pkgs.gtk3.dev}/bin/gtk-query-immodules-3.0 \
      ${pkgs.kime}/lib/gtk-3.0/3.0.0/immodules/im-kime.so > "$out"
  '';

in {
  imports = [ inputs.youtube-music.homeManagerModules.default ./linux-desktop.nix ];

  programs.youtube-music = {
    enable = true;
    options = { tray = true; };
    plugins = {
      adblocker = { enabled = true; };
      bypass-age-restrictions = { enabled = true; };
      downloader = { enabled = true; };
      precise-volume = { enabled = true; };
      quality-changer = { enabled = true; };
      synced-lyrics = { enabled = true; };
      lyrics-genius = {
        enabled = true;
        romanizedLyrics = true;
      };
    };
  };

  home.username = userConfig.username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  targets.genericLinux.enable = true;
  # See https://discourse.nixos.org/t/kde-plasma-6-wont-show-applications-after-install-using-home-manager/40638/4
  home.activation.linkDesktopApplications = {
    after = [ "writeBoundary" "createXdgUserDirectories" ];
    before = [ ];
    data = ''
      rm -rf ${config.xdg.dataHome}/nix-desktop-files/applications
      mkdir -p ${config.xdg.dataHome}/nix-desktop-files/applications
      cp -Lr ${config.home.homeDirectory}/.nix-profile/share/applications/* ${config.xdg.dataHome}/nix-desktop-files/applications/
    '';
  };
  xdg.enable = true;
  xdg.systemDirs.data = [ "${config.xdg.dataHome}/nix-desktop-files" ];

  # Plasma starts applications through systemd, without sourcing shell profiles.
  systemd.user.sessionVariables = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    inherit (config.home.sessionVariables) GTK_IM_MODULE QT_IM_MODULE XMODIFIERS;
  };

  # KWin must launch the Wayland frontend itself to give it an input-method socket.
  # The Home Manager service continues to provide the indicator and XIM frontend.
  xdg.desktopEntries.kime = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    name = "kime daemon";
    exec = "${pkgs.kime}/bin/kime-wayland";
    icon = "kime-hangul-white";
    noDisplay = true;
    startupNotify = false;
    settings."X-KDE-Wayland-VirtualKeyboard" = "true";
  };

  home.activation.configureKimePlasma = lib.mkIf pkgs.stdenv.hostPlatform.isLinux
    (lib.hm.dag.entryAfter [ "installPackages" ] ''
      if [ "''${XDG_SESSION_TYPE:-}" = wayland ] && \
         [[ ":''${XDG_CURRENT_DESKTOP:-}:" == *:KDE:* ]]; then
        run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
          --file kwinrc --group Wayland --key InputMethod --notify \
          "${config.home.profileDirectory}/share/applications/kime.desktop"
      fi
    '');

  programs.brave = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isLinux then
      pkgs.brave.overrideAttrs (old: {
        preFixup = (old.preFixup or "") + ''
          gappsWrapperArgs+=(
            --set GTK_IM_MODULE kime
            --set GTK_IM_MODULE_FILE ${kimeGtk3Cache}
          )
        '';
      })
    else pkgs.brave;
    # kime 3.1.1 aborts on KWin's wl_keyboard.repeat_info event. Chromium's
    # current Wayland backend also bypasses GTK IMEs, so use GTK3 on XWayland.
    commandLineArgs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      "--ozone-platform=x11"
      "--gtk-version=3"
    ];
  };

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
      fastfetch
      curl
      wget
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
      net-tools
      awscli2
      yq-go
      jq
      tmux
      lsof
      kubernetes-helm
      zip
      unzip
      imgcat
      python3
      python3Packages.uv
      pyenv
      micromamba
      nixfmt
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
      vscode
      slack
      (import ./discord-ime.nix { inherit pkgs kimeGtk3Cache; })
      fastfetch
      flock
      ncdu
    ] ++ (if userConfig.system == "x86_64-darwin" || userConfig.system
    == "aarch64-darwin" then [
      # macOS-only packages
      iterm2
      karabiner-elements
    ] else if userConfig.system == "x86_64-linux" || userConfig.system
    == "aarch64-linux" then [
      # Linux-only packages
      chromium
      jetbrains.idea
      kime
      firefox
      xclip # Clipboard
      glibc
      playonlinux
      xrdp
      inputs.codex-desktop-linux.packages.${userConfig.system}.default
      tor-browser
    ] else
      [ ]);
}
