# flake.nix
{
  description = "...s(3dots) with nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wiremix = {
      url = "github:tsowell/wiremix";
      flake = true;
    };
    youtube-music = {
      url = "github:h-banii/youtube-music-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, flake-utils, rust-overlay, home-manager
    , wiremix, youtube-music, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        baseOverlays = [ (import rust-overlay) ];
        # See https://discourse.nixos.org/t/ibus-not-working-with-electron-apps/64128/12
        # And https://discourse.nixos.org/t/partly-overriding-a-desktop-entry/20743/2
        overlays = baseOverlays
          ++ (if system == "x86_64-linux" || system == "aarch64-linux" then
            [
              (final: prev: {
                google-chrome = prev.google-chrome.override {
                  commandLineArgs =
                    "--ozone-platform-hint=auto --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3";
                };
                brave = prev.brave.override {
                  commandLineArgs =
                    "--ozone-platform-hint=auto --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3";
                };
                vscode = prev.vscode.override {
                  commandLineArgs =
                    "--ozone-platform-hint=auto --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3";
                };
                slack = pkgs.symlinkJoin {
                  name = prev.slack.name;
                  paths = [ prev.slack ];
                  buildInputs = [ pkgs.makeWrapper ];
                  postBuild = ''
                    wrapProgram $out/bin/slack \
                      --add-flags "--ozone-platform-hint=auto --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3"
                  '';
                };
                discord = pkgs.symlinkJoin {
                  name = prev.discord.name;
                  paths = [ prev.discord ];
                  buildInputs = [ pkgs.makeWrapper ];
                  postBuild = ''
                    wrapProgram $out/bin/discord \
                      --add-flags "--ozone-platform-hint=auto --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3"
                  '';
                };
                obsidian = pkgs.symlinkJoin {
                  name = prev.obsidian.name;
                  paths = [ prev.obsidian ];
                  buildInputs = [ pkgs.makeWrapper ];
                  postBuild = ''
                    wrapProgram $out/bin/obsidian \
                      --add-flags "--ozone-platform-hint=auto --enable-wayland-ime --enable-features=TouchpadOverscrollHistoryNavigation --wayland-text-input-version=3"
                  '';
                };
              })
            ]
          else
            [ ]);
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };

        commonPkgs = with pkgs; [
          nerd-fonts.symbols-only
          nerd-fonts.fira-code
          starship
          bat
          git
          curl
          asciinema
          emacs
          xorg.xeyes
        ];

        commonShellHooks =
          import ./lib/common-shell-hook.nix { inherit pkgs system; };

        # Default environment definition
        defaultEnv = {
          name = "default";
          pkgList = with pkgs;
            [
              nerd-fonts.symbols-only
              nerd-fonts.fira-code
              starship
              bat
              git
              htop
              curl
              asciinema
              fontconfig
              direnv
              gcc
              gnumake
            ]
            ++ (if system == "x86_64-darwin" || system == "aarch64-darwin" then
              [
                # macOS-only packages
                coreutils
                # (import ./lib/iterm2-settings.nix { inherit pkgs system; })
              ]
            else if system == "x86_64-linux" || system == "aarch64-linux" then
              [
                # Linux-only packages
                systemd
              ]
            else
              [ ]);
          shell = commonShellHooks;
        };

        mkEnv = { name, pkgList ? [ ], shell ? "", combine ? [ ], }:
          let
            # Combine Pkgs
            combinedPkgList = if combine != [ ] then
              pkgList ++ builtins.concatMap (env: env.pkgList) combine
            else
              pkgList;

            # Combine Shell
            combinedShell = if combine != [ ] then
              shell + builtins.concatStringsSep "\n"
              (builtins.map (env: env.shell) combine)
            else
              shell;
          in {
            inherit name;
            pkgList = combinedPkgList;
            shell = combinedShell;

            # Generate buildEnv and mkShell
            toOutputs = baseEnv: {
              packages = {
                "${name}" = pkgs.buildEnv {
                  name = "${name}";
                  paths = combinedPkgList;
                };
              };
              devShells = {
                "${name}" = pkgs.mkShell {
                  name = "${name}";
                  buildInputs = combinedPkgList ++ baseEnv.pkgList;
                  shellHook = baseEnv.shell + combinedShell;
                };
              };
            };
          };

        environments = {
          default = defaultEnv // {
            toOutputs = _: {
              packages = {
                "default" = pkgs.buildEnv {
                  name = "default";
                  paths = defaultEnv.pkgList;
                };
              };
              devShells = {
                "default" = pkgs.mkShell {
                  name = "default";
                  buildInputs = defaultEnv.pkgList;
                  shellHook = defaultEnv.shell;
                };
              };
            };
          };

          # Rust
          rust = mkEnv {
            name = "rust";
            pkgList = with pkgs; [
              (rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
              })
              pkg-config
              openssl.dev
              libiconv
              cargo-edit
              cargo-watch
              cargo-expand
              lldb
            ];
            shell = ''
              echo "Enabled[Rust]: $(rustc --version)"
              export RUST_BACKTRACE=1
              export RUST_LOG=debug
              export CARGO_HOME="$HOME/.cargo"
              mkdir -p $CARGO_HOME
              alias cb='cargo build'
              alias ct='cargo test'
              alias cr='cargo run'
            '';
          };

          # Go

          go = mkEnv {
            name = "go";
            pkgList = with pkgs; [
              go
              gopls
              gotools
              go-outline
              gopkgs
              godef
              golint
              golangci-lint
              gotestsum
              protobuf
              protoc-gen-go
              protoc-gen-go-grpc
              kind
            ];
            shell = ''
              echo "Enabled[Golang]: $(go version)"
              export GOPATH="$HOME/go"
              export PATH="$GOPATH/bin:$PATH"
              mkdir -p $GOPATH
            '';
          };

          # Python
          # TODO: UV가 대신해줄 수 있을것같다.
          py = mkEnv {
            name = "py";
            pkgList = with pkgs; [
              uv
              python3
              python3Packages.pip
              python3Packages.ipython
              python3Packages.black
              python3Packages.pylint
            ];
            shell = ''
              echo "Enabled[Python(uv)]: $(uv --version)"
              export PYTHONPATH="$PWD:$PYTHONPATH"
            '';
          };

          dev = mkEnv {
            name = "dev";
            shell = ''
              echo "###############"
              echo "# DEV Enabled #"
              echo "###############"
              echo "               "
            '';
            combine = [ environments.py environments.go environments.rust ];
          };
        };

        # Generate outputs for all environments
        allOutputs =
          builtins.mapAttrs (name: env: env.toOutputs defaultEnv) environments;

        # packages and devShells merge
        mergeOutputsBy = attr:
          builtins.foldl' (acc: outputs: acc // outputs.${attr}) { }
          (builtins.attrValues allOutputs);

      in {
        packages = mergeOutputsBy "packages";
        devShells = mergeOutputsBy "devShells";
        home-manager = {
          useUserPackages = true;
          useGlobalPkgs = true;
        };
        legacyPackages = {
          # See https://www.chrisportela.com/posts/home-manager-flake/
          homeConfigurations = builtins.listToAttrs (builtins.map (username: {
            name = username;
            value = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;

              extraSpecialArgs = {
                userConfig = {
                  inherit system;
                  inherit username;
                };
                extraPackages = {
                  inherit wiremix;
                  inherit youtube-music;
                };
              };

              modules = [ ./lib/home.nix ];
            };
          }) [ "1eedaegon" "dps0340" ]);
          darwinConfigurations = builtins.listToAttrs (builtins.map (username: {
            name = username;
            value = nix-darwin.lib.darwinSystem {
              system = system;
              # See https://github.com/nix-darwin/nix-darwin/issues/1045
              pkgs = import nixpkgs {
                inherit system overlays;
                config.allowUnfree = true;
              };
              modules = [
                ./lib/darwin-settings.nix
                home-manager.darwinModules.home-manager
                {
                  # See https://github.com/nix-community/home-manager/issues/6036#issuecomment-2466986456
                  users = {
                    users.${username} = {
                      name = username;
                      home = "/Users/${username}";
                    };
                  };
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;

                    users.${username} = ./lib/home.nix;

                    # Optionally, use home-manager.extraSpecialArgs to pass
                    # arguments to home.nix
                    extraSpecialArgs = {
                      userConfig = {
                        inherit system;
                        inherit username;
                      };
                    };
                  };
                }
              ];
            };
          }) [ "1eedaegon" "lee" ]);
        };
      });
}
