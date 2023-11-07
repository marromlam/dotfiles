; -----KEY GUIDE-----
; # Win. (the key with the Windows logo) therefore `Send #e` would hold down Win and then press E.
; + Shift. For example, `Send, +abC` would send the text "AbC", and `Send, !+a` would press Alt+Shift+A.
; ^ Alt (because of remapkey). For example, `Send, This is text!a` would send the keys "This is text" and then press Alt+A. Note: !A produces a different effect in some programs than !a. This is because !A presses Alt+Shift+A and !a presses Alt+A. If in doubt, use lowercase.
; ! Ctrl (because of remapkey). For example, `Send, ^!a` would press Ctrl+Alt+A, and Send, ^{Home} would send Ctrl+Home. Note: ^A produces a different effect in some programs than ^a. This is because ^A presses Ctrl+Shift+A and ^a presses Ctrl+A. If in doubt, use lowercase.Sends Ctrl. For example, Send, ^!a would press Ctrl+Alt+A, and Send, ^{Home} would send Ctrl+Home. Note: ^A produces a different effect in some programs than ^a. This is because ^A presses Ctrl+Shift+A and ^a presses Ctrl+A. If in doubt, use lowercase.
; & An ampersand may be used between any two keys or mouse buttons to combine them into a custom hotkey.

; #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetWorkingDir(A_ScriptDir)


; DLL calls {{{

VDA_PATH := A_ScriptDir . "\VirtualDesktopAccessor.dll"
; MsgBox("hola")
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")

GetDesktopCountProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopCount", "Ptr")
GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetCurrentDesktopNumber", "Ptr")
IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnCurrentVirtualDesktop", "Ptr")
IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnDesktopNumber", "Ptr")
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")
IsPinnedWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedWindow", "Ptr")
GetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopName", "Ptr")
SetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "SetDesktopName", "Ptr")
CreateDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "CreateDesktop", "Ptr")
RemoveDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RemoveDesktop", "Ptr")

; On change listeners
RegisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RegisterPostMessageHook", "Ptr")
UnregisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnregisterPostMessageHook", "Ptr")

GetDesktopCount() {
    global GetDesktopCountProc
    count := DllCall(GetDesktopCountProc, "Int")
    return count
}

MoveCurrentWindowToDesktop(number) {
    global MoveWindowToDesktopNumberProc, GoToDesktopNumberProc
    activeHwnd := WinGetID("A")
    DllCall(MoveWindowToDesktopNumberProc, "Ptr", activeHwnd, "Int", number, "Int")
    DllCall(GoToDesktopNumberProc, "Int", number, "Int")
}

GoToPrevDesktop() {
    global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    last_desktop := GetDesktopCount() - 1
    ; If current desktop is 0, go to last desktop
    if (current = 0) {
        MoveOrGotoDesktopNumber(last_desktop)
    } else {
        MoveOrGotoDesktopNumber(current - 1)
    }
    return
}

GoToNextDesktop() {
    global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    last_desktop := GetDesktopCount() - 1
    ; If current desktop is last, go to first desktop
    if (current = last_desktop) {
        MoveOrGotoDesktopNumber(0)
    } else {
        MoveOrGotoDesktopNumber(current + 1)
    }
    return
}

GoToDesktopNumber(num) {
    global GoToDesktopNumberProc
    DllCall(GoToDesktopNumberProc, "Int", num, "Int")
    return
}
MoveOrGotoDesktopNumber(num) {
    ; If user is holding down Mouse left button, move the current window also
    if (GetKeyState("LButton")) {
        MoveCurrentWindowToDesktop(num)
    } else {
        GoToDesktopNumber(num)
    }
    return
}


CreateDesktop() {
    global CreateDesktopProc
    ran := DllCall(CreateDesktopProc, "Int")
    return ran
}
RemoveDesktop(remove_desktop_number, fallback_desktop_number) {
    global RemoveDesktopProc
    ran := DllCall(RemoveDesktopProc, "Int", remove_desktop_number, "Int", fallback_desktop_number, "Int")
    return ran
}

; }}}

; Move window to desktop 1-9 {{{
RCtrl::RAlt
RAlt & 1::MoveCurrentWindowToDesktop(0)
RAlt & 2::MoveCurrentWindowToDesktop(1)
RAlt & 3::MoveCurrentWindowToDesktop(2)
RAlt & 4::MoveCurrentWindowToDesktop(3)
RAlt & 5::MoveCurrentWindowToDesktop(4)
RAlt & 6::MoveCurrentWindowToDesktop(5)
RAlt & 7::MoveCurrentWindowToDesktop(6)
RAlt & 8::MoveCurrentWindowToDesktop(7)
RAlt & 9::MoveCurrentWindowToDesktop(8)
RAlt & 0::MoveCurrentWindowToDesktop(9)
RCtrl & 1::MoveCurrentWindowToDesktop(0)
RCtrl & 2::MoveCurrentWindowToDesktop(1)
RCtrl & 3::MoveCurrentWindowToDesktop(2)
RCtrl & 4::MoveCurrentWindowToDesktop(3)
RCtrl & 5::MoveCurrentWindowToDesktop(4)
RCtrl & 6::MoveCurrentWindowToDesktop(5)
RCtrl & 7::MoveCurrentWindowToDesktop(6)
RCtrl & 8::MoveCurrentWindowToDesktop(7)
RCtrl & 9::MoveCurrentWindowToDesktop(8)
RCtrl & 0::MoveCurrentWindowToDesktop(9)

; }}}

; switch to desktop 1-9 {{{
RWin & 1::GoToDesktopNumber(0)
RWin & 2::GoToDesktopNumber(1)
RWin & 3::GoToDesktopNumber(2)
RWin & 4::GoToDesktopNumber(3)
RWin & 5::GoToDesktopNumber(4)
RWin & 6::GoToDesktopNumber(5)
RWin & 7::GoToDesktopNumber(6)
RWin & 8::GoToDesktopNumber(7)
RWin & 9::GoToDesktopNumber(8)
RWin & 0::GoToDesktopNumber(9)
; }}}



;CapsLock::		; CapsLock
;'+CapsLock::Send Ctrl	; Shift+CapsLock
;!CapsLock::	; Alt+CapsLock
;^CapsLock::		; Ctrl+CapsLock
;#CapsLock::		; Win+CapsLock
;^!CapsLock::	; Ctrl+Alt+CapsLock
;^!#CapsLock::	; Ctrl+Alt+Win+CapsLock
;CapsLock & XButton1::
;CapsLock & XButton2::
;CapsLock & Tab::

;LShift & CapsLock::SetCapsLockState, % A_PriorHotkey = "Shift" && A_TimeSincePriorHotkey < 500 ? "On" : "Off"


;CcSwap Ctrl with CapsLock for reachability
;*CapsLock::Ctrl
;*CapsLock::Send {LControl down}
;*CapsLock Up::Send {LControl up}








; Application and tab swiching {{{
; LWin & Tab::AltTab
; LWin & Shift::ShiftAltTab

LWin & Tab::
    AltTabMenu := true
    If GetKeyState("Shift","P")
        Send {Alt Down}{Shift Down}{Tab}
    else
        Send {Alt Down}{Tab}
return

#If (AltTabMenu)

    ~*LWin Up::
        Send {Shift Up}{Alt Up}
        AltTabMenu := false
    return

#If

; }}}




;Ctrl::CapsLock
; #Space::!Space
; Disable Caps Lock key
;SetCapsLockState, AlwaysOff

LCtrl & Left::SendEvent {LWin down}{LCtrl down}{Left down}{LWin up}{LCtrl up}{Left up}
LCtrl & Right::SendEvent {LWin down}{LCtrl down}{Right down}{LWin up}{LCtrl up}{Right up}
;CapsLock & Up::SendEvent {LWin down}{LCtrl down}{Up down}{LWin up}{LCtrl up}{Up up}
;CapsLock & Down::SendEvent {LWin down}{LCtrl down}{Down down}{LWin up}{LCtrl up}{Down up}

LWin & XButton1::SendEvent {LWin down}{LCtrl down}{Left down}{LWin up}{LCtrl up}{Left up}{Esc down}{Esc up}
LWin & XButton2::SendEvent {LWin down}{LCtrl down}{Right down}{LWin up}{LCtrl up}{Right up}{Esc down}{Esc up}


; <#::Ctrl
#::!

;following section remaps alt-delete keys to mimic OSX
;command-delete deletes whole line
#BS::Send {LShift down}{Home}{LShift Up}{Del}

;alt-function-delete deletes next word
!Delete::Send {LShift down}{LCtrl down}{Right}{LShift Up}{Lctrl up}{Del}

;alt-delete deletes previous word
!BS::Send {LShift down}{LCtrl down}{Left}{LShift Up}{Lctrl up}{Del}

;following section mimics command-q and command-w
;behaviour to close windows
;note these had to be disabled below for the
;command to ctrl key remaps
#w::^F4
#q::!F4

;following section remaps alt-arrow and command-arrow
;keys to mimic OSX behaviour
#Up::Send {Lctrl down}{Home}{Lctrl up}
#Down::Send {Lctrl down}{End}{Lctrl up}
#Left::Send {Home}
#Right::Send {End}
!Up::Send {Home}
!Down::Send {End}
!Left::^Left
!Right::^Right

$Ctrl::CapsLock
$CapsLock::Ctrl

; Screenshot: Windows logo key + Shift + S
#+4::Send {LWin down}{Shift down}{s}{LWin up}{Shift up}




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



F7::SendInput {Media_Prev}
F8::SendInput {Media_Play_Pause}
F9::SendInput {Media_Next}
F10::SendInput {Volume_Mute}
F11::SendInput {Volume_Down}
F12::SendInput {Volume_Up}



#IfWinActive  ; This puts subsequent remappings and hotkeys in effect for all windows.

#a::Send ^a
#b::Send ^b
#c::Send ^c
#d::Send ^d
#e::Send ^e
#f::Send ^f
#g::Send ^g
#h::Send ^h
#i::Send ^i
#j::Send ^j
#k::Send ^k
#l::Send ^l
#m::Send ^m
#n::Send ^n
#o::Send ^o
#p::Send ^p
#q::Send ^q
#r::Send ^r
#s::Send ^s
#t::Send ^t
#u::Send ^u
#v::Send ^v
#w::Send ^w
#x::Send ^x
#y::Send ^y
#z::Send ^z
#1::Send ^1
#2::Send ^2
#3::Send ^3
#4::Send ^4
#5::Send ^5
#6::Send ^6
#7::Send ^7
#8::Send ^8
#9::Send ^9
#0::Send ^0

#+z::Send ^y
return


; windows space to ctrl space
#Space::!Space


; CTRL-C and CTRL-V have to have special behavious in terminal window
;#IfWinActive ahk_exe


; MAPS FOR TERMINAL
#IfWinActive ahk_exe wezterm-gui.exe
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
#1::Send ^!1
#2::Send ^!2
#3::Send ^!3
#4::Send ^!4
#5::Send ^!5
#6::Send ^!6
#7::Send ^!7
#8::Send ^!8
#9::Send ^!9
#0::Send ^!0

#=::Send ^!=
#-::Send ^!-


return





; vim: fdm=marker
