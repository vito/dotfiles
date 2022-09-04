{ config, pkgs, lib, ... }:

let
  ws1 = "1: werk";
  ws2 = "2: web";
  ws3 = "3: chat";
  ws4 = "4: notes";
  ws5 = "5: music";
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
    discord
    firefox-wayland
    signal-desktop

    # misc shell utils
    ripgrep
    jq
    fzf

    # language server providers
    rnix-lsp
    nixpkgs-fmt
  ];

  programs.git = {
    enable = true;
    userName = "Alex Suraci";
    userEmail = "suraci.alex@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      st = "status";
    };
    delta = {
      # fancy syntax highlighting
      enable = true;
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

  # Configure Fish, which is already installed system-wide but needs to be
  # enabled for these local configs to be respected.
  programs.fish.enable = true;
  programs.fish.shellAliases = {
    gst = "git status";
    gs = "git status"; # i have never ever wanted to run ghostscript
  };
  programs.fish.shellInit = "set -x EDITOR vim";
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
  programs.bat.enable = true;
  programs.bat.config = { theme = "base16-256"; };

  programs.neovim.enable = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.vimdiffAlias = true;
  programs.neovim.plugins = with pkgs.vimPlugins; [
    (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
  ];

  xdg.configFile."nvim" = {
    source = pkgs.fetchFromGitHub {
      owner = "vito";
      repo = "dot-nvim";
      rev = "65032c08a1bb0e0af7908291f3f594553540b269";
      sha256 = "sha256-Znh45z9mypOc3Max38vz8sMT1pGTk9ErmqqiOP3O17Y=";
    };
    recursive = true;
  };

  wayland.windowManager.sway.enable = true;
  wayland.windowManager.sway.config.assigns = {
    ws2 = [{ class = "^Firefox$"; }];
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
  wayland.windowManager.sway.config.keybindings =
    let
      mod = config.wayland.windowManager.sway.config.modifier;
    in
    lib.mkOptionDefault {
      "${mod}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
      "${mod}+Shift+q" = "kill";
      "${mod}+d" = "exec ${pkgs.bemenu}/bin/bemenu-run | ${pkgs.findutils}/bin/xargs ${pkgs.sway}/bin/swaymsg exec --";
      "${mod}+Shift+r" = "reload";
      "${mod}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

      # Brightness
      "XF86MonBrightnessDown" = "exec light -U 10";
      "XF86MonBrightnessUp" = "exec light -A 10";

      # Volume
      "XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
      "XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'";
      "XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";

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
      "${mod}+Ctrl+Shift+Right" = "move workspace to output right";
      "${mod}+Ctrl+Shift+Left" = "move workspace to output left";
      "${mod}+Ctrl+Shift+Down" = "move workspace to output down";
      "${mod}+Ctrl+Shift+Up" = "move workspace to output up";

      # Layout manipulation
      "${mod}+h" = "splith";
      "${mod}+v" = "splitv";
      "${mod}+s" = "layout stacking";
      "${mod}+w" = "layout tabbed";
      "${mod}+e" = "layout toggle split";
      "${mod}+f" = "fullscreen";
      "${mod}+Shift+space" = "floating toggle";
      "${mod}+p" = "focus parent";
    };
  wayland.windowManager.sway.config.startup = [
    { command = "dbus-sway-environment"; }
    { command = "configure-gtk"; }
  ];
  # configure colors and bars in extraConfig for convenient copy/paste from
  # base16 templates
  wayland.windowManager.sway.config.bars = [ ];
  wayland.windowManager.sway.extraConfig = ''
    # Rose Pine
    set $base00 #191724
    set $base01 #1f1d2e
    set $base02 #26233a
    set $base03 #555169
    set $base04 #6e6a86
    set $base05 #e0def4
    set $base06 #f0f0f3
    set $base07 #c5c3ce
    set $base08 #eb6f92
    set $base09 #f6c177
    set $base0A #f6c177
    set $base0B #31748f
    set $base0C #ebbcba
    set $base0D #9ccfd8
    set $base0E #c4a7e7
    set $base0F #e5e5e5

    bar {
      colors {
        background $base00
        separator  $base01
        statusline $base04

        #                   Border  BG      Text
        focused_workspace   $base00 $base0D $base00
        active_workspace    $base00 $base03 $base00
        inactive_workspace  $base00 $base01 $base05
        urgent_workspace    $base08 $base08 $base00
        binding_mode        $base00 $base0A $base00
      }
    }

    #                       Border  BG      Text    Ind     Child Border
    client.focused          $base05 $base0D $base00 $base0D $base0D
    client.focused_inactive $base01 $base01 $base05 $base03 $base01
    client.unfocused        $base01 $base00 $base05 $base01 $base01
    client.urgent           $base08 $base08 $base00 $base08 $base08

    output * bg $base00 solid_color
  '';

  # TODO: verify this has sane defaults
  services.swayidle.enable = true;

  services.kanshi = {
    enable = true;
    profiles = {
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.5;
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
            criteria = "Ancor Communications Inc ROG PG279Q #ASM6IrOLXMDd";
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
