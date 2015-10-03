set -x GOPATH $HOME/go
set -x PATH $GOPATH/bin $PATH

set -x PATH $HOME/bin $PATH

set -x EDITOR nvim
set -x GIT_EDITOR $EDITOR

if which direnv >/dev/null
  eval (direnv hook fish)
end

function bosh
  command bosh -c (lpass show BOSH_CONFIG --notes | psub) $argv
end
