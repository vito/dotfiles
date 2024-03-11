set -U fish_greeting

fish_add_path ~/.bin

set -x EDITOR vim

alias gst 'git status'
alias gs 'git status'

if status is-interactive
  starship init fish | source
  fish_config theme choose rose-pine
end
