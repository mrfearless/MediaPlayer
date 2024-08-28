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

MPMainMenuInit          PROTO hWin:DWORD
MPMainMenuUpdate        PROTO hWin:DWORD

MPContextMenuInit       PROTO hWin:DWORD
MPContextMenuUpdate     PROTO hWin:DWORD
MPContextMenuTrack      PROTO hWin:DWORD, wParam:WPARAM, lParam:LPARAM

MPAspectMenuInit        PROTO hWin:DWORD


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

; MediaPlayer Aspect Ratio Menu IDs
IDM_AM_STRETCH          EQU 10201
IDM_AM_NORMAL           EQU 10202

.DATA
; MediaPlayer Context Menu Strings
szCM_Open		        DB 'Open File...',0
szCM_Stop		        DB 'Stop Playback',0
szCM_Pause		        DB 'Pause Playback',0
szCM_Play		        DB 'Start Playing',0
szCM_Step		        DB 'Frame Step',0
szCM_EnterFS	        DB 'Enter Fullscreen',0
szCM_ExitFS 	        DB 'Exit Fullscreen',0
szCM_Exit		        DB 'Exit Application',0
szCM_Aspect             DB 'Video Aspect',0

; MediaPlayer Aspect Ratio Menu Strings
szAM_STRETCH            DB 'Stretch',0
szAM_NORMAL             DB 'Normal',0

.CODE

;------------------------------------------------------------------------------
; MPMainMenuInit - initialize the main menu
;------------------------------------------------------------------------------
MPMainMenuInit PROC hWin:DWORD
    LOCAL hBitmap:DWORD
    ; Load bitmaps for main menu: File
    Invoke LoadImage, hInstance, BMP_MM_OPEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_FILE_OPEN, MF_BYCOMMAND, hBitmap, 0
    
    Invoke LoadImage, hInstance, BMP_MM_EXIT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_FILE_EXIT, MF_BYCOMMAND, hBitmap, 0
    
    ; Load bitmaps for main menu: Media Controls
    Invoke LoadImage, hInstance, BMP_MM_STOP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_STOP, MF_BYCOMMAND, hBitmap, 0    
    
    Invoke LoadImage, hInstance, BMP_MM_PAUSE, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_PAUSE, MF_BYCOMMAND, hBitmap, 0   
    
    Invoke LoadImage, hInstance, BMP_MM_PLAY, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_PLAY, MF_BYCOMMAND, hBitmap, 0   
    
    Invoke LoadImage, hInstance, BMP_MM_STEP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_STEP, MF_BYCOMMAND, hBitmap, 0   
    
    Invoke LoadImage, hInstance, BMP_MM_FULLSCREEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_FULLSCREEN, MF_BYCOMMAND, hBitmap, 0   
    
    Invoke LoadImage, hInstance, BMP_CM_ASPECT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_ASPECT, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_CM_STRETCH, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_AM_STRETCH, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_CM_NORMAL, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_AM_NORMAL, MF_BYCOMMAND, hBitmap, 0 
    
    ; Load bitmaps for main menu: Help
    Invoke LoadImage, hInstance, BMP_MM_HELP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_HELP_HELP, MF_BYCOMMAND, hBitmap, 0  
    
    Invoke LoadImage, hInstance, BMP_MM_ABOUT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_HELP_ABOUT, MF_BYCOMMAND, hBitmap, 0  
    
    ret
MPMainMenuInit ENDP

;------------------------------------------------------------------------------
; MPMainMenuUpdate
;------------------------------------------------------------------------------
MPMainMenuUpdate PROC hWin:DWORD
    
    
    ret
MPMainMenuUpdate ENDP

;------------------------------------------------------------------------------
; MPContextMenuInit - initialize the context menu
;------------------------------------------------------------------------------
MPContextMenuInit PROC hWin:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hSubMenu:DWORD
    LOCAL mi:MENUITEMINFO

    IFDEF DEBUG32
    ;PrintText 'MPContextMenuInit'
    ENDIF

    Invoke CreatePopupMenu
    mov hMediaPlayerContextMenu, eax
    
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Open, Addr szCM_Open
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Stop, Addr szCM_Stop
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Pause, Addr szCM_Pause
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Play, Addr szCM_Play
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Step, Addr szCM_Step
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Fullscreen, Addr szCM_EnterFS
    
    
    ; Add submenu 'Add' to rght click menu
    Invoke MPAspectMenuInit, hWin
    mov hSubMenu, eax
    mov mi.cbSize, SIZEOF MENUITEMINFO
    mov mi.fMask, MIIM_SUBMENU + MIIM_STRING + MIIM_ID
    mov mi.wID, IDM_MC_ASPECT
    mov eax, hSubMenu
    mov mi.hSubMenu, eax
    lea eax, szCM_Aspect
    mov mi.dwTypeData, eax
    Invoke InsertMenuItem, hMediaPlayerContextMenu, IDM_MC_ASPECT, FALSE, Addr mi
    mov mi.fMask, MIIM_STATE
    mov mi.wID, 0
    mov mi.hSubMenu, 0
    mov mi.dwTypeData, 0    
    
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Exit, Addr szCM_Exit

    Invoke LoadImage, hInstance, BMP_CM_OPEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Open, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_STOP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Stop, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_PAUSE, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Pause, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_PLAY, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Play, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_STEP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Step, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_FULLSCREEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Fullscreen, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_ASPECT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_ASPECT, MF_BYCOMMAND, hBitmap, 0 

    Invoke LoadImage, hInstance, BMP_CM_EXIT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_CM_Exit, MF_BYCOMMAND, hBitmap, 0
    
    ret
MPContextMenuInit ENDP

;------------------------------------------------------------------------------
; MPContextMenuUpdate
;------------------------------------------------------------------------------
MPContextMenuUpdate PROC hWin:DWORD
    LOCAL mi:MENUITEMINFO
    
    IFDEF DEBUG32
    ;PrintText 'MPContextMenuUpdate'
    ENDIF
    
    mov mi.cbSize, SIZEOF MENUITEMINFO
    mov mi.fMask, MIIM_STRING
    
    .IF g_Fullscreen == TRUE    
        lea eax, szCM_ExitFS
    .ELSE
        lea eax, szCM_EnterFS
    .ENDIF
    mov mi.dwTypeData, eax
    Invoke SetMenuItemInfo, hMediaPlayerContextMenu, IDM_CM_Fullscreen, FALSE, Addr mi

    ret
MPContextMenuUpdate ENDP

;------------------------------------------------------------------------------
; MPContextMenuTrack (WM_CONTEXTMENU)
;------------------------------------------------------------------------------
MPContextMenuTrack PROC hWin:DWORD, wParam:WPARAM, lParam:LPARAM
    LOCAL xpos:DWORD
    LOCAL ypos:DWORD
    LOCAL rect:RECT
    
    IFDEF DEBUG32
    ;PrintText 'MPContextMenuTrack'
    ENDIF

    mov eax, lParam
    shr eax, 16
    mov ypos, eax
    mov eax, lParam
    and eax, 0FFFFh
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
MPAspectMenuInit PROC hWin:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hSubMenu:DWORD
    Invoke CreatePopupMenu
    mov hSubMenu, eax
    mov hMediaPlayerAspectMenu, eax
    
    ; Strings for 'Aspect Ratio' submenu
    Invoke AppendMenu, hSubMenu, MF_STRING, IDM_AM_STRETCH, Addr szAM_STRETCH
    Invoke AppendMenu, hSubMenu, MF_STRING, IDM_AM_NORMAL, Addr szAM_NORMAL

    ; Load bitmaps for 'Aspect Ratio' submenu
    Invoke LoadImage, hInstance, BMP_CM_STRETCH, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hSubMenu, IDM_AM_STRETCH, MF_BYCOMMAND, hBitmap, 0
    
    Invoke LoadImage, hInstance, BMP_CM_NORMAL, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hSubMenu, IDM_AM_NORMAL, MF_BYCOMMAND, hBitmap, 0
    
    mov eax, hSubMenu ; return handle to submenu
    ret
MPAspectMenuInit ENDP

