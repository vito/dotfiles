if which direnv >/dev/null
  eval (direnv hook fish)
end

set -x EDITOR vim

set -x GEM_HOME $HOME/.gem

set -x GIT_DUET_CO_AUTHORED_BY 1
alias gst 'git status'

# i have never ever wanted to run ghostscript
alias gs 'git status'

function install_path
  for path in $argv
    if test -d $path
      set -x PATH $path $PATH
    end
  end
end

# local software
install_path ~/bin
install_path ~/.local/bin
install_path ~/go/bin
install_path ~/.yarn/bin
install_path ~/.gem/bin
install_path ~/.emacs.d/bin

# system-wide software
install_path /usr/local/nvim/bin
install_path /usr/local/go/bin
install_path /opt/google-cloud-sdk/bin

if test -d /usr/lib/postgresql
  install_path /usr/lib/postgresql/*/bin
end
