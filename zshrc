export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="ys"

plugins=(
        sudo
        git
        z
        zsh-autosuggestions
        zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
export CLASH_HOME="$HOME/bin/.clash"
export NODE_PATH="/usr/local/lib/node_modules"
export GOPROXY="https://goproxy.cn"

alias zshrc="vim $HOME/.zshrc && source $HOME/.zshrc"

alias pc="proxychains4"
alias rgf="rg --files --no-ignore | rg"

alias pmls="podman image list && podman image list --all && podman container list && podman container list --all"
alias pmr="podman run -it --rm"

alias zypper="sudo zypper"
alias dup="zypper ref && zypper dup --no-recommends"
alias zin="zypper in --no-recommends"
alias zrm="zypper remove --clean-deps"
alias zse="zypper search"

alias tree1="tree -L 1"
alias tree2="tree -L 2"
alias tree3="tree -L 3"
alias pss="ps aux | rg"
alias try_again='while [ $? -ne 0 ]; do $(fc -nl -1); done'
alias loop='while [ true ]; do $(fc -nl -1); done'
alias duh="sudo du -xh . | sort -rhk 1 | head -n 20"
alias python=python3

alias firewall-cmd="sudo firewall-cmd"

function help() {
        curl http://cht.sh/$1
}

function toggle_lan() {
        if [[ $LANG != "en_US.UTF-8" ]]
        then
                export LANG=en_US.UTF-8
        else
                export LANG=zh_CN.UTF-8
        fi
        locale
}

function iplookup() {
        curl -s 'https://www.ipaddress.com/ip-lookup' \
                -X POST \
                -H 'Referer: https://www.ipaddress.com/ip-lookup' \
                --data-raw "host=$1" | perl -e 'while(<>){/https:\/\/www.ipaddress.com\/ipv4\/((\d+\.){3}\d+)/;if($1){print($1);last}}'
}
