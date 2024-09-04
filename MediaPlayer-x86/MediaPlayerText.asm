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

; MediaPlayerText Control Functions:
MediaPlayerTextRegister   PROTO
MediaPlayerTextCreate     PROTO hWndParent:DWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, dwResourceID:DWORD


; MediaPlayerText Control Functions (Internal):
_MPTWndProc                 PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
_MPTInit                    PROTO hWin:DWORD
_MPTPaint                   PROTO hWin:DWORD
_MPTSize                    PROTO hWin:DWORD
_MPTSubclass                PROTO hWin:DWORD
_MPTReflect                 PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, uIdSubclass:UINT, dwRefData:DWORD
_MPTChildPopup              PROTO hWin:DWORD, bChild:DWORD
_MPTPaintText               PROTO hWin:HWND;, hdc:DWORD

.DATA
IFDEF __UNICODE__
szMPTClass                  DB 'M',0,'e',0,'d',0,'i',0,'a',0,'P',0,'l',0,'a',0,'y',0,'e',0,'r',0,'T',0,'e',0,'x',0,'t',0
                            DB 0,0,0,0
szMPTTestText               DB 'T',0,'e',0,'s',0,'t',0,'i',0,'n',0,'g',0,' ',0,'T',0,'e',0,'s',0,'t',0,'e',0,'r',0,' ',0
                            DB 'T',0,'e',0,'s',0,'t',0,' ',0,'T',0,'s',0,'t',0,' ',0,'T',0,'s',0,'t',0,' ',0,'T',0,'e',0,'s',0,'t',0,' ',0
                            DB 'T',0,'e',0,'s',0,'t',0,'e',0,'r',0,' ',0,'T',0,'e',0,'s',0,'t',0,'i',0,'n',0,'g',0
                            DB 0,0,0,0
ELSE
szMPTClass                  DB 'MediaPlayerText',0
szMPTTestText               DB 'Testing Tester Test Tst Tst Test Tester Testing',0
ENDIF

hMPTFont                    DD 0
MPT_SUBCLASS_ID             DD 0000000A0h

szMFTTextBuffer             DB 1024 DUP (0)

.CODE

;------------------------------------------------------------------------------
; MediaPlayerTextRegister
; 
; Registers the MediaPlayerText Control.
;
; Can be used at start of program for use with RadASM custom control
; Custom control class must be set as 'MediaPlayerText'
;------------------------------------------------------------------------------
MediaPlayerTextRegister PROC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx, hinstance, Addr szMPTClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        lea eax, szMPTClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        lea eax, _MPTWndProc
        mov wc.lpfnWndProc, eax 
        mov wc.hCursor, NULL
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, eax
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 12

        Invoke RegisterClassEx, Addr wc
    .ENDIF
    
    ret
MediaPlayerTextRegister ENDP

;------------------------------------------------------------------------------
; MediaPlayerTextCreate
;
; Create the MediaPlayerText Control. Calls MediaPlayerTextRegister beforehand.
;
; Returns handle in eax of the newly created control.
;------------------------------------------------------------------------------
MediaPlayerTextCreate PROC hWndParent:DWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, dwResourceID:DWORD
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MediaPlayerTextRegister

    mov dwStyle, WS_POPUP ;or WS_VISIBLE ; WS_CLIPCHILDREN or WS_CLIPSIBLINGS or 
    ;mov dwStyle, WS_CHILD ;or WS_VISIBLE

    Invoke CreateWindowEx, WS_EX_TOPMOST or WS_EX_TOOLWINDOW, Addr szMPTClass, NULL, dwStyle, xpos, ypos, dwWidth, dwHeight, hWndParent, NULL, hinstance, NULL ; dwResourceID 
    ;Invoke CreateWindowEx, WS_EX_TOPMOST or WS_EX_TOOLWINDOW, Addr szMPTClass, NULL, dwStyle, xpos, ypos, dwWidth, dwHeight, hWndParent, dwResourceID, hinstance, NULL ;WS_EX_TOPMOST or WS_EX_TOOLWINDOW 
    
    mov hControl, eax
    .IF eax != NULL
        
    .ENDIF
    PrintDec hControl
    mov eax, hControl

    ret
MediaPlayerTextCreate ENDP

;------------------------------------------------------------------------------
; _MPTWndProc
;
; Main processing window for our MediaPlayerText Control.
;------------------------------------------------------------------------------
_MPTWndProc PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
        Invoke SetWindowText, hWin, Addr szMPTTestText ;(CREATESTRUCT PTR [ebx]).lpszName
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke _MPTInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        mov eax, 0
        ret

    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret
    
    .ELSEIF eax == WM_PAINT
        Invoke _MPTPaint, hWin
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_NCHITTEST
        mov eax, HTCAPTION
        ret
    
;    .ELSEIF eax == WM_SYSCOMMAND
;        ;PrintDec wParam
;        mov eax, wParam
;        .IF eax == SC_MINIMIZE
;            mov eax, 0
;            ret
;        .ELSE
;            Invoke DefWindowProc, hWin, uMsg, wParam, lParam
;            ret
;        .ENDIF
    
;    .ELSEIF eax == WM_SIZE
;        PrintText '_MPTWndProc::WM_SIZE'
;;        mov eax, wParam
;;        PrintDec eax
;;        .IF eax == SIZE_MINIMIZED
;;            PrintText 'SIZE_MINIMIZED'
;;        .ELSEIF eax == SIZE_MAXHIDE
;;            PrintText 'SIZE_MAXHIDE'
;;        .ELSEIF eax == SIZE_MAXSHOW
;;            PrintText 'SIZE_MAXSHOW'
;;        .ENDIF
;        Invoke _MPTSize, hWin
;        mov eax, 0
;        ret
;
;    .ELSEIF eax == WM_LBUTTONUP
;    
;    .ELSEIF eax == WM_LBUTTONDBLCLK
;    
;    .ELSEIF eax == WM_CONTEXTMENU

    .ELSEIF eax == WM_SETTEXT
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        ret

    .ELSE
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ret
    .ENDIF

    ret
_MPTWndProc ENDP

;------------------------------------------------------------------------------
; _MPTInit
;
; Set some initial default values
;------------------------------------------------------------------------------
_MPTInit PROC hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwExStyle:DWORD
    LOCAL rectparent:RECT
    LOCAL dwWidth:DWORD
    LOCAL dwHeight:DWORD
    LOCAL dwXPos:DWORD
    LOCAL dwYPos:DWORD
    
    IFDEF DEBUG32
    PrintText '_MPTInit'
    ENDIF
    
    Invoke GetParent, hWin
    mov hParent, eax
;    
    Invoke GetWindowRect, hParent, Addr rectparent
    IFDEF DEBUG32
    ;PrintDec rectparent.left
    ;PrintDec rectparent.top
    ;PrintDec rectparent.right
    ;PrintDec rectparent.bottom
    ENDIF  
    
;    Invoke GetWindowLong, hWin, GWL_STYLE
;    mov dwStyle, eax
;    or eax, WS_CHILD or WS_VISIBLE;WS_POPUP
;    and eax, (-1 xor WS_POPUP)
;    mov dwStyle, eax
;    Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    
;    Invoke GetWindowLong, hWin, GWL_STYLE
;    mov dwStyle, eax
;    or eax, WS_POPUP or WS_VISIBLE;
;    and eax, (-1 xor WS_CHILD)
;    mov dwStyle, eax
;    Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    
;    Invoke GetWindowLong, hWin, GWL_STYLE
;    mov dwStyle, eax
;    or eax, WS_CHILD or WS_VISIBLE
;    and eax, (-1 xor WS_POPUP)
;    mov dwStyle, eax
;    Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    
;    Invoke GetWindowLong, hWin, GWL_STYLE
;    or eax, WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_VISIBLE ;or WS_TABSTOP ;or DS_CONTROL
;    mov dwStyle, eax
;    Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    
;    Invoke GetWindowLong, hWin, GWL_EXSTYLE
;    mov dwExStyle, eax
;    and eax, WS_EX_TOPMOST or WS_EX_TOOLWINDOW
;    .IF eax != WS_EX_TOPMOST or WS_EX_TOOLWINDOW
;        mov eax, dwExStyle
;        or eax, WS_EX_TOPMOST or WS_EX_TOOLWINDOW
;        mov dwExStyle, eax
;        Invoke SetWindowLong, hWin, GWL_EXSTYLE, dwExStyle
;    .ENDIF
    
    ;Invoke SetParent, hWin, hParent
    
    ;--------------------------------------------------------------------------
    ; Subclass for reflection of parent events we want
    ;--------------------------------------------------------------------------
    Invoke _MPTSubclass, hWin
    
    ret
_MPTInit ENDP

;------------------------------------------------------------------------------
; _MPTPaint
;
; Paint the control, the background, the border and the position.
;------------------------------------------------------------------------------
_MPTPaint PROC USES EBX hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL hdc:DWORD
    LOCAL hParent:DWORD
    LOCAL hMPTFontOld:DWORD
    LOCAL hBrush:DWORD
    LOCAL hBrushOld:DWORD
    LOCAL rect:RECT
    
    IFDEF DEBUG32
    ;PrintText '_MPTPaint'
    ENDIF
    
;    Invoke GetWindowTextLength, hWin
;    .IF eax == 0
;        ret
;    .ENDIF

    
    
    ;Invoke GetParent, hWin
    mov eax, hMediaPlayerWindow
    mov hParent, eax
    
;    Invoke IsWindowVisible, hParent
;    .IF eax == FALSE
;        ret
;    .ENDIF
    
    Invoke GetWindowText, hWin, Addr szMFTTextBuffer, SIZEOF szMFTTextBuffer
    
    ;Invoke GetClientRect, hParent, Addr rect
    Invoke GetClientRect, hWin, Addr rect
    IFDEF DEBUG32
    ;PrintDec rect.left
    ;PrintDec rect.top
    ;PrintDec rect.right
    ;PrintDec rect.bottom
    ENDIF
    
    ;Invoke GetDC, hParent
    ;mov hdc, eax
    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax
    
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, hBrush
    mov hBrushOld, eax
    Invoke SetDCBrushColor, hdc, RGB(0,0,0)
    Invoke FillRect, hdc, Addr rect, hBrush
    
    Invoke SetBkMode, hdc, OPAQUE ; TRANSPARENT; 
    Invoke SetBkColor, hdc, RGB(0,0,0)
    Invoke SetTextColor, hdc, RGB(255,255,255)
    Invoke SelectObject, hdc, hMPTFont
    mov hMPTFontOld, eax
    
    ;mov rect.top, 50
    
    Invoke DrawText, hdc, Addr szMFTTextBuffer, -1, Addr rect, DT_CENTER or DT_WORDBREAK
    
    Invoke SelectObject, hdc, hMPTFontOld
    Invoke SelectObject, hdc, hBrushOld
    Invoke DeleteObject, hBrushOld
    
    Invoke EndPaint, hWin, Addr ps
    mov eax, 0
    
    ;Invoke ReleaseDC, hParent, hdc

    ret
_MPTPaint ENDP

;------------------------------------------------------------------------------
; _MPTSize
;
; Sizes the text overlay
;------------------------------------------------------------------------------
_MPTSize PROC USES EBX hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL rectparent:RECT
    LOCAL dwWidth:DWORD
    LOCAL dwHeight:DWORD
    LOCAL dwXPos:DWORD
    LOCAL dwYPos:DWORD
    
    IFDEF DEBUG32
    ;PrintText '_MPTSize'
    ENDIF
    
    Invoke GetParent, hWin
    mov hParent, eax
    
    ;Invoke GetClientRect, hParent, Addr rectparent
    Invoke GetWindowRect, hParent, Addr rectparent
    ;Invoke GetWindowRect, hMainWindow, Addr rectparent
    IFDEF DEBUG32
    ;PrintDec rectparent.left
    ;PrintDec rectparent.top
    ;PrintDec rectparent.right
    ;PrintDec rectparent.bottom
    ENDIF    
    
    mov eax, rectparent.right
    sub eax, rectparent.left
    sub eax, MFPLAYER_LEFT
    sub eax, MFPLAYER_LEFT
    sub eax, MFPLAYER_RIGHT
    sub eax, MFPLAYER_RIGHT
    mov dwWidth, eax
    
    mov dwHeight, 80
    
    mov eax, rectparent.left
    add eax, MFPLAYER_LEFT
    add eax, MFPLAYER_LEFT
    mov dwXPos, eax
    
    mov eax, rectparent.bottom
    sub eax, MFPLAYER_TOP
    sub eax, MFPLAYER_BOTTOM
    sub eax, 80
    mov dwYPos, eax

    Invoke SetWindowPos, hWin, NULL, dwXPos, dwYPos, dwWidth, dwHeight, SWP_NOZORDER ;or SWP_FRAMECHANGED
    ;Invoke InvalidateRect, hWin, NULL, TRUE
    ret

_MPTSize ENDP

;------------------------------------------------------------------------------
; _MPTSubclass - Subclass parent window of MPT for msg reflect
;------------------------------------------------------------------------------
_MPTSubclass PROC hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL hWndSubClass:DWORD
    
    IFDEF DEBUG32
    PrintText '_MPTSubclass'
    ENDIF
    
    Invoke GetParent, hWin
    mov hParent, eax

    inc MPT_SUBCLASS_ID
    Invoke SetWindowSubclass, hParent, Addr _MPTReflect, MPT_SUBCLASS_ID, hWin

    ret
_MPTSubclass ENDP

;------------------------------------------------------------------------------
; _MPTReflect - Parent window of MPT subclass proc
;------------------------------------------------------------------------------
_MPTReflect PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, uIdSubclass:UINT, dwRefData:DWORD
    LOCAL dwStyle:DWORD
    LOCAL ps:PAINTSTRUCT
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hParent:DWORD
    
    IFDEF DEBUG32
    ;PrintText '_MPTReflect'
    ENDIF
    
    mov eax, uMsg
    .IF eax == WM_NCDESTROY
        Invoke RemoveWindowSubclass, hWin, Addr _MPTReflect, uIdSubclass
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam 
        ret
    
;    .ELSEIF eax == WM_ERASEBKGND
;        Invoke _MPTPaintText, hWin
;        mov eax, 1
;        ret
    
;    .ELSEIF eax == WM_PAINT
;        Invoke BeginPaint, dwRefData, Addr ps
;        mov hdc, eax
;        Invoke EndPaint, dwRefData, Addr ps
;        mov eax, 0
;        ret
    
    
;        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
;        Invoke _MPTPaintText, hWin;, hdc
;        ret
;        
;        .IF pMP != 0 ;&& g_Playing == TRUE
;            Invoke BeginPaint, hWin, Addr ps
;            mov hdc, eax
;            Invoke _MPTPaintText, hWin;, hdc
;            Invoke EndPaint, hWin, Addr ps
;            mov eax, 0
;            ret
;        .ELSE
;            ret
;        .ENDIF
;    
;    .ELSEIF eax == WM_SIZE
;        .IF wParam == SIZE_RESTORED
;            .IF pMP != 0 ;&& g_Playing == TRUE 
;                Invoke BeginPaint, dwRefData, Addr ps
;                mov hdc, eax
;                Invoke MFPMediaPlayer_UpdateVideo, pMP
;                Invoke EndPaint, dwRefData, Addr ps
;                mov eax, 0
;                ret
;            .ENDIF
;        .ELSE
;            Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
;            ret
;        .ENDIF
    
    .ELSEIF eax == WM_SYSCOMMAND
        ;PrintText 'WM_SYSCOMMAND'
        mov eax, wParam
        .IF eax == SC_CLOSE
        .ELSEIF eax == SC_RESTORE
            PrintText 'WM_SYSCOMMAND::SC_RESTORE'
            Invoke _MPTChildPopup, dwRefData, FALSE
            Invoke _MPTSize, dwRefData
            Invoke ShowWindow, dwRefData, SW_SHOWNA
        .ELSEIF eax == SC_MINIMIZE
            PrintText 'WM_SYSCOMMAND::SC_MINIMIZE'
            Invoke _MPTChildPopup, dwRefData, TRUE
            ;Invoke ShowWindow, dwRefData, SW_HIDE
            ;Invoke ShowWindow, dwRefData, SW_SHOWNA
        .ELSEIF eax == SC_MAXIMIZE
            PrintText 'WM_SYSCOMMAND::SC_MAXIMIZE'
;            Invoke ShowWindow, dwRefData, SW_HIDE
;            Invoke ShowWindow, dwRefData, SW_SHOWNA
        .ENDIF
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
        ret
    
;    .ELSEIF eax == WM_ACTIVATE
;        mov eax, wParam
;        and eax, 0FFFFh
;        .IF eax == WA_INACTIVE
;            Invoke _MPTChildPopup, dwRefData, TRUE
;            Invoke ShowWindow, dwRefData, SW_HIDE
;            Invoke _MPTSize, dwRefData
;        .ELSEIF eax == WA_CLICKACTIVE
;            Invoke _MPTChildPopup, dwRefData, FALSE
;            Invoke ShowWindow, dwRefData, SW_SHOWNA
;            Invoke _MPTSize, dwRefData
;        .ENDIF
;        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
;        ret
    
    .ELSEIF eax == WM_MOVE
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
        Invoke _MPTSize, dwRefData
        ret
    
    .ELSEIF eax == WM_MOVING
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
        Invoke _MPTSize, dwRefData
        ret
        
    .ELSEIF eax == WM_SIZE
        mov eax, wParam
        .IF eax == SIZE_RESTORED
            ;PrintText 'WM_SIZE::SIZE_RESTORED'
            Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
            Invoke _MPTSize, dwRefData
            ;Invoke UpdateWindow, dwRefData
            Invoke ShowWindow, dwRefData, SW_SHOWNA
            Invoke InvalidateRect, dwRefData, NULL, TRUE
        .ELSEIF eax == SIZE_MAXIMIZED
            ;PrintText 'WM_SIZE::SIZE_MAXIMIZED'
            Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
            Invoke _MPTSize, dwRefData
            Invoke ShowWindow, dwRefData, SW_SHOWNA
            Invoke InvalidateRect, dwRefData, NULL, TRUE
            ;Invoke UpdateWindow, dwRefData
        .ELSEIF eax == SIZE_MAXSHOW
            PrintText 'WM_SIZE::SIZE_MAXSHOW'
            Invoke _MPTSize, dwRefData ;hWin
            Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
        .ELSEIF eax == SIZE_MAXHIDE
            PrintText 'WM_SIZE::SIZE_MAXHIDE'
            Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
            Invoke ShowWindow, dwRefData, SW_SHOWNA
        .ELSEIF eax == SIZE_MINIMIZED
            PrintText 'WM_SIZE::SIZE_MINIMIZED'
            Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
        .ENDIF
        ret
    
    .ELSEIF eax == WM_SIZING
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
        Invoke _MPTSize, dwRefData
        ret
        
    .ELSE
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
        ret
    .ENDIF
    
    Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
    ret
_MPTReflect ENDP

;------------------------------------------------------------------------------
; _MPTChildPopup - switch styles to and from WS_CHILD and WS_POPUP
;------------------------------------------------------------------------------
_MPTChildPopup PROC hWin:DWORD, bChild:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    .IF bChild == TRUE
        and eax, WS_CHILD
        .IF eax == WS_CHILD
            ret
        .ENDIF
        mov eax, dwStyle
        or eax, WS_CHILD
        and eax, (-1 xor WS_POPUP)
        mov dwStyle, eax
    .ELSE
        and eax, WS_POPUP
        .IF eax == WS_POPUP
            ret
        .ENDIF
        mov eax, dwStyle
        or eax, WS_POPUP
        and eax, (-1 xor WS_CHILD)
        mov dwStyle, eax
    .ENDIF
    Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    
    Invoke SetWindowPos, hWin, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_NOZORDER or SWP_FRAMECHANGED ;  or SWP_NOSENDCHANGING or SWP_NOREDRAW or SWP_NOACTIVATE or 
    
    ret
_MPTChildPopup ENDP

;------------------------------------------------------------------------------
; _MPTPaintText
;------------------------------------------------------------------------------
_MPTPaintText PROC hWin:DWORD;, hdc:DWORD
    LOCAL hdc:DWORD
    LOCAL hParent:DWORD
    LOCAL hMPTFontOld:DWORD
    LOCAL hBrush:DWORD
    LOCAL hBrushOld:DWORD
    LOCAL rect:RECT
    
    IFDEF DEBUG32
    ;PrintText '_MPTPaintText'
    ENDIF
    
    Invoke GetDC, hWin
    mov hdc, eax
    
    Invoke GetWindowText, hWin, Addr szMFTTextBuffer, SIZEOF szMFTTextBuffer
    Invoke GetClientRect, hWin, Addr rect
    IFDEF DEBUG32
    ;PrintDec rect.left
    ;PrintDec rect.top
    ;PrintDec rect.right
    ;PrintDec rect.bottom
    ENDIF
    
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, hBrush
    mov hBrushOld, eax
    Invoke SetDCBrushColor, hdc, RGB(0,0,0)
    Invoke FillRect, hdc, Addr rect, hBrush
    
    Invoke SetBkMode, hdc, OPAQUE ; TRANSPARENT; 
    Invoke SetBkColor, hdc, RGB(0,0,0)
    Invoke SetTextColor, hdc, RGB(255,255,255)
    Invoke SelectObject, hdc, hMPTFont
    mov hMPTFontOld, eax
    
    mov rect.top, 50
    
    Invoke DrawText, hdc, Addr szMFTTextBuffer, -1, Addr rect, DT_CENTER or DT_WORDBREAK
    
    Invoke SelectObject, hdc, hMPTFontOld
    Invoke SelectObject, hdc, hBrushOld
    Invoke DeleteObject, hBrushOld
    
    Invoke ReleaseDC, hWin, hdc
    
    ret
_MPTPaintText ENDP















