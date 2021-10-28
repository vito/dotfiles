if which direnv >/dev/null
  eval (direnv hook fish)
end

set -x EDITOR vim

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

# system-wide software
install_path /usr/local/nvim/bin
install_path /usr/local/go/bin
install_path /opt/google-cloud-sdk/bin

if test -d /usr/lib/postgresql
  install_path /usr/lib/postgresql/*/bin
end

# faster git prompt
set -g async_prompt_functions _pure_prompt_git

# setting loading indicator for _pure_prompt_git doesn't work, so this approximates it
function fish_prompt_loading_indicator
  echo (_pure_prompt_current_folder 0)' '(set_color brblack)'…'(set_color normal)
  echo (_pure_prompt_symbol 0)' '
end
