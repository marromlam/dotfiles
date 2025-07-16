; WEZTERM

#IfWinActive, ahk_exe wezterm-gui.exe
+#d::Send ^!+d
; shif + LWin + c :: copy
+#c::Send ^!+c

#a::Send ^!a
#b::Send ^!b
#c::Send ^!c
#d::Send ^!d
#e::Send ^!e
#f::Send ^!f
#g::Send ^!g
#h::Send ^!h
#i::Send ^!i
#j::Send ^!j
#k::Send ^!k
#l::Send ^!l
#m::Send ^!m
#n::Send ^!n
#o::Send ^!o
#p::Send ^!p
#q::Send ^!q
#r::Send ^!r
#s::Send ^!s
#t::Send ^!t
#u::Send ^!u
#v::Send ^!v
#w::Send ^!w
#x::Send ^!x
#y::Send ^!y
#z::Send ^!z

#1::GoToDesktopNumber(0)
#2::GoToDesktopNumber(1)
#3::GoToDesktopNumber(2)
#4::GoToDesktopNumber(3)
#5::GoToDesktopNumber(4)
#6::GoToDesktopNumber(5)
#7::GoToDesktopNumber(6)
#8::GoToDesktopNumber(7)
#9::GoToDesktopNumber(8)
#0::GoToDesktopNumber(9)

;#1::Send ^!1
;#2::Send ^!2
;#3::Send ^!3
;#4::Send ^!4
;#5::Send ^!5
;#6::Send ^!6
;#7::Send ^!7
;#8::Send ^!8
;#9::Send ^!9
;#0::Send ^!0

#=::Send ^!=
#-::Send ^!-


; vim: fdm=marker
