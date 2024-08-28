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

MediaPlayerControlsProc     PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
MediaPlayerControlsUpdate   PROTO hWin:QWORD
_MPCInit                    PROTO hWin:QWORD
_MPCPaint                   PROTO hWin:QWORD
_MPCToolbarCustomdraw       PROTO hWin:QWORD, hToolbar:QWORD, lParam:QWORD, bDialog:QWORD
ToolBarScreenAspectDropdown PROTO hWin:QWORD

IFNDEF ImageList_AddIcon
ImageList_AddIcon           PROTO himl:QWORD, hicon:QWORD
ENDIF
IFNDEF TBN_DROPDOWN
TBN_DROPDOWN equ TBN_FIRST - 10
ENDIF
IFNDEF TBDDRET_DEFAULT
TBDDRET_DEFAULT equ 0
ENDIF
IFNDEF TB_ADDBUTTONS
TB_ADDBUTTONSA equ WM_USER + 20
TB_ADDBUTTONS equ TB_ADDBUTTONSA
ENDIF

.CONST
; MediaPlayer Seek Bar Control Messages:
MPCM_UPDATE             EQU WM_USER + 2003 ; update buttons based on media player state (play/pause/stop)

; MediaPlayerControls Icon IDs
ICO_MPC_OPEN            EQU 300
ICO_MPC_STOP            EQU 301
ICO_MPC_PAUSE           EQU 302
ICO_MPC_PLAY            EQU 303
ICO_MPC_STEP            EQU 304
ICO_MPC_EXIT            EQU 305
ICO_MPC_FULLSCREEN      EQU 306
ICO_MPC_ABOUT           EQU 307
ICO_MPC_A_STRETCH       EQU 308
ICO_MPC_A_NORMAL        EQU 309
ICO_MPC_VOLUME          EQU 310
ICO_MPC_MUTE            EQU 311

; MediaPlayerControls.dlg
IDD_MediaPlayerControls	EQU 3000
IDC_MPC_Open		    EQU 3001
IDC_MPC_Stop		    EQU 3002
IDC_MPC_Pause		    EQU 3003
IDC_MPC_Play		    EQU 3004
IDC_MPC_PlayPauseToggle EQU 3004
IDC_MPC_Step		    EQU 3005
IDC_MPC_Fullscreen	    EQU 3006
IDC_MPC_Exit		    EQU 3007
IDC_MPC_ToolbarControls EQU 3008
IDC_MPC_ToolbarVolume   EQU 3009
IDC_MPC_VolumeToggle    EQU 3010
IDC_MPC_VolumeSlider    EQU 3011
IDC_MPC_ToolbarScreen   EQU 3012
IDC_MPC_Aspect          EQU 3013
IDC_MPC_About           EQU 3014

; MediaPlayerControls Toolbar Control IDs
TBID_MPC_Open           EQU 0
TBID_MPC_Stop           EQU 1
TBID_MPC_Pause          EQU 2
TBID_MPC_Play           EQU 3
TBID_MPC_Step           EQU 4
TBID_MPC_Exit           EQU 5
TBID_MPC_Fullscreen     EQU 6
TBID_MPC_About          EQU 7
TBID_MPC_A_STRETCH      EQU 8
TBID_MPC_A_NORMAL       EQU 9
TBID_MPC_Volume         EQU 10
TBID_MPC_Mute           EQU 11

; MediaPlayerControls Toolbar Colors
TB_TEXTCOLOR            EQU RGB(31,31,31)
TB_FS_TEXTCOLOR         EQU RGB(240,240,240)

TB_BACKCOLOR            EQU MAINWINDOW_BACKCOLOR ;RGB(240,240,240)
TB_FS_BACKCOLOR         EQU MAINWINDOW_FS_BACKCOLOR ; RGB(81,81,81)


.DATA
; MediaPlayerControls Tooltips
szTip_MPC_Open		    DB 'Open a media file to play',0
szTip_MPC_Stop		    DB 'Stop Playback',0
szTip_MPC_Pause		    DB 'Pause Playback',0
szTip_MPC_Play		    DB 'Play/Pause Toggle',0
szTip_MPC_Step		    DB 'Frame Step',0
szTip_MPC_Fullscreen	DB 'Toggle Fullscreen',0
szTip_MPC_Exit		    DB 'Exit Application',0
szTip_MPC_VolumeToggle  DB 'Volume Mute Toggle',0
szTip_MPC_Aspect        DB 'Video Aspect',0
szTip_MPC_About         DB 'About MediaPlayer',0

.DATA?
; MediaPlayerControls Handles
hMPC_ToolbarControls    DQ ?
hMPC_ToolbarVolume      DQ ?
hMPC_ToolbarScreen      DQ ?
hMPC_ImageList_Enabled  DQ ?
hMPC_ImageList_Disabled DQ ?
hMPC_VolumeSlider       DQ ?

.CODE

;------------------------------------------------------------------------------
; MediaPlayerControlsProc
;------------------------------------------------------------------------------
MediaPlayerControlsProc PROC FRAME USES RBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL wNotifyCode:QWORD
    LOCAL dwState:QWORD
    
    mov eax, uMsg
    .IF eax == WM_INITDIALOG
        Invoke _MPCInit, hWin

    .ELSEIF eax == WM_COMMAND
        mov rax, wParam
        shr rax, 16
        mov wNotifyCode, rax
        mov rax, wParam
        and rax, 0FFFFh
        
        .IF eax == IDC_MPC_Open
            Invoke MediaPlayerBrowseForFile, hMainWindow
            .IF rax == TRUE
                Invoke MediaPlayerOpenFile, hMainWindow, lpszMediaFileName
            .ENDIF
            
        .ELSEIF eax == IDC_MPC_Stop
            .IF pMI != 0
                Invoke MFPMediaPlayer_Stop, pMP
            .ENDIF
            
        .ELSEIF eax == IDC_MPC_PlayPauseToggle
            .IF pMI != 0
                Invoke MFPMediaPlayer_Toggle, pMP
            .ELSE    
                Invoke MediaPlayerBrowseForFile, hMainWindow
                .IF rax == TRUE
                    Invoke MediaPlayerOpenFile, hMainWindow, lpszMediaFileName
                .ENDIF
            .ENDIF
            Invoke SetFocus, hMediaPlayerWindow
            
        .ELSEIF eax == IDC_MPC_Step
            .IF pMI != 0
                Invoke MFPMediaPlayer_Step, pMP
            .ENDIF
            
        .ELSEIF eax == IDC_MPC_Fullscreen
            Invoke GUIToggleFullscreen, hMainWindow

        .ELSEIF eax == IDC_MPC_VolumeToggle
            .IF g_Mute == TRUE ; Unmute
                mov g_Mute, FALSE
                Invoke SendMessage, hMPC_ToolbarVolume, TB_CHANGEBITMAP, IDC_MPC_VolumeToggle, TBID_MPC_Volume
                Invoke MFPMediaPlayer_SetMute, pMP, FALSE
                Invoke MediaPlayerVolumeSet, hMPC_VolumeSlider, g_PrevVolume
            .ELSE ; Mute
                mov g_Mute, TRUE
                Invoke SendMessage, hMPC_ToolbarVolume, TB_CHANGEBITMAP, IDC_MPC_VolumeToggle, TBID_MPC_Mute
                Invoke MFPMediaPlayer_GetVolume, pMP, Addr g_PrevVolume
                Invoke MFPMediaPlayer_SetMute, pMP, TRUE
                Invoke MediaPlayerVolumeSet, hMPC_VolumeSlider, 0
            .ENDIF
        
        .ELSEIF eax == IDC_MPC_Aspect ; see TBN_DROPDOWN for dropdown part of Aspect button
            Invoke ToolBarScreenAspectDropdown, hWin
            ret
        
        .ELSEIF eax == IDC_MPC_About
            Invoke DialogBoxParam, hInstance, IDD_AboutDlg, hWin, Addr MediaPlayerAboutDlgProc, NULL
            
        .ELSEIF eax == IDC_MPC_Exit
            Invoke SendMessage, hMainWindow, WM_CLOSE, 0, 0
            
        .ENDIF
    
    .ELSEIF eax == WM_NOTIFY
        mov rbx, lParam
        mov eax, [rbx].NMHDR.code
        ;----------------------------------------------------------------------
        ; Tooltips for toolbar buttons
        ;----------------------------------------------------------------------
        .IF eax == TTN_NEEDTEXT
            mov rbx, lParam
            mov rax, [rbx].NMHDR.idFrom
            .IF rax == IDC_MPC_Open
                lea rax, szTip_MPC_Open
            .ELSEIF rax == IDC_MPC_Stop
                lea rax, szTip_MPC_Stop
            .ELSEIF rax == IDC_MPC_Pause
                lea rax, szTip_MPC_Pause
            .ELSEIF rax == IDC_MPC_Play
                lea rax, szTip_MPC_Play
            .ELSEIF rax == IDC_MPC_Step
                lea rax, szTip_MPC_Step
            .ELSEIF rax == IDC_MPC_Fullscreen
                lea rax, szTip_MPC_Fullscreen
            .ELSEIF rax == IDC_MPC_Exit
                lea rax, szTip_MPC_Exit
            .ELSEIF rax == IDC_MPC_VolumeToggle
                lea rax, szTip_MPC_VolumeToggle
            .ELSEIF rax == IDC_MPC_Aspect
                lea rax, szTip_MPC_Aspect
            .ELSEIF rax == IDC_MPC_About
                lea rax, szTip_MPC_About
            .ELSE
                ret   
            .ENDIF
    		mov rbx, lParam
            mov [rbx].TOOLTIPTEXT.lpszText, rax
            
        ;----------------------------------------------------------------------
        ; Customize the look and feel of our Toolbars
        ;----------------------------------------------------------------------
        .ELSEIF eax == NM_CUSTOMDRAW
            mov rbx, lParam
            mov rax, (NMHDR PTR [rbx]).hwndFrom
            .IF rax == hMPC_ToolbarControls
                Invoke _MPCToolbarCustomdraw, hWin, hMPC_ToolbarControls, lParam, TRUE
            .ELSEIF rax == hMPC_ToolbarVolume
                Invoke _MPCToolbarCustomdraw, hWin, hMPC_ToolbarVolume, lParam, TRUE
            .ELSEIF rax == hMPC_ToolbarScreen
                Invoke _MPCToolbarCustomdraw, hWin, hMPC_ToolbarScreen, lParam, TRUE
            .ENDIF
            ret
            
        .ELSEIF eax == TBN_DROPDOWN ; for dropdown part of Aspect button
            Invoke ToolBarScreenAspectDropdown, hWin
            mov rax, TBDDRET_DEFAULT
            ret
            
        .ENDIF
    
    .ELSEIF eax == WM_ERASEBKGND
        mov rax, 1
        ret
    
    .ELSEIF eax == WM_PAINT
        Invoke _MPCPaint, hWin
        ret

    .ELSEIF eax == WM_CLOSE
        Invoke DestroyWindow, hWin
     
    .ELSEIF eax == MPCM_UPDATE
        Invoke MediaPlayerControlsUpdate, hWin
        mov rax, 0
        ret 
       
    .ELSE
        mov rax, FALSE
        ret
    .ENDIF
    
    mov rax, TRUE
    ret
MediaPlayerControlsProc ENDP

;------------------------------------------------------------------------------
; _MPCInit
;------------------------------------------------------------------------------
_MPCInit PROC FRAME USES RBX hWin:QWORD
    LOCAL hIcon:QWORD
    LOCAL bSize:DWORD
	LOCAL tbb:TBBUTTON
    
    Invoke GetDlgItem, hWin, IDC_MPC_ToolbarControls
    mov hMPC_ToolbarControls, rax

    Invoke GetDlgItem, hWin, IDC_MPC_ToolbarVolume ; removed flat style from this toolbar
    mov hMPC_ToolbarVolume, rax

    Invoke GetDlgItem, hWin, IDC_MPC_ToolbarScreen
    mov hMPC_ToolbarScreen, rax

    Invoke ImageList_Create, 32, 32, ILC_COLOR32, 16, 32
    mov hMPC_ImageList_Enabled, rax
    
    Invoke SendMessage, hMPC_ToolbarControls, TB_SETIMAGELIST, 0, hMPC_ImageList_Enabled
    Invoke SendMessage, hMPC_ToolbarControls, TB_SETEXTENDEDSTYLE, TBSTYLE_EX_DOUBLEBUFFER, TBSTYLE_EX_DOUBLEBUFFER
    
    Invoke SendMessage, hMPC_ToolbarVolume, TB_SETIMAGELIST, 0, hMPC_ImageList_Enabled
    Invoke SendMessage, hMPC_ToolbarVolume, TB_SETEXTENDEDSTYLE, TBSTYLE_EX_DOUBLEBUFFER, TBSTYLE_EX_DOUBLEBUFFER
    
    Invoke SendMessage, hMPC_ToolbarScreen, TB_SETIMAGELIST, 0, hMPC_ImageList_Enabled
    Invoke SendMessage, hMPC_ToolbarScreen, TB_SETEXTENDEDSTYLE, TBSTYLE_EX_DOUBLEBUFFER or TBSTYLE_EX_DRAWDDARROWS, TBSTYLE_EX_DOUBLEBUFFER or TBSTYLE_EX_DRAWDDARROWS
    
    ; Media Player Images
    Invoke LoadImage, hInstance, ICO_MPC_OPEN, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, rax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_STOP, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, rax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_PAUSE, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, rax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_PLAY, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, rax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_STEP, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, rax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_EXIT, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, rax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_FULLSCREEN, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, rax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_ABOUT, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, rax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_A_STRETCH, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, rax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_A_NORMAL, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, rax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon

    Invoke LoadImage, hInstance, ICO_MPC_VOLUME, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, rax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_MUTE, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, rax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    ;--------------------------------------------------------------------------
    ; Set button and bitmap size for Media Player toolbar button images
    ;--------------------------------------------------------------------------
    Invoke SendMessage, hMPC_ToolbarControls, TB_BUTTONSTRUCTSIZE, sizeof TBBUTTON, 0	; Set toolbar struct size
	mov rbx, 32
	mov rax, 32
	shl rax, 16d
	mov ax, bx
	mov bSize, eax
	Invoke SendMessage, hMPC_ToolbarControls, TB_SETBITMAPSIZE, 0, bSize ; Set bitmap size
	Invoke SendMessage, hMPC_ToolbarControls, TB_SETBUTTONSIZE, 0, bSize ; Set each button size
    
	mov tbb.fsState, TBSTATE_ENABLED
	mov tbb.dwData, 0
	mov tbb.iString, 0

	mov tbb.iBitmap, TBID_MPC_Stop
	mov tbb.idCommand, IDC_MPC_Stop
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb	

	mov tbb.iBitmap, TBID_MPC_Play
	mov tbb.idCommand, IDC_MPC_PlayPauseToggle
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb	
	
	mov tbb.iBitmap, TBID_MPC_Step
	mov tbb.idCommand, IDC_MPC_Step
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb	

    ;--------------------------------------------------------------------------
    ; Set button and bitmap size for Volume toolbar button images
    ;--------------------------------------------------------------------------
    Invoke SendMessage, hMPC_ToolbarVolume, TB_BUTTONSTRUCTSIZE, sizeof TBBUTTON, 0	; Set toolbar struct size
	mov rbx, 32 ; width
	mov rax, 32 ; height
	shl rax, 16d
	mov ax, bx
	mov bSize, eax
	Invoke SendMessage, hMPC_ToolbarVolume, TB_SETBITMAPSIZE, 0, bSize ; Set bitmap size
	Invoke SendMessage, hMPC_ToolbarVolume, TB_SETBUTTONSIZE, 0, bSize ; Set each button size
    
	mov tbb.fsState, TBSTATE_ENABLED
	mov tbb.dwData, 0
	mov tbb.iString, 0
    
	mov tbb.iBitmap, TBID_MPC_Volume
	mov tbb.idCommand, IDC_MPC_VolumeToggle
	mov tbb.fsStyle, TBSTYLE_CHECK ;TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarVolume, TB_ADDBUTTONS, 1, Addr tbb
    
    mov tbb.iBitmap, 230
    mov tbb.fsStyle, TBSTYLE_SEP ; removed flat style from this toolbar to hide seperator line
    Invoke SendMessage, hMPC_ToolbarVolume, TB_ADDBUTTONS, 1, Addr tbb
    
    ;--------------------------------------------------------------------------
    ; Set button and bitmap size for Screen toolbar button images
    ;--------------------------------------------------------------------------
    Invoke SendMessage, hMPC_ToolbarScreen, TB_BUTTONSTRUCTSIZE, sizeof TBBUTTON, 0	; Set toolbar struct size
	mov rbx, 32 ; width
	mov rax, 32 ; height
	shl rax, 16d
	mov ax, bx
	mov bSize, eax
	Invoke SendMessage, hMPC_ToolbarScreen, TB_SETBITMAPSIZE, 0, bSize ; Set bitmap size
	Invoke SendMessage, hMPC_ToolbarScreen, TB_SETBUTTONSIZE, 0, bSize ; Set each button size
    
	mov tbb.fsState, TBSTATE_ENABLED
	mov tbb.dwData, 0
	mov tbb.iString, 0
    
	mov tbb.iBitmap, TBID_MPC_Fullscreen
	mov tbb.idCommand, IDC_MPC_Fullscreen
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarScreen, TB_ADDBUTTONS, 1, Addr tbb
	
	mov tbb.iBitmap, TBID_MPC_About
	mov tbb.idCommand, IDC_MPC_About
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarScreen, TB_ADDBUTTONS, 1, Addr tbb
	
	mov tbb.iBitmap, TBID_MPC_Exit
	mov tbb.idCommand, IDC_MPC_Exit
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarScreen, TB_ADDBUTTONS, 1, Addr tbb
	
;	mov tbb.iBitmap, TBID_MPC_A_NORMAL
;	mov tbb.idCommand, IDC_MPC_Aspect
;	mov tbb.fsStyle, TBSTYLE_BUTTON or TBSTYLE_DROPDOWN ; or TBSTYLE_AUTOSIZE 
;	Invoke SendMessage, hMPC_ToolbarScreen, TB_ADDBUTTONS, 1, Addr tbb

    ret
_MPCInit ENDP

;------------------------------------------------------------------------------
; _MPCPaint
;------------------------------------------------------------------------------
_MPCPaint PROC FRAME hWin:QWORD
    LOCAL ps:PAINTSTRUCT
    LOCAL rect:RECT
    LOCAL rectbrush:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:QWORD
    LOCAL hBrush:QWORD
    LOCAL dwBrushOrgX:DWORD
    LOCAL dwBrushOrgY:DWORD
    LOCAL hParent:QWORD
    
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
    
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, rax
    Invoke SelectObject, hdcMem, rax
    
    .IF g_Fullscreen == FALSE
        Invoke SetDCBrushColor, hdcMem, MAINWINDOW_BACKCOLOR
    .ELSE
        Invoke SetDCBrushColor, hdcMem, MAINWINDOW_FS_BACKCOLOR
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
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Finish Double Buffering & Cleanup
    ;----------------------------------------------------------    
    Invoke RestoreDC, hdcMem, -1                                ; restore last saved state, which is just after hdcMem was created
    .IF hBufferBitmap != 0
        Invoke DeleteObject, hBufferBitmap                      ; Delete bitmap used for double buffering
    .ENDIF
    Invoke DeleteDC, hdcMem                                     ; Delete double buffer hdc
    
    Invoke EndPaint, hWin, Addr ps
    mov rax, 0
    
    ret
_MPCPaint ENDP

;------------------------------------------------------------------------------
; MediaPlayerControls Toolbar Customdraw
;------------------------------------------------------------------------------
_MPCToolbarCustomdraw PROC FRAME USES RBX hWin:QWORD, hToolbar:QWORD, lParam:QWORD, bDialog:QWORD
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:QWORD
    LOCAL hBrush:QWORD
    LOCAL rect:RECT
    LOCAL rectbrush:RECT
    LOCAL dwBrushOrgX:DWORD
    LOCAL dwBrushOrgY:DWORD
    LOCAL hParent:QWORD
    
    IFDEF DEBUG64
    ;PrintText '_MPCToolbarCustomdraw'
    ENDIF
    
    mov rbx, lParam
    mov eax, (NMTBCUSTOMDRAW PTR [rbx]).nmcd.dwDrawStage
    
    .IF eax == CDDS_PREPAINT
        .IF bDialog == TRUE
            mov rax, CDRF_NOTIFYITEMDRAW
            Invoke SetWindowLongPtr, hWin, DWL_MSGRESULT, rax
            mov rax, TRUE
            ret
        .ELSE
            mov rax, CDRF_NOTIFYITEMDRAW
            ret
        .ENDIF

    .ELSEIF eax == CDDS_PREERASE ; requires style TBSTYLE_CUSTOMERASE
        mov rbx, lParam
        Invoke CopyRect, Addr rect, Addr (NMTBCUSTOMDRAW PTR [rbx]).nmcd.rc
    
        ;----------------------------------------------------------------------
        ; If rectangle is empty then no point doing anything
        ;----------------------------------------------------------------------
        Invoke IsRectEmpty, Addr rect
        .IF rax == TRUE
            .IF bDialog == TRUE
                mov rax, CDRF_DODEFAULT
                Invoke SetWindowLongPtr, hWin, DWL_MSGRESULT, rax
                mov rax, TRUE
                ret
            .ELSE
                mov rax, CDRF_DODEFAULT
                ret
            .ENDIF
        .ENDIF
        
        ;----------------------------------------------------------------------
        ; If hdc is empty then no point doing anything
        ;----------------------------------------------------------------------
        mov rbx, lParam
        mov rax, (NMTBCUSTOMDRAW PTR [rbx]).nmcd.hdc
        .IF rax == 0
            .IF bDialog == TRUE
                mov rax, CDRF_DODEFAULT
                Invoke SetWindowLongPtr, hWin, DWL_MSGRESULT, rax
                mov rax, TRUE
                ret
            .ELSE
                mov rax, CDRF_DODEFAULT
                ret
            .ENDIF
        .ENDIF
        mov hdc, rax
        
        Invoke CreateCompatibleDC, hdc                              ; Create memory dc for our buffer
        mov hdcMem, rax
        
        Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom ; Create bitmap of size that matches dimensions
        mov hBufferBitmap, rax
        Invoke SelectObject, hdcMem, hBufferBitmap                  ; Select our created buffer bitmap into our memory dc
        
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, rax
        Invoke SelectObject, hdcMem, hBrush
        .IF g_Fullscreen == FALSE
            Invoke SetDCBrushColor, hdcMem, TB_BACKCOLOR
        .ELSE
            Invoke SetDCBrushColor, hdcMem, TB_FS_BACKCOLOR
        .ENDIF
        Invoke FillRect, hdcMem, Addr rect, hBrush
        
        ;----------------------------------------------------------
        ; Use pattern brush to texture our background
        ;----------------------------------------------------------
        IFDEF MP_PATTERN_BACKGROUND
        .IF hPatternBrush != 0
            Invoke MPBrushOrgs, hToolbar, hdcMem, 0, 0
            Invoke SelectObject, hdcMem, hPatternBrush
            Invoke PatBlt, hdcMem, 0, 0, rect.right, rect.bottom, PATINVERT
            Invoke SetBrushOrgEx, hdcMem, 0, 0, 0 ; reset the brush origin  
        .ENDIF
        ENDIF
        
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
        
        .IF bDialog == TRUE
            mov rax, CDRF_SKIPDEFAULT
            Invoke SetWindowLongPtr, hWin, DWL_MSGRESULT, rax
            mov rax, TRUE
            ret
        .ELSE
            mov rax, CDRF_SKIPDEFAULT
            ret
        .ENDIF

    .ELSEIF eax == CDDS_ITEMPREPAINT
        .IF bDialog == TRUE
            .IF g_Fullscreen == FALSE
                mov rax, CDRF_DODEFAULT
            .ELSE
                mov rbx, lParam
                mov (NMTBCUSTOMDRAW PTR [rbx]).clrHighlightHotTrack, RGB(197,218,237)
                mov rax, TBCDRF_HILITEHOTTRACK
            .ENDIF 
            Invoke SetWindowLongPtr, hWin, DWL_MSGRESULT, rax
            mov rax, TRUE
            ret
        .ELSE
            mov rax, TBCDRF_HILITEHOTTRACK
            ret
        .ENDIF
    .ENDIF
    
    .IF bDialog == TRUE
        mov rax, CDRF_DODEFAULT
        Invoke SetWindowLongPtr, hWin, DWL_MSGRESULT, rax
        mov rax, TRUE
        ret
    .ELSE
        mov rax, CDRF_DODEFAULT
        ret
    .ENDIF
    
    ret
_MPCToolbarCustomdraw ENDP

;------------------------------------------------------------------------------
; MediaPlayerControlsUpdate
;  
; Update toolbar button bitmaps based on media player state (play/pause/stop)
; Same as SendMessage, hMediaPlayerControls, MPCM_UPDATE, 0, 0
;
; Returns:
;
; eax contains the current state
;
;------------------------------------------------------------------------------
MediaPlayerControlsUpdate PROC FRAME hWin:QWORD
    LOCAL dwState:DWORD
    
    Invoke MFPMediaPlayer_GetState, pMP, Addr dwState
    mov eax, dwState
    .IF eax == MFP_MEDIAPLAYER_STATE_PAUSED || eax == MFP_MEDIAPLAYER_STATE_STOPPED
        Invoke SendMessage, hMPC_ToolbarControls, TB_CHANGEBITMAP, IDC_MPC_PlayPauseToggle, TBID_MPC_Play
    .ELSEIF eax == MFP_MEDIAPLAYER_STATE_PLAYING
        Invoke SendMessage, hMPC_ToolbarControls, TB_CHANGEBITMAP, IDC_MPC_PlayPauseToggle, TBID_MPC_Pause
    .ENDIF
    mov eax, dwState
    ret
MediaPlayerControlsUpdate ENDP

;-------------------------------------------------------------------------------------
; From Toolbar Add button, show dropdown menu
;-------------------------------------------------------------------------------------
ToolBarScreenAspectDropdown PROC FRAME USES RBX hWin:QWORD
    LOCAL xpos:DWORD
    LOCAL ypos:DWORD
    LOCAL rect:RECT
    LOCAL nLeft:DWORD
    LOCAL nHeight:DWORD

    IFDEF DEBUG64
    ;PrintText 'ToolBarScreenAspectDropdown'
    ENDIF

    Invoke SendMessage, hMPC_ToolbarScreen, TB_GETITEMRECT, 1, Addr rect
    
    mov eax, rect.left
    mov nLeft, eax
    
    mov eax, rect.bottom
    mov ebx, rect.top
    sub eax, ebx
 
    mov nHeight, eax
    Invoke MapWindowPoints, hMPC_ToolbarScreen, NULL, Addr rect, 2
    push rax
    shr eax, 16
    add eax, nHeight
    mov ypos, eax
    pop rax
    and	eax, 0FFFFh
    add eax, nLeft
    mov xpos, eax

	Invoke TrackPopupMenu, hMediaPlayerAspectMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON, xpos, ypos, NULL, hMainWindow, NULL
	
    ret
ToolBarScreenAspectDropdown ENDP
















