; TEST
; 1st:  ¬1234567890-=  ¬!@#$%^&*()_+
; 2nd: qwertyuiop[] QWERTYUIOP{}
; 3rd: asdfghjkl;'\ ASDFGHJKL:"|
; 4th: ¬zxcvbnm,./ ¬ZXCVBNM<>?

; First key before the 1 is not working 
; First key before the z is not working



#+`::~
#~::~

; Remap IE keyboar to US international
+3::Send {#}

; left Z: \|
$|::Send ~
$\::`
#+`::Send ~

; right ;: '@ #~  --- OK
$#:: Send {\}
$~:: Send |

; left 1: `¬

;`::\
;~::|
$@::"
$"::@

; TODO fix some wrong symbols here
;$`::Send `±
;$+`::Send `§

;+$+::Send ~
