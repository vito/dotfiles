{ config, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Fix broken GDM/Gnome on Framework
  boot.kernelPackages = pkgs.linuxPackages_5_18;

  # Fix brightness keys.
  boot.kernelParams = [ "module_blacklist=hid_sensor_hub" ];

  # Configure networking.
  networking.hostName = "nixwerk";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable fingerprint reader.
  services.fprintd.enable = true;

  # Font configuration.
  fonts.fonts = with pkgs; [
    iosevka

    # see https://typeof.net/Iosevka/customizer
    (iosevka.override {
      set = "term";
      privateBuildPlan = ''
        [buildPlans.iosevka-term]
        family = "Iosevka Term"
        spacing = "term"
        serifs = "sans"
        no-cv-ss = true
        export-glyph-names = false

          [buildPlans.iosevka-term.variants]
          inherits = "ss08"
      '';
    })
  ];
  fonts.enableDefaultFonts = true;
  fonts.fontconfig = {
    defaultFonts = {
      monospace = [ "Iosevka Term" ];
    };
  };

  # Enable Docker.
  virtualisation.docker.enable = true;

  # Enable fish system-wide so that it sources necessary files.
  programs.fish.enable = true;

  # My user account.
  users.users.vito = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.fish;
  };

  # Enable flakes and the new nix CLI.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
}

