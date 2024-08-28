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

; MediaPlayer Label Control Functions:
MediaPlayerLabelRegister   PROTO
MediaPlayerLabelCreate     PROTO hWndParent:DWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, dwResourceID:DWORD, dwStyle:DWORD

; MediaPlayer Label Control Functions (Internal):
_MPLWndProc                 PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
_MPLInit                    PROTO hWin:DWORD
_MPLPaint                   PROTO hWin:DWORD


.CONST
; MediaPlayer Label Control Properties:
@MPL_Init               EQU  0

; MediaPlayer Label Control Colors
MPL_BACKCOLOR           EQU MAINWINDOW_BACKCOLOR
MPL_FS_BACKCOLOR        EQU MAINWINDOW_FS_BACKCOLOR
MPL_TEXTCOLOR           EQU RGB(0,0,0)
MPL_FS_TEXTCOLOR        EQU RGB(240,240,240)

.DATA

szMPLClass              DB 'MediaPlayerLabel',0     ; Class name for creating our MediaPlayerLabel control
szMPLDefaultText        DB "--:--",0

.CODE
;------------------------------------------------------------------------------
; MediaPlayerLabelRegister - Registers the MediaPlayer Label Control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as 'MediaPlayerLabel'
;------------------------------------------------------------------------------
MediaPlayerLabelRegister PROC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx, hinstance, Addr szMPLClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        lea eax, szMPLClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        lea eax, _MPLWndProc
        mov wc.lpfnWndProc, eax 
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, eax
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
MediaPlayerLabelCreate PROC hWndParent:DWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MediaPlayerLabelRegister

    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_VISIBLE
    .IF eax != WS_CHILD or WS_VISIBLE
        or dwNewStyle, WS_CHILD or WS_VISIBLE
    .ENDIF

    Invoke CreateWindowEx, NULL, Addr szMPLClass, Addr szMPLDefaultText, dwNewStyle, xpos, ypos, dwWidth, dwHeight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL

    .ENDIF
    mov eax, hControl

    ret
MediaPlayerLabelCreate ENDP

;------------------------------------------------------------------------------
; _MPLWndProc
;
; Main processing window for our MediaPlayer Label Control
;------------------------------------------------------------------------------
_MPLWndProc PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
        Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke _MPLInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        mov eax, 0
        ret
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MPLPaint, hWin
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_SIZE
        ; Check if internal properties set
        Invoke GetWindowLong, hWin, @MPL_Init
        .IF eax == TRUE ; Yes they are

        .ENDIF
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_SIZING
        ; Check if internal properties set
        Invoke GetWindowLong, hWin, @MPL_Init
        .IF eax == TRUE ; Yes they are

        .ENDIF
        mov eax, 0
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
_MPLInit PROC hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetParent, hWin
    mov hParent, eax

    ;--------------------------------------------------------------------------
    ; Get style and check it is our default at least
    ;--------------------------------------------------------------------------
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, WS_CHILD or WS_VISIBLE ;or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE ;or WS_CLIPCHILDREN
        mov eax, dwStyle
        or eax, WS_CHILD or WS_VISIBLE ;or WS_CLIPCHILDREN
        mov dwStyle, eax
        Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    .ENDIF
    
    Invoke SetWindowLong, hWin, @MPL_Init, TRUE
    
    ret
_MPLInit ENDP

;------------------------------------------------------------------------------
; _MPLPaint
;
; Paint the control, the background, the border and the position.
;------------------------------------------------------------------------------
_MPLPaint PROC USES EBX hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL hFont:DWORD
    LOCAL dwStyle:DWORD
    LOCAL szText[32]:BYTE
    
    Invoke IsWindowVisible, hWin
    .IF eax == FALSE
        mov eax, 0
        ret
    .ENDIF
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    Invoke GetWindowText, hWin, Addr szText, 16
    mov eax, hPosDurFont
    mov hFont, eax
    
    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect                       ; Get dimensions of area to buffer
    Invoke CreateCompatibleDC, hdc                              ; Create memory dc for our buffer
    mov hdcMem, eax
    Invoke SaveDC, hdcMem                                       ; Save hdcMem status for later restore
    
    Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom ; Create bitmap of size that matches dimensions
    mov hBufferBitmap, eax
    Invoke SelectObject, hdcMem, hBufferBitmap                  ; Select our created buffer bitmap into our memory dc
    
    ;----------------------------------------------------------
    ; Paint background of control
    ;----------------------------------------------------------
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
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
    mov eax, dwStyle
    or eax, (DT_SINGLELINE or DT_VCENTER )
    mov dwStyle, eax 
    Invoke SetBkMode, hdcMem, TRANSPARENT
    .IF g_Fullscreen == FALSE
        Invoke SetTextColor, hdcMem, MPL_TEXTCOLOR
    .ELSE
        Invoke SetTextColor, hdcMem, MPL_FS_TEXTCOLOR
    .ENDIF
    Invoke SelectObject, hdcMem, hFont
    Invoke DrawText, hdcMem, Addr szText, -1, Addr rect, dwStyle

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
    mov eax, 0
    
    ret
_MPLPaint ENDP








