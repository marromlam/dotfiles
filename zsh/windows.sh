# alias wpython="powershell.exe /c set PYTHONPATH=%PYTHONPATH%;%cd% ; python"
alias wpwd="echo $PWD | tr '/' '\\\\'"
alias wpython='powershell.exe /c "\$env:PYTHONPATH=\"\\\\wsl.localhost\Ubuntu$(wpwd)\"; \$env:DEBUG=\"${DEBUG}\"; \$env:WORD_GUI=\"${WORD_GUI}\"; python"'
alias winword='"/mnt/c/Program Files/Microsoft Office/root/Office16/WINWORD.EXE"'

export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
export PATH="$PATH:/mnt/c/WINDOWS/system32"
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"

docker-service() {
	DOCKER_DISTRO="Ubuntu"
	DOCKER_DIR=/mnt/wsl/shared-docker
	export DOCKER_SOCK="$DOCKER_DIR/docker.sock"
	export DOCKER_HOST="unix://$DOCKER_SOCK"
	if [ ! -S "$DOCKER_SOCK" ]; then
		mkdir -pm o=,ug=rwx "$DOCKER_DIR"
		chgrp docker "$DOCKER_DIR"
		/mnt/c/Windows/System32/wsl.exe -d $DOCKER_DISTRO sh -c "nohup sudo -b dockerd < /dev/null > $DOCKER_DIR/dockerd.log 2>&1"
	fi
}
