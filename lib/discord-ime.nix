{ pkgs, kimeGtk3Cache }:

if !pkgs.stdenv.hostPlatform.isLinux then
  pkgs.discord
else
  pkgs.symlinkJoin {
    name = "discord-kime-${pkgs.discord.version}";
    paths = [ pkgs.discord ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    inherit (pkgs.discord) meta;

    # Discord's Nix GTK cache does not include the kime module. Keep both
    # command aliases on the GTK3/XWayland path that supports composition.
    postBuild = ''
      rm "$out/bin/Discord" "$out/bin/discord"
      makeWrapper "${pkgs.discord}/bin/Discord" "$out/bin/Discord" \
        --set GTK_IM_MODULE kime \
        --set GTK_IM_MODULE_FILE "${kimeGtk3Cache}" \
        --set GDK_BACKEND x11 \
        --add-flags "--ozone-platform=x11 --gtk-version=3"
      ln -s Discord "$out/bin/discord"
    '';
  }
