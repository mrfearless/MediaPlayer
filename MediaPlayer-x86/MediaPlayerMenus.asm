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

MPMainMenuInit              PROTO hWin:DWORD
MPMainMenuUpdate            PROTO hWin:DWORD

MPContextMenuInit           PROTO hWin:DWORD
MPContextMenuUpdate         PROTO hWin:DWORD
MPContextMenuTrack          PROTO hWin:DWORD, wParam:WPARAM, lParam:LPARAM

MPMainMenuLoadLanguage      PROTO hWin:DWORD, dwLangID:DWORD
MPContextMenuLoadLanguage   PROTO hContextMenu:DWORD, dwLangID:DWORD

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
BMP_MM_STRETCH          EQU 358
BMP_MM_NORMAL           EQU 359
BMP_MM_ASPECT           EQU 359
BMP_MM_HELP             EQU 360
BMP_MM_STEP10F          EQU 361
BMP_MM_STEP10B          EQU 362
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
BMP_CM_STRETCH          EQU BMP_MM_STRETCH
BMP_CM_NORMAL           EQU BMP_MM_NORMAL
BMP_CM_STEP10F          EQU BMP_MM_STEP10F
BMP_CM_STEP10B          EQU BMP_MM_STEP10B
BMP_CM_FASTER           EQU BMP_MM_FASTER
BMP_CM_SLOWER           EQU BMP_MM_SLOWER
BMP_CM_SPEED            EQU BMP_MM_SPEED

; MediaPlayer Main Menu IDs
IDM_MENU                EQU 10000
IDM_FILE_Open           EQU 10001   ; Ctrl+O
IDM_FILE_Exit           EQU 10002   ; Alt+F4
IDM_MC_Stop             EQU 10021   ; Ctrl+S
IDM_MC_Pause            EQU 10022
IDM_MC_Play             EQU 10023   ; Ctrl+P
IDM_MC_Step             EQU 10024
IDM_MC_Step10B          EQU 10025   ; Ctrl+B
IDM_MC_Step10F          EQU 10026   ; Ctrl+F
IDM_MC_Fullscreen       EQU 10027   ; F11
IDM_MC_Aspect           EQU 10028
IDM_MC_VA_Stretch       EQU 10029
IDM_MC_VA_Normal        EQU 10030
IDM_MC_Speed            EQU 10031
IDM_MC_PS_Slower        EQU 10032   ; Ctrl+Left
IDM_MC_PS_Faster        EQU 10033   ; Ctrl+Right
IDM_LANG_Default        EQU 10050
IDM_LANG_English        EQU 10051
IDM_LANG_French         EQU 10052
IDM_LANG_German         EQU 10053
IDM_LANG_Polish         EQU 10054
IDM_LANG_Italian        EQU 10055
IDM_HELP_Help           EQU 10101
IDM_HELP_About          EQU 10102

; MediaPlayer Context Menu IDs
IDM_CONTEXTMENU         EQU 11000

; Languages Supported:
IDLANG_DEFAULT          EQU 0
IDLANG_ENGLISH          EQU 1
IDLANG_FRENCH           EQU 2
IDLANG_GERMAN           EQU 3
IDLANG_POLISH           EQU 4
IDLANG_ITALIAN          EQU 5

; Primary
LANG_NEUTRAL            EQU 000h
LANG_ENGLISH            EQU 009h
LANG_FRENCH             EQU 00Ch
LANG_GERMAN             EQU 007h
LANG_POLISH             EQU 015h
LANG_ITALIAN            EQU 010h

; Sublang
SUBLANG_NEUTRAL         EQU 000h
SUBLANG_DEFAULT         EQU 001h
SUBLANG_ENGLISH_US      EQU 001h
SUBLANG_ENGLISH_UK      EQU 002h
SUBLANG_FRENCH          EQU 001h
SUBLANG_GERMAN          EQU 001h
SUBLANG_POLISH_POLAND   EQU 001h
SUBLANG_ITALIAN         EQU 001h

.DATA


.CODE

;------------------------------------------------------------------------------
; MPMainMenuInit - initialize the main menu
;------------------------------------------------------------------------------
MPMainMenuInit PROC hWin:DWORD
    LOCAL hBitmap:DWORD
    
    Invoke MPMainMenuLoadLanguage, hWin, g_LangID
    mov hMediaPlayerMainMenu, eax
    
    ; Load bitmaps for File submenu
    Invoke LoadImage, hInstance, BMP_MM_OPEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_FILE_Open, MF_BYCOMMAND, hBitmap, 0
    
    Invoke LoadImage, hInstance, BMP_MM_EXIT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_FILE_Exit, MF_BYCOMMAND, hBitmap, 0
    
    ; Load bitmaps for Media Controls submenu
    Invoke LoadImage, hInstance, BMP_MM_STOP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Stop, MF_BYCOMMAND, hBitmap, 0    
    
    Invoke LoadImage, hInstance, BMP_MM_PAUSE, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Pause, MF_BYCOMMAND, hBitmap, 0   
    
    Invoke LoadImage, hInstance, BMP_MM_PLAY, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Play, MF_BYCOMMAND, hBitmap, 0   
    
    Invoke LoadImage, hInstance, BMP_MM_STEP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Step, MF_BYCOMMAND, hBitmap, 0   
    
    Invoke LoadImage, hInstance, BMP_MM_STEP10F, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Step10F, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_MM_STEP10B, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Step10B, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_MM_FULLSCREEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Fullscreen, MF_BYCOMMAND, hBitmap, 0   
    
    ; Load bitmaps for Video Aspect submenu
    Invoke LoadImage, hInstance, BMP_MM_ASPECT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Aspect, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_MM_STRETCH, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_VA_Stretch, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_MM_NORMAL, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_VA_Normal, MF_BYCOMMAND, hBitmap, 0 
    
    ; Load bitmaps for Playback Speed submenu
    Invoke LoadImage, hInstance, BMP_MM_SPEED, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Speed, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_MM_FASTER, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_PS_Faster, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_MM_SLOWER, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_PS_Slower, MF_BYCOMMAND, hBitmap, 0     
    
    ; Load bitmaps for Help submenu
    Invoke LoadImage, hInstance, BMP_MM_HELP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_HELP_Help, MF_BYCOMMAND, hBitmap, 0  
    
    Invoke LoadImage, hInstance, BMP_MM_ABOUT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_HELP_About, MF_BYCOMMAND, hBitmap, 0  

    ; Checkmark the selected language
    mov eax, g_LangID
    .IF eax == IDLANG_DEFAULT
        Invoke CheckMenuItem, hMediaPlayerMainMenu, IDM_LANG_Default, MF_CHECKED
    .ELSEIF eax == IDLANG_ENGLISH
        Invoke CheckMenuItem, hMediaPlayerMainMenu, IDM_LANG_English, MF_CHECKED
    .ELSEIF eax == IDLANG_FRENCH
        Invoke CheckMenuItem, hMediaPlayerMainMenu, IDM_LANG_French, MF_CHECKED
    .ELSEIF eax == IDLANG_GERMAN
        Invoke CheckMenuItem, hMediaPlayerMainMenu, IDM_LANG_German, MF_CHECKED
    .ELSEIF eax == IDLANG_POLISH
        Invoke CheckMenuItem, hMediaPlayerMainMenu, IDM_LANG_Polish, MF_CHECKED
    .ELSEIF eax == IDLANG_ITALIAN
        Invoke CheckMenuItem, hMediaPlayerMainMenu, IDM_LANG_Italian, MF_CHECKED
    .ENDIF
    
    Invoke DrawMenuBar, hWin
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
    LOCAL hMenu:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hSubMenu:DWORD
    LOCAL mi:MENUITEMINFO

    IFDEF DEBUG32
    ;PrintText 'MPContextMenuInit'
    ENDIF
    
    ; https://stackoverflow.com/questions/18603571/c-win32-creating-a-popup-menu-from-resource
    Invoke MPContextMenuLoadLanguage, hMediaPlayerContextMenu, g_LangID
    ;Invoke LoadMenu, hInstance, IDM_CONTEXTMENU
    ;mov hMenu, eax
    ;Invoke GetSubMenu, hMenu, 0
    mov hMediaPlayerContextMenu, eax

;    Invoke CreatePopupMenu
;    mov hMediaPlayerContextMenu, eax
;    
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Open, Addr szCM_Open
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Stop, Addr szCM_Stop
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Pause, Addr szCM_Pause
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Play, Addr szCM_Play
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Step, Addr szCM_Step
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Step10B, Addr szCM_Step10B
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Step10F, Addr szCM_Step10F
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Fullscreen, Addr szCM_EnterFS
;    
;    ; Add submenu 'Video Aspect' to rght click menu
;    Invoke MPAspectMenuInit, hWin
;    mov hSubMenu, eax
;    mov mi.cbSize, SIZEOF MENUITEMINFO
;    mov mi.fMask, MIIM_SUBMENU + MIIM_STRING + MIIM_ID
;    mov mi.wID, IDM_CM_Aspect
;    mov eax, hSubMenu
;    mov mi.hSubMenu, eax
;    lea eax, szCM_Aspect
;    mov mi.dwTypeData, eax
;    Invoke InsertMenuItem, hMediaPlayerContextMenu, IDM_CM_Aspect, FALSE, Addr mi
;    mov mi.fMask, MIIM_STATE
;    mov mi.wID, 0
;    mov mi.hSubMenu, 0
;    mov mi.dwTypeData, 0    
;    
;    ; Add submenu 'Playback Speed' to rght click menu
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
;    Invoke MPSpeedMenuInit, hWin
;    mov hSubMenu, eax
;    mov mi.cbSize, SIZEOF MENUITEMINFO
;    mov mi.fMask, MIIM_SUBMENU + MIIM_STRING + MIIM_ID
;    mov mi.wID, IDM_CM_Speed
;    mov eax, hSubMenu
;    mov mi.hSubMenu, eax
;    lea eax, szCM_Speed
;    mov mi.dwTypeData, eax
;    Invoke InsertMenuItem, hMediaPlayerContextMenu, IDM_CM_Speed, FALSE, Addr mi
;    mov mi.fMask, MIIM_STATE
;    mov mi.wID, 0
;    mov mi.hSubMenu, 0
;    mov mi.dwTypeData, 0    
;    
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_SEPARATOR, 0, 0
;    Invoke AppendMenu, hMediaPlayerContextMenu, MF_STRING, IDM_CM_Exit, Addr szCM_Exit

    Invoke LoadImage, hInstance, BMP_CM_OPEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_FILE_Open, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_STOP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Stop, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_PAUSE, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Pause, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_PLAY, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Play, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_STEP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Step, MF_BYCOMMAND, hBitmap, 0

    Invoke LoadImage, hInstance, BMP_CM_FULLSCREEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Fullscreen, MF_BYCOMMAND, hBitmap, 0
    
    ; Load bitmaps for 'Aspect Ratio' submenu
    Invoke LoadImage, hInstance, BMP_CM_ASPECT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Aspect, MF_BYCOMMAND, hBitmap, 0 

    Invoke LoadImage, hInstance, BMP_CM_STRETCH, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_VA_Stretch, MF_BYCOMMAND, hBitmap, 0
    
    Invoke LoadImage, hInstance, BMP_CM_NORMAL, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_VA_Normal, MF_BYCOMMAND, hBitmap, 0
    
    ; Load bitmaps for 'Playback Speed' submenu
    Invoke LoadImage, hInstance, BMP_CM_SPEED, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Speed, MF_BYCOMMAND, hBitmap, 0 

    Invoke LoadImage, hInstance, BMP_CM_SLOWER, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_PS_Slower, MF_BYCOMMAND, hBitmap, 0
    
    Invoke LoadImage, hInstance, BMP_CM_FASTER, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_PS_Faster, MF_BYCOMMAND, hBitmap, 0
    
    Invoke LoadImage, hInstance, BMP_CM_STEP10F, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Step10F, MF_BYCOMMAND, hBitmap, 0 
    
    Invoke LoadImage, hInstance, BMP_CM_STEP10B, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Step10B, MF_BYCOMMAND, hBitmap, 0 

    Invoke LoadImage, hInstance, BMP_CM_EXIT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBitmap, eax
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_FILE_Exit, MF_BYCOMMAND, hBitmap, 0
    
    ret
MPContextMenuInit ENDP

;------------------------------------------------------------------------------
; MPContextMenuUpdate
;------------------------------------------------------------------------------
MPContextMenuUpdate PROC hWin:DWORD
;    LOCAL mi:MENUITEMINFO
;    
;    IFDEF DEBUG32
;    ;PrintText 'MPContextMenuUpdate'
;    ENDIF
;    
;    mov mi.cbSize, SIZEOF MENUITEMINFO
;    mov mi.fMask, MIIM_STRING
;    
;    .IF g_Fullscreen == TRUE    
;        lea eax, szCM_ExitFS
;    .ELSE
;        lea eax, szCM_EnterFS
;    .ENDIF
;    mov mi.dwTypeData, eax
;    Invoke SetMenuItemInfo, hMediaPlayerContextMenu, IDM_MC_Fullscreen, FALSE, Addr mi

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
    
    ;Invoke MPContextMenuUpdate, hWin

    Invoke TrackPopupMenu, hMediaPlayerContextMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON, xpos, ypos, NULL, hWin, NULL ; TPM_RIGHTBUTTON
    Invoke PostMessage, hWin, WM_NULL, 0, 0 ; Fix for shortcut menu not popping up right 
    
    ret
MPContextMenuTrack ENDP

;------------------------------------------------------------------------------
; MPMainMenuLoadLanguage - Load main menu resources for a particular language 
;------------------------------------------------------------------------------
MPMainMenuLoadLanguage PROC hWin:DWORD, dwLangID:DWORD
    LOCAL hMainMenu:DWORD
    LOCAL hRes:DWORD
    LOCAL hResData:DWORD
    LOCAL pResData:DWORD
    
    IFDEF DEBUG32
    ;PrintText 'MPMainMenuLoadLanguage'
    ;PrintDec dwLangID
    ENDIF
    
    Invoke GetMenu, hWin
    mov hMainMenu, eax
    .IF eax != 0
        Invoke DestroyMenu, hMainMenu
        mov hMainMenu, 0
    .ENDIF
    
    ; Find Main Menu Resource
    mov eax, dwLangID
    .IF eax == IDLANG_DEFAULT
        Invoke LoadMenu, hInstance, IDM_MENU
        .IF eax != NULL
            mov hMainMenu, eax
            Invoke SetMenu, hWin, hMainMenu
            mov eax, hMainMenu
        .ENDIF
        ret

    .ELSEIF eax == IDLANG_ENGLISH
        Invoke FindResourceEx, NULL, RT_MENU, IDM_MENU, MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_UK)
    
    .ELSEIF eax == IDLANG_FRENCH
        Invoke FindResourceEx, NULL, RT_MENU, IDM_MENU, MAKELANGID(LANG_FRENCH, SUBLANG_FRENCH)
    
    .ELSEIF eax == IDLANG_GERMAN
        Invoke FindResourceEx, NULL, RT_MENU, IDM_MENU, MAKELANGID(LANG_GERMAN, SUBLANG_GERMAN)
        
    .ELSEIF eax == IDLANG_POLISH
        Invoke FindResourceEx, NULL, RT_MENU, IDM_MENU, MAKELANGID(LANG_POLISH, SUBLANG_POLISH_POLAND)
        
    .ELSEIF eax == IDLANG_ITALIAN
        Invoke FindResourceEx, NULL, RT_MENU, IDM_MENU, MAKELANGID(LANG_ITALIAN, SUBLANG_ITALIAN)
        
    .ELSE
        Invoke LoadMenu, hInstance, IDM_MENU
        .IF eax != NULL
            mov hMainMenu, eax
            Invoke SetMenu, hWin, hMainMenu
            mov eax, hMainMenu
        .ENDIF
        ret
        
    .ENDIF
    
    ; Load Main Menu resource
    .IF eax != 0
        mov hRes, eax
        Invoke LoadResource, hInstance, hRes
        .IF eax != 0
            mov hResData, eax
            Invoke LockResource, hResData
            .IF eax != 0
                mov pResData, eax
                Invoke LoadMenuIndirect, pResData
                .IF eax != 0
                    mov hMainMenu, eax
                    Invoke SetMenu, hWin, hMainMenu
                    mov eax, hMainMenu
                .ENDIF
            .ENDIF
        .ENDIF
    .ENDIF

    ret
MPMainMenuLoadLanguage ENDP

;------------------------------------------------------------------------------
; MPContextMenuLoadLanguage - Load Context menu resources for a particular language 
;------------------------------------------------------------------------------
MPContextMenuLoadLanguage PROC hContextMenu:DWORD, dwLangID:DWORD
    LOCAL hMenu:DWORD
    LOCAL hRes:DWORD
    LOCAL hResData:DWORD
    LOCAL pResData:DWORD

    
    IFDEF DEBUG32
    ;PrintText 'MPContextMenuLoadLanguage'
    ;PrintDec dwLangID
    ENDIF
    
    .IF hContextMenu != 0
        Invoke DestroyMenu, hContextMenu
    .ENDIF
    
    ; Find Context Menu Resource
    mov eax, dwLangID
    .IF eax == IDLANG_DEFAULT
        Invoke LoadMenu, hInstance, IDM_CONTEXTMENU
        mov hMenu, eax
        Invoke GetSubMenu, hMenu, 0
        ret

    .ELSEIF eax == IDLANG_ENGLISH
        Invoke FindResourceEx, NULL, RT_MENU, IDM_CONTEXTMENU, MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_UK)
    
    .ELSEIF eax == IDLANG_FRENCH
        Invoke FindResourceEx, NULL, RT_MENU, IDM_CONTEXTMENU, MAKELANGID(LANG_FRENCH, SUBLANG_FRENCH)
    
    .ELSEIF eax == IDLANG_GERMAN
        Invoke FindResourceEx, NULL, RT_MENU, IDM_CONTEXTMENU, MAKELANGID(LANG_GERMAN, SUBLANG_GERMAN)
        
    .ELSEIF eax == IDLANG_POLISH
        Invoke FindResourceEx, NULL, RT_MENU, IDM_MENU, MAKELANGID(LANG_POLISH, SUBLANG_POLISH_POLAND)
        
    .ELSEIF eax == IDLANG_ITALIAN
        Invoke FindResourceEx, NULL, RT_MENU, IDM_MENU, MAKELANGID(LANG_ITALIAN, SUBLANG_ITALIAN)
        
    .ELSE
        Invoke LoadMenu, hInstance, IDM_CONTEXTMENU
        mov hMenu, eax
        Invoke GetSubMenu, hMenu, 0
        ret
        
    .ENDIF
    
    ; Load Context Menu Resource
    .IF eax != 0
        mov hRes, eax
        Invoke LoadResource, hInstance, hRes
        .IF eax != 0
            mov hResData, eax
            Invoke LockResource, hResData
            .IF eax != 0
                mov pResData, eax
                Invoke LoadMenuIndirect, pResData
                mov hMenu, eax
                Invoke GetSubMenu, hMenu, 0
            .ENDIF
        .ENDIF
    .ENDIF
    
    ret
MPContextMenuLoadLanguage ENDP


