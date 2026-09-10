# ...s(3dots)

> Just build own dotfiles

## Install Nix

Install determinate systems nix

Use `install-determinate-nix.sh`

Or

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

- Download nix tar file & Make temp dir
- Make dir /nix
- Move to /nix
- Creating 32 build-user-group [Build user group?](https://nixos.org/manual/nix/stable/installation/multi-user#setting-up-the-build-users)
- Creating default nix profile
- Set flag experimental-feature to /etc/nix/nix.conf & Some others
- Setting shell profile
- Regist nix daemon to systemd
- Clean temp dir

## Make subshell

default

`❯ nix develop github:1eedaegon/...s`

language specific(e.g rust)

`❯ nix develop github:1eedaegon/...s#rust`

User globally

`❯ nix profile install github:1eedaegon/...s`

## Manage home-manager profile

### Install

It's able to add other user on flake.nix!

Change to your architecture from below command example.

`❯ nix profile install github:1eedaegon/...s.#legacyPackages.aarch64-darwin.homeConfigurations."1eedaegon".activationPackage`

### Upgrade

`❯ nix profile upgrade activationPackage`

### Remove

`❯ nix profile remove activationPackage`

## KDE on a non-NixOS Linux host

`lib/linux-desktop.nix` adds the Nix profile to Plasma's startup PATH and the
systemd user environment while keeping existing host commands first. It also
starts Pear Desktop through XWayland and isolates the distribution's Plasma
browser connector from the Qt libraries exported by Nix browsers.
`lib/discord-ime.nix` gives both Discord command aliases the kime GTK3 module
cache and XWayland settings, so Korean composition also works from KDE launchers.

After activating this configuration, log in again to refresh the desktop's
environment. An existing session can be refreshed without closing applications:

```sh
. "$HOME/.config/plasma-workspace/env/10-home-manager-path.sh"
dbus-update-activation-environment --systemd PATH
systemctl --user restart plasma-plasmashell.service
kbuildsycoca6 --noincremental
```

For `dps0340` on x86-64 Linux, the GPU configuration matches the CachyOS NVIDIA
driver. Run the `sudo /nix/store/.../bin/non-nixos-gpu-setup` command printed by
Home Manager after activation. This installs the libraries under
`/run/opengl-driver` and a tmpfiles rule that restores the link on boot; it does
not install a kernel driver. When CachyOS updates NVIDIA, update the version and
archive hash in `lib/linux-desktop.nix` to match, then activate and run the setup
command again. See the [Home Manager GPU instructions](https://github.com/nix-community/home-manager/blob/master/docs/manual/usage/gpu-non-nixos.md).

## Uninstall

1. Clean devshells

`❯ nix-collect-garbage`

2. Clean profile

`> nix profie remove --all`

3. Search profile

`❯ nix profile list`

```bash
❯ nix profile list
Name:               git+file:///Users/leedaegon/workspace/...s#packages.aarch64-darwin.default
Flake attribute:    packages.aarch64-darwin.default
Original flake URL: git+file:///Users/leedaegon/workspace/...s
Locked flake URL:   git+file:///Users/leedaegon/workspace/...s
Store paths:        /nix/store/ggcd2k0fxjnyfc0qvc3s9bnqdyshz7rx-default
...
# And other profiles...
```

Remove specific profile

`❯ nix profile remove [NAME]`

```bash

❯ nix profile remove git+file:///Users/leedaegon/workspace/...s#packages.aarch64-darwin.default

```
