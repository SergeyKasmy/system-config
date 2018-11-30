## History

# History file location
HISTFILE=~/.local/share/zsh/history

# History file size
HISTSIZE=1000
SAVEHIST=1000


## Options
# Append history from all the currently opened terminals to the same history file
# So one could type a command in one terminal and reuse it in another
setopt appendhistory 

# Add more patterns to globbing
setopt extendedglob

path+=(~/.local/bin/)


## Functions autoloading
# TODO: Investigate what does this command do
#zstyle :compinstall filename '/home/gray/.config/zsh/.zshrc'

# Init zsh completion system
autoload -Uz compinit; compinit



## oh-my-zsh
ZSH=/usr/share/oh-my-zsh/
ZSH_THEME="refined"
# ZSH_THEME="agnoster"
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
# DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"
# COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="dd-mm-yyyy"
ZSH_CUSTOM=~/.config/zsh/custom/
plugins=(
  adb
  colored-man-pages
  extract
  git
)
# export MANPATH="/usr/local/man:$MANPATH"
ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi


source $ZSH/oh-my-zsh.sh

## Binds
# Enable Emacs key mode
bindkey -e

autoload zkbd
[[ ! -f ${ZDOTDIR:-$HOME}/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE} ]] && zkbd
source ${ZDOTDIR:-$HOME}/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE}

[[ -n ${key[Backspace]} ]] && bindkey "${key[Backspace]}" backward-delete-char
[[ -n ${key[Insert]} ]] && bindkey "${key[Insert]}" overwrite-mode
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[PageUp]} ]] && bindkey "${key[PageUp]}" up-line-or-history
[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
[[ -n ${key[PageDown]} ]] && bindkey "${key[PageDown]}" down-line-or-history
[[ -n ${key[Up]} ]] && bindkey "${key[Up]}" up-line-or-search
[[ -n ${key[Left]} ]] && bindkey "${key[Left]}" backward-char
[[ -n ${key[Down]} ]] && bindkey "${key[Down]}" down-line-or-search
[[ -n ${key[Right]} ]] && bindkey "${key[Right]}" forward-char
# bindkey "^[OM" forward-word

# Enable help
autoload -Uz run-help
unalias run-help
alias help=run-help

# Enable syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Auto reload PATH
zstyle ':completion:*' rehash true

# set gpg tty for pinentry_tty to work
export GPG_TTY=$(tty)

eval "$(jump shell)"

#-------------------------------------------------------------------------------------------------------------------------------------
# Aliases

# edit cfgs
alias editzcfg='vim ~/.config/zsh/.zshrc'
alias editi3cfg='vim ~/.config/i3/config'

# systemctl --user
alias systemctlu='systemctl --user'

# get public IP
alias whatsmyip='curl ipinfo.io/ip'

# pager
alias -g les='| less'

# pacman and yay 
alias pup='sudo pacman -Syu'
alias y='yay'

# find .pac files
alias pacfind='find /etc -regextype posix-extended -regex ".+\.pac(new|save)" 2> /dev/null'

# rm
alias rm='echo "This is not the command you are looking for. Use tp"; false'
alias tp='trash-put'

# bat
alias cat='bat'

# lsblk
alias lsblk='lsblk -o NAME,FSTYPE,SIZE,RM,RO,MOUNTPOINT,LABEL,PARTLABEL,UUID'

# Exact copy
alias rsync-exact='rsync -aHAX'

# mkdir - verbose and create parent dirs
alias mkdir='mkdir -p'

# colored ip
alias ip='ip -c'

# restart compton
alias compton-restart='killall -USR1 compton'

# ls

#   -A, --almost-all           do not list implied . and ..
#   -l                         use a long listing format
#   -F, --classify             append indicator (one of */=>@|) to entries
#   -h, --human-readable       with -l and/or -s, print human readable sizes
#   -C                         list entries by columns
alias ll='ls -AlFh'
alias la='ls -A'
alias l='ls -CF'

whoneeds()
{
	echo "Packages that depend on [$1]"
	comm -12 <(pactree -ru $1 | sort) <(pacman -Qqe | sort) | grep -v "^$1$" | sed 's/^/  /'
}

pacman-date()
{
	for i in $(pacman -Qq)
	do
		grep "\[ALPM\] installed $i" /var/log/pacman.log
	done | \
  	sort -u | \
  	sed -e 's/\[ALPM\] installed //' -e 's/(.*$//'
}

start()
{
	# If no program name specified -> exit
	(( $# <= 0 )) && return
	
	nohup "$@" &>/dev/null &!
}


aur()
{
	if [ $1 ]; then
		git clone https://aur.archlinux.org/$1.git
		cd $1
		makepkg -si 
	fi
}

# chmod permissions help alias
chmod-help()
{
    arraysize=8

    numbers[1]=7
    numbers[2]=6
    numbers[3]=5
    numbers[4]=4
    numbers[5]=3
    numbers[6]=2
    numbers[7]=1
    numbers[8]=0

    permissions[1]='read, write and execute'
    permissions[2]='read and write'
    permissions[3]='read and execute'
    permissions[4]='read only'
    permissions[5]='write and execute'
    permissions[6]='write only'
    permissions[7]='execute only'
    permissions[8]='none'

    permissions_short[1]='rwx'
    permissions_short[2]='rw-'
    permissions_short[3]='r-x'
    permissions_short[4]='r--'
    permissions_short[5]='-wx'
    permissions_short[6]='-w-'
    permissions_short[7]='--x'
    permissions_short[8]='---'

    echo "|---|-------------------------|-----|"
    for (( i = 1; i <= arraysize; i++ ))
    do
        printf "| %s |%24s | %s |\n" ${numbers[$i]} ${permissions[$i]} ${permissions_short[$i]}
        echo "|---|-------------------------|-----|"
    done
}


# no nested ranger instances
ranger() {
    if [ -z "$RANGER_LEVEL" ]; then
        /usr/bin/ranger "$@"
    else
        exit
    fi
}

# colored less
export LESS=-R
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'
export LESS_TERMCAP_ue=$'\E[0m'



