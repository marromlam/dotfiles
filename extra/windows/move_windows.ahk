#Persistent
SetTitleMatchMode, 2 ; Allows matching partial titles
SetTimer, MoveExplorerToDesktop1, 500 ; Run every 500ms
return

MoveExplorerToDesktop1:
; Look for File Explorer windows
#IfWinExist, ahk_class CabinetWClass
{
    ; Switch to Desktop 1
    Send, ^#Left
    Sleep, 500 ; Wait for the desktop to switch

    ; Activate and position File Explorer
    WinActivate, ahk_class CabinetWClass
    WinMove, ahk_class CabinetWClass, , 100, 100, 1000, 700 ; Adjust size and position as needed
}
return