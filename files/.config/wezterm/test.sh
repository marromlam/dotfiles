function hex2dec () {
    echo "obase=10; ibase=16; $1" | bc
}


function hex2rgb () {
  HEX_COLOR=$1
  RED_COLOR="${HEX_COLOR:1:2}"
  GREEN_COLOR="${HEX_COLOR:3:2}"
  BLUE_COLOR="${HEX_COLOR:5:2}"
  echo $RED_COLOR $GREEN_COLOR $BLUE_COLOR
  echo hex2dec $RED_COLOR
}
