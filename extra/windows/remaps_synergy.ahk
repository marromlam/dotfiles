; -----KEY GUIDE-----
; # Win. (the key with the Windows logo) therefore `Send #e` would hold down Win and then press E.
; + Shift. For example, `Send, +abC` would send the text "AbC", and `Send, !+a` would press Alt+Shift+A.
; ^ Alt (because of remapkey). For example, `Send, This is text!a` would send the keys "This is text" and then press Alt+A. Note: !A produces a different effect in some programs than !a. This is because !A presses Alt+Shift+A and !a presses Alt+A. If in doubt, use lowercase.
; ! Ctrl (because of remapkey). For example, `Send, ^!a` would press Ctrl+Alt+A, and Send, ^{Home} would send Ctrl+Home. Note: ^A produces a different effect in some programs than ^a. This is because ^A presses Ctrl+Shift+A and ^a presses Ctrl+A. If in doubt, use lowercase.Sends Ctrl. For example, Send, ^!a would press Ctrl+Alt+A, and Send, ^{Home} would send Ctrl+Home. Note: ^A produces a different effect in some programs than ^a. This is because ^A presses Ctrl+Shift+A and ^a presses Ctrl+A. If in doubt, use lowercase.
; & An ampersand may be used between any two keys or mouse buttons to combine them into a custom hotkey.

; #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; AutoHotkey v2 script
SetWorkingDir(A_ScriptDir)



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


; Move window to desktop 1-9 {{{

; RAlt::LAlt
!+1::MoveCurrentWindowToDesktop(0)
!@::MoveCurrentWindowToDesktop(1)
#!::MoveCurrentWindowToDesktop(2)
+!4::MoveCurrentWindowToDesktop(3)
+!5::MoveCurrentWindowToDesktop(4)
+!6::MoveCurrentWindowToDesktop(5)
+!7::MoveCurrentWindowToDesktop(6)
+!8::MoveCurrentWindowToDesktop(7)
+!9::MoveCurrentWindowToDesktop(8)
+!0::MoveCurrentWindowToDesktop(9)

; }}}

; switch to desktop 1-9 {{{

!1::GoToDesktopNumber(0)
!2::GoToDesktopNumber(1)
!3::GoToDesktopNumber(2)
!4::GoToDesktopNumber(3)
!5::GoToDesktopNumber(4)
!6::GoToDesktopNumber(5)
!7::GoToDesktopNumber(6)
!8::GoToDesktopNumber(7)
!9::GoToDesktopNumber(8)
!0::GoToDesktopNumber(9)

; }}} 


; START 1! ----------------
; FINAL 1! 2@ 3# 4$ 5% 6^ 7& 8* 9( 0) -_ =+ 











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



LCtrl & Left::SendEvent {LWin down}{LCtrl down}{Left down}{LWin up}{LCtrl up}{Left up}
LCtrl & Right::SendEvent {LWin down}{LCtrl down}{Right down}{LWin up}{LCtrl up}{Right up}
;CapsLock & Up::SendEvent {LWin down}{LCtrl down}{Up down}{LWin up}{LCtrl up}{Up up}
;CapsLock & Down::SendEvent {LWin down}{LCtrl down}{Down down}{LWin up}{LCtrl up}{Down up}

LWin & XButton1::SendEvent {LWin down}{LCtrl down}{Left down}{LWin up}{LCtrl up}{Left up}{Esc down}{Esc up}
LWin & XButton2::SendEvent {LWin down}{LCtrl down}{Right down}{LWin up}{LCtrl up}{Right up}{Esc down}{Esc up}


; <#::Ctrl
;#::!

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





; TODO fix some wrong symbols here
;$`::Send `±
;$+`::Send `§

;+$+::Send c

;ZZz
;
;




F3::Send {Win}{Tab}

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
