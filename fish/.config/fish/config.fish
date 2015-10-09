set --erase fish_greeting

set -x GOPATH $HOME/go
set -x PATH $GOPATH/bin $PATH

set -x PATH $HOME/bin $PATH

set -x EDITOR nvim
set -x GIT_EDITOR $EDITOR

if which direnv >/dev/null
  eval (direnv hook fish)
end

set -x PATH $HOME/rubinius/bin $PATH
set -x GEM_HOME $HOME/rubinius/gems

set -x PATH $GEM_HOME/bin $PATH

alias gst 'git status'
