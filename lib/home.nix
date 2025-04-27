{ config, pkgs, userConfig, ... }:

{
  home.username = userConfig.username;
  home.homeDirectory = (if userConfig.system == "x86_64-darwin" || userConfig.system == "aarch64-darwin" then "/Users/${userConfig.username}"
    else if userConfig.system == "x86_64-linux" || userConfig.system == "aarch64-linux" then "/home/${userConfig.username}"
    # Assuming windows based system
    else "C:\\Users\\${userConfig.username}");
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;  # 폰트 설정 활성화
  home.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
	coreutils-full
	terraform
	openssh
	ansible
	fira-code
	zsh
	zplug
	neovim
	neovide
	tldr
	gh
	bat
	neofetch
	curl
	wget
	thefuck
	nodejs
	gcc
	glibc
	libiconv
	fzf
	gnupg
	go
	obsidian
	kubectl
	kubectx
	rustc
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
	python3
	direnv
	opentofu
    zoxide
	htop
	slack
	playonlinux
	pure-prompt
	libxcrypt
	brave
    kubetail
  ] ++ (if system == "x86_64-darwin" || system == "aarch64-darwin" then [
        # macOS-only packages
        iterm2
        karabiner-elements 
      ] else if system == "x86_64-linux" || system == "aarch64-linux" then [
        # Linux-only packages
        chromium
        jetbrains.idea-ultimate
        kime
        google-chrome
        firefox
        xclip # Clipboard
      ] else []);
}
