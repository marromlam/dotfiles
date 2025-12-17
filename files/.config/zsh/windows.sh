# alias wpython="powershell.exe /c set PYTHONPATH=%PYTHONPATH%;%cd% ; python"
alias wpwd="echo $PWD | tr '/' '\\\\'"
# alias wpython='powershell.exe /c "\$env:PYTHONPATH=\"\\\\wsl.localhost\Ubuntu$(wpwd)\"; \$env:DEBUG=\"${DEBUG}\"; \$env:WORD_GUI=\"${WORD_GUI}\"; python"'
alias winword='"/mnt/c/Program Files/Microsoft Office/root/Office16/WINWORD.EXE"'

export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
export PATH="$PATH:/mnt/c/WINDOWS/system32"
export PATH="$PATH:/mnt/c/WINDOWS"
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"

docker-service() {
    # DOCKER_DISTRO="Debian"
    DOCKER_DISTRO="Ubuntu-24.04"
    DOCKER_DIR=/mnt/wsl/shared-docker
    export DOCKER_SOCK="$DOCKER_DIR/docker.sock"
    export DOCKER_HOST="unix://$DOCKER_SOCK"
    if [ ! -S "$DOCKER_SOCK" ]; then
        mkdir -pm o=,ug=rwx "$DOCKER_DIR"
        chgrp docker "$DOCKER_DIR"
        /mnt/c/Windows/System32/wsl.exe -d $DOCKER_DISTRO sh -c "nohup sudo -b dockerd < /dev/null > $DOCKER_DIR/dockerd.log 2>&1"
    fi
}

# if .vcxsrv-display exists, then set DISPLAY
if [ -f $HOME/.vcxsrv ]; then
    export DISPLAY="$(cat $HOME/.vcxsrv)"
fi

get-vcxsrv-display() {
    # Get the IP address of the Wi-Fi interface
    IP4_ADDRESS=$(powershell.exe Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Wi-Fi | grep IPAddress | awk '{print $3}')

    # Create .vcxsrv-display file
    rm -rf $HOME/.vcxsrv
    echo "${IP4_ADDRESS}" >$HOME/.vcxsrv
    dos2unix $HOME/.vcxsrv &>/dev/null
    sed -i 's/$/:0/g' ~/.vcxsrv
    # echo ":0" >>$HOME/.vcxsrv
    dos2unix $HOME/.vcxsrv &>/dev/null
}

sync-windows-config() {

    # Some of the dotfiles in WSL must be configured such that they are
    # **copied** in the Windows system. They will live under ~/.config
    # directory.
    #
    #
    LINUX_CONFIG=~/Projects/personal/dotfiles/files/.config
    WINDOWS_CONFIG=/mnt/c/Users/marcos.romero/.config
    mkdir -p $WINDOWS_CONFIG
    chmod -R 777 $WINDOWS_CONFIG

    # Wezterm is a GUI app living on Windows system, so its dotfiles
    # are copied to WINDOWS_CONFIG folder
    # cp -r {$LINUX_CONFIG,$WINDOWS_CONFIG}/wezterm

    # Install some Windows app without sudo permisions
    WINDOWS_APPLICATIONS=/mnt/c/Users/marcos.romero/Applications/
    mkdir -p $WINDOWS_APPLICATIONS
    chmod -R 777 $WINDOWS_APPLICATIONS

    ln -sf /mnt/c/Users/marcos.romero/Downloads $HOME/Downloads
    ln -sf /mnt/c/Users/marcos.romero/Documents $HOME/Documents
    ln -sf /mnt/c/Users/marcos.romero/Desktop $HOME/Desktop
    ln -sf /mnt/c/Users/marcos.romero/Applications $HOME/Applications

}


# vim: fdm=marker ft=bash
