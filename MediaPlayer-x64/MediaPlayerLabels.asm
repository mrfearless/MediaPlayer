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

; MediaPlayer Label Control Functions:
MediaPlayerLabelRegister   PROTO
MediaPlayerLabelCreate     PROTO hWndParent:QWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, dwResourceID:QWORD, dwStyle:QWORD

; MediaPlayer Label Control Functions (Internal):
_MPLWndProc                 PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
_MPLInit                    PROTO hWin:QWORD
_MPLPaint                   PROTO hWin:QWORD


.CONST
; MediaPlayer Label Control Properties:
@MPL_Init               EQU  0

; MediaPlayer Label Control Colors
MPL_BACKCOLOR           EQU MAINWINDOW_BACKCOLOR
MPL_FS_BACKCOLOR        EQU MAINWINDOW_FS_BACKCOLOR
MPL_TEXTCOLOR           EQU RGB(0,0,0)
MPL_FS_TEXTCOLOR        EQU RGB(240,240,240)

MPL_MAXTEXTLENGTH       EQU 64

.DATA

IFDEF __UNICODE__
szMPLClass              DB 'M',0,'e',0,'d',0,'i',0,'a',0,'P',0,'l',0,'a',0,'y',0,'e',0,'r',0,'L',0,'a',0,'b',0,'e',0,'l',0     ; Class name for creating our MediaPlayerLabel control
                        DB 0,0,0,0
szMPLDefaultText        DB '-',0,'-',0,':',0,'-',0,'-',0
                        DB 0,0,0,0
ELSE
szMPLClass              DB 'MediaPlayerLabel',0     ; Class name for creating our MediaPlayerLabel control
szMPLDefaultText        DB "--:--",0
ENDIF

.CODE
;------------------------------------------------------------------------------
; MediaPlayerLabelRegister - Registers the MediaPlayer Label Control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as 'MediaPlayerLabel'
;------------------------------------------------------------------------------
MediaPlayerLabelRegister PROC FRAME
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:QWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, rax

    invoke GetClassInfoEx, hinstance, Addr szMPLClass, Addr wc 
    .IF rax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        lea rax, szMPLClass
        mov wc.lpszClassName, rax
        mov rax, hinstance
        mov wc.hInstance, rax
        lea rax, _MPLWndProc
        mov wc.lpfnWndProc, rax 
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, rax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 32

        Invoke RegisterClassEx, Addr wc
    .ENDIF
    ret
MediaPlayerLabelRegister ENDP

;------------------------------------------------------------------------------
; MediaPlayerLabelCreate
;
; Create the MediaPlayer Label Control. Calls MediaPlayerLabelRegister beforehand.
;
; Returns handle in eax of the newly created control.
;------------------------------------------------------------------------------
MediaPlayerLabelCreate PROC FRAME hWndParent:QWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, qwResourceID:QWORD, qwStyle:QWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:QWORD
    LOCAL hControl:QWORD
    LOCAL qwNewStyle:QWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, rax

    Invoke MediaPlayerLabelRegister

    mov rax, qwStyle
    mov qwNewStyle, rax
    and rax, WS_CHILD or WS_VISIBLE
    .IF rax != WS_CHILD or WS_VISIBLE
        or qwNewStyle, WS_CHILD or WS_VISIBLE
    .ENDIF

    Invoke CreateWindowEx, NULL, Addr szMPLClass, Addr szMPLDefaultText, dword ptr qwNewStyle, xpos, ypos, dwWidth, dwHeight, hWndParent, qwResourceID, hinstance, NULL
    mov hControl, rax
    .IF eax != NULL

    .ENDIF
    mov rax, hControl

    ret
MediaPlayerLabelCreate ENDP

;------------------------------------------------------------------------------
; _MPLWndProc
;
; Main processing window for our MediaPlayer Label Control
;------------------------------------------------------------------------------
_MPLWndProc PROC FRAME USES RBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_NCCREATE
        mov rbx, lParam
        Invoke SetWindowText, hWin, (CREATESTRUCT PTR [rbx]).lpszName
        mov rax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke _MPLInit, hWin
        mov rax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        mov rax, 0
        ret
        
    .ELSEIF eax == WM_ERASEBKGND
        mov rax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MPLPaint, hWin
        mov rax, 0
        ret
    
    .ELSEIF eax == WM_SIZE
        ; Check if internal properties set
        Invoke GetWindowLongPtr, hWin, @MPL_Init
        .IF rax == TRUE ; Yes they are

        .ENDIF
        mov rax, 0
        ret
    
    .ELSEIF eax == WM_SIZING
        ; Check if internal properties set
        Invoke GetWindowLongPtr, hWin, @MPL_Init
        .IF rax == TRUE ; Yes they are

        .ENDIF
        mov rax, 0
        ret
        
    .ELSEIF eax == WM_SETTEXT
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        ret
        
    ; custom messages start here

    .ELSE
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ret
        
    .ENDIF
    ret
_MPLWndProc ENDP

;------------------------------------------------------------------------------
; _MPLInit
;
; Set some initial default values
;------------------------------------------------------------------------------
_MPLInit PROC FRAME hWin:QWORD
    LOCAL hParent:QWORD
    LOCAL qwStyle:QWORD
    
    Invoke GetParent, hWin
    mov hParent, rax

    ;--------------------------------------------------------------------------
    ; Get style and check it is our default at least
    ;--------------------------------------------------------------------------
    Invoke GetWindowLongPtr, hWin, GWL_STYLE
    mov qwStyle, rax
    and rax, WS_CHILD or WS_VISIBLE
    .IF rax != WS_CHILD or WS_VISIBLE
        mov rax, qwStyle
        or rax, WS_CHILD or WS_VISIBLE
        mov qwStyle, rax
        Invoke SetWindowLongPtr, hWin, GWL_STYLE, qwStyle
    .ENDIF
    
    Invoke SetWindowLongPtr, hWin, @MPL_Init, TRUE
    
    ret
_MPLInit ENDP

;------------------------------------------------------------------------------
; _MPLPaint
;
; Paint the control, the background, the border and the position.
;------------------------------------------------------------------------------
_MPLPaint PROC FRAME USES RBX hWin:QWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:QWORD
    LOCAL hBrush:QWORD
    LOCAL hFont:QWORD
    LOCAL qwStyle:QWORD
    LOCAL szText[MPL_MAXTEXTLENGTH]:BYTE
    
    Invoke IsWindowVisible, hWin
    .IF rax == FALSE
        mov rax, 0
        ret
    .ENDIF
    
    Invoke GetWindowLongPtr, hWin, GWL_STYLE
    mov qwStyle, rax
    IFDEF __UNICODE__
    Invoke GetWindowText, hWin, Addr szText, (MPL_MAXTEXTLENGTH /2) ; chars
    ELSE
    Invoke GetWindowText, hWin, Addr szText, MPL_MAXTEXTLENGTH
    ENDIF
    mov rax, hPosDurFont
    mov hFont, rax
    
    Invoke BeginPaint, hWin, Addr ps
    mov hdc, rax
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect                       ; Get dimensions of area to buffer
    Invoke CreateCompatibleDC, hdc                              ; Create memory dc for our buffer
    mov hdcMem, rax
    Invoke SaveDC, hdcMem                                       ; Save hdcMem status for later restore
    
    Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom ; Create bitmap of size that matches dimensions
    mov hBufferBitmap, rax
    Invoke SelectObject, hdcMem, hBufferBitmap                  ; Select our created buffer bitmap into our memory dc
    
    ;----------------------------------------------------------
    ; Paint background of control
    ;----------------------------------------------------------
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, rax
    Invoke SelectObject, hdcMem, rax
    .IF g_Fullscreen == FALSE
        Invoke SetBkColor, hdcMem, MPL_BACKCOLOR
        Invoke SetDCBrushColor, hdcMem, MPL_BACKCOLOR
    .ELSE
        Invoke SetBkColor, hdcMem, MPL_FS_BACKCOLOR
        Invoke SetDCBrushColor, hdcMem, MPL_FS_BACKCOLOR
    .ENDIF
    Invoke FillRect, hdcMem, Addr rect, hBrush
    
    ;----------------------------------------------------------
    ; Use pattern brush to texture our background
    ;----------------------------------------------------------
    IFDEF MP_PATTERN_BACKGROUND
    .IF hPatternBrush != 0
        Invoke MPBrushOrgs, hWin, hdcMem, 0, 0
        Invoke SelectObject, hdcMem, hPatternBrush
        Invoke PatBlt, hdcMem, 0, 0, rect.right, rect.bottom, PATINVERT
        Invoke SetBrushOrgEx, hdcMem, 0, 0, 0 ; reset the brush origin  
    .ENDIF
    ENDIF
    
    ;----------------------------------------------------------
    ; Draw Text
    ;----------------------------------------------------------
    mov rax, qwStyle
    or rax, (DT_SINGLELINE or DT_VCENTER ) ;or DT_NOCLIP
    mov qwStyle, rax 
    Invoke SetBkMode, hdcMem, TRANSPARENT
    .IF g_Fullscreen == FALSE
        Invoke SetTextColor, hdcMem, MPL_TEXTCOLOR
    .ELSE
        Invoke SetTextColor, hdcMem, MPL_FS_TEXTCOLOR
    .ENDIF
    Invoke SelectObject, hdcMem, hFont
    Invoke DrawText, hdcMem, Addr szText, -1, Addr rect, dword ptr qwStyle

    ;----------------------------------------------------------
    ; Copy back to main hdc from hdcMem
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Finish Double Buffering & Cleanup
    ;----------------------------------------------------------    
    Invoke RestoreDC, hdcMem, -1                                ; restore last saved state, which is just after hdcMem was created
    Invoke DeleteObject, hBufferBitmap                          ; Delete bitmap used for double buffering
    Invoke DeleteDC, hdcMem                                     ; Delete double buffer hdc
    
    Invoke EndPaint, hWin, Addr ps
    mov rax, 0
    
    ret
_MPLPaint ENDP








