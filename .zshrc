#load colors
autoload -U colors && colors

#assign readable names to colors
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
    eval $COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
    eval BOLD_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done
eval RESET='%{$reset_color%}'

#enable colors in the terminal
export CLICOLOR='Yes'
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

#load auto completion
autoload -Uz compinit && compinit -u

#load vcs_info module
autoload -Uz vcs_info

#customize prompt
precmd_vcs_info() {
  vcs_info
  
  if [[ -n ${vcs_info_msg_0_} ]]; then
    #there are messages from vcs, show a short pwd
    PS1="${WHITE}%n@captech %2~ ${BOLD_BLUE}( ${vcs_info_msg_0_} ${BOLD_BLUE}) ${GREEN}%% "
  else
    #no messages from vcs, show longer pwd
    PS1="${WHITE}%n@captech %5~ ${GREEN}%% "
  fi
}

precmd_functions+=( precmd_vcs_info )

#adding branch name, changes and misc messages
zstyle ':vcs_info:git:*' formats '%b%c%m'

#hook up git functions
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-st-staged git-st-diff

#define function for untraked files/changes
function +vi-git-untracked(){
  local stagedfile stagedchange
  local -a gitstaged

  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
     git status --porcelain | grep '??' &> /dev/null ; then
     stagedfile=' | +' 
  fi

  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
     git status --porcelain | grep ' M ' || git status --porcelain | grep ' D ' &> /dev/null ; then
     stagedchange=' | *' 
  fi

  hook_com[staged]=${BOLD_YELLOW}${stagedfile}${stagedchange}
}

#define function for staged changes that have not been committed yet
function +vi-git-st-staged(){
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
     git status --porcelain | grep 'M  ' || git status --porcelain | grep 'A  ' || git status --porcelain | grep 'D  ' &> /dev/null ; then
    hook_com[misc]=${BOLD_CYAN}' | *'
  fi
}

#define function diferences between local and remote
function +vi-git-st-diff(){
  local ahead behind
  local -a gitstatus
 
  ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
  (( $ahead )) && gitstatus+=(" | ⬆ ${ahead// /}")

  behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
  (( $ahead)) && (( $behind )) && gitstatus+=(" ⬇ ${behind// /}")
  (( ! $ahead )) && (( $behind )) && gitstatus+=(" | ⬇ ${behind// /}")
  
  hook_com[misc]+=${BOLD_MAGENTA}${gitstatus}
}

#tell vcs_info where to look at for git repos
zstyle -e ':vcs_info:git:*' \
  check-for-changes 'estyle-cfc && reply=( true ) || reply=( false )'

#look only at repos under ~/DevEnvironment/*
function estyle-cfc() {
  local d
  local -a cfc_dirs

  cfc_dirs=(
    ${HOME}/DevEnvironment/*(/)
  )

  for d in ${cfc_dirs}; do
    d=${d%/##}
    [[ $PWD == $d(|/*) ]] && return 0
  done
  return 1
}

