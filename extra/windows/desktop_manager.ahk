
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

; }}}


; vim: fdm=marker
