{ pkgs, kimeGtk3Cache }:

if !pkgs.stdenv.hostPlatform.isLinux then
  pkgs.vscode
else
  pkgs.symlinkJoin {
    name = "vscode-kime-${pkgs.vscode.version}";
    paths = [ pkgs.vscode ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    inherit (pkgs.vscode) meta;

    # Use the Kime GTK3 module on XWayland for editor and terminal input.
    # Both desktop launchers and the shell resolve this code command.
    postBuild = ''
      rm "$out/bin/code"
      makeWrapper "${pkgs.vscode}/bin/code" "$out/bin/code" \
        --set GTK_IM_MODULE kime \
        --set GTK_IM_MODULE_FILE "${kimeGtk3Cache}" \
        --set GDK_BACKEND x11 \
        --add-flags "--ozone-platform=x11 --gtk-version=3"
    '';
  }
