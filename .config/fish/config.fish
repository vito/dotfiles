set -U fish_greeting

fish_add_path ~/.bin

set -x EDITOR vim

alias gst 'git status'
alias gs 'git status'

alias host 'distrobox-host-exec'
alias dev 'distrobox enter dev'

if status is-interactive
  starship init fish | source
  fish_config theme choose rose-pine
end

# pnpm
set -gx PNPM_HOME "/home/vito/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
