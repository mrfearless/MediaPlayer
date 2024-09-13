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

; MediaPlayer Seek Bar Control Functions:
MediaPlayerSeekBarRegister  PROTO
MediaPlayerSeekBarCreate    PROTO hWndParent:DWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
MPSBInit                    PROTO hControl:DWORD, hMediaWindow:DWORD, pMediaPlayer:DWORD, lpTimerCallback:DWORD, lpTimerCallbackParam:DWORD
MPSBSetDurationMS           PROTO hControl:DWORD, dwDurationMS:DWORD
MPSBSetPositionMS           PROTO hControl:DWORD, dwPositionMS:DWORD
MPSBGetPositionMS           PROTO hControl:DWORD
MPSBStart                   PROTO hControl:DWORD
MPSBStop                    PROTO hControl:DWORD
MPSBStepPosition            PROTO hControl:DWORD, dwSeconds:DWORD, bForward:DWORD
MPSBRefresh                 PROTO hControl:DWORD

; MediaPlayer Seek Bar Control Functions (Internal):
_MPSBWndProc                PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
_MPSBPaint                  PROTO hWin:DWORD
_MPSBInit                   PROTO hWin:DWORD
_MPSBCleanup                PROTO hWin:DWORD

_MPSBOnMouseDn              PROTO hWin:DWORD, wParam:WPARAM, lParam:LPARAM
_MPSBOnMouseUp              PROTO hWin:DWORD, wParam:WPARAM, lParam:LPARAM
_MPSBOnMouseMove            PROTO hWin:DWORD, wParam:WPARAM, lParam:LPARAM

_MPSBGetPosition            PROTO hWin:DWORD
_MPSBCalcPosWidth           PROTO hWin:DWORD
_MPSBTimerProc              PROTO lpParam:DWORD, TimerOrWaitFired:DWORD

_MPSBTimerCallback_Proto    TYPEDEF PROTO STDCALL dwPositionMS:DWORD, lParam:DWORD  
_MPSBTimerCallback_Ptr      TYPEDEF PTR _MPSBTimerCallback_Proto





.CONST
; MediaPlayer Seek Bar Control Messages:
MPSBM_START             EQU WM_USER + 2001
MPSBM_STOP              EQU WM_USER + 2002

; MediaPlayer Seek Bar Control Properties:
@MPSB_Init              EQU  0
@MPSB_MediaWindow       EQU  4
@MPSB_MediaPlayer       EQU  8
@MPSB_Queue             EQU 12
@MPSB_Timer             EQU 16
@MPSB_DurationMS        EQU 20
@MPSB_PositionMS        EQU 24
@MPSB_PositionWidth     EQU 28
@MPSB_PositionHeight    EQU 32
@MPSB_TimerCB           EQU 36
@MPSB_TimerCBParam      EQU 40
@MPSB_MouseMove         EQU 44
@MPSB_MouseDown         EQU 48

MPSB_TIMER_INTERVAL     EQU 250 ; 500 ; 1000 ; ms

; MediaPlayer Seek Bar Control Colors
MPSB_BACKCOLOR          EQU MAINWINDOW_BACKCOLOR
MPSB_FS_BACKCOLOR       EQU MAINWINDOW_FS_BACKCOLOR

MPSB_BORDERCOLOR        EQU RGB(128,128,128) 
MPSB_BACKCOLORFROM      EQU RGB(189,189,189)
MPSB_BACKCOLORTO        EQU RGB(235,235,235)

MPSB_FS_BORDERCOLOR     EQU RGB(140,140,140)
MPSB_FS_BACKCOLORFROM   EQU RGB(84,84,84)
MPSB_FS_BACKCOLORTO     EQU RGB(150,150,150)

MPSB_POSCOLORFROM       EQU RGB(55,143,225)
MPSB_POSCOLORTO         EQU RGB(40,125,204)

MPSB_FS_POSCOLORFROM    EQU RGB(100,168,232)
MPSB_FS_POSCOLORTO      EQU RGB(76,150,220)

.DATA
IFDEF __UNICODE__
szMPSBClass             DB 'M',0,'e',0,'d',0,'i',0,'a',0,'P',0,'l',0,'a',0,'y',0,'e',0,'r',0,'S',0,'e',0,'e',0,'k',0,'B',0,'a',0,'r',0     ; Class name for creating our MediaPlayerSeekBar control
                        DB 0,0,0,0
ELSE
szMPSBClass             DB 'MediaPlayerSeekBar',0     ; Class name for creating our MediaPlayerSeekBar control
ENDIF

.CODE

;------------------------------------------------------------------------------
; MediaPlayerSeekBarRegister - Registers the MediaPlayer Seek Bar Control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as 'MediaPlayerSeekBar'
;------------------------------------------------------------------------------
MediaPlayerSeekBarRegister PROC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx, hinstance, Addr szMPSBClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        lea eax, szMPSBClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        lea eax, _MPSBWndProc
        mov wc.lpfnWndProc, eax 
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, eax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 64
        Invoke RegisterClassEx, Addr wc
    .ENDIF
    
    ret
MediaPlayerSeekBarRegister ENDP

;------------------------------------------------------------------------------
; MediaPlayerSeekBarCreate
;
; Create the MediaPlayer Seek Bar Control. Calls MediaPlayerSeekBarRegister beforehand.
;
; Returns handle in eax of the newly created control.
;------------------------------------------------------------------------------
MediaPlayerSeekBarCreate PROC hWndParent:DWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MediaPlayerSeekBarRegister

    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_TABSTOP or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_TABSTOP or WS_VISIBLE or WS_CLIPCHILDREN
        or dwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF

    Invoke CreateWindowEx, NULL, Addr szMPSBClass, NULL, dwNewStyle, xpos, ypos, dwWidth, dwHeight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL

    .ENDIF
    mov eax, hControl
    
    ret
MediaPlayerSeekBarCreate ENDP

;------------------------------------------------------------------------------
; _MPSBWndProc
;
; Main processing window for our MediaPlayer Seek Bar Control
;------------------------------------------------------------------------------
_MPSBWndProc PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke _MPSBInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MPSBCleanup, hWin
        mov eax, 0
        ret
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MPSBPaint, hWin
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_SIZE
        ; Check if internal properties set
        Invoke GetWindowLong, hWin, @MPSB_Init
        .IF eax == TRUE ; Yes they are
            ;Invoke _MPSBCalcPosWidth, hWin
            ;Invoke InvalidateRect, hWin, NULL, TRUE
            Invoke MPSBRefresh, hWin
        .ENDIF
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_SIZING
        ; Check if internal properties set
        Invoke GetWindowLong, hWin, @MPSB_Init
        .IF eax == TRUE ; Yes they are
            Invoke _MPSBCalcPosWidth, hWin
            ;Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke _MPSBOnMouseDn, hWin, wParam, lParam
        mov eax, 0
        ret
        
    .ELSEIF eax == WM_LBUTTONUP
        Invoke _MPSBOnMouseUp, hWin, wParam, lParam
        mov eax, 0
        ret
        
    .ELSEIF eax == WM_MOUSEMOVE
        Invoke _MPSBOnMouseMove, hWin, wParam, lParam
        mov eax, 0
        ret
    
    ; custom messages start here
    .ELSEIF eax == MPSBM_START
        Invoke MPSBStart, hWin
        ret
        
    .ELSEIF eax == MPSBM_STOP
        Invoke MPSBStop, hWin
        ret

    .ELSE
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ret
        
    .ENDIF
    
    xor eax, eax
    ret
_MPSBWndProc ENDP

;------------------------------------------------------------------------------
; _MPSBInit
;
; Set some initial default values
;------------------------------------------------------------------------------
_MPSBInit PROC hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetParent, hWin
    mov hParent, eax
    
    ; get style and check it is our default at least
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, WS_CHILD or WS_TABSTOP or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_TABSTOP or WS_VISIBLE or WS_CLIPCHILDREN
        mov eax, dwStyle
        or eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov dwStyle, eax
        Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Use 0-63 of style for height of position bar
    ;--------------------------------------------------------------------------
    mov eax, dwStyle
    and eax, 3Fh
    .IF eax == 0
        mov eax, 12
    .ENDIF
    Invoke SetWindowLong, hWin, @MPSB_PositionHeight, eax
    
    Invoke SetWindowLong, hWin, @MPSB_Init, TRUE
    
    ret
_MPSBInit ENDP

;------------------------------------------------------------------------------
; _MPSBCleanup
;
; Cleanup any stuff we need to
;------------------------------------------------------------------------------
_MPSBCleanup PROC hWin:DWORD
    LOCAL hQueue:DWORD
    LOCAL hTimer:DWORD
    
    Invoke GetWindowLong, hWin, @MPSB_Queue
    mov hQueue, eax
    Invoke GetWindowLong, hWin, @MPSB_Timer
    mov hTimer, eax
    
    .IF hQueue != NULL
        Invoke DeleteTimerQueueEx, hQueue, FALSE
    .ENDIF
    
    ret
_MPSBCleanup ENDP

;------------------------------------------------------------------------------
; _MPSBPaint
;
; Paint the control, the background, the border and the position.
;------------------------------------------------------------------------------
_MPSBPaint PROC USES EBX hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL rectposition:RECT
    LOCAL rectcontrol:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL PositionWidth:DWORD
    LOCAL PositionHeight:DWORD
    LOCAL PositionY:DWORD
    
    Invoke IsWindowVisible, hWin
    .IF eax == FALSE
        mov eax, 0
        ret
    .ENDIF
    
    Invoke GetWindowLong, hWin, @MPSB_PositionWidth
    mov PositionWidth, eax
    Invoke GetWindowLong, hWin, @MPSB_PositionHeight
    mov PositionHeight, eax
    
    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect                       ; Get dimensions of area to buffer
    Invoke CopyRect, Addr rectposition, Addr rect
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
    mov eax, rect.bottom
    sub eax, rect.top
    shr eax, 1
    
    mov ebx, PositionHeight
    shr ebx, 1
    
    sub eax, ebx
    mov PositionY, eax
    
    mov eax, PositionY
    mov rectcontrol.top, eax
    mov rectposition.top, eax
    add eax, PositionHeight
    mov rectcontrol.bottom, eax
    mov rectposition.bottom, eax
    inc rectposition.top
    dec rectposition.bottom
    mov rectposition.left, 1
    sub rectposition.right, 1

    ;----------------------------------------------------------
    ; Paint background of control
    ;----------------------------------------------------------
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    .IF g_Fullscreen == FALSE
        ;IFDEF DEBUG32
        ;Invoke SetDCBrushColor, hdcMem, RGB(239,87,202) ; MPSB_BACKCOLOR
        ;ELSE
        Invoke SetDCBrushColor, hdcMem, MPSB_BACKCOLOR
        ;ENDIF
    .ELSE
        Invoke SetDCBrushColor, hdcMem, MPSB_FS_BACKCOLOR
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
    ; Draw SeekBar Background
    ;----------------------------------------------------------
    .IF g_Fullscreen == FALSE
        Invoke MPPaintGradient, hdcMem, Addr rectcontrol, MPSB_BACKCOLORFROM, MPSB_BACKCOLORTO, 1
    .ELSE
        Invoke MPPaintGradient, hdcMem, Addr rectcontrol, MPSB_FS_BACKCOLORFROM, MPSB_FS_BACKCOLORTO, 1
    .ENDIF
    
    ;----------------------------------------------------------
    ; Draw SeekBar Border
    ;----------------------------------------------------------
    mov eax, MPSB_BORDERCOLOR
    .IF eax != -1
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, eax
        Invoke SelectObject, hdcMem, eax
        .IF g_Fullscreen == FALSE
            Invoke SetDCBrushColor, hdcMem, MPSB_BORDERCOLOR
        .ELSE
            Invoke SetDCBrushColor, hdcMem, MPSB_FS_BORDERCOLOR
        .ENDIF
        Invoke FrameRect, hdcMem, Addr rectcontrol, hBrush
    .ENDIF
    
    ;----------------------------------------------------------
    ; Draw SeekBar Current Position
    ;----------------------------------------------------------
    .IF PositionWidth != 0
        ;add rectposition.left, 1
        ;add rectposition.top, 1
        mov eax, rectposition.left
        add eax, PositionWidth
        mov rectposition.right, eax
        ;sub rectposition.bottom, 1
        Invoke MPPaintGradient, hdcMem, Addr rectposition, MPSB_POSCOLORFROM, MPSB_POSCOLORTO, 1
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
_MPSBPaint ENDP

;------------------------------------------------------------------------------
; _MPSBOnMouseDn (WM_LBUTTONDOWN)
;------------------------------------------------------------------------------
_MPSBOnMouseDn PROC hWin:DWORD, wParam:WPARAM, lParam:LPARAM
    LOCAL dwState:DWORD
    
    Invoke MFPMediaPlayer_GetState, pMP, Addr dwState
    mov eax, dwState
    .IF eax == MFP_MEDIAPLAYER_STATE_EMPTY || eax == MFP_MEDIAPLAYER_STATE_SHUTDOWN || eax == MFP_MEDIAPLAYER_STATE_STOPPED
        ret
    .ENDIF
    
    Invoke SetWindowLong, hWin, @MPSB_MouseDown, TRUE
    Invoke SetCapture, hWin
    ret
_MPSBOnMouseDn ENDP

;------------------------------------------------------------------------------
; _MPSBOnMouseUp (WM_LBUTTONUP)
;------------------------------------------------------------------------------
_MPSBOnMouseUp PROC USES EBX ECX hWin:DWORD, wParam:WPARAM, lParam:LPARAM
    LOCAL dwState:DWORD
    LOCAL pt:POINT
    LOCAL rect:RECT
    LOCAL dwPositionWidth:DWORD
    LOCAL dwPositionMaxWidth:DWORD
    LOCAL fPositionPercent:REAL4
    LOCAL dwDurationMS:DWORD
    LOCAL dwPositionMS:DWORD
    LOCAL dw100:DWORD
    
    Invoke GetWindowLong, hWin, @MPSB_MouseDown
    .IF eax == TRUE
        Invoke SetWindowLong, hWin, @MPSB_MouseDown, FALSE

        Invoke ReleaseCapture
        mov eax, lParam
        and eax, 0FFFFh
        mov pt.x, eax
        mov eax, lParam
        shr eax, 16d
        mov pt.y, eax
        
        Invoke GetClientRect, hWin, Addr rect
        add rect.left, 1
        sub rect.right, 1
        mov eax, rect.right
        sub eax, 1
        add eax, 1
        sub eax, rect.left
        mov dwPositionMaxWidth, eax
        
        mov eax, pt.x
        mov ebx, rect.left
        mov ecx, rect.right
        .IF sword ptr ax <= bx
            mov dwPositionWidth, 0
        .ELSEIF sword ptr ax >= cx
            mov eax, rect.right
            sub eax, rect.left
            mov dwPositionWidth, eax
        .ELSE
            mov eax, pt.x
            sub eax, 1
            mov dwPositionWidth, eax
        .ENDIF
        
        Invoke GetWindowLong, hWin, @MPSB_DurationMS
        mov dwDurationMS, eax
        
        Invoke SetWindowLong, hWin, @MPSB_PositionWidth, dwPositionWidth
        Invoke InvalidateRect, hWin, NULL, TRUE
        
        mov eax, dwPositionWidth
        .IF eax == 0
            mov dwPositionMS, 0
        .ELSEIF eax == dwPositionMaxWidth
            mov eax, dwDurationMS
            mov dwPositionMS, eax
        .ELSE
            mov dw100, 100
            finit
            fwait
            fild dw100
            fild dwPositionMaxWidth
            fdiv
            fild dwPositionWidth
            fmul
            fstp fPositionPercent
            fild dwDurationMS
            fmul MFP_DIV100
            fld fPositionPercent
            fmul
            fistp dwPositionMS
        .ENDIF
        
        Invoke MFPMediaPlayer_SetPosition, pMP, dwPositionMS
        .IF eax == FALSE
            IFDEF DEBUG32
            PrintText 'Failed to set position'
            ENDIF
        .ENDIF
    .ENDIF
    
    ret
_MPSBOnMouseUp ENDP

;------------------------------------------------------------------------------
; _MPVOnMouseMove (WM_MOUSEMOVE)
;------------------------------------------------------------------------------
_MPSBOnMouseMove PROC USES EBX ECX hWin:DWORD, wParam:WPARAM, lParam:LPARAM
    LOCAL pt:POINT
    LOCAL rect:RECT
    LOCAL dwPositionWidth:DWORD
    
    Invoke GetWindowLong, hWin, @MPSB_MouseDown
    .IF eax == TRUE
        mov eax, lParam
        and eax, 0FFFFh
        mov pt.x, eax
        mov eax, lParam
        shr eax, 16d
        mov pt.y, eax

        Invoke GetClientRect, hWin, Addr rect
        add rect.left, 1
        sub rect.right, 1

        mov eax, pt.x
        mov ebx, rect.left
        mov ecx, rect.right
        .IF sword ptr ax <= bx
            mov dwPositionWidth, 0
        .ELSEIF sword ptr ax >= cx
            mov eax, rect.right
            sub eax, rect.left
            mov dwPositionWidth, eax
        .ELSE
            mov eax, pt.x
            sub eax, 1
            mov dwPositionWidth, eax
        .ENDIF
        
        Invoke SetWindowLong, hWin, @MPSB_PositionWidth, dwPositionWidth
        Invoke InvalidateRect, hWin, NULL, TRUE
    .ENDIF
    
    ret
_MPSBOnMouseMove ENDP

;------------------------------------------------------------------------------
; _MPSBGetPosition
;
; Get the actual current position from the media player mediaitem being played
; and saves it to the @MPSB_PositionMS variable.
;
; Called from _MPSBTimerProc
;------------------------------------------------------------------------------
_MPSBGetPosition PROC hWin:DWORD
    LOCAL pMediaPlayer:DWORD
    LOCAL dwPositionMS:DWORD
    
    mov dwPositionMS, -1
    ;--------------------------------------------------------------------------
    ; Get Position Value From Media Player
    ;--------------------------------------------------------------------------
    Invoke GetWindowLong, hWin, @MPSB_MediaPlayer
    mov pMediaPlayer, eax
    .IF pMediaPlayer != 0
        Invoke MFPMediaPlayer_GetPosition, pMediaPlayer, Addr dwPositionMS
        .IF eax == TRUE
            Invoke SetWindowLong, hWin, @MPSB_PositionMS, dwPositionMS
        .ELSE
            Invoke SetWindowLong, hWin, @MPSB_PositionMS, -1
        .ENDIF
    .ELSE
        Invoke SetWindowLong, hWin, @MPSB_PositionMS, -1
    .ENDIF
    mov eax, dwPositionMS
    ret
_MPSBGetPosition ENDP

;------------------------------------------------------------------------------
; _MPSBCalcPosWidth
;
; Calculate the width of the current position in the MediaPlayer Seek Bar 
; Control.
;
; Called from _MPSBTimerProc and from WM_SIZE/WM_SIZING
;------------------------------------------------------------------------------
_MPSBCalcPosWidth PROC USES EBX hWin:DWORD
    LOCAL dwDurationWidth:DWORD
    LOCAL dwPositionWidth:DWORD
    LOCAL dwMaxPositionWidth:DWORD
    LOCAL dwDurationMS:DWORD
    LOCAL dwPositionMS:DWORD
    LOCAL rect:RECT
    
    Invoke IsWindowVisible, hWin
    .IF eax == FALSE
        mov eax, 0
        ret
    .ENDIF
    
    Invoke GetWindowLong, hWin, @MPSB_MediaWindow
    Invoke IsWindow, eax
    .IF eax == TRUE

        Invoke GetWindowLong, hWin, @MPSB_PositionMS
        .IF eax == -1 || eax == 0
            Invoke SetWindowLong, hWin, @MPSB_PositionWidth, 0
            jmp _MPSBCalcPosWidth_Exit
        .ENDIF
        mov dwPositionMS, eax
        
        ;----------------------------------------------------------------------
        ; Get width of MediaPlayerSeekBar and the max size of current position
        ;----------------------------------------------------------------------
        Invoke GetClientRect, hWin, Addr rect
        mov eax, rect.right
        sub eax, rect.left
        mov dwDurationWidth, eax
        sub eax, 2
        mov dwMaxPositionWidth, eax
        
        .IF sdword ptr dwDurationWidth < 0
            Invoke SetWindowLong, hWin, @MPSB_PositionWidth, 0
            jmp _MPSBCalcPosWidth_Exit
        .ENDIF
        
        ;----------------------------------------------------------------------
        ; Calculate the width of the position bar based on current position ms,
        ; duration ms and max width for position bar
        ;----------------------------------------------------------------------
        Invoke GetWindowLong, hWin, @MPSB_DurationMS
        mov dwDurationMS, eax
        
        mov eax, dwPositionMS
        .IF eax == dwDurationMS ; at max already
            Invoke SetWindowLong, hWin, @MPSB_PositionWidth, dwMaxPositionWidth
        .ELSE ; calculate width of position bar
            finit
            fwait
            fild dwMaxPositionWidth
            fild dwDurationMS
            fdiv
            fld st
            fild dwPositionMS
            fmul
            fistp dwPositionWidth
            Invoke SetWindowLong, hWin, @MPSB_PositionWidth, dwPositionWidth
        .ENDIF
        
    .ELSE ; MediaWindow handle not valid
        Invoke SetWindowLong, hWin, @MPSB_PositionWidth, 0
        jmp _MPSBCalcPosWidth_Exit
    .ENDIF

_MPSBCalcPosWidth_Exit:

    mov eax, 0
    ret
_MPSBCalcPosWidth ENDP

;------------------------------------------------------------------------------
; _MPSBTimerProc
;
; Function called from timer when it is running. Default is every 1 second
; (1000ms) it will call this function, which gets the current position of the
; media player mediaitem being played.
; 
; Parameters:
; 
; * lpParam - Handle to the MediaPlayer Seek Bar Control.
;
; * TimerOrWaitFired - not used.
;
; Notes:
; 
; See MPSBStart and MPSBStop for controlling the timer.
;
;------------------------------------------------------------------------------
_MPSBTimerProc PROC lpParam:DWORD, TimerOrWaitFired:DWORD
    LOCAL TimerCallbackFunction:_MPSBTimerCallback_Ptr
    LOCAL TimerCallbackParam:DWORD
    LOCAL dwDurationMS:DWORD
    LOCAL dwPositionMS:DWORD
    
    ; lpParam is hControl
    
    IFDEF DEBUG32
    ;PrintText '_MPSBTimerProc'
    ENDIF

    Invoke IsWindow, lpParam
    .IF eax == TRUE
        Invoke GetWindowLong, lpParam, @MPSB_MouseDown
        .IF eax == TRUE
            ret ; skip whilst user is moving the bar around    
        .ENDIF
        Invoke GetWindowLong, lpParam, @MPSB_MediaWindow
        Invoke IsWindow, eax
        .IF eax == TRUE
            Invoke GetWindowLong, lpParam, @MPSB_DurationMS
            mov dwDurationMS, eax
            Invoke _MPSBGetPosition, lpParam
            mov dwPositionMS, eax
            Invoke _MPSBCalcPosWidth, lpParam
            Invoke InvalidateRect, lpParam, NULL, TRUE
            Invoke UpdateWindow, lpParam
            Invoke GetWindowLong, lpParam, @MPSB_TimerCB
            .IF eax != 0
                mov TimerCallbackFunction, eax
                Invoke GetWindowLong, lpParam, @MPSB_TimerCBParam
                mov TimerCallbackParam, eax
                ; Call callback function
                Invoke TimerCallbackFunction, dwPositionMS, TimerCallbackParam
            .ENDIF
            
            ; Added check for > duration issue
            mov eax, dwPositionMS
            .IF sdword ptr eax > dwDurationMS
                Invoke MFPMediaPlayer_Stop, pMP
                Invoke MPSBSetPositionMS, lpParam, 0
                Invoke MPSBRefresh, lpParam
                ret
            .ENDIF
            
        .ELSE
            Invoke SetWindowLong, lpParam, @MPSB_DurationMS, 0
            Invoke SetWindowLong, lpParam, @MPSB_PositionMS, 0
        .ENDIF
    .ENDIF
    ret
_MPSBTimerProc ENDP

;------------------------------------------------------------------------------
; MPSBInit
;
; Initialize the MediaPlayerSeekBar Control with values it needs to work
; 
; Parameters:
; 
; * hControl - Handle to the MediaPlayer Seek Bar Control.
;
; * hMediaWindow - Handle to the main MFPlayer window.
;
; Notes:
; 
; The address of the required MFPlayer functions are abstracted here, so that 
; we dont have to link in the MFPlayer.lib file, to make this control self 
; contained.
;
;------------------------------------------------------------------------------
MPSBInit PROC hControl:DWORD, hMediaWindow:DWORD, pMediaPlayer:DWORD, lpTimerCallback:DWORD, lpTimerCallbackParam:DWORD

    IFDEF DEBUG32
    ;PrintText 'MPSBInit'
    ENDIF

    Invoke IsWindow, hControl
    .IF eax == TRUE
        Invoke IsWindow, hMediaWindow
        .IF eax == TRUE
            Invoke SetWindowLong, hControl, @MPSB_MediaWindow, hMediaWindow
            Invoke SetWindowLong, hControl, @MPSB_MediaPlayer, pMediaPlayer
            
            .IF lpTimerCallback != 0
                Invoke SetWindowLong, hControl, @MPSB_TimerCB, lpTimerCallback
            .ELSE
                Invoke SetWindowLong, hControl, @MPSB_TimerCB, 0
            .ENDIF
            
            .IF lpTimerCallbackParam != 0
                Invoke SetWindowLong, hControl, @MPSB_TimerCBParam, lpTimerCallbackParam
            .ELSE
                Invoke SetWindowLong, hControl, @MPSB_TimerCBParam, 0
            .ENDIF
            
        .ELSE
            Invoke SetWindowLong, hControl, @MPSB_MediaWindow, 0
            Invoke SetWindowLong, hControl, @MPSB_MediaPlayer, 0
            Invoke SetWindowLong, hControl, @MPSB_TimerCB, 0
            Invoke SetWindowLong, hControl, @MPSB_TimerCBParam, 0
        .ENDIF
    .ENDIF
    ret
MPSBInit ENDP

;------------------------------------------------------------------------------
; MPSBSetDurationMS
;
; Set the @MPSB_DurationMS variable by the value in the dwDurationMS parameter.
; 
; Parameters:
; 
; * hControl - Handle to the MediaPlayer Seek Bar Control.
;
; * dwDurationMS - The duration of the mediaitem in milliseconds. If -1 is used
;   then the duration is fetched from the MFPlayer itself.
;------------------------------------------------------------------------------
MPSBSetDurationMS PROC hControl:DWORD, dwDurationMS:DWORD
    LOCAL pMediaPlayer:DWORD
    LOCAL dwDurationValueMS:DWORD
    
    IFDEF DEBUG32
    ;PrintText 'MPSBSetDurationMS'
    ENDIF
    
    Invoke IsWindow, hControl
    .IF eax == TRUE
        Invoke GetWindowLong, hControl, @MPSB_MediaWindow
        Invoke IsWindow, eax
        .IF eax == TRUE
            .IF dwDurationMS == -1
                ;------------------------------------------------------------------
                ; Get Duration Value From Media Player
                ;------------------------------------------------------------------
                Invoke GetWindowLong, hControl, @MPSB_MediaPlayer
                mov pMediaPlayer, eax
                .IF pMediaPlayer != 0
                    Invoke MFPMediaPlayer_GetDuration, pMediaPlayer, Addr dwDurationValueMS
                    .IF eax == TRUE
                        Invoke SetWindowLong, hControl, @MPSB_DurationMS, dwDurationValueMS
                    .ELSE
                        Invoke SetWindowLong, hControl, @MPSB_DurationMS, 0
                    .ENDIF
                .ENDIF
            .ELSE
                Invoke SetWindowLong, hControl, @MPSB_DurationMS, dwDurationMS    
            .ENDIF
        .ELSE
            Invoke SetWindowLong, hControl, @MPSB_DurationMS, 0
        .ENDIF
    .ENDIF
    
    ret
MPSBSetDurationMS ENDP

;------------------------------------------------------------------------------
; MPSBSetPositionMS
;
; Set the @MPSB_PositionMS variable by the value in the dwPositionMS parameter.
; 
; Parameters:
; 
; * hControl - Handle to the MediaPlayer Seek Bar Control.
;
; * dwPositionMS - The position of the mediaitem in milliseconds. If -1 is used
;   then the position is fetched from the MFPlayer itself.
;------------------------------------------------------------------------------
MPSBSetPositionMS PROC hControl:DWORD, dwPositionMS:DWORD
    LOCAL pMediaPlayer:DWORD
    LOCAL dwPositionValueMS:DWORD
    
    IFDEF DEBUG32
    ;PrintText 'MPSBSetPositionMS'
    ENDIF
    
    Invoke IsWindow, hControl
    .IF eax == TRUE
        Invoke GetWindowLong, hControl, @MPSB_MediaWindow
        Invoke IsWindow, eax
        .IF eax == TRUE
            .IF dwPositionMS == -1
                ;------------------------------------------------------------------
                ; Get Position Value From Media Player
                ;------------------------------------------------------------------
                Invoke GetWindowLong, hControl, @MPSB_MediaPlayer
                mov pMediaPlayer, eax
                .IF pMediaPlayer != 0
                    Invoke MFPMediaPlayer_GetPosition, pMediaPlayer, Addr dwPositionValueMS
                    .IF eax == TRUE
                        Invoke SetWindowLong, hControl, @MPSB_PositionMS, dwPositionValueMS
                    .ELSE
                        Invoke SetWindowLong, hControl, @MPSB_PositionMS, 0
                    .ENDIF
                .ENDIF
            .ELSE
                Invoke SetWindowLong, hControl, @MPSB_PositionMS, dwPositionMS    
            .ENDIF
        .ELSE
            Invoke SetWindowLong, hControl, @MPSB_PositionMS, 0
        .ENDIF
    .ENDIF
    ret
MPSBSetPositionMS ENDP

;------------------------------------------------------------------------------
; MPSBGetPositionMS
;
; Get the value of the @MPSB_PositionMS variable.
;
; Parameters:
; 
; * hControl - Handle to the MediaPlayer Seek Bar Control.
;
; Returns:
;
; The @MPSB_PositionMS variable in eax. The position in milliseconds. -1 error
;
;------------------------------------------------------------------------------
MPSBGetPositionMS PROC hControl:DWORD
    Invoke IsWindow, hControl
    .IF eax == TRUE
        Invoke GetWindowLong, hControl, @MPSB_MediaWindow
        Invoke IsWindow, eax
        .IF eax == TRUE
            Invoke GetWindowLong, hControl, @MPSB_PositionMS
        .ELSE
            mov eax, -1
        .ENDIF
    .ELSE
        mov eax, -1
    .ENDIF
    ret
MPSBGetPositionMS ENDP

;------------------------------------------------------------------------------
; MPSBStart
;
; Starts the timer. On a defined interval, default is 1 second (1000ms) the
; timer event will call the _MPSBTimerProc function. This will fetch the
; current position of the mediaitem from the MFPlayer and recalculate the
; position width in pixels for when the control draws that.
; 
; Parameters:
; 
; * hControl - Handle to the MediaPlayer Seek Bar Control.
;
; Notes:
;
; This should be called anytime the MFPlayer is about to Play a mediaitem.
; Usually this is when the user clicks a 'Play' button.
;
;------------------------------------------------------------------------------
MPSBStart PROC hControl:DWORD
    LOCAL hQueue:DWORD
    LOCAL hTimer:DWORD
    
    IFDEF DEBUG32
    ;PrintText 'MPSBStart'
    ENDIF
    
    Invoke IsWindow, hControl
    .IF eax == TRUE
    
        Invoke GetWindowLong, hControl, @MPSB_Queue
        mov hQueue, eax
        Invoke GetWindowLong, hControl, @MPSB_Timer
        mov hTimer, eax
        .IF hQueue != NULL ; re-use existing hQueue
            Invoke ChangeTimerQueueTimer, hQueue, hTimer, MPSB_TIMER_INTERVAL, MPSB_TIMER_INTERVAL
            .IF eax == 0 ; failed
                .IF hQueue != NULL
                    Invoke DeleteTimerQueueEx, hQueue, FALSE
                .ENDIF
                Invoke SetWindowLong, hControl, @MPSB_Queue, 0
                Invoke SetWindowLong, hControl, @MPSB_Timer, 0
                IFDEF DEBUG32
                PrintText 'MPSBStart::ChangeTimerQueueTimer Failed'
                ENDIF
            .ENDIF
        .ELSE ; Try to create TimerQueue 
            Invoke CreateTimerQueue
            .IF eax != NULL
                mov hQueue, eax
                Invoke CreateTimerQueueTimer, Addr hTimer, hQueue, Addr _MPSBTimerProc, hControl, MPSB_TIMER_INTERVAL, MPSB_TIMER_INTERVAL, 0
                .IF eax == 0 ; failed
                    .IF hQueue != NULL
                        Invoke DeleteTimerQueueEx, hQueue, FALSE
                    .ENDIF
                    Invoke SetWindowLong, hControl, @MPSB_Queue, 0
                    Invoke SetWindowLong, hControl, @MPSB_Timer, 0
                    IFDEF DEBUG32
                    PrintText 'MPSBStart::CreateTimerQueueTimer Failed'
                    ENDIF
                .ELSE ; Success! - so save TimerQueue handles for re-use
                    IFDEF DEBUG32
                    ;PrintText 'MPSBStart::CreateTimerQueueTimer Ok'
                    ENDIF
                    Invoke SetWindowLong, hControl, @MPSB_Queue, hQueue
                    Invoke SetWindowLong, hControl, @MPSB_Timer, hTimer
                .ENDIF
            .ELSE ; failed
                IFDEF DEBUG32
                PrintText 'MPSBStart::CreateTimerQueue Failed'
                ENDIF
            .ENDIF
        .ENDIF
    .ENDIF
    
    ret
MPSBStart ENDP

;------------------------------------------------------------------------------
; MPSBStop
;
; Stops the timer.
;
; Parameters:
; 
; * hControl - Handle to the MediaPlayer Seek Bar Control.
;
; Notes:
;
; This should be called anytime the MFPlayer has stopped playing a mediaitem.
; Usually this is when the user clicks a 'Stop' button.
; 
; If 'Pause' or 'Step' are being used then the timer does not need to be 
; stopped, although you can if you want to.
; 
;------------------------------------------------------------------------------
MPSBStop PROC hControl:DWORD
    LOCAL TimerCallbackFunction:_MPSBTimerCallback_Ptr
    LOCAL TimerCallbackParam:DWORD
    LOCAL hQueue:DWORD
    LOCAL hTimer:DWORD
    
    IFDEF DEBUG32
    ;PrintText 'MPSBStop'
    ENDIF
    
    Invoke IsWindow, hControl
    .IF eax == TRUE
        Invoke GetWindowLong, hControl, @MPSB_Queue
        mov hQueue, eax
        Invoke GetWindowLong, hControl, @MPSB_Timer
        mov hTimer, eax
        .IF hQueue != NULL
            Invoke ChangeTimerQueueTimer, hQueue, hTimer, INFINITE, 0
            .IF eax == 0 ; failed
                .IF hQueue != NULL
                    Invoke DeleteTimerQueueEx, hQueue, FALSE
                .ENDIF
                Invoke SetWindowLong, hControl, @MPSB_Queue, 0
                Invoke SetWindowLong, hControl, @MPSB_Timer, 0
                IFDEF DEBUG32
                PrintText 'MPSBStop::ChangeTimerQueueTimer Failed'
                ENDIF
            .ENDIF
            
            ; Call the callback one last time to update anything
            ;Invoke _MPSBTimerProc, hControl, 0
            Invoke GetWindowLong, hControl, @MPSB_TimerCB
            .IF eax != 0
                mov TimerCallbackFunction, eax
                Invoke GetWindowLong, hControl, @MPSB_TimerCBParam
                mov TimerCallbackParam, eax
                ; Call callback function
                Invoke TimerCallbackFunction, 0, TimerCallbackParam
                
                Invoke MPSBSetPositionMS, hControl, 0
                Invoke MPSBRefresh, hControl
                
            .ENDIF

        .ELSE ; failed
            IFDEF DEBUG32
            PrintText 'MPSBStop::hQueue == 0'
            ENDIF
        .ENDIF
    .ENDIF    
    
    ret
MPSBStop ENDP

;------------------------------------------------------------------------------
; MPSBStepPosition
;------------------------------------------------------------------------------
MPSBStepPosition PROC USES EBX hControl:DWORD, dwSeconds:DWORD, bForward:DWORD
    LOCAL dwDurationMS:DWORD
    LOCAL dwPositionMS:DWORD
    LOCAL dwState:DWORD
    
    Invoke IsWindow, hControl
    .IF eax == TRUE
        Invoke GetWindowLong, hControl, @MPSB_MediaWindow
        Invoke IsWindow, eax
        .IF eax == TRUE
        
            Invoke MFPMediaPlayer_GetState, pMP, Addr dwState
            mov eax, dwState
            .IF eax == MFP_MEDIAPLAYER_STATE_EMPTY || eax == MFP_MEDIAPLAYER_STATE_SHUTDOWN || eax == MFP_MEDIAPLAYER_STATE_STOPPED
                ret
            .ENDIF
            
            .IF dwCurrentRate > MFP_DEFAULT_RATE
                ret ; limit step 10 to default play speed or below
            .ENDIF
            
            Invoke GetWindowLong, hControl, @MPSB_DurationMS
            mov dwDurationMS, eax
            ;Invoke GetWindowLong, hControl, @MPSB_PositionMS
            ;mov dwPositionMS, eax
            
            ; Get current position rather than last reported one stored in @MPSB_PositionMS
            Invoke MFPMediaPlayer_GetPosition, pMP, Addr dwPositionMS
            
            mov eax, dwSeconds
            .IF eax == 0
                mov eax, 10
            .ENDIF
            mov ebx, 1000
            mul ebx ; convert to milliseconds
            mov ebx, dwPositionMS
            .IF bForward == TRUE
                add ebx, eax
                ; added check for > duration issue
                mov eax, dwDurationMS
                .IF sdword ptr ebx > eax
                    Invoke MFPMediaPlayer_Stop, pMP
                    Invoke MPSBSetPositionMS, hControl, 0
                    Invoke MPSBRefresh, hControl
                    ret
                .ENDIF
            .ELSE
                sub ebx, eax
                .IF sdword ptr ebx < 0
                    mov ebx, 0
                .ENDIF
            .ENDIF
            mov dwPositionMS, ebx
            
            ;------------------------------------------------------------------
            ; If timer is firing, we prevent it from updating whilst we are
            ; setting the position +/- 10 seconds, by faking mouse down
            ;------------------------------------------------------------------            
            Invoke SetWindowLong, hControl, @MPSB_MouseDown, TRUE
            Invoke MFPMediaPlayer_SetPosition, pMP, dwPositionMS
            ;Invoke MFPMediaPlayer_UpdateVideo, pMP
            Invoke SetWindowLong, hControl, @MPSB_MouseDown, FALSE
            
        .ENDIF
    .ENDIF
    
    ret
MPSBStepPosition ENDP

;------------------------------------------------------------------------------
; MPSBRefresh
;------------------------------------------------------------------------------
MPSBRefresh PROC hControl:DWORD
    Invoke _MPSBCalcPosWidth, hControl
    Invoke InvalidateRect, hControl, NULL, TRUE
    ret
MPSBRefresh ENDP











