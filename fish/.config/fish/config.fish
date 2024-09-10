eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

set -x EDITOR vim

# git shorthand
alias gst 'git status'
alias gs 'git status'
alias gpl 'git pull'

# local software
fish_add_path ~/bin ~/.local/bin ~/go/bin ~/.yarn/bin

if status is-interactive
  set fish_greeting

  set -x BAT_THEME base16

  if set -q LIGHT
    fish_config theme choose "Rosé Pine Dawn"
  else
    fish_config theme choose "Rosé Pine"
  end

  starship init fish | source

  if which direnv >/dev/null
    eval (direnv hook fish)
  end
end
