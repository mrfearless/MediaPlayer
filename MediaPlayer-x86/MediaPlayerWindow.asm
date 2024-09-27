;==============================================================================
;
; MediaPlayer x86
;
; http://github.com/mrfearless
;
; This software is provided 'as-is', without any express or implied warranty. 
; In no event will the author be held liable for any damages arising from the 
; use of this software.
;
;==============================================================================

; MediaPlayerWindow Control Functions:
MediaPlayerWindowRegister   PROTO
MediaPlayerWindowCreate     PROTO hWndParent:DWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, dwResourceID:DWORD


; MediaPlayerWindow Control Functions (Internal):
_MPWWndProc                 PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
_MPWInit                    PROTO hWin:DWORD

.CONST


.DATA
ALIGN 4

IFDEF __UNICODE__
szMPWClass                  DB 'M',0,'e',0,'d',0,'i',0,'a',0,'P',0,'l',0,'a',0,'y',0,'e',0,'r',0,'W',0,'i',0,'n',0,'d',0,'o',0,'w',0
                            DB 0,0,0,0
ELSE
szMPWClass                  DB 'MediaPlayerWindow',0
ENDIF

.CODE

;------------------------------------------------------------------------------
; MediaPlayerWindowRegister
; 
; Registers the MediaPlayerWindow Control.
;
; Can be used at start of program for use with RadASM custom control
; Custom control class must be set as 'MediaPlayerWindow'
;------------------------------------------------------------------------------
MediaPlayerWindowRegister PROC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx, hinstance, Addr szMPWClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        lea eax, szMPWClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        lea eax, _MPWWndProc
        mov wc.lpfnWndProc, eax 
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, eax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, CS_DBLCLKS
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 12

        Invoke RegisterClassEx, Addr wc
    .ENDIF
    
    ret
MediaPlayerWindowRegister ENDP

;------------------------------------------------------------------------------
; MediaPlayerWindowCreate
;
; Create the MediaPlayerWindow Control. Calls MediaPlayerWindowRegister beforehand.
;
; Returns handle in eax of the newly created control.
;------------------------------------------------------------------------------
MediaPlayerWindowCreate PROC hWndParent:DWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, dwResourceID:DWORD
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MediaPlayerWindowRegister

    Invoke CreateWindowEx, NULL, Addr szMPWClass, NULL, WS_CHILD or WS_TABSTOP, xpos, ypos, dwWidth, dwHeight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL

    .ENDIF
    mov eax, hControl

    ret
MediaPlayerWindowCreate ENDP

;------------------------------------------------------------------------------
; _MPWWndProc
;
; Main processing window for our MediaPlayerWindow Control.
;------------------------------------------------------------------------------
_MPWWndProc PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_NCCREATE
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke _MPWInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke DragAcceptFiles, hWin, FALSE
        mov eax, 0
        ret

    .ELSEIF eax == WM_MOUSEMOVE
        Invoke GUIShowControlsCheck, lParam
        mov eax, 0
        ret
    
    ;--------------------------------------------------------------------------
    ; Drag and drop support
    ;--------------------------------------------------------------------------
    .ELSEIF eax == WM_DROPFILES
        mov eax, wParam
        mov hDrop, eax
        Invoke DragQueryFile, hDrop, 0, Addr szDroppedFilename, SIZEOF szDroppedFilename
        .IF eax != 0
            Invoke MediaPlayerOpenFile, hMainWindow, Addr szDroppedFilename
        .ENDIF
        Invoke DragFinish, hDrop
        mov hDrop, 0
        mov eax, 0
        ret

    .ELSEIF eax == WM_CHAR
        .IF wParam == VK_ESCAPE
            .IF g_Fullscreen == TRUE
                Invoke GUIFullscreenExit, hMainWindow
                mov eax, 0
                ret
            .ENDIF
        .ENDIF
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ret
    
    .ELSEIF eax == WM_LBUTTONUP
        Invoke MFPMediaPlayer_Toggle, pMP
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_LBUTTONDBLCLK
        Invoke SetFocus, hWin
        .IF g_Fullscreen == TRUE
            Invoke GUIFullscreenExit, hMainWindow
            mov eax, 0
            ret
        .ELSE
            Invoke GUIFullscreenEnter, hMainWindow
            mov eax, 0
            ret
        .ENDIF
    
    .ELSEIF eax == WM_CONTEXTMENU
        Invoke MPContextMenuTrack, hMainWindow, wParam, lParam
        mov eax, 0
        ret
    .ELSE
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ret
    .ENDIF
    
    xor eax, eax
    ret
_MPWWndProc ENDP

;------------------------------------------------------------------------------
; _MPWInit
;
; Set some initial default values
;------------------------------------------------------------------------------
_MPWInit PROC hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetParent, hWin
    mov hParent, eax
    
    ; get style and check it is our default at least
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, WS_CHILD or WS_TABSTOP
    .IF eax != WS_CHILD or WS_TABSTOP
        mov eax, dwStyle
        or eax, WS_CHILD or WS_TABSTOP
        and eax, (-1 xor WS_VISIBLE) ; remove visible style if specified
        mov dwStyle, eax
        Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    .ENDIF
    
    Invoke DragAcceptFiles, hWin, TRUE
    
    ret
_MPWInit ENDP











