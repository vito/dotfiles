set --erase fish_greeting

set -x GOPATH $HOME/go
set -x PATH $GOPATH/bin $PATH

set -x EDITOR nvim
set -x GIT_EDITOR $EDITOR

if which direnv >/dev/null
  eval (direnv hook fish)
end

set -x GEM_HOME $HOME/.gems
set -x PATH $GEM_HOME/bin $PATH

alias gst 'git status'

# i have never ever wanted to run ghostscript
alias gs 'git status'

set -x PATH $HOME/bin $PATH

if which keychain >/dev/null
  eval (keychain --eval --quiet)
end

if test -e /usr/local/share/chruby/chruby.fish
  source /usr/local/share/chruby/chruby.fish
end

# override fish colors to use the stock 16 colors, so that it can be themed with .Xresources
set fish_color_autosuggestion white
set fish_color_command blue
set fish_color_comment yellow
set fish_color_cwd blue
set fish_color_cwd_root red
set fish_color_end magenta
set fish_color_error red
set fish_color_escape cyan
set fish_color_history_current cyan
set fish_color_match cyan
set fish_color_normal normal
set fish_color_operator cyan
set fish_color_param green
set fish_color_quote cyan
set fish_color_redirection red
set fish_color_search_match \x2d\x2dbackground\x3dpurple
set fish_color_selection \x2d\x2dbackground\x3dpurple
set fish_color_valid_path \x2d\x2dunderline
set fish_key_bindings fish_default_key_bindings
set fish_pager_color_completion normal
set fish_pager_color_description 555\x1eyellow
set fish_pager_color_prefix cyan
set fish_pager_color_progress cyan

# automatically run tmux
if which tmux >/dev/null; and status --is-interactive
    if test -z (echo $TMUX)
        exec tmux
    end
end
