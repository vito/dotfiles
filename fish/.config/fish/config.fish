if which direnv >/dev/null
  eval (direnv hook fish)
end

set -x EDITOR vim

set -x GIT_DUET_CO_AUTHORED_BY 1
alias gst 'git status'

# i have never ever wanted to run ghostscript
alias gs 'git status'

function add_path_if_exists
  for path in $argv
    if test -d $path
      fish_add_path -pP $path
    end
  end
end

# local software
add_path_if_exists ~/bin ~/.local/bin ~/go/bin ~/.yarn/bin

# system-wide software
add_path_if_exists /usr/local/go/bin /usr/local/nvim/bin
add_path_if_exists /opt/google-cloud-sdk/bin
set postgres_paths /usr/lib/postgresql/*/bin # allow glob to match no directory
add_path_if_exists $postgres_paths           # so we can pass empty args here

# faster git prompt
set -g async_prompt_functions _pure_prompt_git

# setting loading indicator for _pure_prompt_git doesn't work, so this approximates it
function fish_prompt_loading_indicator
  echo (_pure_prompt_current_folder 0)' '(set_color brblack)'…'(set_color normal)
  echo (_pure_prompt_symbol 0)' '
end

if set -q base16_theme && test -d ~/src/base16-config/templates/fzf/fish
  source ~/src/base16-config/templates/fzf/fish/base16-$base16_theme.fish
end

# configure colors for bat
set -x BAT_THEME base16-256
