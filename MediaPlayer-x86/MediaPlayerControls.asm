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
ToolBarScreenAspectDropdown PROTO hWin:DWORD

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
ICO_MPC_STEPFORWARD10   EQU 312
ICO_MPC_STEPBACKWARD10  EQU 313
ICO_MPC_FASTER          EQU 314
ICO_MPC_SLOWER          EQU 315

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
IDC_MPC_StepForward10   EQU 3015
IDC_MPC_StepBackward10  EQU 3016
IDC_MPC_Faster          EQU 3017
IDC_MPC_Slower          EQU 3018

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
TBID_MPC_StepForward10  EQU 12
TBID_MPC_StepBackward10 EQU 13
TBID_MPC_Faster         EQU 14
TBID_MPC_Slower         EQU 15

; MediaPlayerControls Toolbar Colors
TB_TEXTCOLOR            EQU RGB(31,31,31)
TB_FS_TEXTCOLOR         EQU RGB(240,240,240)

TB_BACKCOLOR            EQU MAINWINDOW_BACKCOLOR ;RGB(240,240,240)
TB_FS_BACKCOLOR         EQU MAINWINDOW_FS_BACKCOLOR ; RGB(81,81,81)


.DATA
; MediaPlayerControls Tooltips
IFDEF __UNICODE__
szTip_MPC_Open		    DB 'O',0,'p',0,'e',0,'n',0,' ',0,'a',0,' ',0,'m',0,'e',0,'d',0,'i',0,'a',0,' ',0,'f',0,'i',0,'l',0,'e',0,' ',0,'t',0,'o',0,' ',0
                        DB 'p',0,'l',0,'a',0,'y',0
                        DB 0,0,0,0
szTip_MPC_Stop		    DB 'S',0,'t',0,'o',0,'p',0,' ',0,'P',0,'l',0,'a',0,'y',0,'b',0,'a',0,'c',0,'k',0
                        DB 0,0,0,0
szTip_MPC_Pause		    DB 'P',0,'a',0,'u',0,'s',0,'e',0,' ',0,'P',0,'l',0,'a',0,'y',0,'b',0,'a',0,'c',0,'k',0
                        DB 0,0,0,0
szTip_MPC_Play		    DB 'P',0,'l',0,'a',0,'y',0,'/',0,'P',0,'a',0,'u',0,'s',0,'e',0,' ',0,'T',0,'o',0,'g',0,'g',0,'l',0,'e',0
                        DB 0,0,0,0
szTip_MPC_Step		    DB 'F',0,'r',0,'a',0,'m',0,'e',0,' ',0,'S',0,'t',0,'e',0,'p',0
                        DB 0,0,0,0
szTip_MPC_Fullscreen	DB 'T',0,'o',0,'g',0,'g',0,'l',0,'e',0,' ',0,'F',0,'u',0,'l',0,'l',0,'s',0,'c',0,'r',0,'e',0,'e',0,'n',0
                        DB 0,0,0,0
szTip_MPC_Exit		    DB 'E',0,'x',0,'i',0,'t',0,' ',0,'A',0,'p',0,'p',0,'l',0,'i',0,'c',0,'a',0,'t',0,'i',0,'o',0,'n',0
                        DB 0,0,0,0
szTip_MPC_VolumeToggle  DB 'V',0,'o',0,'l',0,'u',0,'m',0,'e',0,' ',0,'M',0,'u',0,'t',0,'e',0,' ',0,'T',0,'o',0,'g',0,'g',0,'l',0,'e',0
                        DB 0,0,0,0
szTip_MPC_Aspect        DB 'V',0,'i',0,'d',0,'e',0,'o',0,' ',0,'A',0,'s',0,'p',0,'e',0,'c',0,'t',0
                        DB 0,0,0,0
szTip_MPC_About         DB 'A',0,'b',0,'o',0,'u',0,'t',0,' ',0,'M',0,'e',0,'d',0,'i',0,'a',0,'P',0,'l',0,'a',0,'y',0,'e',0,'r',0
                        DB 0,0,0,0
szTip_MPC_StepForward10 DB 'S',0,'t',0,'e',0,'p',0,' ',0,'F',0,'o',0,'r',0,'w',0,'a',0,'r',0,'d',0,' ',0,'1',0,'0',0,' ',0,'S',0,'e',0,'c',0,'o',0,'n',0,'d',0,'s',0
                        DB 0,0,0,0
szTip_MPC_StepBackward10 DB 'S',0,'t',0,'e',0,'p',0,' ',0,'B',0,'a',0,'c',0,'k',0,'w',0,'a',0,'r',0,'d',0,' ',0,'1',0,'0',0,' ',0,'S',0,'e',0,'c',0,'o',0,'n',0,'d',0,'s',0
                        DB 0,0,0,0
szTip_MPC_Faster        DB 'F',0,'a',0,'s',0,'t',0,'e',0,'r',0,' ',0,'P',0,'l',0,'a',0,'y',0,' ',0,'S',0,'p',0,'e',0,'e',0,'d',0
                        DB 0,0,0,0
szTip_MPC_Slower        DB 'S',0,'l',0,'o',0,'w',0,'e',0,'r',0,' ',0,'P',0,'l',0,'a',0,'y',0,' ',0,'S',0,'p',0,'e',0,'e',0,'d',0
                        DB 0,0,0,0
ELSE
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
szTip_MPC_StepForward10 DB 'Step Forward 10 Seconds',0
szTip_MPC_StepBackward10 DB 'Step Backward 10 Seconds',0
szTip_MPC_Faster        DB 'Faster Play Speed',0
szTip_MPC_Slower        DB 'Slower Play Speed',0

ENDIF

.DATA?
; MediaPlayerControls Handles
hMPC_ToolbarControls    DD ?
hMPC_ToolbarVolume      DD ?
hMPC_ToolbarScreen      DD ?
hMPC_ImageList_Enabled  DD ?
hMPC_ImageList_Disabled DD ?
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
        
        .IF eax == IDC_MPC_Open
            Invoke MediaPlayerBrowseForFile, hMainWindow
            .IF eax == TRUE
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
        
        .ELSEIF eax == IDC_MPC_Aspect ; see TBN_DROPDOWN for dropdown part of Aspect button
            Invoke ToolBarScreenAspectDropdown, hWin
            ret
        
        .ELSEIF eax == IDC_MPC_About
            Invoke DialogBoxParam, hInstance, IDD_AboutDlg, hWin, Addr MediaPlayerAboutDlgProc, NULL
            
        .ELSEIF eax == IDC_MPC_Exit
            Invoke SendMessage, hMainWindow, WM_CLOSE, 0, 0
            
        .ELSEIF eax == IDC_MPC_StepForward10
            Invoke MPSBStepPosition, hMediaPlayerSeekBar, 10, TRUE
            
        .ELSEIF eax == IDC_MPC_StepBackward10
            Invoke MPSBStepPosition, hMediaPlayerSeekBar, 10, FALSE
            
        .ELSEIF eax == IDC_MPC_Faster
            .IF pMI != 0
                mov eax, dwCurrentRate
                shl eax, 1 ; x2
                Invoke MFPMediaPlayer_SetRate, pMP, eax
            .ENDIF
            
        .ELSEIF eax == IDC_MPC_Slower
            .IF pMI != 0
                mov eax, dwCurrentRate
                shr eax, 1 ; /2
                Invoke MFPMediaPlayer_SetRate, pMP, eax
            .ENDIF
            
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
            .IF eax == IDC_MPC_Open
                lea eax, szTip_MPC_Open
            .ELSEIF eax == IDC_MPC_Stop
                lea eax, szTip_MPC_Stop
            .ELSEIF eax == IDC_MPC_Pause
                lea eax, szTip_MPC_Pause
            .ELSEIF eax == IDC_MPC_Play
                lea eax, szTip_MPC_Play
            .ELSEIF eax == IDC_MPC_Step
                lea eax, szTip_MPC_Step
            .ELSEIF eax == IDC_MPC_Fullscreen
                lea eax, szTip_MPC_Fullscreen
            .ELSEIF eax == IDC_MPC_Exit
                lea eax, szTip_MPC_Exit
            .ELSEIF eax == IDC_MPC_VolumeToggle
                lea eax, szTip_MPC_VolumeToggle
            .ELSEIF eax == IDC_MPC_Aspect
                lea eax, szTip_MPC_Aspect
            .ELSEIF eax == IDC_MPC_About
                lea eax, szTip_MPC_About
            .ELSEIF eax == IDC_MPC_StepForward10
                lea eax, szTip_MPC_StepForward10
            .ELSEIF eax == IDC_MPC_StepBackward10
                lea eax, szTip_MPC_StepBackward10
            .ELSEIF eax == IDC_MPC_Faster
                lea eax, szTip_MPC_Faster
            .ELSEIF eax == IDC_MPC_Slower
                lea eax, szTip_MPC_Slower
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
;            .ELSEIF eax == hMPC_ToolbarVolume
;                Invoke _MPCToolbarCustomdraw, hWin, hMPC_ToolbarVolume, lParam, TRUE
;            .ELSEIF eax == hMPC_ToolbarScreen
;                Invoke _MPCToolbarCustomdraw, hWin, hMPC_ToolbarScreen, lParam, TRUE
            .ENDIF
            ret
            
        .ELSEIF eax == TBN_DROPDOWN ; for dropdown part of Aspect button
            Invoke ToolBarScreenAspectDropdown, hWin
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

;    Invoke GetDlgItem, hWin, IDC_MPC_ToolbarVolume ; removed flat style from this toolbar
;    mov hMPC_ToolbarVolume, eax
;
;    Invoke GetDlgItem, hWin, IDC_MPC_ToolbarScreen
;    mov hMPC_ToolbarScreen, eax

    Invoke ImageList_Create, 32, 32, ILC_COLOR32, 16, 32
    mov hMPC_ImageList_Enabled, eax
    
    Invoke SendMessage, hMPC_ToolbarControls, TB_SETIMAGELIST, 0, hMPC_ImageList_Enabled
    Invoke SendMessage, hMPC_ToolbarControls, TB_SETEXTENDEDSTYLE, TBSTYLE_EX_DOUBLEBUFFER, TBSTYLE_EX_DOUBLEBUFFER
    
;    Invoke SendMessage, hMPC_ToolbarVolume, TB_SETIMAGELIST, 0, hMPC_ImageList_Enabled
;    Invoke SendMessage, hMPC_ToolbarVolume, TB_SETEXTENDEDSTYLE, TBSTYLE_EX_DOUBLEBUFFER, TBSTYLE_EX_DOUBLEBUFFER
;    
;    Invoke SendMessage, hMPC_ToolbarScreen, TB_SETIMAGELIST, 0, hMPC_ImageList_Enabled
;    Invoke SendMessage, hMPC_ToolbarScreen, TB_SETEXTENDEDSTYLE, TBSTYLE_EX_DOUBLEBUFFER or TBSTYLE_EX_DRAWDDARROWS, TBSTYLE_EX_DOUBLEBUFFER or TBSTYLE_EX_DRAWDDARROWS
    
    ; Media Player Images
    Invoke LoadImage, hInstance, ICO_MPC_OPEN, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_STOP, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_PAUSE, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_PLAY, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_STEP, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_EXIT, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_FULLSCREEN, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_ABOUT, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_A_STRETCH, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_A_NORMAL, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon

    Invoke LoadImage, hInstance, ICO_MPC_VOLUME, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_MUTE, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_STEPFORWARD10, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_STEPBACKWARD10, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_FASTER, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcon, eax
    Invoke ImageList_AddIcon, hMPC_ImageList_Enabled, hIcon
    
    Invoke LoadImage, hInstance, ICO_MPC_SLOWER, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
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
	mov tbb.iBitmap, 16
	mov tbb.idCommand, -1
    mov tbb.fsStyle, TBSTYLE_SEP ; removed flat style from this toolbar to hide seperator line
    Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
	; 128 ; 158
	mov tbb.iBitmap, TBID_MPC_Slower
	mov tbb.idCommand, IDC_MPC_Slower
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
	
	mov tbb.iBitmap, TBID_MPC_Faster
	mov tbb.idCommand, IDC_MPC_Faster
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
	
	mov tbb.iBitmap, TBID_MPC_StepBackward10
	mov tbb.idCommand, IDC_MPC_StepBackward10
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb

	mov tbb.iBitmap, TBID_MPC_StepForward10
	mov tbb.idCommand, IDC_MPC_StepForward10
	mov tbb.fsStyle, TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
	;256 ;326
	mov tbb.iBitmap, 16
	mov tbb.idCommand, -1
    mov tbb.fsStyle, TBSTYLE_SEP ; removed flat style from this toolbar to hide seperator line
    Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
	;288 ; 358
	mov tbb.iBitmap, TBID_MPC_Volume
	mov tbb.idCommand, IDC_MPC_VolumeToggle
	mov tbb.fsStyle, TBSTYLE_CHECK ;TBSTYLE_BUTTON
	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
    ;320 ; 400
    mov tbb.iBitmap, 116 ;230
    mov tbb.idCommand, -1
    mov tbb.fsStyle, TBSTYLE_SEP ; removed flat style from this toolbar to hide seperator line
    Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
    ;630
	mov tbb.iBitmap, 18
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
	
;	mov tbb.iBitmap, TBID_MPC_Exit
;	mov tbb.idCommand, IDC_MPC_Exit
;	mov tbb.fsStyle, TBSTYLE_BUTTON
;	Invoke SendMessage, hMPC_ToolbarControls, TB_ADDBUTTONS, 1, Addr tbb
    ;646 ;788
;    ;--------------------------------------------------------------------------
;    ; Set button and bitmap size for Volume toolbar button images
;    ;--------------------------------------------------------------------------
;    Invoke SendMessage, hMPC_ToolbarVolume, TB_BUTTONSTRUCTSIZE, sizeof TBBUTTON, 0	; Set toolbar struct size
;	mov ebx, 32 ; width
;	mov eax, 32 ; height
;	shl eax, 16d
;	mov ax, bx
;	mov bSize, eax
;	Invoke SendMessage, hMPC_ToolbarVolume, TB_SETBITMAPSIZE, 0, bSize ; Set bitmap size
;	Invoke SendMessage, hMPC_ToolbarVolume, TB_SETBUTTONSIZE, 0, bSize ; Set each button size
;    
;	mov tbb.fsState, TBSTATE_ENABLED
;	mov tbb.dwData, 0
;	mov tbb.iString, 0
;    
;	mov tbb.iBitmap, TBID_MPC_Volume
;	mov tbb.idCommand, IDC_MPC_VolumeToggle
;	mov tbb.fsStyle, TBSTYLE_CHECK ;TBSTYLE_BUTTON
;	Invoke SendMessage, hMPC_ToolbarVolume, TB_ADDBUTTONS, 1, Addr tbb
;    
;    mov tbb.iBitmap, 230
;    mov tbb.fsStyle, TBSTYLE_SEP ; removed flat style from this toolbar to hide seperator line
;    Invoke SendMessage, hMPC_ToolbarVolume, TB_ADDBUTTONS, 1, Addr tbb
    
;    ;--------------------------------------------------------------------------
;    ; Set button and bitmap size for Screen toolbar button images
;    ;--------------------------------------------------------------------------
;    Invoke SendMessage, hMPC_ToolbarScreen, TB_BUTTONSTRUCTSIZE, sizeof TBBUTTON, 0	; Set toolbar struct size
;	mov ebx, 32 ; width
;	mov eax, 32 ; height
;	shl eax, 16d
;	mov ax, bx
;	mov bSize, eax
;	Invoke SendMessage, hMPC_ToolbarScreen, TB_SETBITMAPSIZE, 0, bSize ; Set bitmap size
;	Invoke SendMessage, hMPC_ToolbarScreen, TB_SETBUTTONSIZE, 0, bSize ; Set each button size
;    
;	mov tbb.fsState, TBSTATE_ENABLED
;	mov tbb.dwData, 0
;	mov tbb.iString, 0
;    
;	mov tbb.iBitmap, TBID_MPC_Fullscreen
;	mov tbb.idCommand, IDC_MPC_Fullscreen
;	mov tbb.fsStyle, TBSTYLE_BUTTON
;	Invoke SendMessage, hMPC_ToolbarScreen, TB_ADDBUTTONS, 1, Addr tbb
;	
;	mov tbb.iBitmap, TBID_MPC_About
;	mov tbb.idCommand, IDC_MPC_About
;	mov tbb.fsStyle, TBSTYLE_BUTTON
;	Invoke SendMessage, hMPC_ToolbarScreen, TB_ADDBUTTONS, 1, Addr tbb
;	
;	mov tbb.iBitmap, TBID_MPC_Exit
;	mov tbb.idCommand, IDC_MPC_Exit
;	mov tbb.fsStyle, TBSTYLE_BUTTON
;	Invoke SendMessage, hMPC_ToolbarScreen, TB_ADDBUTTONS, 1, Addr tbb
	
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
; From Toolbar Add button, show dropdown menu
;-------------------------------------------------------------------------------------
ToolBarScreenAspectDropdown PROC USES EBX hWin:DWORD
    LOCAL xpos:DWORD
    LOCAL ypos:DWORD
    LOCAL rect:RECT
    LOCAL nLeft:DWORD
    LOCAL nHeight:DWORD

    IFDEF DEBUG32
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
    push eax
    shr eax, 16
    add eax, nHeight
    mov ypos, eax
    pop eax
    and	eax,0FFFFh
    add eax, nLeft
    mov xpos, eax

	Invoke TrackPopupMenu, hMediaPlayerAspectMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON, xpos, ypos, NULL, hMainWindow, NULL
	
    ret
ToolBarScreenAspectDropdown ENDP
















