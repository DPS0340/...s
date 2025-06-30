{
  config,
  pkgs,
  specialArgs,
  lib,
  inputs,
  ...
}:

# Original code from https://github.com/nix-darwin/nix-darwin/blob/master/modules/examples/simple.nix
{
  # See https://github.com/nix-darwin/nix-darwin?tab=readme-ov-file#prerequisites
  nix.enable = false;
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ ];

  homebrew.enable = true;
  homebrew.brews = [
    "openldap"
    "argon2"
    "e2fsprogs"
  ];
  homebrew.casks = [
    "orbstack"
    "macfuse"
    "onedrive"
    "wireshark"
  ];

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
