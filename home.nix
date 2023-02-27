{ config, pkgs, lib, ... }:

let
  ws1 = "1: werk";
  ws2 = "2: web";
  ws3 = "3: chat";
  ws4 = "4: notes";
  ws5 = "5: music";

  # Rose Pine
  base00 = "#191724";
  base01 = "#1f1d2e";
  base02 = "#26233a";
  base03 = "#555169";
  base04 = "#6e6a86";
  base05 = "#e0def4";
  base06 = "#f0f0f3";
  base07 = "#c5c3ce";
  base08 = "#eb6f92";
  base09 = "#f6c177";
  base0A = "#f6c177";
  base0B = "#31748f";
  base0C = "#ebbcba";
  base0D = "#9ccfd8";
  base0E = "#c4a7e7";
  base0F = "#e5e5e5";
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "vito";
  home.homeDirectory = "/home/vito";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # For 1password.
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # gui
    _1password
    _1password-gui
    (discord.override { nss = nss_latest; }) # override fixes links
    firefox-wayland
    signal-desktop
    spotify
    pavucontrol
    vlc
    google-chrome

    # misc shell utils
    ripgrep
    jq
    fzf
    wget
    htop
    lsof
    unzip
    bc
    gnumake
    ngrok
    sqlite

    # screenshots
    slurp
    grim

    ## languages & lsps for editing non-flake'd projects
    # go
    go_1_20
    gopls
    gotools
    gcc
    # nix
    rnix-lsp
    nixpkgs-fmt
    # js/ts
    # typescript itself needs to be in each project(?!)
    nodePackages.typescript-language-server
    nodePackages.pnpm
    # github copilot
    nodejs-16_x
    # for compiling neovim grammars with TSInstall
    tree-sitter

    # necessary for discord et al. to be able to open links
    xdg-utils
  ];

  # Configure git aliases and such.
  programs.git = {
    enable = true;
    userName = "Alex Suraci";
    userEmail = "suraci.alex@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      st = "status";
    };
    extraConfig = {
      push = {
        default = "simple";
      };
      url = {
        "git@github.com:" = {
          pushInsteadOf = "https://github.com/";
        };
      };
      trailer = {
        ifexists = "addIfDifferent";
      };
    };
  };

  # Configure SSH key commit signing.
  programs.git.extraConfig.gpg.format = "ssh";
  programs.git.extraConfig.gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
  programs.git.extraConfig.user.signingkey = "~/.ssh/id_ecdsa.pub";
  programs.git.signing.key = null;
  programs.git.signing.signByDefault = true;
  home.file.".ssh/allowed_signers".text =
    "* ${builtins.readFile /home/vito/.ssh/id_ecdsa.pub}";

  # Configure Fish, which is already installed system-wide but needs to be
  # enabled for these local configs to be respected.
  programs.fish.enable = true;
  programs.fish.shellAliases = {
    gst = "git status";
    gs = "git status"; # i have never ever wanted to run ghostscript
  };
  programs.fish.plugins = [
    {
      name = "pure";
      src = pkgs.fetchFromGitHub {
        owner = "pure-fish";
        repo = "pure";
        rev = "2d07e74567e9190c82ae66c37c34ca86850cd9ac";
        sha256 = "sha256-F6IywGT50/2QHZPJejelhyAC+sU8hUw+pQKbZVIv7lo=";
      };
    }
    {
      name = "base16";
      src = pkgs.fetchFromGitHub {
        owner = "vito";
        repo = "base16-fish";
        rev = "771ad22aff852be86fdbb8ca56f856f1134726b9";
        sha256 = "sha256-0oJxrIjD1XZd349b4R6xIVvtrB9aXQEEvMG4mN8lTqU=";
      };
    }
  ];

  programs.direnv.enable = true;

  # For Neovim fzf.
  programs.fzf.enable = true;
  programs.fzf.defaultOptions = [ "--color 16" ];
  programs.bat.enable = true;
  programs.bat.config = { theme = "base16-256"; };

  programs.neovim.enable = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.vimdiffAlias = true;
  programs.neovim.plugins =
    let
      ts = pkgs.tree-sitter.override
        {
          extraGrammars = {
            tree-sitter-bass = {
              src = _: ~/src/tree-sitter-bass;
            };
          };
        };
    in
    with pkgs.vimPlugins; [
      (ts.withPlugins (_: ts.allGrammars))
      markdown-preview-nvim
      copilot-vim
    ];

  home.sessionVariables.EDITOR = "vim";
  home.sessionVariables.DO_NOT_TRACK = "1";
  home.sessionVariables.GOTESTSUM_FORMAT = "dots";

  xdg.configFile."nvim" = {
    source = ~/src/nvim;
    /* pkgs.fetchFromGitHub { */
    /*   owner = "vito"; */
    /*   repo = "dot-nvim"; */
    /*   rev = "0404651cecea87726304912d6e8ff6a195839f68"; */
    /*   sha256 = "sha256-qE8beeAIw0o9YrorjKbC9SknSoF/jcziMKpCIVYRqgs="; */
    /* }; */
    recursive = true;
  };

  wayland.windowManager.sway.enable = true;
  wayland.windowManager.sway.config.assigns = {
    "2: web" = [{ app_id = "firefox"; }];
  };
  wayland.windowManager.sway.config.input = {
    "type:touchpad" = {
      scroll_factor = "0.76";
      natural_scroll = "enabled";
      tap = "enabled";
      tap_button_map = "lrm";
      accel_profile = "adaptive";
    };
  };
  wayland.windowManager.sway.config.fonts = {
    names = [ "Iosevka Term" ];
    style = "Bold";
    size = 12.0;
  };
  wayland.windowManager.sway.config.workspaceAutoBackAndForth = true;
  wayland.windowManager.sway.config.modifier = "Mod4";
  wayland.windowManager.sway.config.menu = "${pkgs.bemenu}/bin/bemenu-run -p run -c -B 3 -W 0.8 --fn 'Iosevka Term 18' --hp 5 --bdr '${base0E}' --tb '${base00}' --tf '${base0E}' --fb '${base00}' --ff '${base05}' --nb '${base00}' --ab '${base00}' --hb '${base0E}' --hf '${base00}' | ${pkgs.findutils}/bin/xargs ${pkgs.sway}/bin/swaymsg exec --";
  wayland.windowManager.sway.config.terminal = "${pkgs.alacritty}/bin/alacritty";
  wayland.windowManager.sway.config.gaps = {
    inner = 5;
    smartGaps = true;
  };
  wayland.windowManager.sway.config.keybindings =
    let
      mod = config.wayland.windowManager.sway.config.modifier;
      menu = config.wayland.windowManager.sway.config.menu;
      term = config.wayland.windowManager.sway.config.terminal;
    in
    lib.mkOptionDefault {
      "${mod}+Return" = "exec ${term}";
      "${mod}+Shift+q" = "kill";
      "${mod}+d" = "exec ${menu}";
      "${mod}+Shift+r" = "reload";
      "${mod}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

      # Screenshot
      "Print" = "exec 'grim -g \"$(slurp -b \"${base00}80\" -c \"${base0C}\")\" - | wl-copy'";

      # Brightness
      "XF86MonBrightnessDown" = "exec light -U 10";
      "XF86MonBrightnessUp" = "exec light -A 10";

      # Volume
      "XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +5%'";
      "XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -5%'";
      "XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";

      # Media
      "XF86AudioPlay" = "exec 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause'";
      "XF86AudioPause" = "exec 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause'";
      "XF86AudioPrev" = "exec 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous'";
      "XF86AudioNext" = "exec 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next'";

      # Moving windows/focus around
      "${mod}+Left" = "focus left";
      "${mod}+Shift+Left" = "move left";
      "${mod}+Right" = "focus right";
      "${mod}+Shift+Right" = "move right";
      "${mod}+Up" = "focus up";
      "${mod}+Shift+Up" = "move up";
      "${mod}+Down" = "focus down";
      "${mod}+Shift+Down" = "move down";

      # Move between workspaces
      "${mod}+1" = "workspace ${ws1}";
      "${mod}+Shift+1" = "move container to workspace ${ws1}";
      "${mod}+2" = "workspace ${ws2}";
      "${mod}+Shift+2" = "move container to workspace ${ws2}";
      "${mod}+3" = "workspace ${ws3}";
      "${mod}+Shift+3" = "move container to workspace ${ws3}";
      "${mod}+4" = "workspace ${ws4}";
      "${mod}+Shift+4" = "move container to workspace ${ws4}";
      "${mod}+5" = "workspace ${ws5}";
      "${mod}+Shift+5" = "move container to workspace ${ws5}";
      "${mod}+6" = "workspace 6";
      "${mod}+Shift+6" = "move container to workspace 6";
      "${mod}+7" = "workspace 7";
      "${mod}+Shift+7" = "move container to workspace 7";
      "${mod}+8" = "workspace 8";
      "${mod}+Shift+8" = "move container to workspace 8";
      "${mod}+9" = "workspace 9";
      "${mod}+Shift+9" = "move container to workspace 9";
      "${mod}+0" = "workspace 10";
      "${mod}+Shift+0" = "move container to workspace 10";

      # Move between displays
      "${mod}+Mod1+Ctrl+Right" = "move workspace to output right";
      "${mod}+Mod1+Ctrl+Left" = "move workspace to output left";
      "${mod}+Mod1+Ctrl+Down" = "move workspace to output down";
      "${mod}+Mod1+Ctrl+Up" = "move workspace to output up";

      # Layout manipulation
      "${mod}+h" = "splith";
      "${mod}+v" = "splitv";
      "${mod}+s" = "layout stacking";
      "${mod}+w" = "layout tabbed";
      "${mod}+e" = "layout toggle split";
      "${mod}+f" = "fullscreen";
      "${mod}+Shift+space" = "floating toggle";
      "${mod}+p" = "focus parent";
      "${mod}+r" = "mode resize";
    };
  wayland.windowManager.sway.config.startup = [
    { command = "dbus-sway-environment"; }
    { command = "configure-gtk"; }
  ];
  wayland.windowManager.sway.config.colors = {
    focused = {
      border = base05;
      background = base0D;
      text = base00;
      indicator = base0D;
      childBorder = base0D;
    };
    focusedInactive = {
      border = base01;
      background = base01;
      text = base05;
      indicator = base03;
      childBorder = base01;
    };
    unfocused = {
      border = base01;
      background = base00;
      text = base05;
      indicator = base01;
      childBorder = base01;
    };
    urgent = {
      border = base08;
      background = base08;
      text = base00;
      indicator = base08;
      childBorder = base08;
    };
  };
  wayland.windowManager.sway.config.bars = [ ]; # use waybar instead
  wayland.windowManager.sway.config.output."*".bg = "${base00} solid_color";

  programs.waybar.enable = true;
  programs.waybar.systemd.enable = true;
  programs.waybar.systemd.target = "sway-session.target";
  wayland.windowManager.sway.systemdIntegration = true;
  programs.waybar.settings = {
    main = {
      layer = "top";
      position = "top";
      height = 24;
      spacing = 4;
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "cpu" "memory" "network" "pulseaudio" "battery" "tray" "clock" ];

      "sway/workspaces" = {
        disable-scroll = false;
        disable-markup = false;
      };
      "network" = {
        format-wifi = "{essid} ";
        format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
        format-disconnected = "Disconnected ⚠";
        interval = 7;
      };
      "cpu" = {
        format = "{usage}% ";
      };
      "memory" = {
        format = "{}% ";
      };
      "pulseaudio" = {
        format = "{volume}% {icon}";
        format-bluetooth = ": {volume}% {icon}";
        format-muted = "";
        format-icons.headphones = "";
        format-icons.handsfree = "";
        format-icons.headset = "";
        format-icons.phone = "";
        format-icons.portable = "";
        format-icons.car = "";
        format-icons.default = [ "" "" ];
      };
      "battery" = {
        states = {
          good = 95;
          warning = 30;
          critical = 15;
        };
        format = "{capacity}% {icon}";
        format-icons = [ "" "" "" "" "" ];
      };
      "clock" = {
        format = "{:%F %I:%M %p}";
      };
      "tray" = {
        icon-size = 16;
        spacing = 10;
      };
    };
  };
  programs.waybar.style = ''
    * {
        border: none;
        border-radius: 0;
        font-family: FontAwesome, Iosevka, sans-serif;
        font-size: 14px;
        min-height: 0;
        transition: none;
        text-shadow: none;
    }

    window#waybar {
        background-color: ${base00};
        color: ${base05};
    }

    tooltip {
      background: ${base08};
      border: 1px solid ${base08};
    }
    tooltip label {
      color: ${base05};
    }

    window#waybar.hidden {
        opacity: 0.2;
    }

    /*
    window#waybar.empty {
        background-color: transparent;
    }
    window#waybar.solo {
        background-color: #FFFFFF;
    }
    */

    #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: ${base05};
        /* Avoid rounded borders under each workspace name */
        border: none;
        border-radius: 0;
    }

    #workspaces button:hover {
        background: ${base01};
        font-weight: normal;
    }

    #workspaces button.focused {
        background-color: ${base0D};
        color: ${base00};
        font-weight: bold;
    }

    #workspaces button.urgent {
        background-color: ${base08};
    }

    #mode {
        background-color: ${base0C};
        font-style: italic;
    }

    #clock,
    #battery,
    #cpu,
    #memory,
    #disk,
    #temperature,
    #backlight,
    #network,
    #pulseaudio,
    #custom-media,
    #tray,
    #mode,
    #idle_inhibitor,
    #mpd {
        padding: 0 5px;
        color: ${base00};
        margin: 0;
        border: 0;
    }

    #window,
    #workspaces {
        margin: 0 5px;
    }

    /* If workspaces is the leftmost module, omit left margin */
    .modules-left > widget:first-child > #workspaces {
        margin-left: 0;
    }

    /* If workspaces is the rightmost module, omit right margin */
    .modules-right > widget:last-child > #workspaces {
        margin-right: 0;
    }

    #clock {
        background-color: ${base00};
        color: ${base04};
    }

    #battery {
        background-color: ${base09};
    }

    #battery.charging, #battery.plugged {
        background-color: ${base0B};
    }

    @keyframes blink {
        to {
            color: ${base00};
            background-color: ${base05};
        }
    }

    #battery.critical:not(.charging) {
        background-color: ${base08};
        color: ${base00};
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
    }

    label:focus {
        background-color: ${base00};
    }

    #cpu, #memory, #disk {
        background-color: ${base0E};
        color: ${base00};
    }

    #backlight {
        background-color: ${base01};
    }

    #network {
        background-color: ${base0B};
    }

    #network.disconnected {
        background-color: ${base08};
    }

    #pulseaudio {
        background-color: ${base0B};
        color: ${base00};
    }

    #pulseaudio.muted {
        background-color: ${base09};
        color: ${base00};
    }

    #tray {
        background-color: ${base00};
    }

    #tray > .passive {
        -gtk-icon-effect: dim;
    }

    #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: ${base08};
    }

    #idle_inhibitor {
        background-color: ${base09};
    }

    #idle_inhibitor.activated {
        background-color: ${base0E};
        color: ${base00};
    }
  '';

  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 600; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      {
        timeout = 900;
        command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
        resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
      }
    ];
  };

  programs.swaylock.settings = {
    font = "Iosevka Term";
    font-size = 18;

    indicator-radius = 100;
    indicator-thickness = 10;

    color = base00;

    ring-color = base0D;
    inside-color = base00;
    text-color = base05;

    ring-ver-color = base09;
    inside-ver-color = base00;
    text-ver-color = base05;

    ring-wrong-color = base08;
    inside-wrong-color = base08;
    text-wrong-color = base00;

    line-uses-inside = true;
    line-uses-ring = true;
  };

  programs.mako = {
    enable = true;
    backgroundColor = base00;
    textColor = base05;
    borderColor = base0D;
    width = 500;
    borderSize = 2;
    font = "Iosevka Term 11";
    margin = "5";
    maxIconSize = 48;
    defaultTimeout = 10000;
    groupBy = "app-name";
    extraConfig = ''
      [urgency=high]
      background-color=${base00}
      text-color=${base08}
      border-color=${base0D}
    '';
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 12;
      };
    };
  };

  services.kanshi = {
    enable = true;
    profiles = {
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.0;
          }
        ];
      };
      docked-home = {
        outputs = [
          {
            criteria = "Dell Inc. DELL U2717D 67YGV71AA15L";
            status = "enable";
            mode = "2560x1440@60Hz";
            position = "0,0";
          }
          {
            criteria = "Ancor Communications Inc ROG PG279Q HCLMQS118715";
            status = "enable";
            mode = "2560x1440@60Hz"; # TODO: 165hz doesnt work :(
            position = "2560,0";
          }
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.5;
            position = "5120,0";
          }
        ];
      };
      docked-uptown = {
        outputs = [
          {
            criteria = "Dell Inc. DELL U3415W PXF7904J06YL";
            status = "enable";
            mode = "3440x1440@60Hz";
            position = "0,0";
          }
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.0;
            position = "592,1440";
          }
        ];
      };
      docked-home-secondary = {
        outputs = [
          {
            criteria = "Dell Inc. DELL U2717D 67YGV71AA15L";
            status = "enable";
            mode = "2560x1440@60Hz";
            position = "0,0";
          }
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.5;
            position = "2560,0";
          }
        ];
      };
      docked-home-primary = {
        outputs = [
          {
            criteria = "Ancor Communications Inc ROG PG279Q HCLMQS118715";
            status = "enable";
            mode = "2560x1440@60Hz"; # TODO: 165hz doesnt work :(
            position = "0,0";
          }
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.5;
            position = "2560,0";
          }
        ];
      };
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";
}
