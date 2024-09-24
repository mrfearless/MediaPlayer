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

MediaPlayerControlsProc     PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
MediaPlayerControlsUpdate   PROTO hWin:DWORD
_MPCInit                    PROTO hWin:DWORD
_MPCPaint                   PROTO hWin:DWORD
_MPCToolbarCustomdraw       PROTO hWin:DWORD, hToolbar:DWORD, lParam:DWORD, bDialog:DWORD

ToolBarPlaySpeedDropdown    PROTO hWin:DWORD
ToolBarAudioStreamDropdown  PROTO hWin:DWORD


.CONST
; MediaPlayer Seek Bar Control Messages:
MPCM_UPDATE             EQU WM_USER + 2003 ; update buttons based on media player state (play/pause/stop)

; MediaPlayerControls Icon IDs
ICO_MPC_STOP            EQU 300
ICO_MPC_PAUSE           EQU 301
ICO_MPC_PLAY            EQU 302
ICO_MPC_STEP            EQU 303
ICO_MPC_FULLSCREEN      EQU 304
ICO_MPC_ABOUT           EQU 305
ICO_MPC_VOLUME          EQU 306
ICO_MPC_MUTE            EQU 307
ICO_MPC_STEP10F         EQU 308
ICO_MPC_STEP10B         EQU 309
ICO_MPC_PLAYSPEED       EQU 310

; MediaPlayerControls.dlg
IDD_MediaPlayerControls	EQU 3000
IDC_MPC_Stop		    EQU 3001
IDC_MPC_PlayPauseToggle EQU 3002
IDC_MPC_Step		    EQU 3003
IDC_MPC_Fullscreen	    EQU 3004
IDC_MPC_About           EQU 3005
IDC_MPC_Step10F         EQU 3008
IDC_MPC_Step10B         EQU 3009
IDC_MPC_PlaySpeed       EQU 3010
IDC_MPC_VolumeToggle    EQU 3015
IDC_MPC_VolumeSlider    EQU 3016
IDC_MPC_ToolbarControls EQU 3020

; MediaPlayerControls Toolbar Control IDs
TBID_MPC_Stop           EQU 0
TBID_MPC_Pause          EQU 1
TBID_MPC_Play           EQU 2
TBID_MPC_Step           EQU 3
TBID_MPC_Fullscreen     EQU 4
TBID_MPC_About          EQU 5
TBID_MPC_Volume         EQU 6
TBID_MPC_Mute           EQU 7
TBID_MPC_Step10F        EQU 8
TBID_MPC_Step10B        EQU 9
TBID_MPC_PlaySpeed      EQU 10

; MediaPlayerControls Toolbar Colors
TB_TEXTCOLOR            EQU RGB(31,31,31)
TB_FS_TEXTCOLOR         EQU RGB(240,240,240)

TB_BACKCOLOR            EQU MAINWINDOW_BACKCOLOR ;RGB(240,240,240)
TB_FS_BACKCOLOR         EQU MAINWINDOW_FS_BACKCOLOR ; RGB(81,81,81)


.DATA?
ALIGN 4

; MediaPlayerControls Handles
hMPC_ToolbarControls    DD ?
hMPC_ImageList_Enabled  DD ?
hMPC_VolumeSlider       DD ?

.CODE

;------------------------------------------------------------------------------
; MediaPlayerControlsProc
;------------------------------------------------------------------------------
MediaPlayerControlsProc PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL wNotifyCode:DWORD
    LOCAL dwState:DWORD
    
    mov eax, uMsg
    .IF eax == WM_INITDIALOG
        Invoke _MPCInit, hWin

    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        shr eax, 16
        mov wNotifyCode, eax
        mov eax,wParam
        and eax,0FFFFh

        .IF eax == IDC_MPC_Stop
            .IF pMI != 0
                Invoke MFPMediaPlayer_Stop, pMP
            .ENDIF
            
        .ELSEIF eax == IDC_MPC_PlayPauseToggle
            .IF pMI != 0
                Invoke MFPMediaPlayer_Toggle, pMP
            .ELSE    
                Invoke MediaPlayerBrowseForFile, hMainWindow
                .IF eax == TRUE
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
                Invoke SendMessage, hMPC_ToolbarControls, TB_CHANGEBITMAP, IDC_MPC_VolumeToggle, TBID_MPC_Volume
                Invoke MFPMediaPlayer_SetMute, pMP, FALSE
                Invoke MediaPlayerVolumeSet, hMPC_VolumeSlider, g_PrevVolume
            .ELSE ; Mute
                mov g_Mute, TRUE
                Invoke SendMessage, hMPC_ToolbarControls, TB_CHANGEBITMAP, IDC_MPC_VolumeToggle, TBID_MPC_Mute
                Invoke MFPMediaPlayer_GetVolume, pMP, Addr g_PrevVolume
                Invoke MFPMediaPlayer_SetMute, pMP, TRUE
                Invoke MediaPlayerVolumeSet, hMPC_VolumeSlider, 0
            .ENDIF

        .ELSEIF eax == IDC_MPC_About
            Invoke GetKeyState, VK_CONTROL
            and eax, 8000h
            .IF eax == 8000h ; Ctrl + click on about menu item opens folder with ini file
                Invoke ShellExecute, hWin, Addr szShellExplore, Addr MediaPlayerIniFolder, NULL, NULL, SW_SHOW
            .ELSE
                Invoke DialogBoxParam, hInstance, IDD_AboutDlg, hWin, Addr MediaPlayerAboutDlgProc, NULL
            .ENDIF

        .ELSEIF eax == IDC_MPC_Step10F
            Invoke MPSBStepPosition, hMediaPlayerSeekBar, 10, TRUE
            
        .ELSEIF eax == IDC_MPC_Step10B
            Invoke MPSBStepPosition, hMediaPlayerSeekBar, 10, FALSE
            
        .ELSEIF eax == IDC_MPC_PlaySpeed
            Invoke ToolBarPlaySpeedDropdown, hWin

        .ENDIF
    
    .ELSEIF eax == WM_NOTIFY
        mov ebx, lParam
        mov eax, [ebx].NMHDR.code
        ;----------------------------------------------------------------------
        ; Tooltips for toolbar buttons
        ;----------------------------------------------------------------------
        .IF eax == TTN_NEEDTEXT
            mov ebx, lParam
            mov eax, [ebx].NMHDR.idFrom
            .IF eax == IDC_MPC_Stop
                mov eax, lpszTip_MPC_Stop
            .ELSEIF eax == IDC_MPC_PlayPauseToggle
                mov eax, lpszTip_MPC_Play
            .ELSEIF eax == IDC_MPC_Step
                mov eax, lpszTip_MPC_Step
            .ELSEIF eax == IDC_MPC_Fullscreen
                mov eax, lpszTip_MPC_Fullscreen
            .ELSEIF eax == IDC_MPC_VolumeToggle
                mov eax, lpszTip_MPC_VolumeToggle
            .ELSEIF eax == IDC_MPC_About
                .IF pszMediaItemInfo == 0
                    mov eax, lpszTip_MPC_About
                .ELSE
                    mov eax, pszMediaItemInfo
                .ENDIF
            .ELSEIF eax == IDC_MPC_Step10F
                mov eax, lpszTip_MPC_Step10F
            .ELSEIF eax == IDC_MPC_Step10B
                mov eax, lpszTip_MPC_Step10B
            .ELSEIF eax == IDC_MPC_PlaySpeed
                mov eax, lpszTip_MPC_PlaySpeed
            .ELSE
                ret   
            .ENDIF
    		mov ebx, lParam
            mov [ebx].TOOLTIPTEXT.lpszText, eax
            
        ;----------------------------------------------------------------------
        ; Customize the look and feel of our Toolbars
        ;----------------------------------------------------------------------
        .ELSEIF eax == NM_CUSTOMDRAW
            mov ebx, lParam
            mov eax, (NMHDR PTR [ebx]).hwndFrom
            .IF eax == hMPC_ToolbarControls
                Invoke _MPCToolbarCustomdraw, hWin, hMPC_ToolbarControls, lParam, TRUE
            .ENDIF
            ret
            
        .ELSEIF eax == TBN_DROPDOWN ; for dropdown buttons
            mov ebx, lParam
            mov eax, (NMTOOLBAR PTR [ebx]).iItem
            .IF eax == IDC_MPC_PlaySpeed
                Invoke ToolBarPlaySpeedDropdown, hWin
            
            .ELSEIF eax == IDC_MPC_VolumeToggle
                Invoke ToolBarAudioStreamDropdown, hWin
                
            .ENDIF
            mov eax, TBDDRET_DEFAULT
            ret
            
        .ENDIF
    
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret
    
    .ELSEIF eax == WM_PAINT
        Invoke _MPCPaint, hWin
        ret

    .ELSEIF eax == WM_CLOSE
        Invoke DestroyWindow, hWin
     
    .ELSEIF eax == MPCM_UPDATE
        Invoke MediaPlayerControlsUpdate, hWin
        mov eax, 0
        ret 
       
    .ELSE
        mov eax, FALSE
        ret
    .ENDIF
    
    mov eax, TRUE
    ret
MediaPlayerControlsProc ENDP

;------------------------------------------------------------------------------
; _MPCInit
;------------------------------------------------------------------------------
_MPCInit PROC USES EBX hWin:DWORD
    LOCAL hIcon:DWORD
    LOCAL bSize:DWORD
	LOCAL tbb:TBBUTTON
    
    Invoke GetDlgItem, hWin, IDC_MPC_ToolbarControls
    mov hMPC_ToolbarControls, eax

    Invoke ImageList_Create, 32, 32, ILC_COLOR32, 16, 32
    mov hMPC_ImageList_Enabled, eax
    
    Invoke SendMessage, hMPC_ToolbarControls, TB_SETIMAGELIST, 0, hMPC_ImageList_Enabled
    Invoke SendMessage, hMPC_ToolbarControls, TB_SETEXTENDEDSTYLE, TBSTYLE_EX_DOUBLEBUFFER or TBSTYLE_EX_DRAWDDARROWS, TBSTYLE_EX_DOUBLEBUFFER or TBSTYLE_EX_DRAWDDARROWS
    Invoke SendMessage, hMPC_ToolbarControls, TB_SETANCHORHIGHLIGHT, FALSE, 0
    
    ; Media Player Images
    IFDEF MP_RTLC_RESOURCES
    Invoke IconCreateFromCompressedRes, hInstance, ICO_MPC_STOP
    ELSE  
    Invoke LoadImage, hInstance, ICO_MPC_STOP, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    ENDIF
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    IFDEF MP_RTLC_RESOURCES
    Invoke IconCreateFromCompressedRes, hInstance, ICO_MPC_PAUSE
    ELSE  
    Invoke LoadImage, hInstance, ICO_MPC_PAUSE, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    ENDIF
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    IFDEF MP_RTLC_RESOURCES
    Invoke IconCreateFromCompressedRes, hInstance, ICO_MPC_PLAY
    ELSE  
    Invoke LoadImage, hInstance, ICO_MPC_PLAY, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    ENDIF
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    IFDEF MP_RTLC_RESOURCES
    Invoke IconCreateFromCompressedRes, hInstance, ICO_MPC_STEP
    ELSE  
    Invoke LoadImage, hInstance, ICO_MPC_STEP, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    ENDIF
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    IFDEF MP_RTLC_RESOURCES
    Invoke IconCreateFromCompressedRes, hInstance, ICO_MPC_FULLSCREEN
    ELSE  
    Invoke LoadImage, hInstance, ICO_MPC_FULLSCREEN, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    ENDIF
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    IFDEF MP_RTLC_RESOURCES
    Invoke IconCreateFromCompressedRes, hInstance, ICO_MPC_ABOUT
    ELSE  
    Invoke LoadImage, hInstance, ICO_MPC_ABOUT, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    ENDIF
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon

    IFDEF MP_RTLC_RESOURCES
    Invoke IconCreateFromCompressedRes, hInstance, ICO_MPC_VOLUME
    ELSE  
    Invoke LoadImage, hInstance, ICO_MPC_VOLUME, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    ENDIF
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    IFDEF MP_RTLC_RESOURCES
    Invoke IconCreateFromCompressedRes, hInstance, ICO_MPC_MUTE
    ELSE  
    Invoke LoadImage, hInstance, ICO_MPC_MUTE, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    ENDIF
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    IFDEF MP_RTLC_RESOURCES
    Invoke IconCreateFromCompressedRes, hInstance, ICO_MPC_STEP10F
    ELSE  
    Invoke LoadImage, hInstance, ICO_MPC_STEP10F, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    ENDIF
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    IFDEF MP_RTLC_RESOURCES
    Invoke IconCreateFromCompressedRes, hInstance, ICO_MPC_STEP10B
    ELSE  
    Invoke LoadImage, hInstance, ICO_MPC_STEP10B, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    ENDIF
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    IFDEF MP_RTLC_RESOURCES
    Invoke IconCreateFromCompressedRes, hInstance, ICO_MPC_PLAYSPEED
    ELSE  
    Invoke LoadImage, hInstance, ICO_MPC_PLAYSPEED, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    ENDIF
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    ;--------------------------------------------------------------------------
    ; Set button and bitmap size for Media Player toolbar button images
    ;--------------------------------------------------------------------------
    Invoke SendMessage, hMPC_ToolbarControls, TB_BUTTONSTRUCTSIZE, sizeof TBBUTTON, 0	; Set toolbar struct size
	mov ebx, 32
	mov eax, 32
	shl eax, 16d
	mov ax, bx
	mov bSize, eax
	Invoke SendMessage, hMPC_ToolbarControls, TB_SETBITMAPSIZE, 0, bSize ; Set bitmap size
	Invoke SendMessage, hMPC_ToolbarControls, TB_SETBUTTONSIZE, 0, bSize ; Set each button size
    
	mov tbb.fsState, TBSTATE_ENABLED
	mov tbb.dwData, 0
	mov tbb.iString, 0
    
    ; 42 wide each button, except seperators and volume spacing
    
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
	; 96 ; 126
	mov tbb.iBitmap, 14
	mov tbb.idCommand, -1
    mov tbb.fsStyle, TBSTYLE_SEP ; removed flat style from this toolbar to hide seperator line
    Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
	; 128 ; 158
	
	mov tbb.iBitmap, TBID_MPC_PlaySpeed
	mov tbb.idCommand, IDC_MPC_PlaySpeed
	mov tbb.fsStyle, TBSTYLE_BUTTON or TBSTYLE_DROPDOWN
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
	
	mov tbb.iBitmap, 2
	mov tbb.idCommand, -1
    mov tbb.fsStyle, TBSTYLE_SEP ; removed flat style from this toolbar to hide seperator line
    Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
	
	mov tbb.iBitmap, TBID_MPC_Step10B
	mov tbb.idCommand, IDC_MPC_Step10B
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb

	mov tbb.iBitmap, TBID_MPC_Step10F
	mov tbb.idCommand, IDC_MPC_Step10F
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
	;256 ;326
	mov tbb.iBitmap, 14
	mov tbb.idCommand, -1
    mov tbb.fsStyle, TBSTYLE_SEP ; removed flat style from this toolbar to hide seperator line
    Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
	;288 ; 358
	mov tbb.iBitmap, TBID_MPC_Volume
	mov tbb.idCommand, IDC_MPC_VolumeToggle
	mov tbb.fsStyle, TBSTYLE_CHECK or TBSTYLE_DROPDOWN;TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
    ;320 ; 400
    mov tbb.iBitmap, 116 ;230
    mov tbb.idCommand, -1
    mov tbb.fsStyle, TBSTYLE_SEP ; removed flat style from this toolbar to hide seperator line
    Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
    ;630
	mov tbb.iBitmap, 12 ;18
	mov tbb.idCommand, -1
    mov tbb.fsStyle, TBSTYLE_SEP ; removed flat style from this toolbar to hide seperator line
    Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
    ;550 ; 662
	mov tbb.iBitmap, TBID_MPC_Fullscreen
	mov tbb.idCommand, IDC_MPC_Fullscreen
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
	
	mov tbb.iBitmap, TBID_MPC_About
	mov tbb.idCommand, IDC_MPC_About
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
	
;	mov tbb.iBitmap, TBID_MPC_A_NORMAL
;	mov tbb.idCommand, IDC_MPC_Aspect
;	mov tbb.fsStyle, TBSTYLE_BUTTON or TBSTYLE_DROPDOWN ; or TBSTYLE_AUTOSIZE 
;	Invoke SendMessage, hMPC_ToolbarScreen, TB_ADDBUTTONS, 1, Addr tbb
    
    ret
_MPCInit ENDP

;------------------------------------------------------------------------------
; _MPCPaint
;------------------------------------------------------------------------------
_MPCPaint PROC hWin:DWORD
    LOCAL ps:PAINTSTRUCT
    LOCAL rect:RECT
    LOCAL rectbrush:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL dwBrushOrgX:DWORD
    LOCAL dwBrushOrgY:DWORD
    LOCAL hParent:DWORD
    
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
    
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    
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
    mov eax, 0
    
    ret
_MPCPaint ENDP

;------------------------------------------------------------------------------
; MediaPlayerControls Toolbar Customdraw
;------------------------------------------------------------------------------
_MPCToolbarCustomdraw PROC USES EBX hWin:DWORD, hToolbar:DWORD, lParam:DWORD, bDialog:DWORD
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL rect:RECT
    LOCAL rectbrush:RECT
    LOCAL dwBrushOrgX:DWORD
    LOCAL dwBrushOrgY:DWORD
    LOCAL hParent:DWORD
    
    IFDEF DEBUG32
    ;PrintText '_MPCToolbarCustomdraw'
    ENDIF
    
    mov ebx, lParam
    mov eax, (NMTBCUSTOMDRAW PTR [ebx]).nmcd.dwDrawStage
    
    .IF eax == CDDS_PREPAINT
        .IF bDialog == TRUE
            mov eax, CDRF_NOTIFYITEMDRAW
            Invoke SetWindowLong, hWin, DWL_MSGRESULT, eax
            mov eax, TRUE
            ret
        .ELSE
            mov eax, CDRF_NOTIFYITEMDRAW
            ret
        .ENDIF

    .ELSEIF eax == CDDS_PREERASE ; requires style TBSTYLE_CUSTOMERASE
        mov ebx, lParam
        Invoke CopyRect, Addr rect, Addr (NMTBCUSTOMDRAW PTR [ebx]).nmcd.rc
    
        ;----------------------------------------------------------------------
        ; If rectangle is empty then no point doing anything
        ;----------------------------------------------------------------------
        Invoke IsRectEmpty, Addr rect
        .IF eax == TRUE
            .IF bDialog == TRUE
                mov eax, CDRF_DODEFAULT
                Invoke SetWindowLong, hWin, DWL_MSGRESULT, eax
                mov eax, TRUE
                ret
            .ELSE
                mov eax, CDRF_DODEFAULT
                ret
            .ENDIF
        .ENDIF
        
        ;----------------------------------------------------------------------
        ; If hdc is empty then no point doing anything
        ;----------------------------------------------------------------------
        mov ebx, lParam
        mov eax, (NMTBCUSTOMDRAW PTR [ebx]).nmcd.hdc
        .IF eax == 0
            .IF bDialog == TRUE
                mov eax, CDRF_DODEFAULT
                Invoke SetWindowLong, hWin, DWL_MSGRESULT, eax
                mov eax, TRUE
                ret
            .ELSE
                mov eax, CDRF_DODEFAULT
                ret
            .ENDIF
        .ENDIF
        mov hdc, eax
        
        Invoke CreateCompatibleDC, hdc                              ; Create memory dc for our buffer
        mov hdcMem, eax
        
        Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom ; Create bitmap of size that matches dimensions
        mov hBufferBitmap, eax
        Invoke SelectObject, hdcMem, hBufferBitmap                  ; Select our created buffer bitmap into our memory dc
        
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, eax
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
            mov eax, CDRF_SKIPDEFAULT
            Invoke SetWindowLong, hWin, DWL_MSGRESULT, eax
            mov eax, TRUE
            ret
        .ELSE
            mov eax, CDRF_SKIPDEFAULT
            ret
        .ENDIF

    .ELSEIF eax == CDDS_ITEMPREPAINT
        .IF bDialog == TRUE
            .IF g_Fullscreen == FALSE
                mov eax, CDRF_DODEFAULT
            .ELSE
                mov ebx, lParam
                mov (NMTBCUSTOMDRAW PTR [ebx]).clrHighlightHotTrack, RGB(197,218,237)
                mov eax, TBCDRF_HILITEHOTTRACK
            .ENDIF 
            Invoke SetWindowLong, hWin, DWL_MSGRESULT, eax
            mov eax, TRUE
            ret
        .ELSE
            mov eax, TBCDRF_HILITEHOTTRACK
            ret
        .ENDIF
    .ENDIF
    
    .IF bDialog == TRUE
        mov eax, CDRF_DODEFAULT
        Invoke SetWindowLong, hWin, DWL_MSGRESULT, eax
        mov eax, TRUE
        ret
    .ELSE
        mov eax, CDRF_DODEFAULT
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
MediaPlayerControlsUpdate PROC hWin:DWORD
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
; From Toolbar PlaySpeed show dropdown menu
;-------------------------------------------------------------------------------------
ToolBarPlaySpeedDropdown PROC USES EBX hWin:DWORD
    LOCAL xpos:DWORD
    LOCAL ypos:DWORD
    LOCAL rect:RECT
    LOCAL nLeft:DWORD
    LOCAL nHeight:DWORD

    IFDEF DEBUG32
    ;PrintText 'ToolBarPlaySpeedDropdown'
    ENDIF
    
    .IF hMediaPlayerSpeedMenu == 0
        ret
    .ENDIF
    
    Invoke SendMessage, hMPC_ToolbarControls, TB_GETITEMRECT, 4, Addr rect
    
    .IF g_LangRTL == TRUE
        mov eax, rect.right
    .ELSE
        mov eax, rect.left
    .ENDIF
    mov nLeft, eax
    
    mov eax, rect.bottom
    mov ebx, rect.top
    sub eax, ebx
 
    mov nHeight, eax
    Invoke MapWindowPoints, hMPC_ToolbarControls, NULL, Addr rect, 2
    push eax
    shr eax, 16
    add eax, nHeight
    mov ypos, eax
    pop eax
    and	eax,0FFFFh
    add eax, nLeft
    mov xpos, eax

    .IF g_LangRTL == TRUE
        Invoke TrackPopupMenu, hMediaPlayerSpeedMenu, TPM_LAYOUTRTL or TPM_RIGHTALIGN or TPM_LEFTBUTTON, xpos, ypos, NULL, hWin, NULL
	.ELSE
	    Invoke TrackPopupMenu, hMediaPlayerSpeedMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON, xpos, ypos, NULL, hMainWindow, NULL
	.ENDIF
	
    ret
ToolBarPlaySpeedDropdown ENDP

;-------------------------------------------------------------------------------------
; From Toolbar Audio Stream show dropdown menu
;-------------------------------------------------------------------------------------
ToolBarAudioStreamDropdown PROC USES EBX hWin:DWORD
    LOCAL xpos:DWORD
    LOCAL ypos:DWORD
    LOCAL rect:RECT
    LOCAL nLeft:DWORD
    LOCAL nHeight:DWORD

    IFDEF DEBUG32
    ;PrintText 'ToolBarAudioStreamDropdown'
    ENDIF
    
    .IF hMediaPlayerAudioMenu == 0
        ret
    .ENDIF
    
    Invoke SendMessage, hMPC_ToolbarControls, TB_GETITEMRECT, 9, Addr rect
    
    .IF g_LangRTL == TRUE
        mov eax, rect.right
    .ELSE
        mov eax, rect.left
    .ENDIF
    mov nLeft, eax
    
    mov eax, rect.bottom
    mov ebx, rect.top
    sub eax, ebx
 
    mov nHeight, eax
    Invoke MapWindowPoints, hMPC_ToolbarControls, NULL, Addr rect, 2
    push eax
    shr eax, 16
    add eax, nHeight
    mov ypos, eax
    pop eax
    and	eax,0FFFFh
    add eax, nLeft
    mov xpos, eax

    .IF g_LangRTL == TRUE
        Invoke TrackPopupMenu, hMediaPlayerAudioMenu, TPM_LAYOUTRTL or TPM_RIGHTALIGN or TPM_LEFTBUTTON, xpos, ypos, NULL, hWin, NULL
	.ELSE
	    Invoke TrackPopupMenu, hMediaPlayerAudioMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON, xpos, ypos, NULL, hMainWindow, NULL
	.ENDIF
    ret

ToolBarAudioStreamDropdown ENDP












