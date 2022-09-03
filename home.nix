{ config, pkgs, ... }:

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

    # misc shell utils
    ripgrep
    jq
    fzf

    # language server providers
    rnix-lsp
  ];

  programs.wezterm.enable = true;
  programs.wezterm.extraConfig = ''
    local wezterm = require 'wezterm'

    return {
      font = wezterm.font "Iosevka Term",
      color_scheme = "Rosé Pine (base16)",
      keys = {
        {
          key = '+',
          mods = 'ALT|SHIFT',
          action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
        },
        {
          key = '_',
          mods = 'ALT|SHIFT',
          action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
        },
        {
          key = 'Enter',
          mods = 'ALT|SHIFT',
          action = wezterm.action.TogglePaneZoomState,
        },
        {
          key = 'LeftArrow',
          mods = 'ALT',
          action = wezterm.action.ActivatePaneDirection 'Left',
        },
        {
          key = 'RightArrow',
          mods = 'ALT',
          action = wezterm.action.ActivatePaneDirection 'Right',
        },
        {
          key = 'UpArrow',
          mods = 'ALT',
          action = wezterm.action.ActivatePaneDirection 'Up',
        },
        {
          key = 'DownArrow',
          mods = 'ALT',
          action = wezterm.action.ActivatePaneDirection 'Down',
        },
        {
          key = 'LeftArrow',
          mods = 'ALT|SHIFT',
          action = wezterm.action.AdjustPaneSize { 'Left', 5},
        },
        {
          key = 'RightArrow',
          mods = 'ALT|SHIFT',
          action = wezterm.action.AdjustPaneSize { 'Right', 5},
        },
        {
          key = 'UpArrow',
          mods = 'ALT|SHIFT',
          action = wezterm.action.AdjustPaneSize { 'Up', 5 },
        },
        {
          key = 'DownArrow',
          mods = 'ALT|SHIFT',
          action = wezterm.action.AdjustPaneSize { 'Down', 5 },
        },
      },
    }
  '';

  programs.git = {
    enable = true;
    userName = "Alex Suraci";
    userEmail = "suraci.alex@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      st = "status";
    };
    delta = { # fancy syntax highlighting
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
    source = ~/src/dotfiles/nvim/.config/nvim;
    recursive = true;
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
