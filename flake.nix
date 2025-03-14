# flake.nix
{
  description = "gg";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };
  # TODO: Define packages and apps for default environment
  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
     flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
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
        commonShellHooks = import ./lib/common-shell-hook.nix { inherit pkgs; };

        # Not yet: https://github.com/NixOS/nix/pull/8901 
        # ++ (if stdenv.isWindows then [ chocolatey ] else []);
        
        # CLI 바이너리 처리
        # myCliBinary = import ./cli-derivation.nix { inherit pkgs system; };
        # hasBinary = myCliBinary ? package && myCliBinary.package != null;
        # cliBinary = if hasBinary then [ myCliBinary.package ] else [];
        
        # Rust dev latest
        rustLatest = pkgs.mkShell {
          name = "rust";
          buildInputs = with pkgs; [
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
          ] ++ commonPkgs;
          
          shellHook = ''
            ${commonShellHooks}
            # Log level
            declare -x name="rust"
            export RUST_BACKTRACE=1
            export RUST_LOG=debug
            
            # Cargo cache
            export CARGO_HOME="$HOME/.cargo"
            mkdir -p $CARGO_HOME
            
            # Cargo alias
            alias cb='cargo build'
            alias ct='cargo test'
            alias cr='cargo run'
          '';
        } ;
        
        # Rust 1.70.0
        rust_1_70_0 = pkgs.mkShell {
          name = "rust-1.70.0";
          buildInputs = with pkgs; [
            (rust-bin.stable."1.70.0".default.override {
              extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
            })
            pkg-config
            openssl.dev
            libiconv
            cargo-edit
            cargo-watch
            cargo-expand
            lldb
          ] ++ commonPkgs;
          
          shellHook = commonShellHooks + ''
            # Rust 로그
            export RUST_BACKTRACE=1
            export RUST_LOG=debug
            
            # Cargo 캐시
            export CARGO_HOME="$HOME/.cargo"
            mkdir -p $CARGO_HOME
            
            # Cargo alias
            alias cb='cargo build'
            alias ct='cargo test'
            alias cr='cargo run'
          '';
        };
        
        # Go Dev
        goLatest = pkgs.mkShell {
          name = "go";
          buildInputs = with pkgs; [
            go
            gopls
            gotools
            go-outline
            gopkgs
            godef
            golint
          ] ++ commonPkgs;
        
          shellHook = commonShellHooks + ''
            # Go 환경 설정
            export GOPATH="$HOME/go"
            export PATH="$GOPATH/bin:$PATH"
            mkdir -p $GOPATH
          '';
        };
        

        # Default, 
        devShell = pkgs.mkShell {
          name = "dev";
          buildInputs = 
            rustLatest.buildInputs ++ 
            goLatest.buildInputs;
          
          shellHook = commonShellHooks+ ''
            echo "Develop in cycle"
            ${rustLatest.shellHook}
            ${goLatest.shellHook}
          '';
        };
      
      in {
        devShells = {
          default = devShell;
          dev = devShell;
          rust = rustLatest;
          rust170 = rust_1_70_0;
          go = goLatest;
        };
      }
    );
}