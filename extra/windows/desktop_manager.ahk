
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

OpenExplorer() {
    SetTitleMatchMode 2
    if (!WinExist("ahk_class CabinetWClass")) {
        Run explorer.exe
    }
    WinActivate, CabinetWClass
    ; WinGetPos, X, Y, Width, Height, ahk_class CabinetWClass
    Sleep 300
    WinMove, A,, 100, 100, 650, 698
    ; WinMove, A, , %X%, %Y%, %Width%, %Height%
    GoToDesktopNumber(0)
}

OpenFirefox() {
    SetTitleMatchMode 2
    if (!WinExist("ahk_class MozillaWindowClass")) {
        Run firefox.exe
    }
    WinActivate, MozillaWindowClass
    WinGetPos, X, Y, Width, Height, ahk_class MozillaWindowClass
    Sleep 300
    ; WinMove, A,, 0, 0, 650, 698
    WinMove, A, , %X%, %Y%, %Width%, %Height%
    GoToDesktopNumber(2)
}

OpenTeams() {
    SetTitleMatchMode 2
    if (!WinExist("ahk_class TeamsWebView")) {
            Run ms-teams.exe
    }
    WinActivate, TeamsWebView
    WinGetPos, X, Y, Width, Height, ahk_class TeamsWebView
    Sleep 300
    ; WinMove, A,, 0, 0, 650, 698
    WinMove, A, , %X%, %Y%, %Width%, %Height%
    GoToDesktopNumber(3)
}

OpenOutlook() {
    SetTitleMatchMode 2
    if (!WinExist("ahk_exe olk.exe")) {
            Run olk.exe
    }
    WinActivate, olk.exe 
    ; WinGetPos, X, Y, Width, Height, ahk_exe olk.exe
    Sleep 300
    WinMove, A,, 0, 0, 650, 698
    ; WinMove, A, , %X%, %Y%, %Width%, %Height%
    WinMaximize, A
    GoToDesktopNumber(9)
}


#1::OpenExplorer()
#2::GoToDesktopNumber(1)
#3::OpenFirefox()
#4::OpenTeams()
#5::GoToDesktopNumber(4)
#6::GoToDesktopNumber(5)
#7::GoToDesktopNumber(6)
#8::GoToDesktopNumber(7)
#9::GoToDesktopNumber(8)
#0::OpenOutlook()

; }}}


; vim: fdm=marker
