SCRIPT_ADDITION="$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d' ' -f 1) $(which yabai) --load-sa"

sudo sh -c "echo \"${SCRIPT_ADDITION}\" >> /etc/sudoers"
