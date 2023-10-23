# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.xremap-flake.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModprobeConfig = ''
    options snd slots=snd-hda-intel
  '';

  boot.supportedFilesystems = [ "ntfs" ];







  # key remapping
  services.xremap = {
    withHypr = true;
    userName = "ekstdolaptop1";
    yamlConfig = ''
    modmap:
      - name: main remaps
        remap: 
          CapsLock: Tab
          Tab: Delete
          Leftshift:
            held: Leftshift
            alone: Kpleftparen
            alone_timeout_millis: 150
          Rightshift:
            held: Rightshift
            alone: Kprightparen
            alone_timeout_millis: 150
    '';
  };
  hardware.uinput.enable = true;

  networking.hostName = "nikstdo"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "colemak";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ekstdolaptop1 = {
    isNormalUser = true;
    description = "Ekstdo Loi";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; let
      my-python-packages = (ps: with ps; [
        pandas
        requests
        pynvim
        numpy
        sympy
        seaborn
        matplotlib
        opencv4
        jupyterlab
        buildPythonPackage rec {
          pname = "bbot";
          version = "1.1.1";
          src = fetchPypi {
            inherit pname version;
            sha256 = "sha256-de6c7992c758506948becde4e730f5419063d9b39f871deb954114529bcbbc7a";
          };
        }
      ]);
      tex = (texlive.combine {
        inherit (texlive) scheme-full standalone;
      });
      python =
        let
          packageOverrides = self:
          super: {
            opencv4 = super.opencv4.overrideAttrs (old: rec {
              enableGtk2 = pkgs.gtk2 ; # pkgs.gtk2-x11 # pkgs.gnome2.gtk;
              # doCheck = false;
              });
          };
      in pkgs.python3.override {inherit packageOverrides; self = python3;}; in [
      firefox
      speechd
      kate
      thunderbird
      filezilla
      kitty
      wezterm
      flameshot
      tor-browser-bundle-bin
      libsForQt5.filelight
      libsForQt5.ktorrent
      libsForQt5.kasts
      libsForQt5.kitinerary
      libsForQt5.ktimer
      partition-manager
      audacity

      # design & drawing
      inkscape
      krita
      blender
      drawio
      obs-studio
      kdenlive
      gimp
      fontforge
      prusa-slicer
      digikam
      musescore
      rawtherapee
      godot_4
      lmms
      zynaddsubfx
      logseq


      # mobile and printing connection
      droidcam
      libsForQt5.kdeconnect-kde
      hplip

      # science & learning & office
      anki
      libreoffice-qt
      hunspell
      hunspellDicts.de_DE
      qgis
      marvin
      stellarium
      zotero
      tex
      xournalpp

      # social
      discord
      anydesk
      webcamoid
      telegram-desktop 
      signal-desktop
      lutris
      sgtpuzzles
      prismlauncher


      # password manager
      keepassxc
      git-credential-keepassxc
      syncthing

      # it sec
      wireshark
      sherlock
      metasploit
      cutter 
      cyberchef
      avalonia-ilspy
      social-engineer-toolkit
      aircrack-ng
      stegseek
      ffuf
      nmap
      sleuthkit
      whatweb
      theharvester
      ghidra-bin
      hashcat
      john
      (callPackage ./packages/common-password.nix {})

      # desktop customization
      eww
      swww
      rofi-wayland
      rofi-calc
      rofi-emoji
      dunst
      nerdfonts
      rstudio
      rPackages.IRkernel

      # dev
      tabnine
      jetbrains.idea-ultimate

      (python.withPackages my-python-packages)
      rPackages.IRkernel
    ];
  };
  users.groups.uinput.members = ["ekstdolaptop1"];
  users.groups.input.members = ["ekstdolaptop1"];

  programs.hyprland.enable = true;
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     home-manager
     wget
     git
     docker
     gdb
     pwndbg
     restic
     ffmpeg
     imagemagick
     gnumake
     linuxHeaders
     inxi
     psmisc
     zip
     fd
     unzip
     navi
     w3m
     macchanger
     openssl
	 zlib
     zoxide

     # development 
     neovim
     fzy
     ripgrep
     ripgrep-all
     opencv3
     libsForQt5.libqtav

     # emulation
     waydroid

     # important
     cmatrix

     # programming languages 
     gcc 
     idris2 
     elixir
     ghc
     dotnet-aspnetcore
     dotnet-sdk
     rustup
     nodejs
     octave
     julia
     powershell
     R

     pandoc
     typst
     
     # language servers 
     elixir-ls
     texlab
     lua-language-server
     typst-lsp

     libnotify
     wl-clipboard
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.sessionVariables = {
    # WLR_NO_HARDWARE_CURSORS = "1"; # enable if cursor invisible 
    NIXOS_OZONE_WL = "1";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  nix.gc = { # collecting garbage 
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}

# optimizing storage:
# nix-store --optimise 
# nix-store --gc
