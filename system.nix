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
in
{
  imports = [
    <nixos-hardware/framework/12th-gen-intel>
    ./modules/cursor.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Fix broken GDM/Gnome on Framework
  boot.kernelPackages = pkgs.linuxPackages_6_1;

  # Fix brightness keys.
  boot.kernelParams = [ "module_blacklist=hid_sensor_hub" ];

  # Configure networking.
  networking.hostName = "nixwerk";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Enable updating firmware.
  services.fwupd.enable = true;

  # Enable accelerated video playback.
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

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

  networking.firewall.enable = false;

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

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "vito" ];

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

    (stdenv.mkDerivation {
      pname = "symbols-nerd-font";
      version = "2.2.0";
      src = fetchFromGitHub {
        owner = "ryanoasis";
        repo = "nerd-fonts";
        rev = "bde5c7def1775de187aae810e08d28a804e676da";
        sha256 = "nvqtakqdhzmBbycNGjSOki+my1/58PozDzJa9jcIvtU=";
        sparseCheckout = ''
          10-nerd-font-symbols.conf
          patched-fonts/NerdFontsSymbolsOnly
        '';
      };
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        runHook preInstall

        fontconfigdir="$out/etc/fonts/conf.d"
        install -d "$fontconfigdir"
        install 10-nerd-font-symbols.conf "$fontconfigdir"

        fontdir="$out/share/fonts/truetype"
        install -d "$fontdir"
        install "patched-fonts/NerdFontsSymbolsOnly/complete/Symbols-2048-em Nerd Font Complete.ttf" "$fontdir"

        runHook postInstall
      '';
      enableParallelBuilding = true;
    })
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

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # needed for store VS Code auth token
  services.gnome.gnome-keyring.enable = true;

  security.apparmor.enable = true;
  security.apparmor.policies = {
    "usr.sbin.dnsmasq".profile = ''
      # ------------------------------------------------------------------
      #
      #    Copyright (C) 2009 John Dong <jdong@ubuntu.com>
      #    Copyright (C) 2010 Canonical Ltd.
      #
      #    This program is free software; you can redistribute it and/or
      #    modify it under the terms of version 2 of the GNU General Public
      #    License published by the Free Software Foundation.
      #
      # ------------------------------------------------------------------

      abi <abi/3.0>,

      @{TFTP_DIR}=/var/tftp /srv/tftp /srv/tftpboot

      include <tunables/global>
      profile dnsmasq /usr/{bin,sbin}/dnsmasq flags=(attach_disconnected) {
        include <abstractions/base>
        include <abstractions/dbus>
        include <abstractions/nameservice>

        capability chown,
        capability net_bind_service,
        capability setgid,
        capability setuid,
        capability dac_override,
        capability net_admin,         # for DHCP server
        capability net_raw,           # for DHCP server ping checks
        network inet raw,
        network inet6 raw,

        signal (receive) peer=/usr/{bin,sbin}/libvirtd,
        signal (receive) peer=libvirtd,
        ptrace (readby) peer=/usr/{bin,sbin}/libvirtd,
        ptrace (readby) peer=libvirtd,

        owner /dev/tty rw,

        @{PROC}/@{pid}/fd/ r,

        /etc/dnsmasq.conf r,
        /etc/dnsmasq.d/ r,
        /etc/dnsmasq.d/* r,
        /etc/dnsmasq.d-available/ r,
        /etc/dnsmasq.d-available/* r,
        /etc/ethers r,
        /etc/NetworkManager/dnsmasq.d/ r,
        /etc/NetworkManager/dnsmasq.d/* r,
        /etc/NetworkManager/dnsmasq-shared.d/ r,
        /etc/NetworkManager/dnsmasq-shared.d/* r,
        /etc/dnsmasq-conf.conf r,
        /etc/dnsmasq-resolv.conf r,

        /usr/{bin,sbin}/dnsmasq mr,

        /var/log/dnsmasq*.log w,

        /usr/share/dnsmasq{-base,}/ r,
        /usr/share/dnsmasq{-base,}/* r,

        @{run}/*dnsmasq*.pid w,
        @{run}/dnsmasq-forwarders.conf r,
        @{run}/dnsmasq/ r,
        @{run}/dnsmasq/* rw,

        /var/lib/misc/dnsmasq.leases rw, # Required only for DHCP server usage

        /{,usr/}bin/{ba,da,}sh ix, # Required to execute --dhcp-script argument

        # access to iface mtu needed for Router Advertisement messages in IPv6
        # Neighbor Discovery protocol (RFC 2461)
        @{PROC}/sys/net/ipv6/conf/*/mtu r,

        # for the read-only TFTP server
        @{TFTP_DIR}/ r,
        @{TFTP_DIR}/** r,

        # libvirt config and hosts file for dnsmasq
        /var/lib/libvirt/dnsmasq/          r,
        /var/lib/libvirt/dnsmasq/*         r,

        # libvirt pid files for dnsmasq
        @{run}/libvirt/network/      r,
        @{run}/libvirt/network/*.pid rw,

        # libvirt lease helper
        /usr/lib{,64}/libvirt/libvirt_leaseshelper Cx -> libvirt_leaseshelper,
        /usr/libexec/libvirt_leaseshelper Cx -> libvirt_leaseshelper,

        # lxc-net pid and lease files
        @{run}/lxc/dnsmasq.pid    rw,
        /var/lib/misc/dnsmasq.*.leases rw,

        # lxd-bridge pid and lease files
        @{run}/lxd-bridge/dnsmasq.pid   rw,
        /var/lib/lxd-bridge/dnsmasq.*.leases rw,
        /var/lib/lxd/networks/*/dnsmasq.* r,
        /var/lib/lxd/networks/*/dnsmasq.leases rw,
        /var/lib/lxd/networks/*/dnsmasq.pid rw,

        # NetworkManager integration
        /var/lib/NetworkManager/dnsmasq-*.leases rw,
        @{run}/nm-dns-dnsmasq.conf r,
        @{run}/nm-dnsmasq-*.pid rw,
        @{run}/sendsigs.omit.d/*dnsmasq.pid w,
        @{run}/NetworkManager/dnsmasq.conf r,
        @{run}/NetworkManager/dnsmasq.pid w,
        @{run}/NetworkManager/NetworkManager.pid w,

        # dnsname plugin in podman
        @{run}/containers/cni/dnsname/*/dnsmasq.conf r,
        @{run}/containers/cni/dnsname/*/addnhosts r,
        @{run}/containers/cni/dnsname/*/pidfile rw,
        owner @{run}/user/*/containers/cni/dnsname/*/dnsmasq.conf r,
        owner @{run}/user/*/containers/cni/dnsname/*/addnhosts r,
        owner @{run}/user/*/containers/cni/dnsname/*/pidfile rw,

        # waydroid lxc-net pid file
        @{run}/waydroid-lxc/dnsmasq.pid rw,

        profile libvirt_leaseshelper {
          include <abstractions/base>

          /etc/libnl-3/classid r,

          /usr/lib{,64}/libvirt/libvirt_leaseshelper mr,
          /usr/libexec/libvirt_leaseshelper mr,

          owner @{PROC}/@{pid}/net/psched r,

          @{sys}/devices/system/node/ r,
          @{sys}/devices/system/node/*/meminfo r,

          # libvirt lease and status files for dnsmasq
          /var/lib/libvirt/dnsmasq/*.leases  rw,
          /var/lib/libvirt/dnsmasq/*.status* rw,

          @{run}/leaseshelper.pid rwk,
        }

        # Site-specific additions and overrides. See local/README for details.
        include if exists <local/usr.sbin.dnsmasq>
      }
    '';
  };
}
