

# 1 - First export the display
export DISPLAY=:0.0

# 2 - Check whether lemonade is running
ps cax | grep lemonade> /dev/null
if [ $? -eq 0 ]; then
  echo "=  lemonade is running.                                                        ="
else
  echo "=  lemonade was not running... lemonade was launched.                          ="
  nohup lemonade server -allow 127.0.0.1 &
fi

# 3 - Generate random string as window titles
EDITOR_ID=`xxd -l4 -ps /dev/urandom`
KERNEL_ID=`xxd -l4 -ps /dev/urandom`

# 4 - Launch a new tab / os-window and split it
KE_ID=`kitty @ launch --type=tab --title $EDITOR_ID --keep-focus`
KK_ID=`kitty @ launch -m title:$EDITOR_ID --title $KERNEL_ID --keep-focus`

# 5 -put juKitty as window name
kitty @ set-tab-title --match title:$EDITOR_ID "juKitty"

echo "keditor" $KE_ID
echo "kkernel" $KK_ID

# export KITTY_WINDOW_ID to be the one in the KKERNEL_ID window
kitty @ send-text --match title:$EDITOR_ID "export KITTY_WINDOW_ID=${KK_ID}\n"
# open nvim in first window
kitty @ send-text --match title:$EDITOR_ID "nvim $1\n"
kitty @ send-text --match title:$KERNEL_ID "alias ssh=ssh -R 2489:127.0.0.1:2489\n"

#nvim $1

kitty @ focus-tab --match title:$KERNEL_ID
#LOGO=${cat << EndOfMessage
#      _           _  __  _   _     _            
#     (_)  _   _  | |/ / (_) | |_  | |_   _   _ 
#     | | | | | | | ' /  | | | __| | __| | | | |
#     | | | |_| | | . \  | | | |_  | |_  | |_| |
#    _/ |  \__,_| |_|\_\ |_|  \__|  \__|  \__, |
#   |__/                                  |___/ 
#EndOfMessage
#}

merde="
      _           _  __  _   _     _            
     (_)  _   _  | |/ / (_) | |_  | |_   _   _ 
     | | | | | | | ' /  | | | __| | __| | | | |
     | | | |_| | | . \  | | | |_  | |_  | |_| |
    _/ |  \__,_| |_|\_\ |_|  \__|  \__|  \__, |
   |__/                                  |___/ 
"
#echo $merde | kitty @ send-text --match title:$KERNEL_ID --stdin

kitty @ send-text --match title:$KERNEL_ID "clc; echo juKitty kernel running at ${KERNEL_ID} with window ID = ${KK_ID}\n"
#ls | kitty @ send-text --match title:$KERNEL_ID --stdin
#kitty @ send-text --match title:$KERNEL_ID cat  ls
