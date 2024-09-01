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

; MediaPlayer Volume Control Functions:
MediaPlayerVolumeRegister   PROTO
MediaPlayerVolumeCreate     PROTO hWndParent:QWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, qwResourceID:QWORD, qwStyle:QWORD
MPVInit                     PROTO hControl:QWORD, pMediaPlayer:QWORD
MediaPlayerVolumeSet        PROTO hControl:QWORD, dwVolume:DWORD


; MediaPlayer Volume Control Functions (Internal):
_MPVWndProc                 PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
_MPVInit                    PROTO hWin:QWORD
_MPVPaint                   PROTO hWin:QWORD

_MPVOnMouseDn               PROTO hWin:QWORD, wParam:WPARAM, lParam:LPARAM
_MPVOnMouseUp               PROTO hWin:QWORD, wParam:WPARAM, lParam:LPARAM
_MPVOnMouseMove             PROTO hWin:QWORD, wParam:WPARAM, lParam:LPARAM

_MPVCalcVolumeWidth         PROTO hWin:QWORD
_MPVGetVolume               PROTO hWin:QWORD
_MPVSetVolume               PROTO hWin:QWORD, qwVolume:QWORD


.CONST
; MediaPlayer Volume Control Properties:
@MPV_Init               EQU  0
@MPV_MediaPlayer        EQU  8
@MPV_Volume             EQU 16
@MPV_VolumeWidth        EQU 24
@MPV_VolumeHeight       EQU 32
@MPV_MouseOver          EQU 40
@MPV_MouseDown          EQU 48

MPV_LEFT                EQU 8
MPV_RIGHT               EQU 8

; MediaPlayer Volume Control Colors
MPV_BACKCOLOR           EQU MAINWINDOW_BACKCOLOR
MPV_FS_BACKCOLOR        EQU MAINWINDOW_FS_BACKCOLOR

MPV_BORDERCOLOR         EQU RGB(128,128,128)
MPV_BACKCOLORFROM       EQU RGB(189,189,189)
MPV_BACKCOLORTO         EQU RGB(225,225,225)

MPV_FS_BORDERCOLOR      EQU RGB(128,128,128)
MPV_FS_BACKCOLORFROM    EQU RGB(104,104,104)
MPV_FS_BACKCOLORTO      EQU RGB(140,140,140)

MPV_LEVELCOLORFROM      EQU RGB(78,156,228)
MPV_LEVELCOLORTO        EQU RGB(46,138,224)

MPV_FS_LEVELCOLORFROM   EQU RGB(122,180,235)
MPV_FS_LEVELCOLORTO     EQU RGB(91,163,230)

MPV_HIGHLIGHTCOLOR      EQU RGB(198,212,224)


.DATA
IFDEF __UNICODE__
szMPVClass              DB 'M',0,'e',0,'d',0,'i',0,'a',0,'P',0,'l',0,'a',0,'y',0,'e',0,'r',0,'V',0,'o',0,'l',0,'u',0,'m',0,'e',0     ; Class name for creating our MediaPlayerVolume control
                        DB 0,0,0,0
ELSE
szMPVClass              DB 'MediaPlayerVolume',0     ; Class name for creating our MediaPlayerVolume control
ENDIF


.CODE
;------------------------------------------------------------------------------
; MediaPlayerVolumeRegister - Registers the MediaPlayer Volume Control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as 'MediaPlayerVolume'
;------------------------------------------------------------------------------
MediaPlayerVolumeRegister PROC FRAME
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:QWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, rax

    invoke GetClassInfoEx, hinstance, Addr szMPVClass, Addr wc 
    .IF rax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        lea rax, szMPVClass
        mov wc.lpszClassName, rax
        mov rax, hinstance
        mov wc.hInstance, rax
        lea rax, _MPVWndProc
        mov wc.lpfnWndProc, rax 
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, rax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 56

        Invoke RegisterClassEx, Addr wc
    .ENDIF
    ret
MediaPlayerVolumeRegister ENDP

;------------------------------------------------------------------------------
; MediaPlayerVolumeCreate
;
; Create the MediaPlayer Volume Control. Calls MediaPlayerVolumeRegister beforehand.
;
; Returns handle in rax of the newly created control.
;------------------------------------------------------------------------------
MediaPlayerVolumeCreate PROC FRAME hWndParent:QWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, qwResourceID:QWORD, qwStyle:QWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:QWORD
    LOCAL hControl:QWORD
    LOCAL qwNewStyle:QWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, rax

    Invoke MediaPlayerVolumeRegister

    mov rax, qwStyle
    mov qwNewStyle, rax
    and rax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF rax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or qwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF

    Invoke CreateWindowEx, NULL, Addr szMPVClass, NULL, dword ptr qwNewStyle, xpos, ypos, dwWidth, dwHeight, hWndParent, qwResourceID, hinstance, NULL
    mov hControl, rax
    .IF rax != NULL

    .ENDIF
    mov rax, hControl
    
    ret
MediaPlayerVolumeCreate ENDP

;------------------------------------------------------------------------------
; _MPVWndProc
;
; Main processing window for our MediaPlayer Volume Control
;------------------------------------------------------------------------------
_MPVWndProc PROC FRAME hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_NCCREATE
        mov rax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke _MPVInit, hWin
        mov rax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        mov rax, 0
        ret
        
    .ELSEIF eax == WM_ERASEBKGND
        mov rax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MPVPaint, hWin
        mov rax, 0
        ret
    
    .ELSEIF eax == WM_SIZE
        ; Check if internal properties set
        Invoke GetWindowLongPtr, hWin, @MPV_Init
        .IF rax == TRUE ; Yes they are

        .ENDIF
        mov rax, 0
        ret
    
    .ELSEIF eax == WM_SIZING
        ; Check if internal properties set
        Invoke GetWindowLongPtr, hWin, @MPV_Init
        .IF rax == TRUE ; Yes they are

        .ENDIF
        mov rax, 0
        ret
    
    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke _MPVOnMouseDn, hWin, wParam, lParam
        mov rax, 0
        ret
        
    .ELSEIF eax == WM_LBUTTONUP
        Invoke _MPVOnMouseUp, hWin, wParam, lParam
        mov rax, 0
        ret
        
    .ELSEIF eax == WM_MOUSEMOVE
        Invoke _MPVOnMouseMove, hWin, wParam, lParam
        mov rax, 0
        ret
    
    .ELSEIF eax == WM_MOUSELEAVE
        Invoke SetWindowLongPtr, hWin, @MPV_MouseOver, FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE
        mov rax, 0
        ret
    
    ; custom messages start here

    .ELSE
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ret
        
    .ENDIF
    ret
_MPVWndProc ENDP

;------------------------------------------------------------------------------
; _MPVInit
;
; Set some initial default values
;------------------------------------------------------------------------------
_MPVInit PROC FRAME hWin:QWORD
    LOCAL hParent:QWORD
    LOCAL qwStyle:QWORD
    
    Invoke GetParent, hWin
    mov hParent, rax

    ;--------------------------------------------------------------------------
    ; Get style and check it is our default at least
    ;--------------------------------------------------------------------------
    Invoke GetWindowLongPtr, hWin, GWL_STYLE
    mov qwStyle, rax
    and rax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF rax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov rax, qwStyle
        or rax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov qwStyle, rax
        Invoke SetWindowLongPtr, hWin, GWL_STYLE, qwStyle
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Use 0-63 of style for height of volume bar
    ;--------------------------------------------------------------------------
    mov rax, qwStyle
    and rax, 3Fh
    .IF rax == 0
        mov rax, 8
    .ENDIF
    Invoke SetWindowLongPtr, hWin, @MPV_VolumeHeight, rax
    
    Invoke SetWindowLongPtr, hWin, @MPV_Init, TRUE
    
    ret
_MPVInit ENDP

;------------------------------------------------------------------------------
; _MPVPaint
;
; Paint the control, the background, the border and the position.
;------------------------------------------------------------------------------
_MPVPaint PROC FRAME USES RBX hWin:QWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL rectcontrol:RECT
    LOCAL rectvolume:RECT
    LOCAL rectbrush:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:QWORD
    LOCAL hBrush:QWORD
    LOCAL VolumeWidth:DWORD
    LOCAL VolumeHeight:DWORD
    LOCAL VolumeY:DWORD
    LOCAL dwBrushOrgX:DWORD
    LOCAL dwBrushOrgY:DWORD
    LOCAL hParent:QWORD
    
    Invoke IsWindowVisible, hWin
    .IF rax == FALSE
        mov rax, 0
        ret
    .ENDIF
    
    Invoke GetWindowLongPtr, hWin, @MPV_VolumeWidth
    mov VolumeWidth, eax
    Invoke GetWindowLongPtr, hWin, @MPV_VolumeHeight
    mov VolumeHeight, eax

    Invoke BeginPaint, hWin, Addr ps
    mov hdc, rax
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect                       ; Get dimensions of area to buffer
    Invoke CopyRect, Addr rectvolume, Addr rect
    Invoke CopyRect, Addr rectcontrol, Addr rect
    Invoke CreateCompatibleDC, hdc                              ; Create memory dc for our buffer
    mov hdcMem, rax
    Invoke SaveDC, hdcMem                                       ; Save hdcMem status for later restore
    
    Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom ; Create bitmap of size that matches dimensions
    mov hBufferBitmap, rax
    Invoke SelectObject, hdcMem, hBufferBitmap                  ; Select our created buffer bitmap into our memory dc
    
    ;----------------------------------------------------------
    ; Calculate rectangles
    ;----------------------------------------------------------
    mov rectcontrol.left, MPV_LEFT
    sub rectcontrol.right, MPV_RIGHT
    mov eax, rect.bottom
    sub eax, rect.top
    shr eax, 1
    
    mov ebx, VolumeHeight
    shr ebx, 1
    
    sub eax, ebx
    mov VolumeY, eax
    
    mov eax, VolumeY
    mov rectcontrol.top, eax
    mov rectvolume.top, eax
    add eax, VolumeHeight
    mov rectcontrol.bottom, eax
    mov rectvolume.bottom, eax
    inc rectvolume.top
    dec rectvolume.bottom
    mov rectvolume.left, (MPV_LEFT +1)
    sub rectvolume.right, (MPV_RIGHT +1)
    
    ;----------------------------------------------------------
    ; Paint background of control
    ;----------------------------------------------------------
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, rax
    Invoke SelectObject, hdcMem, rax
    
    Invoke GetWindowLongPtr, hWin, @MPV_MouseOver
    .IF rax == TRUE
        Invoke SetDCBrushColor, hdcMem, MPV_HIGHLIGHTCOLOR
    .ELSE
        .IF g_Fullscreen == FALSE
            Invoke SetDCBrushColor, hdcMem, MPV_BACKCOLOR
        .ELSE
            Invoke SetDCBrushColor, hdcMem, MPV_FS_BACKCOLOR
        .ENDIF
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
    ; Draw Volume Slider Background
    ;----------------------------------------------------------
    .IF g_Fullscreen == FALSE
        Invoke MPPaintGradient, hdcMem, Addr rectcontrol, MPV_BACKCOLORFROM, MPV_BACKCOLORTO, 1 ; rect
    .ELSE
        Invoke MPPaintGradient, hdcMem, Addr rectcontrol, MPV_FS_BACKCOLORFROM, MPV_FS_BACKCOLORTO, 1 ; rect
    .ENDIF
    
    ;----------------------------------------------------------
    ; Draw Volume Slider Border
    ;----------------------------------------------------------
    mov rax, MPV_BORDERCOLOR
    .IF rax != -1
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, rax
        Invoke SelectObject, hdcMem, rax
        .IF g_Fullscreen == FALSE
            Invoke SetDCBrushColor, hdcMem, MPV_BORDERCOLOR
        .ELSE
            Invoke SetDCBrushColor, hdcMem, MPV_FS_BORDERCOLOR
        .ENDIF
        Invoke FrameRect, hdcMem, Addr rectcontrol, hBrush ; rect
    .ENDIF
    
    ;----------------------------------------------------------
    ; Draw Volume Slider Current Volume Level
    ;----------------------------------------------------------
    .IF VolumeWidth != 0
        ;add rectvolume.left, 1
        mov eax, rectvolume.left
        add eax, VolumeWidth
        mov rectvolume.right, eax
        Invoke MPPaintGradient, hdcMem, Addr rectvolume, MPV_LEVELCOLORFROM, MPV_LEVELCOLORTO, 1
    .ENDIF
    
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
_MPVPaint ENDP

;------------------------------------------------------------------------------
; _MPVOnMouseDn (WM_LBUTTONDOWN)
;------------------------------------------------------------------------------
_MPVOnMouseDn PROC FRAME hWin:QWORD, wParam:WPARAM, lParam:LPARAM
    Invoke SetWindowLongPtr, hWin, @MPV_MouseDown, TRUE
    Invoke SetCapture, hWin
    ret
_MPVOnMouseDn ENDP

;------------------------------------------------------------------------------
; _MPVOnMouseUp (WM_LBUTTONUP)
;------------------------------------------------------------------------------
_MPVOnMouseUp PROC FRAME USES RBX RCX hWin:QWORD, wParam:WPARAM, lParam:LPARAM
    LOCAL pt:POINT
    LOCAL rect:RECT
    LOCAL dwVolumeWidth:DWORD
    LOCAL dwVolumeMaxWidth:DWORD
    LOCAL dwVolume:DWORD
    LOCAL dw100:DWORD
    
    Invoke SetWindowLongPtr, hWin, @MPV_MouseDown, FALSE
    Invoke ReleaseCapture
    mov rax, lParam
    and rax, 0FFFFh
    mov pt.x, eax
    mov rax, lParam
    shr rax, 16d
    mov pt.y, eax
    
    Invoke GetClientRect, hWin, Addr rect
    add rect.left, (MPV_LEFT +1)
    sub rect.right, (MPV_RIGHT +1)
    mov eax, rect.right
    sub eax, (MPV_RIGHT +1)
    add eax, (MPV_LEFT +1)
    sub eax, rect.left
    mov dwVolumeMaxWidth, eax
    
    mov eax, pt.x
    mov ebx, rect.left
    mov ecx, rect.right
    .IF sword ptr ax <= bx
        mov dwVolumeWidth, 0
    .ELSEIF sword ptr ax >= cx
        mov eax, rect.right
        sub eax, rect.left
        ;add eax, 2
        mov dwVolumeWidth, eax
    .ELSE
        mov eax, pt.x
        sub eax, (MPV_LEFT + 1)
        mov dwVolumeWidth, eax
    .ENDIF
    
    Invoke SetWindowLongPtr, hWin, @MPV_VolumeWidth, dwVolumeWidth
    Invoke InvalidateRect, hWin, NULL, TRUE

    mov dw100, 100
    finit
    fwait
    fild dw100
    fild dwVolumeMaxWidth
    fdiv
    fild dwVolumeWidth
    fmul
    fistp dwVolume

    Invoke MFPMediaPlayer_SetVolume, pMP, dwVolume
    .IF rax == FALSE
        IFDEF DEBUG64
        PrintText 'Failed to set volume'
        ENDIF
    .ENDIF
    
    ret
_MPVOnMouseUp ENDP

;------------------------------------------------------------------------------
; _MPVOnMouseMove (WM_MOUSEMOVE)
;------------------------------------------------------------------------------
_MPVOnMouseMove PROC FRAME USES RBX RCX hWin:QWORD, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    LOCAL pt:POINT
    LOCAL rect:RECT
    LOCAL qwVolumeWidth:QWORD
    
    Invoke GetWindowLongPtr, hWin, @MPV_MouseOver
    .IF rax == FALSE
        Invoke SetWindowLongPtr, hWin, @MPV_MouseOver, TRUE
        Invoke InvalidateRect, hWin, NULL, TRUE
        mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
        mov TE.dwFlags, TME_LEAVE
        mov rax, hWin
        mov TE.hwndTrack, rax
        mov TE.dwHoverTime, NULL
        Invoke TrackMouseEvent, Addr TE
    .ENDIF
    
    
    Invoke GetWindowLongPtr, hWin, @MPV_MouseDown
    .IF rax == TRUE
        mov rax, lParam
        and rax, 0FFFFh
        mov pt.x, eax
        mov rax, lParam
        shr rax, 16d
        mov pt.y, eax
        
        Invoke GetClientRect, hWin, Addr rect
        add rect.left, (MPV_LEFT +1)
        sub rect.right, (MPV_RIGHT +1)
        
        mov eax, pt.x
        mov ebx, rect.left
        mov ecx, rect.right
        .IF sword ptr ax <= bx ;rect.left
            mov qwVolumeWidth, 0
        .ELSEIF sword ptr ax >= cx ;rect.right
            mov eax, rect.right
            sub eax, rect.left
            ;add eax, 2
            mov qwVolumeWidth, rax
        .ELSE
            mov eax, pt.x
            sub eax, (MPV_LEFT + 1)
            mov qwVolumeWidth, rax
        .ENDIF

        Invoke SetWindowLongPtr, hWin, @MPV_VolumeWidth, qwVolumeWidth
        Invoke InvalidateRect, hWin, NULL, TRUE
        
    .ENDIF
    
    ret
_MPVOnMouseMove ENDP

;------------------------------------------------------------------------------
; _MPVCalcVolumeWidth
;------------------------------------------------------------------------------
_MPVCalcVolumeWidth PROC FRAME USES RBX hWin:QWORD
    LOCAL qwVolumeWidth:QWORD
    LOCAL qwMaxVolumeWidth:QWORD
    LOCAL qwVolume:QWORD
    LOCAL rect:RECT

    Invoke GetWindowLongPtr, hWin, @MPV_Volume
    mov qwVolume, rax
    
    ;----------------------------------------------------------------------
    ; Get width and the max size of volume width
    ;----------------------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect
    mov eax, rect.right
    sub eax, rect.left
    sub eax, (MPV_LEFT + MPV_RIGHT)
    sub eax, 2
    mov qwMaxVolumeWidth, rax
    
    ;----------------------------------------------------------------------
    ; Calculate the width of the position bar based on current position ms,
    ; duration ms and max width for position bar
    ;----------------------------------------------------------------------
    
    mov rax, qwVolume
    .IF rax == 0
        Invoke SetWindowLongPtr, hWin, @MPV_VolumeWidth, 0
    .ELSEIF rax == 100 ; at max already
        Invoke SetWindowLongPtr, hWin, @MPV_VolumeWidth, qwMaxVolumeWidth
    .ELSE ; calculate width of volume
        finit
        fwait
        fild qword ptr qwMaxVolumeWidth
        fmul MFP_DIV100
        fld st
        fild qword ptr qwVolume
        fmul
        fistp qword ptr qwVolumeWidth
        Invoke SetWindowLongPtr, hWin, @MPV_VolumeWidth, qwVolumeWidth
    .ENDIF
    
    mov rax, TRUE
    
    ret
_MPVCalcVolumeWidth ENDP

;------------------------------------------------------------------------------
; _MPVGetVolume
;------------------------------------------------------------------------------
_MPVGetVolume PROC FRAME USES RBX hWin:QWORD
    LOCAL pMediaPlayer:QWORD
    LOCAL qwVolume:QWORD
    
    mov qwVolume, 0
    ;--------------------------------------------------------------------------
    ; Get Volume Value From Media Player
    ;--------------------------------------------------------------------------
    Invoke GetWindowLongPtr, hWin, @MPV_MediaPlayer
    mov pMediaPlayer, rax
    .IF pMediaPlayer != 0
        Invoke MFPMediaPlayer_GetVolume, pMediaPlayer, Addr qwVolume
        .IF rax == TRUE
            Invoke SetWindowLongPtr, hWin, @MPV_Volume, qwVolume
        .ELSE
            Invoke SetWindowLongPtr, hWin, @MPV_Volume, 0
        .ENDIF
    .ELSE
        Invoke SetWindowLongPtr, hWin, @MPV_Volume, 0
    .ENDIF
    mov rax, qwVolume
    ret
_MPVGetVolume ENDP

;------------------------------------------------------------------------------
; MPVInit
;------------------------------------------------------------------------------
MPVInit PROC FRAME hControl:QWORD, pMediaPlayer:QWORD
    
    IFDEF DEBUG64
    ;PrintText 'MPVInit'
    ENDIF

    Invoke IsWindow, hControl
    .IF rax == TRUE
        Invoke SetWindowLongPtr, hControl, @MPV_MediaPlayer, pMediaPlayer
        Invoke _MPVGetVolume, hControl
        Invoke _MPVCalcVolumeWidth, hControl
    .ENDIF
    ret

MPVInit ENDP

;------------------------------------------------------------------------------
; MediaPlayerVolumeSet
;------------------------------------------------------------------------------
MediaPlayerVolumeSet PROC FRAME hControl:QWORD, dwVolume:DWORD
    LOCAL pMediaPlayer:QWORD
    
    IFDEF DEBUG64
    ;PrintText 'MediaPlayerVolumeSet'
    ENDIF
    
    Invoke IsWindow, hControl
    .IF rax == TRUE
        Invoke GetWindowLongPtr, hControl, @MPV_MediaPlayer
        mov pMediaPlayer, rax
        .IF pMediaPlayer != 0
            Invoke MFPMediaPlayer_SetVolume, pMediaPlayer, dwVolume
            .IF rax == TRUE
                Invoke SetWindowLongPtr, hControl, @MPV_Volume, dwVolume
                Invoke _MPVCalcVolumeWidth, hControl
                Invoke InvalidateRect, hControl, NULL, TRUE
            .ELSE
                IFDEF DEBUG64
                PrintText 'MediaPlayerVolumeSet failed to set volume'
                ENDIF
            .ENDIF
        .ENDIF
    .ENDIF
    ret
MediaPlayerVolumeSet ENDP










