{ config, pkgs, ... }:

let
  ## VIA https://nixos.wiki/wiki/Sway
  # bash script to let dbus know about important env variables and
  # propogate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but
  # also restarts  some user services to make sure they have the correct
  # environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  ## VIA https://nixos.wiki/wiki/Sway
  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Rose-Pine'
      '';
  };

  v4l2-webcam = pkgs.writeTextFile {
    name = "v4l2-webcam";
    destination = "/bin/v4l2-webcam";
    executable = true;
    text = ''
      ${pkgs.ffmpeg}/bin/ffmpeg -f v4l2 -i /dev/video1 -s:v 1280x720 -r 60 -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video0
    '';
  };
in
{
  imports = [
    ./modules/cursor.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Fix broken GDM/Gnome on Framework
  boot.kernelPackages = pkgs.linuxPackages_5_18;

  # Fix brightness keys.
  boot.kernelParams = [ "module_blacklist=hid_sensor_hub" ];

  # For v4l2-webcam, which is needed for my Opal C1.
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];

  # Configure networking.
  networking.hostName = "nixwerk";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  ## BEGIN Sway config

  environment.systemPackages = with pkgs; [
    wayland
    sway
    swayidle
    swaylock
    swaybg
    waybar
    wob # meters for brightness/volume
    dbus-sway-environment
    configure-gtk
    glib # gsettings
    alacritty
    rose-pine-gtk-theme # gtk theme
    gnome3.adwaita-icon-theme # default gnome cursors
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    bemenu # wayland clone of dmenu
    mako # notification system developed by swaywm maintainer
    pulseaudio # until pw-cli has commands for volume control
    v4l2-webcam # for making my Opal C1 webcam available via v4l2loopback
  ];
  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && sway
  '';

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    gtkUsePortal = true;
  };

  # enable sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # brightness control
  programs.light.enable = true;

  ## END Sway config

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable fingerprint reader.
  services.fprintd.enable = true;

  # For corefonts
  nixpkgs.config.allowUnfree = true;

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

    font-awesome # for waybar
    corefonts # common Microsoft fonts
  ];
  fonts.enableDefaultFonts = true;
  fonts.fontconfig = {
    defaultFonts = {
      monospace = [ "Iosevka Term" ];
    };
    localConf = ''
      <?xml version='1.0'?>
      <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
      <fontconfig>
        <match target="font">
          <edit mode="assign" name="rgba">
            <const>rgb</const>
          </edit>
        </match>
        <match target="font">
          <edit mode="assign" name="hinting">
            <bool>true</bool>
          </edit>
        </match>
        <match target="font">
          <edit mode="assign" name="hintstyle">
            <const>hintslight</const>
          </edit>
        </match>
        <match target="font">
          <edit mode="assign" name="antialias">
            <bool>true</bool>
          </edit>
        </match>
        <match target="font">
          <edit mode="assign" name="lcdfilter">
            <const>lcddefault</const>
          </edit>
        </match>
      </fontconfig>
    '';
  };

  # Enable Docker.
  virtualisation.docker.enable = true;

  # Enable fish system-wide so that it sources necessary files.
  programs.fish.enable = true;

  # My user account.
  users.users.vito = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "networkmanager" "docker" ];
    shell = pkgs.fish;
  };

  # Enable flakes and the new nix CLI.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Set the default mouse cursor theme for Alacritty etc.
  environment.defaultCursor.enable = true;
  environment.defaultCursor.theme = "Adwaita";
}
