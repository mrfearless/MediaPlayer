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

MPLoadMenuBitmaps           PROTO hWin:QWORD
MPSetMenuBitmaps            PROTO hWin:QWORD
MPContextMenuTrack          PROTO hWin:QWORD, wParam:WPARAM, lParam:LPARAM

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
IDM_LANG_Spanish        EQU 10056
IDM_HELP_Help           EQU 10101
IDM_HELP_About          EQU 10102

; MediaPlayer Context Menu IDs
IDM_CONTEXTMENU         EQU 11000


.DATA?
hBmp_MM_Open            DQ ?
hBmp_MM_Stop            DQ ?
hBmp_MM_Pause           DQ ?
hBmp_MM_Play            DQ ?
hBmp_MM_Step            DQ ?
hBmp_MM_Exit            DQ ?
hBmp_MM_Fullscreen      DQ ?
hBmp_MM_About           DQ ?
hBmp_MM_Stretch         DQ ?
hBmp_MM_Normal          DQ ?
hBmp_MM_Aspect          DQ ?
hBmp_MM_Help            DQ ?
hBmp_MM_Step10f         DQ ?
hBmp_MM_Step10b         DQ ?
hBmp_MM_Faster          DQ ?
hBmp_MM_Slower          DQ ?
hBmp_MM_Speed           DQ ?
hBmpFileMRU             DQ ?
hBmpFileMRUClear        DQ ?


.CODE

;------------------------------------------------------------------------------
; MPLoadMenuBitmaps - load menu bitmaps (compressed or uncompressed)
;------------------------------------------------------------------------------
MPLoadMenuBitmaps PROC FRAME hWin:QWORD

    ; Load bitmaps for File submenu
    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_OPEN
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_OPEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Open, rax

    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_EXIT
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_EXIT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Exit, rax
    
    ; Load bitmaps for Media Controls submenu
    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_STOP
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_STOP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Stop, rax
 
    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_PAUSE
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_PAUSE, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Pause, rax

    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_PLAY
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_PLAY, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Play, rax
  
    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_STEP
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_STEP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Step, rax

    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_STEP10F
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_STEP10F, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Step10f, rax

    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_STEP10B
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_STEP10B, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Step10b, rax

    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_FULLSCREEN
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_FULLSCREEN, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Fullscreen, rax
    
    ; Load bitmaps for Video Aspect submenu
    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_ASPECT
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_ASPECT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Aspect, rax

    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_STRETCH
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_STRETCH, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Stretch, rax

    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_NORMAL
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_NORMAL, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Normal, rax
    
    ; Load bitmaps for Playback Speed submenu
    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_SPEED
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_SPEED, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Speed, rax

    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_FASTER
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_FASTER, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Faster, rax

    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_SLOWER
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_SLOWER, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Slower, rax
     
    ; Load bitmaps for Help submenu
    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_HELP
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_HELP, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_Help, rax

    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_ABOUT
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_ABOUT, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_About, rax

    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_FILE_MRU
    ELSE
    Invoke LoadImage, hInstance, BMP_FILE_MRU, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmpFileMRU, rax
    
    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_FILE_MRU_CLEAR
    ELSE
    Invoke LoadImage, hInstance, BMP_FILE_MRU_CLEAR, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmpFileMRUClear, rax

    ret
MPLoadMenuBitmaps ENDP

;------------------------------------------------------------------------------
; MPSetMenuBitmaps
;------------------------------------------------------------------------------
MPSetMenuBitmaps PROC FRAME hWin:QWORD
    
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_FILE_Open, MF_BYCOMMAND, hBmp_MM_Open, 0
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_FILE_Exit, MF_BYCOMMAND, hBmp_MM_Exit, 0
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Stop, MF_BYCOMMAND, hBmp_MM_Stop, 0    
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Pause, MF_BYCOMMAND, hBmp_MM_Pause, 0   
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Play, MF_BYCOMMAND, hBmp_MM_Play, 0   
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Step, MF_BYCOMMAND, hBmp_MM_Step, 0   
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Step10F, MF_BYCOMMAND, hBmp_MM_Step10f, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Step10B, MF_BYCOMMAND, hBmp_MM_Step10b, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Fullscreen, MF_BYCOMMAND, hBmp_MM_Fullscreen, 0   
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Aspect, MF_BYCOMMAND, hBmp_MM_Aspect, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_VA_Stretch, MF_BYCOMMAND, hBmp_MM_Stretch, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_VA_Normal, MF_BYCOMMAND, hBmp_MM_Normal, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_Speed, MF_BYCOMMAND, hBmp_MM_Speed, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_PS_Faster, MF_BYCOMMAND, hBmp_MM_Faster, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_PS_Slower, MF_BYCOMMAND, hBmp_MM_Slower, 0     
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_HELP_Help, MF_BYCOMMAND, hBmp_MM_Help, 0  
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_HELP_About, MF_BYCOMMAND, hBmp_MM_About, 0
    
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_FILE_Open, MF_BYCOMMAND, hBmp_MM_Open, 0
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Stop, MF_BYCOMMAND, hBmp_MM_Stop, 0
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Pause, MF_BYCOMMAND, hBmp_MM_Pause, 0
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Play, MF_BYCOMMAND, hBmp_MM_Play, 0
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Step, MF_BYCOMMAND, hBmp_MM_Step, 0
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Fullscreen, MF_BYCOMMAND, hBmp_MM_Fullscreen, 0
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Aspect, MF_BYCOMMAND, hBmp_MM_Aspect, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_VA_Stretch, MF_BYCOMMAND, hBmp_MM_Stretch, 0
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_VA_Normal, MF_BYCOMMAND, hBmp_MM_Normal, 0
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Speed, MF_BYCOMMAND, hBmp_MM_Speed, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_PS_Slower, MF_BYCOMMAND, hBmp_MM_Slower, 0
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_PS_Faster, MF_BYCOMMAND, hBmp_MM_Faster, 0
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Step10F, MF_BYCOMMAND, hBmp_MM_Step10f, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_Step10B, MF_BYCOMMAND, hBmp_MM_Step10b, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_FILE_Exit, MF_BYCOMMAND, hBmp_MM_Exit, 0
    
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
    .ELSEIF eax == IDLANG_SPANISH
        Invoke CheckMenuItem, hMediaPlayerMainMenu, IDM_LANG_Spanish, MF_CHECKED
    .ENDIF
    
    ret

MPSetMenuBitmaps ENDP

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
    
    ;Invoke MPContextMenuUpdate, hWin

    Invoke TrackPopupMenu, hMediaPlayerContextMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON, xpos, ypos, NULL, hWin, NULL ; TPM_RIGHTBUTTON
    Invoke PostMessage, hWin, WM_NULL, 0, 0 ; Fix for shortcut menu not popping up right 
    
    ret
MPContextMenuTrack ENDP



