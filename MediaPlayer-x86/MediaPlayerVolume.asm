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

; MediaPlayer Volume Control Functions:
MediaPlayerVolumeRegister   PROTO
MediaPlayerVolumeCreate     PROTO hWndParent:DWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
MPVInit                     PROTO hControl:DWORD, pMediaPlayer:DWORD
MediaPlayerVolumeSet        PROTO hControl:DWORD, dwVolume:DWORD


; MediaPlayer Volume Control Functions (Internal):
_MPVWndProc                 PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
_MPVInit                    PROTO hWin:DWORD
_MPVPaint                   PROTO hWin:DWORD

_MPVOnMouseDn               PROTO hWin:DWORD, wParam:WPARAM, lParam:LPARAM
_MPVOnMouseUp               PROTO hWin:DWORD, wParam:WPARAM, lParam:LPARAM
_MPVOnMouseMove             PROTO hWin:DWORD, wParam:WPARAM, lParam:LPARAM

_MPVCalcVolumeWidth         PROTO hWin:DWORD
_MPVGetVolume               PROTO hWin:DWORD
_MPVSetVolume               PROTO hWin:DWORD, dwVolume:DWORD


.CONST
; MediaPlayer Volume Control Properties:
@MPV_Init               EQU  0
@MPV_MediaPlayer        EQU  4
@MPV_Volume             EQU  8
@MPV_VolumeWidth        EQU 12
@MPV_VolumeHeight       EQU 16
@MPV_MouseOver          EQU 20
@MPV_MouseDown          EQU 24

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
MediaPlayerVolumeRegister PROC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx, hinstance, Addr szMPVClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        lea eax, szMPVClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        lea eax, _MPVWndProc
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
MediaPlayerVolumeRegister ENDP

;------------------------------------------------------------------------------
; MediaPlayerVolumeCreate
;
; Create the MediaPlayer Volume Control. Calls MediaPlayerVolumeRegister beforehand.
;
; Returns handle in eax of the newly created control.
;------------------------------------------------------------------------------
MediaPlayerVolumeCreate PROC hWndParent:DWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MediaPlayerVolumeRegister

    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or dwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF

    Invoke CreateWindowEx, NULL, Addr szMPVClass, NULL, dwNewStyle, xpos, ypos, dwWidth, dwHeight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL

    .ENDIF
    mov eax, hControl
    
    ret
MediaPlayerVolumeCreate ENDP

;------------------------------------------------------------------------------
; _MPVWndProc
;
; Main processing window for our MediaPlayer Volume Control
;------------------------------------------------------------------------------
_MPVWndProc PROC hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_NCCREATE
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke _MPVInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        mov eax, 0
        ret
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MPVPaint, hWin
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_SIZE
        ; Check if internal properties set
        Invoke GetWindowLong, hWin, @MPV_Init
        .IF eax == TRUE ; Yes they are

        .ENDIF
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_SIZING
        ; Check if internal properties set
        Invoke GetWindowLong, hWin, @MPV_Init
        .IF eax == TRUE ; Yes they are

        .ENDIF
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke _MPVOnMouseDn, hWin, wParam, lParam
        mov eax, 0
        ret
        
    .ELSEIF eax == WM_LBUTTONUP
        Invoke _MPVOnMouseUp, hWin, wParam, lParam
        mov eax, 0
        ret
        
    .ELSEIF eax == WM_MOUSEMOVE
        Invoke _MPVOnMouseMove, hWin, wParam, lParam
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_MOUSELEAVE
        Invoke SetWindowLong, hWin, @MPV_MouseOver, FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE
        mov eax, 0
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
_MPVInit PROC hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetParent, hWin
    mov hParent, eax

    ;--------------------------------------------------------------------------
    ; Get style and check it is our default at least
    ;--------------------------------------------------------------------------
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov eax, dwStyle
        or eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov dwStyle, eax
        Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Use 0-63 of style for height of volume bar
    ;--------------------------------------------------------------------------
    mov eax, dwStyle
    and eax, 3Fh
    .IF eax == 0
        mov eax, 8
    .ENDIF
    Invoke SetWindowLong, hWin, @MPV_VolumeHeight, eax
    
    Invoke SetWindowLong, hWin, @MPV_Init, TRUE
    
    ret
_MPVInit ENDP

;------------------------------------------------------------------------------
; _MPVPaint
;
; Paint the control, the background, the border and the position.
;------------------------------------------------------------------------------
_MPVPaint PROC USES EBX hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL rectcontrol:RECT
    LOCAL rectvolume:RECT
    LOCAL rectbrush:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL VolumeWidth:DWORD
    LOCAL VolumeHeight:DWORD
    LOCAL VolumeY:DWORD
    LOCAL dwBrushOrgX:DWORD
    LOCAL dwBrushOrgY:DWORD
    LOCAL hParent:DWORD
    
    Invoke IsWindowVisible, hWin
    .IF eax == FALSE
        mov eax, 0
        ret
    .ENDIF
    
    Invoke GetWindowLong, hWin, @MPV_VolumeWidth
    mov VolumeWidth, eax
    Invoke GetWindowLong, hWin, @MPV_VolumeHeight
    mov VolumeHeight, eax

    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect                       ; Get dimensions of area to buffer
    Invoke CopyRect, Addr rectvolume, Addr rect
    Invoke CopyRect, Addr rectcontrol, Addr rect
    Invoke CreateCompatibleDC, hdc                              ; Create memory dc for our buffer
    mov hdcMem, eax
    Invoke SaveDC, hdcMem                                       ; Save hdcMem status for later restore
    
    Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom ; Create bitmap of size that matches dimensions
    mov hBufferBitmap, eax
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
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    
    Invoke GetWindowLong, hWin, @MPV_MouseOver
    .IF eax == TRUE
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
    mov eax, MPV_BORDERCOLOR
    .IF eax != -1
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, eax
        Invoke SelectObject, hdcMem, eax
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
    mov eax, 0
    
    ret
_MPVPaint ENDP

;------------------------------------------------------------------------------
; _MPVOnMouseDn (WM_LBUTTONDOWN)
;------------------------------------------------------------------------------
_MPVOnMouseDn PROC hWin:DWORD, wParam:WPARAM, lParam:LPARAM
    Invoke SetWindowLong, hWin, @MPV_MouseDown, TRUE
    Invoke SetCapture, hWin
    ret
_MPVOnMouseDn ENDP

;------------------------------------------------------------------------------
; _MPVOnMouseUp (WM_LBUTTONUP)
;------------------------------------------------------------------------------
_MPVOnMouseUp PROC USES EBX ECX hWin:DWORD, wParam:WPARAM, lParam:LPARAM
    LOCAL pt:POINT
    LOCAL rect:RECT
    LOCAL dwVolumeWidth:DWORD
    LOCAL dwVolumeMaxWidth:DWORD
    LOCAL dwVolume:DWORD
    LOCAL dw100:DWORD
    
    Invoke SetWindowLong, hWin, @MPV_MouseDown, FALSE
    Invoke ReleaseCapture
    mov eax, lParam
    and eax, 0FFFFh
    mov pt.x, eax
    mov eax, lParam
    shr eax, 16d
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
        mov dwVolumeWidth, eax
    .ELSE
        mov eax, pt.x
        sub eax, (MPV_LEFT + 1)
        mov dwVolumeWidth, eax
    .ENDIF
    
    Invoke SetWindowLong, hWin, @MPV_VolumeWidth, dwVolumeWidth
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
    .IF eax == FALSE
        IFDEF DEBUG32
        PrintText 'Failed to set volume'
        ENDIF
    .ENDIF
    
    ret
_MPVOnMouseUp ENDP

;------------------------------------------------------------------------------
; _MPVOnMouseMove (WM_MOUSEMOVE)
;------------------------------------------------------------------------------
_MPVOnMouseMove PROC USES EBX ECX hWin:DWORD, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    LOCAL pt:POINT
    LOCAL rect:RECT
    LOCAL dwVolumeWidth:DWORD
    
    Invoke GetWindowLong, hWin, @MPV_MouseOver
    .IF eax == FALSE
        Invoke SetWindowLong, hWin, @MPV_MouseOver, TRUE
        Invoke InvalidateRect, hWin, NULL, TRUE
        mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
        mov TE.dwFlags, TME_LEAVE
        mov eax, hWin
        mov TE.hwndTrack, eax
        mov TE.dwHoverTime, NULL
        Invoke TrackMouseEvent, Addr TE
    .ENDIF
    
    Invoke GetWindowLong, hWin, @MPV_MouseDown
    .IF eax == TRUE
        mov eax, lParam
        and eax, 0FFFFh
        mov pt.x, eax
        mov eax, lParam
        shr eax, 16d
        mov pt.y, eax
        
        Invoke GetClientRect, hWin, Addr rect
        add rect.left, (MPV_LEFT +1)
        sub rect.right, (MPV_RIGHT +1)
        
        mov eax, pt.x
        mov ebx, rect.left
        mov ecx, rect.right
        .IF sword ptr ax <= bx ;rect.left
            mov dwVolumeWidth, 0
        .ELSEIF sword ptr ax >= cx ;rect.right
            mov eax, rect.right
            sub eax, rect.left
            ;add eax, 2
            mov dwVolumeWidth, eax
        .ELSE
            mov eax, pt.x
            sub eax, (MPV_LEFT + 1)
            mov dwVolumeWidth, eax
        .ENDIF
        
        Invoke SetWindowLong, hWin, @MPV_VolumeWidth, dwVolumeWidth
        Invoke InvalidateRect, hWin, NULL, TRUE
        
    .ENDIF
    
    ret
_MPVOnMouseMove ENDP

;------------------------------------------------------------------------------
; _MPVCalcVolumeWidth
;------------------------------------------------------------------------------
_MPVCalcVolumeWidth PROC USES EBX hWin:DWORD
    LOCAL dwVolumeWidth:DWORD
    LOCAL dwMaxVolumeWidth:DWORD
    LOCAL dwVolume:DWORD
    LOCAL rect:RECT

    Invoke GetWindowLong, hWin, @MPV_Volume
    mov dwVolume, eax
    
    ;----------------------------------------------------------------------
    ; Get width and the max size of volume width
    ;----------------------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect
    mov eax, rect.right
    sub eax, rect.left
    sub eax, (MPV_LEFT + MPV_RIGHT)
    sub eax, 2
    mov dwMaxVolumeWidth, eax
    
    ;----------------------------------------------------------------------
    ; Calculate the width of the position bar based on current position ms,
    ; duration ms and max width for position bar
    ;----------------------------------------------------------------------
    
    mov eax, dwVolume
    .IF eax == 0
        Invoke SetWindowLong, hWin, @MPV_VolumeWidth, 0
    .ELSEIF eax == 100 ; at max already
        Invoke SetWindowLong, hWin, @MPV_VolumeWidth, dwMaxVolumeWidth
    .ELSE ; calculate width of volume
        finit
        fwait
        fild dwMaxVolumeWidth
        fmul MFP_DIV100
        fld st
        fild dwVolume
        fmul
        fistp dwVolumeWidth
        Invoke SetWindowLong, hWin, @MPV_VolumeWidth, dwVolumeWidth
    .ENDIF
    
    mov eax, TRUE
    
    ret
_MPVCalcVolumeWidth ENDP

;------------------------------------------------------------------------------
; _MPVGetVolume
;------------------------------------------------------------------------------
_MPVGetVolume PROC USES EBX hWin:DWORD
    LOCAL pMediaPlayer:DWORD
    LOCAL dwVolume:DWORD
    
    mov dwVolume, 0
    ;--------------------------------------------------------------------------
    ; Get Volume Value From Media Player
    ;--------------------------------------------------------------------------
    Invoke GetWindowLong, hWin, @MPV_MediaPlayer
    mov pMediaPlayer, eax
    .IF pMediaPlayer != 0
        Invoke MFPMediaPlayer_GetVolume, pMediaPlayer, Addr dwVolume
        .IF eax == TRUE
            Invoke SetWindowLong, hWin, @MPV_Volume, dwVolume
        .ELSE
            Invoke SetWindowLong, hWin, @MPV_Volume, 0
        .ENDIF
    .ELSE
        Invoke SetWindowLong, hWin, @MPV_Volume, 0
    .ENDIF
    mov eax, dwVolume
    ret
_MPVGetVolume ENDP

;------------------------------------------------------------------------------
; MPVInit
;------------------------------------------------------------------------------
MPVInit PROC hControl:DWORD, pMediaPlayer:DWORD
    
    IFDEF DEBUG32
    ;PrintText 'MPVInit'
    ENDIF

    Invoke IsWindow, hControl
    .IF eax == TRUE
        Invoke SetWindowLong, hControl, @MPV_MediaPlayer, pMediaPlayer
        Invoke _MPVGetVolume, hControl
        Invoke _MPVCalcVolumeWidth, hControl
    .ENDIF
    ret

MPVInit ENDP

;------------------------------------------------------------------------------
; MediaPlayerVolumeSet
;------------------------------------------------------------------------------
MediaPlayerVolumeSet PROC hControl:DWORD, dwVolume:DWORD
    LOCAL pMediaPlayer:DWORD
    
    IFDEF DEBUG32
    ;PrintText 'MediaPlayerVolumeSet'
    ENDIF
    
    Invoke IsWindow, hControl
    .IF eax == TRUE
        Invoke GetWindowLong, hControl, @MPV_MediaPlayer
        mov pMediaPlayer, eax
        .IF pMediaPlayer != 0
            Invoke MFPMediaPlayer_SetVolume, pMediaPlayer, dwVolume
            .IF eax == TRUE
                Invoke SetWindowLong, hControl, @MPV_Volume, dwVolume
                Invoke _MPVCalcVolumeWidth, hControl
                Invoke InvalidateRect, hControl, NULL, TRUE
            .ELSE
                IFDEF DEBUG32
                PrintText 'MediaPlayerVolumeSet failed to set volume'
                ENDIF
            .ENDIF
        .ENDIF
    .ENDIF
    ret
MediaPlayerVolumeSet ENDP










