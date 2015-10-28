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

set -x PATH $HOME/bin $PATH

if which keychain >/dev/null
  eval (keychain --eval --quiet)
end
