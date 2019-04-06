base16 gruvbox-dark-soft

if which direnv >/dev/null
  eval (direnv hook fish)
end

alias gst 'git status'

# i have never ever wanted to run ghostscript
alias gs 'git status'

for path in $HOME/bin
  if test -d $path
    set -x PATH $path $PATH
  end
end
