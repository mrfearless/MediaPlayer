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

MPMainMenuInit          PROTO hWin:QWORD
MPMainMenuUpdate        PROTO hWin:QWORD

MPContextMenuInit       PROTO hWin:QWORD
MPContextMenuUpdate     PROTO hWin:QWORD
MPContextMenuTrack      PROTO hWin:QWORD, wParam:WPARAM, lParam:LPARAM

MPAspectMenuInit        PROTO hWin:QWORD
MPSpeedMenuInit         PROTO hWin:QWORD

.CONST
; MediaPlayer Context Menu Bitmap IDs
BMP_MM_OPEN             EQU 350
BMP_MM_STOP             EQU 351
BMP_MM_PAUSE            EQU 352
BMP_MM_PLAY             EQU 353
BMP_MM_STEP             EQU 354
BMP_MM_EXIT             EQU 355
BMP_MM_FULLSCREEN       EQU 356
BMP_MM_ABOUT            EQU 357
BMP_MM_A_STRETCH        EQU 358
BMP_MM_A_NORMAL         EQU 359
BMP_MM_ASPECT           EQU 359
BMP_MM_HELP             EQU 360
BMP_MM_STEPFORWARD10    EQU 361
BMP_MM_STEPBACKWARD10   EQU 362
BMP_MM_FASTER           EQU 363
BMP_MM_SLOWER           EQU 364
BMP_MM_SPEED            EQU 365

; MediaPlayer Context Menu Bitmap IDs
BMP_CM_OPEN             EQU BMP_MM_OPEN
BMP_CM_STOP             EQU BMP_MM_STOP
BMP_CM_PAUSE            EQU BMP_MM_PAUSE
BMP_CM_PLAY             EQU BMP_MM_PLAY
BMP_CM_STEP             EQU BMP_MM_STEP
BMP_CM_EXIT             EQU BMP_MM_EXIT
BMP_CM_FULLSCREEN       EQU BMP_MM_FULLSCREEN
BMP_CM_ASPECT           EQU BMP_MM_ASPECT
BMP_CM_STRETCH          EQU BMP_MM_A_STRETCH
BMP_CM_NORMAL           EQU BMP_MM_A_NORMAL
BMP_CM_STEPFORWARD10    EQU BMP_MM_STEPFORWARD10
BMP_CM_STEPBACKWARD10   EQU BMP_MM_STEPBACKWARD10
BMP_CM_FASTER           EQU BMP_MM_FASTER
BMP_CM_SLOWER           EQU BMP_MM_SLOWER
BMP_CM_SPEED            EQU BMP_MM_SPEED

; MediaPlayer Main Menu IDs
IDM_MENU                EQU 10000
IDM_FILE_OPEN           EQU 10001   ; Ctrl+O
IDM_FILE_EXIT           EQU 10002   ; Alt+F4
IDM_MEDIA_CONTROLS      EQU 10050
IDM_MC_STOP             EQU 10051   ; Ctrl+S
IDM_MC_PAUSE            EQU 10052
IDM_MC_PLAY             EQU 10053   ; Ctrl+P
IDM_MC_STEP             EQU 10054
IDM_MC_FULLSCREEN       EQU 10055   ; F11
IDM_MC_ASPECT           EQU 10056
IDM_MC_STEP10B          EQU 10060   ; Ctrl+B
IDM_MC_STEP10F          EQU 10061   ; Ctrl+F
IDM_MC_SPEED            EQU 10062
IDM_MC_SLOWER           EQU 10063   ; Ctrl+Left
IDM_MC_FASTER           EQU 10064   ; Ctrl+Right
IDM_HELP_HELP           EQU 10101   ; F1
IDM_HELP_ABOUT          EQU 10102

; MediaPlayer Context Menu IDs
IDM_CONTEXTMENU         EQU 11000
IDM_CM_Open		        EQU 11001
IDM_CM_Stop		        EQU 11002
IDM_CM_Pause		    EQU 11003
IDM_CM_Play		        EQU 11004
IDM_CM_Step		        EQU 11005
IDM_CM_Fullscreen	    EQU 11006
IDM_CM_Exit		        EQU 11007
IDM_CM_Aspect           EQU 11008
IDM_CM_Speed            EQU 11009
IDM_CM_Step10           EQU 11010
IDM_CM_Step10B          EQU 10020   ; Ctrl+B
IDM_CM_Step10F          EQU 10021   ; Ctrl+F

; MediaPlayer Aspect Ratio Menu IDs
IDM_AM_STRETCH          EQU 10201
IDM_AM_NORMAL           EQU 10202

; MediaPlayer Playback Speed Menu IDs
IDM_SM_Slower           EQU 10022   ; Ctrl+Left
IDM_SM_Faster           EQU 10023   ; Ctrl+Right

.DATA
; MediaPlayer Context Menu Strings
IFDEF __UNICODE__
szCM_Open		        DB 'O',0,'p',0,'e',0,'n',0,' ',0,'F',0,'i',0,'l',0,'e',0,'.',0,'.',0,'.',0
                        DB 09h,0,'C',0,'t',0,'r',0,'l',0,'+',0,'O',0
                        DB 0,0,0,0
szCM_Stop		        DB 'S',0,'t',0,'o',0,'p',0,' ',0,'P',0,'l',0,'a',0,'y',0,'b',0,'a',0,'c',0,'k',0
                        DB 09h,0,'C',0,'t',0,'r',0,'l',0,'+',0,'S',0
                        DB 0,0,0,0
szCM_Pause		        DB 'P',0,'a',0,'u',0,'s',0,'e',0,' ',0,'P',0,'l',0,'a',0,'y',0,'b',0,'a',0,'c',0,'k',0
                        DB 0,0,0,0
szCM_Play		        DB 'S',0,'t',0,'a',0,'r',0,'t',0,' ',0,'P',0,'l',0,'a',0,'y',0,'i',0,'n',0,'g',0
                        DB 09h,0,'C',0,'t',0,'r',0,'l',0,'+',0,'P',0
                        DB 0,0,0,0
szCM_Step		        DB 'F',0,'r',0,'a',0,'m',0,'e',0,' ',0,'S',0,'t',0,'e',0,'p',0
                        DB 0,0,0,0
szCM_EnterFS	        DB 'E',0,'n',0,'t',0,'e',0,'r',0,' ',0,'F',0,'u',0,'l',0,'l',0,'s',0,'c',0,'r',0,'e',0,'e',0,'n',0
                        DB 09h,0,'F',0,'1',0,'1',0
                        DB 0,0,0,0
szCM_ExitFS 	        DB 'E',0,'x',0,'i',0,'t',0,' ',0,'F',0,'u',0,'l',0,'l',0,'s',0,'c',0,'r',0,'e',0,'e',0,'n',0
                        DB 09h,0,'F',0,'1',0,'1',0
                        DB 0,0,0,0
szCM_Exit		        DB 'E',0,'x',0,'i',0,'t',0,' ',0,'A',0,'p',0,'p',0,'l',0,'i',0,'c',0,'a',0,'t',0,'i',0,'o',0,'n',0
                        DB 09h,0,'A',0,'l',0,'t',0,'+',0,'F',0,'4',0
                        DB 0,0,0,0
szCM_Aspect             DB 'V',0,'i',0,'d',0,'e',0,'o',0,' ',0,'A',0,'s',0,'p',0,'e',0,'c',0,'t',0
                        DB 0,0,0,0
szCM_Speed              DB 'P',0,'l',0,'a',0,'y',0,'b',0,'a',0,'c',0,'k',0,' ',0,'S',0,'p',0,'e',0,'e',0,'d',0
                        DB 0,0,0,0
szCM_Step10             DB 'S',0,'t',0,'e',0,'p',0,' ',0,'1',0,'0',0,' ',0,'S',0,'e',0,'c',0,'o',0,'n',0,'d',0,'s',0
                        DB 0,0,0,0
szCM_Step10B            DB 'S',0,'t',0,'e',0,'p',0,' ',0,'B',0,'a',0,'c',0,'k',0,'w',0,'a',0,'r',0,'d',0,' ',0
                        DB '1',0,'0',0,' ',0,'S',0,'e',0,'c',0,'o',0,'n',0,'d',0,'s',0
                        DB 09h,0,'C',0,'t',0,'r',0,'l',0,'+',0,'B',0
                        DB 0,0,0,0
szCM_Step10F            DB 'S',0,'t',0,'e',0,'p',0,' ',0,'F',0,'o',0,'r',0,'w',0,'a',0,'r',0,'d',0,' ',0
                        DB '1',0,'0',0,' ',0,'S',0,'e',0,'c',0,'o',0,'n',0,'d',0,'s',0
                        DB 09h,0,'C',0,'t',0,'r',0,'l',0,'+',0,'F',0
                        DB 0,0,0,0
; MediaPlayer Aspect Ratio Menu Strings
szAM_STRETCH            DB 'S',0,'t',0,'r',0,'e',0,'t',0,'c',0,'h',0
                        DB 0,0,0,0
szAM_NORMAL             DB 'N',0,'o',0,'r',0,'m',0,'a',0,'l',0
                        DB 0,0,0,0
; MediaPlayer Playback Speed Menu IDs
szSM_Slower             DB 'S',0,'l',0,'o',0,'w',0,'e',0,'r',0
                        DB 09h,0,'C',0,'t',0,'r',0,'l',0,'+',0,'L',0,'e',0,'f',0,'t',0
                        DB 0,0,0,0
szSM_Faster             DB 'F',0,'a',0,'s',0,'t',0,'e',0,'r',0
                        DB 09h,0,'C',0,'t',0,'r',0,'l',0,'+',0,'R',0,'i',0,'g',0,'h',0,'t',0
                        DB 0,0,0,0
ELSE
szCM_Open		        DB 'Open File...',09h,'Ctrl+O',0
szCM_Stop		        DB 'Stop Playback',09h,'Ctrl+S',0
szCM_Pause		        DB 'Pause Playback',0
szCM_Play		        DB 'Start Playing',09h,'Ctrl+P',0
szCM_Step		        DB 'Frame Step',0
szCM_EnterFS	        DB 'Enter Fullscreen',09h,'F11',0
szCM_ExitFS 	        DB 'Exit Fullscreen',09h,'F11',0
szCM_Exit		        DB 'Exit Application',09h,'Alt+F4',0
szCM_Aspect             DB 'Video Aspect',0
szCM_Speed              DB 'Playback Speed',0
szCM_Step10             DB 'Step 10 Seconds',0
szCM_Step10B            DB 'Step Backward 10 Seconds',09h,'Ctrl+B',0
szCM_Step10F            DB 'Step Forward 10 Seconds',09h,'Ctrl+F',0
; MediaPlayer Aspect Ratio Menu Strings
szAM_STRETCH            DB 'Stretch',0
szAM_NORMAL             DB 'Normal',0
; MediaPlayer Playback Speed Menu IDs
szSM_Slower             DB 'Slower',09h,'Ctrl+Left',0
szSM_Faster             DB 'Faster',09h,'Ctrl+Right',0
ENDIF

.CODE

;------------------------------------------------------------------------------
; MPMainMenuInit - initialize the main menu
;------------------------------------------------------------------------------
MPMainMenuInit PROC FRAME hWin:QWORD
    LOCAL hBitmap:QWORD
    ; Load bitmaps for main menu: File
    Invoke LoadImage, hInstance, BMP_MM_OPEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_FILE_OPEN, MF_BYCOMMAND, hBitmap, 0
    
    Invoke LoadImage, hInstance, BMP_MM_EXIT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_FILE_EXIT, MF_BYCOMMAND, hBitmap, 0
    
    ; Load bitmaps for main menu: Media Controls
    Invoke LoadImage, hInstance, BMP_MM_STOP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_STOP, MF_BYCOMMAND, hBitmap, 0    
    
    Invoke LoadImage, hInstance, BMP_MM_PAUSE, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_PAUSE, MF_BYCOMMAND, hBitmap, 0   
    
    Invoke LoadImage, hInstance, BMP_MM_PLAY, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_PLAY, MF_BYCOMMAND, hBitmap, 0   
    
    Invoke LoadImage, hInstance, BMP_MM_STEP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_STEP, MF_BYCOMMAND, hBitmap, 0   
    
    Invoke LoadImage, hInstance, BMP_MM_FULLSCREEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_FULLSCREEN, MF_BYCOMMAND, hBitmap, 0   
    
    Invoke LoadImage, hInstance, BMP_CM_ASPECT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_ASPECT, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_CM_STRETCH, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_AM_STRETCH, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_CM_NORMAL, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_AM_NORMAL, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_MM_SPEED, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_SPEED, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_MM_STEPFORWARD10, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_STEP10F, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_MM_STEPBACKWARD10, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_STEP10B, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_MM_FASTER, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_FASTER, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_MM_SLOWER, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_SLOWER, MF_BYCOMMAND, hBitmap, 0 
    
    ; Load bitmaps for main menu: Help
    Invoke LoadImage, hInstance, BMP_MM_HELP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_HELP_HELP, MF_BYCOMMAND, hBitmap, 0  
    
    Invoke LoadImage, hInstance, BMP_MM_ABOUT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_HELP_ABOUT, MF_BYCOMMAND, hBitmap, 0  
    
    ret
MPMainMenuInit ENDP

;------------------------------------------------------------------------------
; MPMainMenuUpdate
;------------------------------------------------------------------------------
MPMainMenuUpdate PROC FRAME hWin:QWORD
    
    
    ret
MPMainMenuUpdate ENDP

;------------------------------------------------------------------------------
; MPContextMenuInit - initialize the context menu
;------------------------------------------------------------------------------
MPContextMenuInit PROC FRAME hWin:QWORD
    LOCAL hBitmap:QWORD
    LOCAL hSubMenu:QWORD
    LOCAL mi:MENUITEMINFO

    IFDEF DEBUG64
    ;PrintText 'MPContextMenuInit'
    ENDIF

    Invoke CreatePopupMenu
    mov hMediaPlayerContextMenu, rax
    
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Open, Addr szCM_Open
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Stop, Addr szCM_Stop
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Pause, Addr szCM_Pause
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Play, Addr szCM_Play
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Step, Addr szCM_Step
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Fullscreen, Addr szCM_EnterFS
    
    ; Add submenu 'Video Aspect' to rght click menu
    Invoke MPAspectMenuInit, hWin
    mov hSubMenu, rax
    mov mi.cbSize, SIZEOF MENUITEMINFO
    mov mi.fMask, MIIM_SUBMENU + MIIM_STRING + MIIM_ID
    mov mi.wID, IDM_MC_ASPECT
    mov rax, hSubMenu
    mov mi.hSubMenu, rax
    lea rax, szCM_Aspect
    mov mi.dwTypeData, rax
    Invoke InsertMenuItem, hMediaPlayerContextMenu, IDM_MC_ASPECT, FALSE, Addr mi
    mov mi.fMask, MIIM_STATE
    mov mi.wID, 0
    mov mi.hSubMenu, 0
    mov mi.dwTypeData, 0    
    
    ; Add submenu 'Playback Speed' to rght click menu
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
    Invoke MPSpeedMenuInit, hWin
    mov hSubMenu, rax
    mov mi.cbSize, SIZEOF MENUITEMINFO
    mov mi.fMask, MIIM_SUBMENU + MIIM_STRING + MIIM_ID
    mov mi.wID, IDM_CM_Speed
    mov rax, hSubMenu
    mov mi.hSubMenu, rax
    lea rax, szCM_Speed
    mov mi.dwTypeData, rax
    Invoke InsertMenuItem, hMediaPlayerContextMenu, IDM_CM_Speed, FALSE, Addr mi
    mov mi.fMask, MIIM_STATE
    mov mi.wID, 0
    mov mi.hSubMenu, 0
    mov mi.dwTypeData, 0  
    
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Exit, Addr szCM_Exit

    Invoke LoadImage, hInstance, BMP_CM_OPEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Open, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_STOP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Stop, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_PAUSE, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Pause, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_PLAY, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Play, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_STEP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Step, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_FULLSCREEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Fullscreen, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_ASPECT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_ASPECT, MF_BYCOMMAND, hBitmap, 0 

    Invoke LoadImage, hInstance, BMP_CM_SPEED, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Speed, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_CM_STEPFORWARD10, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Step10F, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_CM_STEPBACKWARD10, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Step10B, MF_BYCOMMAND, hBitmap, 0 

    Invoke LoadImage, hInstance, BMP_CM_EXIT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Exit, MF_BYCOMMAND, hBitmap, 0
    
    ret
MPContextMenuInit ENDP

;------------------------------------------------------------------------------
; MPContextMenuUpdate
;------------------------------------------------------------------------------
MPContextMenuUpdate PROC FRAME hWin:QWORD
    LOCAL mi:MENUITEMINFO
    
    IFDEF DEBUG64
    ;PrintText 'MPContextMenuUpdate'
    ENDIF
    
    mov mi.cbSize, SIZEOF MENUITEMINFO
    mov mi.fMask, MIIM_STRING
    
    .IF g_Fullscreen == TRUE    
        lea rax, szCM_ExitFS
    .ELSE
        lea rax, szCM_EnterFS
    .ENDIF
    mov mi.dwTypeData, rax
    Invoke SetMenuItemInfo, hMediaPlayerContextMenu, IDM_CM_Fullscreen, FALSE, Addr mi

    ret
MPContextMenuUpdate ENDP

;------------------------------------------------------------------------------
; MPContextMenuTrack (WM_CONTEXTMENU)
;------------------------------------------------------------------------------
MPContextMenuTrack PROC FRAME hWin:QWORD, wParam:WPARAM, lParam:LPARAM
    LOCAL xpos:DWORD
    LOCAL ypos:DWORD
    LOCAL rect:RECT
    
    IFDEF DEBUG64
    ;PrintText 'MPContextMenuTrack'
    ENDIF

    mov rax, lParam
    shr rax, 16
    mov ypos, eax
    mov rax, lParam
    and rax, 0FFFFh
    mov xpos, eax

    .IF xpos == -1 && ypos == -1
        ; keystroke invocation
        Invoke GetClientRect, hWin, Addr rect
        Invoke ClientToScreen, hWin, Addr rect
        
        mov eax, rect.left
        add eax, 20
        mov xpos, eax
        mov eax, rect.top
        add eax, 20
        mov ypos, eax
    .ENDIF
    
    Invoke MPContextMenuUpdate, hWin

    Invoke TrackPopupMenu, hMediaPlayerContextMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON, xpos, ypos, NULL, hWin, NULL ; TPM_RIGHTBUTTON
    Invoke PostMessage, hWin, WM_NULL, 0, 0 ; Fix for shortcut menu not popping up right 
    
    ret
MPContextMenuTrack ENDP

;------------------------------------------------------------------------------
; MPAspectMenuInit - initialize the Aspect Ratio menu
;------------------------------------------------------------------------------
MPAspectMenuInit PROC FRAME hWin:QWORD
    LOCAL hBitmap:QWORD
    LOCAL hSubMenu:QWORD
    Invoke CreatePopupMenu
    mov hSubMenu, rax
    mov hMediaPlayerAspectMenu, rax
    
    ; Strings for 'Aspect Ratio' submenu
    Invoke AppendMenu, hSubMenu, MF_STRING, IDM_AM_STRETCH, Addr szAM_STRETCH
    Invoke AppendMenu, hSubMenu, MF_STRING, IDM_AM_NORMAL, Addr szAM_NORMAL

    ; Load bitmaps for 'Aspect Ratio' submenu
    Invoke LoadImage, hInstance, BMP_CM_STRETCH, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hSubMenu, IDM_AM_STRETCH, MF_BYCOMMAND, hBitmap, 0
    
    Invoke LoadImage, hInstance, BMP_CM_NORMAL, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hSubMenu, IDM_AM_NORMAL, MF_BYCOMMAND, hBitmap, 0
    
    mov rax, hSubMenu ; return handle to submenu
    ret
MPAspectMenuInit ENDP

;------------------------------------------------------------------------------
; MPSpeedMenuInit - initialize the playback speed menu
;------------------------------------------------------------------------------
MPSpeedMenuInit PROC FRAME hWin:QWORD
    LOCAL hBitmap:QWORD
    LOCAL hSubMenu:QWORD
    Invoke CreatePopupMenu
    mov hSubMenu, rax
    mov hMediaPlayerSpeedMenu, rax
    
    ; Strings for 'Aspect Ratio' submenu
    Invoke AppendMenu, hSubMenu, MF_STRING, IDM_SM_Slower, Addr szSM_Slower
    Invoke AppendMenu, hSubMenu, MF_STRING, IDM_SM_Faster, Addr szSM_Faster

    ; Load bitmaps for 'Aspect Ratio' submenu
    Invoke LoadImage, hInstance, BMP_CM_SLOWER, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hSubMenu, IDM_SM_Slower, MF_BYCOMMAND, hBitmap, 0
    
    Invoke LoadImage, hInstance, BMP_CM_FASTER, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, rax
    Invoke SetMenuItemBitmaps, hSubMenu, IDM_SM_Faster, MF_BYCOMMAND, hBitmap, 0
    
    mov rax, hSubMenu ; return handle to submenu
    ret
MPSpeedMenuInit ENDP