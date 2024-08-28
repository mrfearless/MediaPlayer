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

; MediaPlayer Seek Bar Control Functions:
MediaPlayerSeekBarRegister  PROTO
MediaPlayerSeekBarCreate    PROTO hWndParent:QWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, qwResourceID:QWORD, qwStyle:QWORD
MPSBInit                    PROTO hControl:QWORD, hMediaWindow:QWORD, pMediaPlayer:QWORD, lpTimerCallback:QWORD, lpTimerCallbackParam:QWORD
MPSBSetDurationMS           PROTO hControl:QWORD, dwDurationMS:DWORD
MPSBSetPositionMS           PROTO hControl:QWORD, dwPositionMS:DWORD
MPSBGetPositionMS           PROTO hControl:QWORD
MPSBStart                   PROTO hControl:QWORD
MPSBStop                    PROTO hControl:QWORD

; MediaPlayer Seek Bar Control Functions (Internal):
_MPSBWndProc                PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
_MPSBPaint                  PROTO hWin:QWORD
_MPSBInit                   PROTO hWin:QWORD
_MPSBCleanup                PROTO hWin:QWORD

_MPSBOnMouseDn              PROTO hWin:QWORD, wParam:WPARAM, lParam:LPARAM
_MPSBOnMouseUp              PROTO hWin:QWORD, wParam:WPARAM, lParam:LPARAM
_MPSBOnMouseMove            PROTO hWin:QWORD, wParam:WPARAM, lParam:LPARAM

_MPSBGetPosition            PROTO hWin:QWORD
_MPSBCalcPosWidth           PROTO hWin:QWORD
_MPSBTimerProc              PROTO lpParam:QWORD, TimerOrWaitFired:QWORD

_MPSBTimerCallback_Proto    TYPEDEF PROTO dwPositionMS:DWORD, lParam:QWORD  
_MPSBTimerCallback_Ptr      TYPEDEF PTR _MPSBTimerCallback_Proto





.CONST
; MediaPlayer Seek Bar Control Messages:
MPSBM_START             EQU WM_USER + 2001
MPSBM_STOP              EQU WM_USER + 2002

; MediaPlayer Seek Bar Control Properties:
@MPSB_Init              EQU  0
@MPSB_MediaWindow       EQU  8
@MPSB_MediaPlayer       EQU 16
@MPSB_Queue             EQU 24
@MPSB_Timer             EQU 32
@MPSB_DurationMS        EQU 40
@MPSB_PositionMS        EQU 48
@MPSB_PositionWidth     EQU 56
@MPSB_PositionHeight    EQU 64
@MPSB_TimerCB           EQU 72
@MPSB_TimerCBParam      EQU 80
@MPSB_MouseMove         EQU 88
@MPSB_MouseDown         EQU 96

MPSB_TIMER_INTERVAL     EQU 250 ; 500 ; 1000 ; ms

; MediaPlayer Seek Bar Control Colors
MPSB_BACKCOLOR          EQU MAINWINDOW_BACKCOLOR
MPSB_FS_BACKCOLOR       EQU MAINWINDOW_FS_BACKCOLOR

MPSB_BORDERCOLOR        EQU RGB(128,128,128) ; RGB(168,168,168) ; 
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
szMPSBClass             DB 'MediaPlayerSeekBar',0     ; Class name for creating our MediaPlayerSeekBar control


.CODE

;------------------------------------------------------------------------------
; MediaPlayerSeekBarRegister - Registers the MediaPlayer Seek Bar Control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as 'MediaPlayerSeekBar'
;------------------------------------------------------------------------------
MediaPlayerSeekBarRegister PROC FRAME
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:QWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, rax

    invoke GetClassInfoEx, hinstance, Addr szMPSBClass, Addr wc 
    .IF rax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        lea rax, szMPSBClass
        mov wc.lpszClassName, rax
        mov rax, hinstance
        mov wc.hInstance, rax
        lea rax, _MPSBWndProc
        mov wc.lpfnWndProc, rax 
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, rax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 108
        Invoke RegisterClassEx, Addr wc
    .ENDIF
    
    ret
MediaPlayerSeekBarRegister ENDP

;------------------------------------------------------------------------------
; MediaPlayerSeekBarCreate
;
; Create the MediaPlayer Seek Bar Control. Calls MediaPlayerSeekBarRegister beforehand.
;
; Returns handle in rax of the newly created control.
;------------------------------------------------------------------------------
MediaPlayerSeekBarCreate PROC FRAME hWndParent:QWORD, xpos:DWORD, ypos:DWORD, dwWidth:DWORD, dwHeight:DWORD, qwResourceID:QWORD, qwStyle:QWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:QWORD
    LOCAL hControl:QWORD
    LOCAL qwNewStyle:QWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, rax

    Invoke MediaPlayerSeekBarRegister

    mov rax, qwStyle
    mov qwNewStyle, rax
    and rax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF rax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or qwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF

    Invoke CreateWindowEx, NULL, Addr szMPSBClass, NULL, dword ptr qwNewStyle, xpos, ypos, dwWidth, dwHeight, hWndParent, qwResourceID, hinstance, NULL
    mov hControl, rax
    .IF rax != NULL

    .ENDIF
    mov rax, hControl
    
    ret
MediaPlayerSeekBarCreate ENDP

;------------------------------------------------------------------------------
; _MPSBWndProc
;
; Main processing window for our MediaPlayer Seek Bar Control
;------------------------------------------------------------------------------
_MPSBWndProc PROC FRAME USES RBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_NCCREATE
        mov rax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke _MPSBInit, hWin
        mov rax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MPSBCleanup, hWin
        mov rax, 0
        ret
        
    .ELSEIF eax == WM_ERASEBKGND
        mov rax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MPSBPaint, hWin
        mov rax, 0
        ret
    
    .ELSEIF eax == WM_SIZE
        ; Check if internal properties set
        Invoke GetWindowLongPtr, hWin, @MPSB_Init
        .IF rax == TRUE ; Yes they are
            Invoke _MPSBCalcPosWidth, hWin
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF
        mov rax, 0
        ret
    
    .ELSEIF eax == WM_SIZING
        ; Check if internal properties set
        Invoke GetWindowLongPtr, hWin, @MPSB_Init
        .IF rax == TRUE ; Yes they are
            Invoke _MPSBCalcPosWidth, hWin
            ;Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF
        mov rax, 0
        ret
    
    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke _MPSBOnMouseDn, hWin, wParam, lParam
        mov rax, 0
        ret
        
    .ELSEIF eax == WM_LBUTTONUP
        Invoke _MPSBOnMouseUp, hWin, wParam, lParam
        mov rax, 0
        ret
        
    .ELSEIF eax == WM_MOUSEMOVE
        Invoke _MPSBOnMouseMove, hWin, wParam, lParam
        mov rax, 0
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
_MPSBInit PROC FRAME hWin:QWORD
    LOCAL hParent:QWORD
    LOCAL qwStyle:QWORD
    
    Invoke GetParent, hWin
    mov hParent, rax
    
    ; get style and check it is our default at least
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
    ; Use 0-63 of style for height of position bar
    ;--------------------------------------------------------------------------
    mov rax, qwStyle
    and rax, 3Fh
    .IF rax == 0
        mov rax, 12
    .ENDIF
    Invoke SetWindowLongPtr, hWin, @MPSB_PositionHeight, rax
    
    Invoke SetWindowLongPtr, hWin, @MPSB_Init, TRUE
    
    ret
_MPSBInit ENDP

;------------------------------------------------------------------------------
; _MPSBCleanup
;
; Cleanup any stuff we need to
;------------------------------------------------------------------------------
_MPSBCleanup PROC FRAME hWin:QWORD
    LOCAL hQueue:QWORD
    LOCAL hTimer:QWORD
    
    Invoke GetWindowLongPtr, hWin, @MPSB_Queue
    mov hQueue, rax
    Invoke GetWindowLongPtr, hWin, @MPSB_Timer
    mov hTimer, rax
    
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
_MPSBPaint PROC FRAME USES RBX hWin:QWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL rectposition:RECT
    LOCAL rectcontrol:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:QWORD
    LOCAL hBrush:QWORD
    LOCAL PositionWidth:DWORD
    LOCAL PositionHeight:DWORD
    LOCAL PositionY:DWORD
    
    Invoke IsWindowVisible, hWin
    .IF rax == FALSE
        mov rax, 0
        ret
    .ENDIF
    
    Invoke GetWindowLongPtr, hWin, @MPSB_PositionWidth
    mov PositionWidth, eax
    Invoke GetWindowLongPtr, hWin, @MPSB_PositionHeight
    mov PositionHeight, eax
    
    Invoke BeginPaint, hWin, Addr ps
    mov hdc, rax
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect                       ; Get dimensions of area to buffer
    Invoke CopyRect, Addr rectposition, Addr rect
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
    xor rax, rax
    mov eax, rect.bottom
    sub eax, rect.top
    shr eax, 1
    
    xor rbx, rbx
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
    mov hBrush, rax
    Invoke SelectObject, hdcMem, rax
    .IF g_Fullscreen == FALSE
        Invoke SetDCBrushColor, hdcMem, MPSB_BACKCOLOR
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
    mov rax, MPSB_BORDERCOLOR
    .IF rax != -1
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, rax
        Invoke SelectObject, hdcMem, rax
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
        xor rax, rax
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
    mov rax, 0
    
    ret
_MPSBPaint ENDP

;------------------------------------------------------------------------------
; _MPSBOnMouseDn (WM_LBUTTONDOWN)
;------------------------------------------------------------------------------
_MPSBOnMouseDn PROC FRAME hWin:QWORD, wParam:WPARAM, lParam:LPARAM
    LOCAL dwState:DWORD
    
    IFDEF DEBUG64
    ;PrintText '_MPSBOnMouseDn'
    ENDIF
    
    Invoke MFPMediaPlayer_GetState, pMP, Addr dwState
    mov eax, dwState
    .IF eax == MFP_MEDIAPLAYER_STATE_EMPTY || eax == MFP_MEDIAPLAYER_STATE_SHUTDOWN || eax == MFP_MEDIAPLAYER_STATE_STOPPED
        ret
    .ENDIF
    
    Invoke SetWindowLongPtr, hWin, @MPSB_MouseDown, TRUE
    Invoke SetCapture, hWin
    ret
_MPSBOnMouseDn ENDP

;------------------------------------------------------------------------------
; _MPSBOnMouseUp (WM_LBUTTONUP)
;------------------------------------------------------------------------------
_MPSBOnMouseUp PROC FRAME USES RBX RCX hWin:QWORD, wParam:WPARAM, lParam:LPARAM
    LOCAL dwState:DWORD
    LOCAL pt:POINT
    LOCAL rect:RECT
    LOCAL dwPositionWidth:DWORD
    LOCAL dwPositionMaxWidth:DWORD
    LOCAL fPositionPercent:REAL4
    LOCAL dwDurationMS:DWORD
    LOCAL dwPositionMS:DWORD
    LOCAL dw100:QWORD
    
    IFDEF DEBUG64
    ;PrintText '_MPSBOnMouseUp'
    ENDIF
    
    Invoke GetWindowLongPtr, hWin, @MPSB_MouseDown
    .IF eax == TRUE
        Invoke SetWindowLongPtr, hWin, @MPSB_MouseDown, FALSE

        Invoke ReleaseCapture
        mov rax, lParam
        and rax, 0FFFFh
        mov pt.x, eax
        mov rax, lParam
        shr rax, 16d
        mov pt.y, eax
        
        Invoke GetClientRect, hWin, Addr rect
        add rect.left, 1
        sub rect.right, 1
        mov eax, rect.right
        sub eax, 1
        add eax, 1
        sub eax, rect.left
        mov dwPositionMaxWidth, eax
        
        xor rax, rax
        xor rbx, rbx
        xor rcx, rcx
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
        
        Invoke GetWindowLongPtr, hWin, @MPSB_DurationMS
        mov dwDurationMS, eax
        
        Invoke SetWindowLongPtr, hWin, @MPSB_PositionWidth, dwPositionWidth
        Invoke InvalidateRect, hWin, NULL, TRUE
        
        xor rax, rax
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
        .IF rax == FALSE
            IFDEF DEBUG64
            PrintText 'Failed to set position'
            ENDIF
        .ENDIF
    .ENDIF
    
    ret
_MPSBOnMouseUp ENDP

;------------------------------------------------------------------------------
; _MPVOnMouseMove (WM_MOUSEMOVE)
;------------------------------------------------------------------------------
_MPSBOnMouseMove PROC FRAME USES RBX RCX hWin:QWORD, wParam:WPARAM, lParam:LPARAM
    LOCAL pt:POINT
    LOCAL rect:RECT
    LOCAL dwPositionWidth:DWORD
    
    Invoke GetWindowLongPtr, hWin, @MPSB_MouseDown
    .IF rax == TRUE
        mov rax, lParam
        and rax, 0FFFFh
        mov pt.x, eax
        mov rax, lParam
        shr rax, 16d
        mov pt.y, eax

        Invoke GetClientRect, hWin, Addr rect
        add rect.left, 1
        sub rect.right, 1
        
        xor rax, rax
        xor rbx, rbx
        xor rcx, rcx
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
        
        Invoke SetWindowLongPtr, hWin, @MPSB_PositionWidth, dwPositionWidth
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
_MPSBGetPosition PROC FRAME hWin:QWORD
    LOCAL pMediaPlayer:QWORD
    LOCAL dwPositionMS:DWORD
    
    mov dwPositionMS, -1
    ;--------------------------------------------------------------------------
    ; Get Position Value From Media Player
    ;--------------------------------------------------------------------------
    Invoke GetWindowLongPtr, hWin, @MPSB_MediaPlayer
    mov pMediaPlayer, rax
    .IF pMediaPlayer != 0
        Invoke MFPMediaPlayer_GetPosition, pMediaPlayer, Addr dwPositionMS
        .IF rax == TRUE
            Invoke SetWindowLongPtr, hWin, @MPSB_PositionMS, dwPositionMS
        .ELSE
            Invoke SetWindowLongPtr, hWin, @MPSB_PositionMS, -1
        .ENDIF
    .ELSE
        Invoke SetWindowLongPtr, hWin, @MPSB_PositionMS, -1
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
_MPSBCalcPosWidth PROC FRAME USES RBX hWin:QWORD
    LOCAL dwDurationWidth:DWORD
    LOCAL dwPositionWidth:DWORD
    LOCAL dwMaxPositionWidth:DWORD
    LOCAL dwDurationMS:DWORD
    LOCAL dwPositionMS:DWORD
    LOCAL rect:RECT
    
    Invoke IsWindowVisible, hWin
    .IF rax == FALSE
        mov rax, 0
        ret
    .ENDIF
    
    Invoke GetWindowLongPtr, hWin, @MPSB_MediaWindow
    Invoke IsWindow, rax
    .IF rax == TRUE

        Invoke GetWindowLongPtr, hWin, @MPSB_PositionMS
        .IF rax == -1 || rax == 0
            Invoke SetWindowLongPtr, hWin, @MPSB_PositionWidth, 0
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
        
        .IF SDWORD ptr dwDurationWidth < 0
            Invoke SetWindowLongPtr, hWin, @MPSB_PositionWidth, 0
            jmp _MPSBCalcPosWidth_Exit
        .ENDIF
        
        ;----------------------------------------------------------------------
        ; Calculate the width of the position bar based on current position ms,
        ; duration ms and max width for position bar
        ;----------------------------------------------------------------------
        Invoke GetWindowLongPtr, hWin, @MPSB_DurationMS
        mov dwDurationMS, eax
        
        mov eax, dwPositionMS
        .IF eax == dwDurationMS ; at max already
            Invoke SetWindowLongPtr, hWin, @MPSB_PositionWidth, dwMaxPositionWidth
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
            Invoke SetWindowLongPtr, hWin, @MPSB_PositionWidth, dwPositionWidth
        .ENDIF
        
    .ELSE ; MediaWindow handle not valid
        Invoke SetWindowLongPtr, hWin, @MPSB_PositionWidth, 0
        jmp _MPSBCalcPosWidth_Exit
    .ENDIF

_MPSBCalcPosWidth_Exit:

    mov rax, 0
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
_MPSBTimerProc PROC FRAME lpParam:QWORD, TimerOrWaitFired:QWORD
    LOCAL TimerCallbackFunction:_MPSBTimerCallback_Ptr
    LOCAL TimerCallbackParam:QWORD
    LOCAL dwPostionMS:DWORD
    
    ; lpParam is hControl
    
    IFDEF DEBUG64
    ;PrintText '_MPSBTimerProc'
    ENDIF
    
    Invoke IsWindow, lpParam
    .IF rax == TRUE
        Invoke GetWindowLongPtr, lpParam, @MPSB_MouseDown
        .IF rax == TRUE
            ret ; skip whilst user is moving the bar around    
        .ENDIF
        Invoke GetWindowLongPtr, lpParam, @MPSB_MediaWindow
        Invoke IsWindow, rax
        .IF rax == TRUE
            Invoke _MPSBGetPosition, lpParam
            mov dwPostionMS, eax
            Invoke _MPSBCalcPosWidth, lpParam
            Invoke InvalidateRect, lpParam, NULL, TRUE
            Invoke UpdateWindow, lpParam
            Invoke GetWindowLongPtr, lpParam, @MPSB_TimerCB
            .IF rax != 0
                mov TimerCallbackFunction, rax
                Invoke GetWindowLongPtr, lpParam, @MPSB_TimerCBParam
                mov TimerCallbackParam, rax
                ; Call callback function
                Invoke TimerCallbackFunction, dwPostionMS, TimerCallbackParam
            .ENDIF
        .ELSE
            Invoke SetWindowLongPtr, lpParam, @MPSB_DurationMS, 0
            Invoke SetWindowLongPtr, lpParam, @MPSB_PositionMS, 0
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
MPSBInit PROC FRAME hControl:QWORD, hMediaWindow:QWORD, pMediaPlayer:QWORD, lpTimerCallback:QWORD, lpTimerCallbackParam:QWORD

    IFDEF DEBUG64
    ;PrintText 'MPSBInit'
    ENDIF

    Invoke IsWindow, hControl
    .IF rax == TRUE
        Invoke IsWindow, hMediaWindow
        .IF rax == TRUE
            Invoke SetWindowLongPtr, hControl, @MPSB_MediaWindow, hMediaWindow
            Invoke SetWindowLongPtr, hControl, @MPSB_MediaPlayer, pMediaPlayer
            
            .IF lpTimerCallback != 0
                Invoke SetWindowLongPtr, hControl, @MPSB_TimerCB, lpTimerCallback
            .ELSE
                Invoke SetWindowLongPtr, hControl, @MPSB_TimerCB, 0
            .ENDIF
            
            .IF lpTimerCallbackParam != 0
                Invoke SetWindowLongPtr, hControl, @MPSB_TimerCBParam, lpTimerCallbackParam
            .ELSE
                Invoke SetWindowLongPtr, hControl, @MPSB_TimerCBParam, 0
            .ENDIF
            
        .ELSE
            Invoke SetWindowLongPtr, hControl, @MPSB_MediaWindow, 0
            Invoke SetWindowLongPtr, hControl, @MPSB_MediaPlayer, 0
            Invoke SetWindowLongPtr, hControl, @MPSB_TimerCB, 0
            Invoke SetWindowLongPtr, hControl, @MPSB_TimerCBParam, 0
        .ENDIF
    .ENDIF
    ret
MPSBInit ENDP

;------------------------------------------------------------------------------
; MPSBSetDurationMS
;
; Set the @MPSB_DurationMS variable by the value in the qwDurationMS parameter.
; 
; Parameters:
; 
; * hControl - Handle to the MediaPlayer Seek Bar Control.
;
; * qwDurationMS - The duration of the mediaitem in milliseconds. If -1 is used
;   then the duration is fetched from the MFPlayer itself.
;------------------------------------------------------------------------------
MPSBSetDurationMS PROC FRAME hControl:QWORD, dwDurationMS:DWORD
    LOCAL pMediaPlayer:QWORD
    LOCAL dwDurationValueMS:DWORD

    Invoke IsWindow, hControl
    .IF rax == TRUE
        Invoke GetWindowLongPtr, hControl, @MPSB_MediaWindow
        Invoke IsWindow, rax
        .IF rax == TRUE
            .IF dwDurationMS == -1
                ;------------------------------------------------------------------
                ; Get Duration Value From Media Player
                ;------------------------------------------------------------------
                Invoke GetWindowLongPtr, hControl, @MPSB_MediaPlayer
                mov pMediaPlayer, rax
                .IF pMediaPlayer != 0
                    Invoke MFPMediaPlayer_GetDuration, pMediaPlayer, Addr dwDurationValueMS
                    .IF rax == TRUE
                        Invoke SetWindowLongPtr, hControl, @MPSB_DurationMS, dwDurationValueMS
                    .ELSE
                        Invoke SetWindowLongPtr, hControl, @MPSB_DurationMS, 0
                    .ENDIF
                .ENDIF
            .ELSE
                Invoke SetWindowLongPtr, hControl, @MPSB_DurationMS, dwDurationMS
            .ENDIF
        .ELSE
            Invoke SetWindowLongPtr, hControl, @MPSB_DurationMS, 0
        .ENDIF
    .ENDIF
    
    ret
MPSBSetDurationMS ENDP

;------------------------------------------------------------------------------
; MPSBSetPositionMS
;
; Set the @MPSB_PositionMS variable by the value in the qwPositionMS parameter.
; 
; Parameters:
; 
; * hControl - Handle to the MediaPlayer Seek Bar Control.
;
; * qwPositionMS - The position of the mediaitem in milliseconds. If -1 is used
;   then the position is fetched from the MFPlayer itself.
;------------------------------------------------------------------------------
MPSBSetPositionMS PROC FRAME hControl:QWORD, dwPositionMS:DWORD
    LOCAL pMediaPlayer:QWORD
    LOCAL dwPositionValueMS:DWORD
    
    IFDEF DEBUG64
    ;PrintText 'MPSBSetPositionMS'
    ENDIF
    
    Invoke IsWindow, hControl
    .IF rax == TRUE
        Invoke GetWindowLongPtr, hControl, @MPSB_MediaWindow
        Invoke IsWindow, rax
        .IF rax == TRUE
            .IF dwPositionMS == -1
                ;------------------------------------------------------------------
                ; Get Position Value From Media Player
                ;------------------------------------------------------------------
                Invoke GetWindowLongPtr, hControl, @MPSB_MediaPlayer
                mov pMediaPlayer, rax
                .IF pMediaPlayer != 0
                    Invoke MFPMediaPlayer_GetPosition, pMediaPlayer, Addr dwPositionValueMS
                    .IF rax == TRUE
                        Invoke SetWindowLongPtr, hControl, @MPSB_PositionMS, dwPositionValueMS
                    .ELSE
                        Invoke SetWindowLongPtr, hControl, @MPSB_PositionMS, 0
                    .ENDIF
                .ENDIF
            .ELSE
                Invoke SetWindowLongPtr, hControl, @MPSB_PositionMS, dwPositionMS    
            .ENDIF
        .ELSE
            Invoke SetWindowLongPtr, hControl, @MPSB_PositionMS, 0
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
; The @MPSB_PositionMS variable in rax. The position in milliseconds. -1 error
;
;------------------------------------------------------------------------------
MPSBGetPositionMS PROC FRAME hControl:QWORD
    Invoke IsWindow, hControl
    .IF rax == TRUE
        Invoke GetWindowLongPtr, hControl, @MPSB_MediaWindow
        Invoke IsWindow, rax
        .IF rax == TRUE
            Invoke GetWindowLongPtr, hControl, @MPSB_PositionMS
        .ELSE
            mov rax, -1
        .ENDIF
    .ELSE
        mov rax, -1
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
MPSBStart PROC FRAME hControl:QWORD
    LOCAL hQueue:QWORD
    LOCAL hTimer:QWORD
    
    IFDEF DEBUG64
    ;PrintText 'MPSBStart'
    ENDIF
    
    Invoke IsWindow, hControl
    .IF rax == TRUE
    
        Invoke GetWindowLongPtr, hControl, @MPSB_Queue
        mov hQueue, rax
        Invoke GetWindowLongPtr, hControl, @MPSB_Timer
        mov hTimer, rax
        .IF hQueue != NULL ; re-use existing hQueue
            Invoke ChangeTimerQueueTimer, hQueue, hTimer, MPSB_TIMER_INTERVAL, MPSB_TIMER_INTERVAL
            .IF rax == 0 ; failed
                .IF hQueue != NULL
                    Invoke DeleteTimerQueueEx, hQueue, FALSE
                .ENDIF
                Invoke SetWindowLongPtr, hControl, @MPSB_Queue, 0
                Invoke SetWindowLongPtr, hControl, @MPSB_Timer, 0
                IFDEF DEBUG64
                PrintText 'MPSBStart::ChangeTimerQueueTimer Failed'
                ENDIF
            .ENDIF
        .ELSE ; Try to create TimerQueue 
            Invoke CreateTimerQueue
            .IF rax != NULL
                mov hQueue, rax
                Invoke CreateTimerQueueTimer, Addr hTimer, hQueue, Addr _MPSBTimerProc, hControl, MPSB_TIMER_INTERVAL, MPSB_TIMER_INTERVAL, 0
                .IF rax == 0 ; failed
                    .IF hQueue != NULL
                        Invoke DeleteTimerQueueEx, hQueue, FALSE
                    .ENDIF
                    Invoke SetWindowLongPtr, hControl, @MPSB_Queue, 0
                    Invoke SetWindowLongPtr, hControl, @MPSB_Timer, 0
                    IFDEF DEBUG64
                    PrintText 'MPSBStart::CreateTimerQueueTimer Failed'
                    ENDIF
                .ELSE ; Success! - so save TimerQueue handles for re-use
                    IFDEF DEBUG64
                    ;PrintText 'MPSBStart::CreateTimerQueueTimer Ok'
                    ENDIF
                    Invoke SetWindowLongPtr, hControl, @MPSB_Queue, hQueue
                    Invoke SetWindowLongPtr, hControl, @MPSB_Timer, hTimer
                .ENDIF
            .ELSE ; failed
                IFDEF DEBUG64
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
MPSBStop PROC FRAME hControl:QWORD
    LOCAL TimerCallbackFunction:_MPSBTimerCallback_Ptr
    LOCAL TimerCallbackParam:QWORD
    LOCAL hQueue:QWORD
    LOCAL hTimer:QWORD
    
    IFDEF DEBUG64
    ;PrintText 'MPSBStop'
    ENDIF
    
    Invoke IsWindow, hControl
    .IF rax == TRUE
        Invoke GetWindowLongPtr, hControl, @MPSB_Queue
        mov hQueue, rax
        Invoke GetWindowLongPtr, hControl, @MPSB_Timer
        mov hTimer, rax
        .IF hQueue != NULL
            Invoke ChangeTimerQueueTimer, hQueue, hTimer, INFINITE, 0
            .IF rax == 0 ; failed
                .IF hQueue != NULL
                    Invoke DeleteTimerQueueEx, hQueue, FALSE
                .ENDIF
                Invoke SetWindowLongPtr, hControl, @MPSB_Queue, 0
                Invoke SetWindowLongPtr, hControl, @MPSB_Timer, 0
                IFDEF DEBUG64
                PrintText 'MPSBStop::ChangeTimerQueueTimer Failed'
                ENDIF
            .ENDIF
            
            ; Call the callback one last time to update anything
            Invoke _MPSBTimerProc, hControl, 0
;            Invoke GetWindowLongPtr, hControl, @MPSB_TimerCB
;            .IF rax != 0
;                mov TimerCallbackFunction, rax
;                Invoke GetWindowLongPtr, hControl, @MPSB_TimerCBParam
;                mov TimerCallbackParam, rax
;                ; Call callback function
;                Invoke TimerCallbackFunction, -1, TimerCallbackParam
;            .ENDIF

        .ELSE ; failed
            IFDEF DEBUG64
            PrintText 'MPSBStop::hQueue == 0'
            ENDIF
        .ENDIF
    .ENDIF    
    
    ret
MPSBStop ENDP















