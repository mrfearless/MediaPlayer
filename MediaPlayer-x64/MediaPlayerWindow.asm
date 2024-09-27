;==============================================================================
;
; MediaPlayer x64
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
MediaPlayerWindowCreate     PROTO hWndParent:QWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, qwResourceID:QWORD


; MediaPlayerWindow Control Functions (Internal):
_MPWWndProc                 PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
_MPWInit                    PROTO hWin:QWORD


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
MediaPlayerWindowRegister PROC FRAME
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:QWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, rax

    invoke GetClassInfoEx, hinstance, Addr szMPWClass, Addr wc 
    .IF rax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        lea rax, szMPWClass
        mov wc.lpszClassName, rax
        mov rax, hinstance
        mov wc.hInstance, rax
        lea rax, _MPWWndProc
        mov wc.lpfnWndProc, rax 
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, rax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, CS_DBLCLKS
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 16

        Invoke RegisterClassEx, Addr wc
    .ENDIF
    
    ret
MediaPlayerWindowRegister ENDP

;------------------------------------------------------------------------------
; MediaPlayerWindowCreate
;
; Create the MediaPlayerWindow Control. Calls MediaPlayerWindowRegister beforehand.
;
; Returns handle in rax of the newly created control.
;------------------------------------------------------------------------------
MediaPlayerWindowCreate PROC FRAME hWndParent:QWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, qwResourceID:QWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:QWORD
    LOCAL hControl:QWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, rax

    Invoke MediaPlayerWindowRegister

    Invoke CreateWindowEx, NULL, Addr szMPWClass, NULL, WS_CHILD or WS_TABSTOP, xpos, ypos, dwWidth, dwHeight, hWndParent, qwResourceID, hinstance, NULL
    mov hControl, rax
    .IF rax != NULL

    .ENDIF
    mov rax, hControl

    ret
MediaPlayerWindowCreate ENDP

;------------------------------------------------------------------------------
; _MPWWndProc
;
; Main processing window for our MediaPlayerWindow Control.
;------------------------------------------------------------------------------
_MPWWndProc PROC FRAME USES RBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_NCCREATE
        mov rax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke _MPWInit, hWin
        mov rax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke DragAcceptFiles, hWin, FALSE
        mov rax, 0
        ret

    .ELSEIF eax == WM_MOUSEMOVE
        Invoke GUIShowControlsCheck, lParam
        mov rax, 0
        ret
    
    ;--------------------------------------------------------------------------
    ; Drag and drop support
    ;--------------------------------------------------------------------------
    .ELSEIF eax == WM_DROPFILES
        mov rax, wParam
        mov hDrop, rax
        Invoke DragQueryFile, hDrop, 0, Addr szDroppedFilename, SIZEOF szDroppedFilename
        .IF rax != 0
            Invoke MediaPlayerOpenFile, hMainWindow, Addr szDroppedFilename
        .ENDIF
        Invoke DragFinish, hDrop
        mov hDrop, 0
        mov rax, 0
        ret
    
    .ELSEIF eax == WM_CHAR
        .IF wParam == VK_ESCAPE
            .IF g_Fullscreen == TRUE
                Invoke GUIFullscreenExit, hMainWindow
                mov rax, 0
                ret
            .ENDIF
        .ENDIF
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ret
    
    .ELSEIF eax == WM_LBUTTONUP
        Invoke MFPMediaPlayer_Toggle, pMP
        mov rax, 0
        ret
    
    .ELSEIF eax == WM_LBUTTONDBLCLK
        Invoke SetFocus, hWin
        .IF g_Fullscreen == TRUE
            Invoke GUIFullscreenExit, hMainWindow
            mov rax, 0
            ret
        .ELSE
            Invoke GUIFullscreenEnter, hMainWindow
            mov rax, 0
            ret
        .ENDIF
    
    .ELSEIF eax == WM_CONTEXTMENU
        Invoke MPContextMenuTrack, hMainWindow, wParam, lParam
        mov rax, 0
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
_MPWInit PROC FRAME hWin:QWORD
    LOCAL hParent:QWORD
    LOCAL qwStyle:QWORD
    
    Invoke GetParent, hWin
    mov hParent, rax
    
    ; get style and check it is our default at least
    Invoke GetWindowLongPtr, hWin, GWL_STYLE
    mov qwStyle, rax
    and rax, WS_CHILD or WS_TABSTOP
    .IF rax != WS_CHILD or WS_TABSTOP
        mov rax, qwStyle
        or rax, WS_CHILD or WS_TABSTOP
        and rax, (-1 xor WS_VISIBLE) ; remove visible style if specified
        mov qwStyle, rax
        Invoke SetWindowLongPtr, hWin, GWL_STYLE, qwStyle
    .ENDIF
    
    Invoke DragAcceptFiles, hWin, TRUE
    
    ret
_MPWInit ENDP













