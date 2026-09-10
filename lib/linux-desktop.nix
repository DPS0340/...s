{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  profileBin = "${config.home.profileDirectory}/bin";
  daemonBin = "/nix/var/nix/profiles/default/bin";

  # A Nix browser exports its Qt libraries to native messaging subprocesses.
  # The distribution's Plasma connector must load the distribution's libraries.
  plasmaBrowserHost = pkgs.writeShellScript "plasma-browser-integration-host" ''
    unset LD_LIBRARY_PATH LD_PRELOAD QT_PLUGIN_PATH QT_QPA_PLATFORM_PLUGIN_PATH
    unset QML_IMPORT_PATH QML2_IMPORT_PATH
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/bin
    exec /usr/bin/plasma-browser-integration-host "$@"
  '';

  nativeMessagingManifest = builtins.toJSON {
    name = "org.kde.plasma.browser_integration";
    description = "Native connector for KDE Plasma";
    path = toString plasmaBrowserHost;
    type = "stdio";
    allowed_origins = [
      "chrome-extension://cimiefiiaegbelhefglklhhakcgmhkai/"
      "chrome-extension://dnnckbejblnejeabhcmhklcaljjpdjeh/"
    ];
  };
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    # This CachyOS host uses the matching NVIDIA kernel driver. Update these
    # together with nvidia-utils, then rerun non-nixos-gpu-setup as root.
    targets.genericLinux.gpu =
      lib.mkIf (config.home.username == "dps0340" && pkgs.stdenv.hostPlatform.system == "x86_64-linux")
        {
          packages = import pkgs.path {
            inherit (pkgs.stdenv.hostPlatform) system;
            config = pkgs.config // {
              nvidia.acceptLicense = true;
            };
          };
          nvidia = {
            enable = true;
            version = "610.57.04";
            sha256 = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
          };
        };

    # On Plasma, Electron 43 can stay running without presenting a Wayland
    # window. Apply the working XWayland backend to both menu and CLI launches.
    programs.pear-desktop.package = pkgs.symlinkJoin {
      name = "pear-desktop-plasma";
      paths = [ options.programs.pear-desktop.package.default ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/pear-desktop" --add-flags "--ozone-platform=x11"
      '';
    };

    # Keep host utilities and ~/.local/bin wrappers first. Plasma does not read
    # interactive shell startup files, and it overwrites systemd's initial PATH.
    xdg.configFile = {
      "plasma-workspace/env/10-home-manager-path.sh".text = ''
        # Sourced by startplasma before launching the desktop session.
        case ":$PATH:" in
          *:"${profileBin}":*) ;;
          *) PATH="''${PATH:+$PATH:}${profileBin}" ;;
        esac
        case ":$PATH:" in
          *:"${daemonBin}":*) ;;
          *) PATH="''${PATH:+$PATH:}${daemonBin}" ;;
        esac
        export PATH
      '';
    }
    //
      lib.genAttrs
        (map (profile: "${profile}/NativeMessagingHosts/org.kde.plasma.browser_integration.json") [
          "BraveSoftware/Brave-Browser"
          "chromium"
          "google-chrome"
        ])
        (_: {
          text = nativeMessagingManifest;
        });

    # Also cover applications activated directly by the user service manager.
    systemd.user.sessionVariables.PATH = "$PATH:${profileBin}:${daemonBin}";

  };
}
