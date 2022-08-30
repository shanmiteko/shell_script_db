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
export PATH=$PATH:$HOME/.cargo/bin
export GCC_INCLUDE="/usr/lib64/gcc/x86_64-suse-linux/12/include/"

export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup

export CLASH_HOME="$HOME/bin/.clash"
export NODE_PATH="/usr/local/lib/node_modules"
export GOPROXY="https://goproxy.cn"

alias zshrc="vim $HOME/.zshrc && source $HOME/.zshrc"

alias pc="proxychains4"
alias rgf="rg --files --no-ignore | rg"

alias docker=podman
alias pmls="podman image list && podman image list --all && podman container list && podman container list --all"
alias pmr="podman run -it --rm"

alias lynx=lynx-color

alias zypper="sudo zypper"
alias dup="zypper ref && zypper dup --no-recommends"
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
        if [[ $LANG != "en_US.UTF-8" ]]; then
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

function youdao() {
        lynx "https://dict.youdao.com/w/$1"
}

function zin() {
        tmp_zypp_cache=/tmp/zypp-cache/$1
        mkdir -p $tmp_zypp_cache
        sudo zypper --pkg-cache-dir $tmp_zypp_cache install -yfd --no-recommends "$1"
	printf "examine? [y/n] (y) "
        read insp
        case "${insp}" in
        "" | "y")
                rpm -qlp $tmp_zypp_cache/**/*.rpm
                ;;
        *) ;;
        esac
	printf "install? [y/n] (y) "
        read inst
        case "${inst}" in
        "" | "y")
                sudo zypper --pkg-cache-dir $tmp_zypp_cache install -yf --no-recommends "$1"
                ;;
        *) ;;
        esac
}
