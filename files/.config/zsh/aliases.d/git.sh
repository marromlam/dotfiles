# Git aliases {{{
# source: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh#L53
# NOTE: a lot of these commands are single quoted ON PURPOSE to prevent them
# from being evaluated immediately rather than in the shell when the alias is
# expanded

alias g="git"
alias gss="git status -s"
alias gst="git status"
alias gc="git commit"
alias gd="git diff"
alias gco="git checkout"
alias ga='git add'
alias gaa='git add --all'
alias gcb='git checkout -b'
alias gb='git branch'
alias gbD='git branch -D'
alias gbl='git blame -b -w'
alias gbr='git branch --remote'
alias gc='git commit -v'
alias gd='git diff'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'
alias gm='git merge'
alias gma='git merge --abort'
alias gmom='git merge origin/$(git_main_branch)'
alias gp='git push'
alias gbda='git branch --no-color --merged | command grep -vE "^(\+|\*|\s*($(git_main_branch)|development|develop|devel|dev)\s*$)" | command xargs -n 1 git branch -d'
alias gpristine='git reset --hard && git clean -dffx'
alias gcl='git clone --recurse-submodules'
alias gl='git pull'
alias glum='git pull upstream $(git_main_branch)'
alias grhh='git reset --hard'
alias groh='git reset origin/$(git_current_branch) --hard'
alias grbi='git rebase -i'
alias grbm='git rebase $(git_main_branch)'
alias gcm='git checkout $(git_main_branch)'
alias gcd="git checkout development"
alias gcb="git checkout -b"
alias gstp="git stash pop"
alias gsts="git stash show -p"

function grename() {
        if [[ -z "$1" || -z "$2" ]]; then
                echo "Usage: $0 old_branch new_branch"
                return 1
        fi

        # Rename branch locally
        git branch -m "$1" "$2"
        # Rename branch in origin remote
        if git push origin :"$1"; then
                git push --set-upstream origin "$2"
        fi
}

function gdnolock() {
        git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}
# compdef _git gdnolock=git-diff

# Check if main exists and use instead of master
function git_main_branch() {
        local branch
        for branch in main trunk; do
                if command git show-ref -q --verify refs/heads/$branch; then
                        echo $branch
                        return
                fi
        done
        echo master
}

# }}}
# Github CLI {{{
function cs-list() {
        gh codespace list | awk 'NR > 0 {print $1"@"$5}'
}

function cs-ssh() {
        # if we get one argument, we assume it's a codespace name
        # else we use fzf to select one

        if [ $# -eq 1 ]; then
                gh codespace ssh -c $1
        else
                CODESPACE=$(gh codespace list | awk 'NR > 0 {print $1"@"$5}' | fzf | awk -F@ '{print $1}')
                echo $CODESPACE
                gh codespace ssh -c $CODESPACE
        fi
}






# }}}
# Mounting {{{

select_partition() {
        local partition

        # Use lsblk to list all partitions (excluding loops) not mounted and pipe to fzf for selection
        PARTITION=$(lsblk -o NAME,SIZE,TYPE,MOUNTPOINT -n | awk '$3 == "part" {gsub(/[├└]─/, "", $1); print $1}' | fzf --height 50% --reverse --prompt="Select a partition to mount: " --header="NAME SIZE TYPE")

        # Check if a partition was selected
        if [ -n "$PARTITION" ]; then
                echo "Selected partition: $PARTITION"
                # Perform further actions with the selected partition, e.g., mount it
                # Add your custom logic here
                sudo mount /dev/$PARTITION /mnt/
        else
                echo "No partition selected."
        fi
}

# }}}


# Docker {{{

dcu(){
    # docker-service
    docker compose up -d
}

dcd(){
    docker compose down
}

# }}}


repo() {
    # This will list up to 2 depth of given directory. Add/remove '*/' to your preferences.
    # The path should be absolute path.
    # Note that too many depth will slow-down the script, less depth will show fewer results.
    local srchDir=/Users/marcos/Projects/*/*/

    # if any arguments arn't given, just list up everything else use search query
    [ "$1" = false ] && cd "$(ls -d $srchDir | fzf)" || local qTerm="${@}"; cd "$(ls -d $srchDir | fzf -q "$qTerm")"
}



ocurrences() {
    rg -o "$@" | wc -l
}



# vim: fdm=marker et ts=4 sw=4 tw=80
