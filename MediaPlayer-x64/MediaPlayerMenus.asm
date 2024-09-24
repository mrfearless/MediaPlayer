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

MPMenuPlaySpeedInit         PROTO
MPMenuAudioStreamInit       PROTO

MPMenusUnavailable          PROTO

MPMenuClearMRU              PROTO hWin:QWORD

EXTERNDEF MFI_AudioStreamText   :PROTO pStreamRecord:QWORD, lpszAudioStreamText:QWORD, bMajorType:DWORD, dwStreamNo:DWORD

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
BMP_MM_AUDIOSTREAMS     EQU 366

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
BMP_CM_AUDIOSTREAMS     EQU BMP_MM_AUDIOSTREAMS

; MediaPlayer Main Menu IDs
IDM_MENU                EQU 10000
IDM_FILE_Open           EQU 10001   ; Ctrl+O
IDM_FILE_Exit           EQU 10002   ; Alt+F4
IDM_MC_Stop             EQU 10021   ; Ctrl+S
IDM_MC_Pause            EQU 10022
IDM_MC_Play             EQU 10023   ; Ctrl+P
IDM_MC_Step             EQU 10024
IDM_MC_Step10B          EQU 10025   ; Ctrl+B or Ctrl+Left
IDM_MC_Step10F          EQU 10026   ; Ctrl+F or Ctrl+Right
IDM_MC_Fullscreen       EQU 10027   ; F11
IDM_MC_Aspect           EQU 10028
IDM_MC_VA_Stretch       EQU 10029
IDM_MC_VA_Normal        EQU 10030
IDM_MC_PlaySpeed        EQU 10031
IDM_MC_AudioStreams     EQU 10040
IDM_LANG_Default        EQU 10050
IDM_LANG_English        EQU 10051
IDM_LANG_French         EQU 10052
IDM_LANG_German         EQU 10053
IDM_LANG_Polish         EQU 10054
IDM_LANG_Italian        EQU 10055
IDM_LANG_Spanish        EQU 10056
IDM_LANG_Ukrainian      EQU 10057
IDM_LANG_Persian        EQU 10058
IDM_HELP_Help           EQU 10101
IDM_HELP_About          EQU 10102

; MediaPlayer Context Menu IDs
IDM_CONTEXTMENU         EQU 11000

IDM_UNAVAILABLE         EQU 12099

; MediaPlayer PlaySpeed Menu IDs
IDM_PS_FIRST            EQU 12100
IDM_PS_125              EQU 12100
IDM_PS_250              EQU 12101
IDM_PS_500              EQU 12102
IDM_PS_750              EQU 12103
IDM_PS_1000             EQU 12104
IDM_PS_1250             EQU 12105
IDM_PS_1500             EQU 12106
IDM_PS_1750             EQU 12107
IDM_PS_2000             EQU 12108
IDM_PS_3000             EQU 12109
IDM_PS_4000             EQU 12110
IDM_PS_LAST             EQU 12110

; MediaPlayer Audio Stream Menu IDs
IDM_AS_FIRST            EQU 12200
IDM_AS_LAST             EQU 12299

.DATA
ALIGN 4

IFDEF __UNICODE__
szPS_125                DB "x",0," ",0,"0",0,".",0,"1",0,"2",0,"5",0
                        DB 0,0,0,0
szPS_250                DB "x",0," ",0,"0",0,".",0,"2",0,"5",0
                        DB 0,0,0,0
szPS_500                DB "x",0," ",0,"0",0,".",0,"5",0
                        DB 0,0,0,0
szPS_750                DB "x",0," ",0,"0",0,".",0,"7",0,"5",0
                        DB 0,0,0,0
szPS_1000               DB "x",0," ",0,"1",0,".",0,"0",0 
                        DB 0,0,0,0 ; ," ",0,"(",0,"N",0,"o",0,"r",0,"m",0,"a",0,"l",0,")",0
szPS_1250               DB "x",0," ",0,"1",0,".",0,"2",0,"5",0
                        DB 0,0,0,0
szPS_1500               DB "x",0," ",0,"1",0,".",0,"5",0
                        DB 0,0,0,0
szPS_1750               DB "x",0," ",0,"1",0,".",0,"7",0,"5",0
                        DB 0,0,0,0
szPS_2000               DB "x",0," ",0,"2",0,".",0,"0",0
                        DB 0,0,0,0
szPS_3000               DB "x",0," ",0,"3",0,".",0,"0",0
                        DB 0,0,0,0
szPS_4000               DB "x",0," ",0,"4",0,".",0,"0",0
                        DB 0,0,0,0
ELSE
szPS_125                DB "x 0.125",0
szPS_250                DB "x 0.25",0
szPS_500                DB "x 0.5",0
szPS_750                DB "x 0.75",0
szPS_1000               DB "x 1.0",0 ;  (Normal)
szPS_1250               DB "x 1.25",0
szPS_1500               DB "x 1.5",0
szPS_1750               DB "x 1.75",0
szPS_2000               DB "x 2.0",0
szPS_3000               DB "x 3.0",0
szPS_4000               DB "x 4.0",0
ENDIF

IFDEF __UNICODE__
szAudioStreamMenuItem   DB 288 DUP (0)
ELSE
szAudioStreamMenuItem   DB 144 DUP (0)
ENDIF

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
hBmp_MM_AudioStreams    DQ ?
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

    IFDEF MP_RTLC_RESOURCES
    Invoke BitmapCreateFromCompressedRes, hInstance, BMP_MM_AUDIOSTREAMS
    ELSE
    Invoke LoadImage, hInstance, BMP_MM_AUDIOSTREAMS, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    ENDIF
    mov hBmp_MM_AudioStreams, rax

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
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_PlaySpeed, MF_BYCOMMAND, hBmp_MM_Speed, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerMainMenu, IDM_MC_AudioStreams, MF_BYCOMMAND, hBmp_MM_AudioStreams, 0
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
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_PlaySpeed, MF_BYCOMMAND, hBmp_MM_Speed, 0 
    Invoke SetMenuItemBitmaps, hMediaPlayerContextMenu, IDM_MC_AudioStreams, MF_BYCOMMAND, hBmp_MM_AudioStreams, 0
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
    .ELSEIF eax == IDLANG_UKRAINIAN
        Invoke CheckMenuItem, hMediaPlayerMainMenu, IDM_LANG_Ukrainian, MF_CHECKED
    .ELSEIF eax == IDLANG_PERSIAN
        Invoke CheckMenuItem, hMediaPlayerMainMenu, IDM_LANG_Persian, MF_CHECKED
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
        
        .IF g_LangRTL == TRUE
            mov eax, rect.right
        .ELSE
            mov eax, rect.left
        .ENDIF
        add eax, 20
        mov xpos, eax
        mov eax, rect.top
        add eax, 20
        mov ypos, eax
    .ENDIF
    
    ;Invoke MPContextMenuUpdate, hWin

    .IF g_LangRTL == TRUE
        Invoke TrackPopupMenu, hMediaPlayerContextMenu, TPM_LAYOUTRTL or TPM_RIGHTALIGN or TPM_LEFTBUTTON, xpos, ypos, NULL, hWin, NULL ; TPM_RIGHTBUTTON
    .ELSE
        Invoke TrackPopupMenu, hMediaPlayerContextMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON, xpos, ypos, NULL, hWin, NULL ; TPM_RIGHTBUTTON
    .ENDIF
    Invoke PostMessage, hWin, WM_NULL, 0, 0 ; Fix for shortcut menu not popping up right 
    
    ret
MPContextMenuTrack ENDP

;------------------------------------------------------------------------------
; MPMenuPlaySpeedInit
;------------------------------------------------------------------------------
MPMenuPlaySpeedInit PROC FRAME USES RBX
    LOCAL mi:MENUITEMINFO
    
    .IF hMediaPlayerSpeedMenu != 0
        Invoke DestroyMenu, hMediaPlayerSpeedMenu
        mov hMediaPlayerSpeedMenu, 0
    .ENDIF

    Invoke CreatePopupMenu
    mov hMediaPlayerSpeedMenu, rax
    
    .IF pMI == 0
        Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED, IDM_UNAVAILABLE, lpszTextUnvailable
    .ELSE
    
        mov eax, dwSlowestRate
        .IF sdword ptr eax <= 125
            Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED or MF_UNCHECKED, IDM_PS_125, Addr szPS_125
        .ENDIF
        mov eax, dwSlowestRate
        .IF sdword ptr eax <= 250
            Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED or MF_UNCHECKED, IDM_PS_250, Addr szPS_250
        .ENDIF
        mov eax, dwSlowestRate
        .IF sdword ptr eax <= 500
            Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED or MF_UNCHECKED, IDM_PS_500, Addr szPS_500
        .ENDIF
        mov eax, dwSlowestRate
        .IF sdword ptr eax <= 750
            Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED or MF_UNCHECKED, IDM_PS_750, Addr szPS_750
        .ENDIF
        mov eax, dwSlowestRate
        .IF sdword ptr eax < 1000
            Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_SEPARATOR, 0, 0
        .ENDIF
    
        Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED or MF_UNCHECKED, IDM_PS_1000, Addr szPS_1000
        
        mov eax, dwFastestRate
        .IF sdword ptr eax > 1000
            Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_SEPARATOR, 0, 0
        .ENDIF
        mov eax, dwFastestRate
        .IF sdword ptr eax >= 1250
            Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED or MF_UNCHECKED, IDM_PS_1250, Addr szPS_1250
        .ENDIF
        mov eax, dwFastestRate
        .IF sdword ptr eax >= 1500
            Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED or MF_UNCHECKED, IDM_PS_1500, Addr szPS_1500
        .ENDIF
        mov eax, dwFastestRate
        .IF sdword ptr eax >= 1750
            Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED or MF_UNCHECKED, IDM_PS_1750, Addr szPS_1750
        .ENDIF
        mov eax, dwFastestRate
        .IF sdword ptr eax >= 2000
            Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED or MF_UNCHECKED, IDM_PS_2000, Addr szPS_2000
        .ENDIF
        mov eax, dwFastestRate
        .IF sdword ptr eax >= 3000
            Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED or MF_UNCHECKED, IDM_PS_3000, Addr szPS_3000
        .ENDIF
        mov eax, dwFastestRate
        .IF sdword ptr eax >= 4000
            Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED or MF_UNCHECKED, IDM_PS_4000, Addr szPS_4000
        .ENDIF
    
        mov eax, dwCurrentRate
        .IF eax == 125
            Invoke CheckMenuItem, hMediaPlayerSpeedMenu, IDM_PS_125, MF_CHECKED
        .ELSEIF eax == 250
            Invoke CheckMenuItem, hMediaPlayerSpeedMenu, IDM_PS_250, MF_CHECKED
        .ELSEIF eax == 500
            Invoke CheckMenuItem, hMediaPlayerSpeedMenu, IDM_PS_500, MF_CHECKED
        .ELSEIF eax == 750
            Invoke CheckMenuItem, hMediaPlayerSpeedMenu, IDM_PS_750, MF_CHECKED
        .ELSEIF eax == 1000
            Invoke CheckMenuItem, hMediaPlayerSpeedMenu, IDM_PS_1000, MF_CHECKED
        .ELSEIF eax == 1250
            Invoke CheckMenuItem, hMediaPlayerSpeedMenu, IDM_PS_1250, MF_CHECKED
        .ELSEIF eax == 1500
            Invoke CheckMenuItem, hMediaPlayerSpeedMenu, IDM_PS_1500, MF_CHECKED
        .ELSEIF eax == 1750
            Invoke CheckMenuItem, hMediaPlayerSpeedMenu, IDM_PS_1750, MF_CHECKED
        .ELSEIF eax == 2000
            Invoke CheckMenuItem, hMediaPlayerSpeedMenu, IDM_PS_2000, MF_CHECKED
        .ELSEIF eax == 3000
            Invoke CheckMenuItem, hMediaPlayerSpeedMenu, IDM_PS_3000, MF_CHECKED
        .ELSEIF eax == 4000
            Invoke CheckMenuItem, hMediaPlayerSpeedMenu, IDM_PS_4000, MF_CHECKED
        .ENDIF

    .ENDIF
    
    ; Set Main Menu's Play Speed Submenu
    mov mi.cbSize, SIZEOF MENUITEMINFO
    mov mi.fMask, MIIM_SUBMENU + MIIM_ID ; + MIIM_STRING
    mov mi.wID, IDM_MC_PlaySpeed
    mov rax, hMediaPlayerSpeedMenu
    mov mi.hSubMenu, rax
    Invoke SetMenuItemInfo, hMediaPlayerMainMenu, IDM_MC_PlaySpeed, FALSE, Addr mi
    
    ; Set Context Menu's Play Speed Submenu
    mov mi.cbSize, SIZEOF MENUITEMINFO
    mov mi.fMask, MIIM_SUBMENU + MIIM_ID ; + MIIM_STRING
    mov mi.wID, IDM_MC_PlaySpeed
    mov rax, hMediaPlayerSpeedMenu
    mov mi.hSubMenu, rax
    Invoke SetMenuItemInfo, hMediaPlayerContextMenu, IDM_MC_PlaySpeed, FALSE, Addr mi
    
    ret
MPMenuPlaySpeedInit ENDP

;------------------------------------------------------------------------------
; MPMenuAudioStreamInit
;------------------------------------------------------------------------------
MPMenuAudioStreamInit PROC FRAME USES RBX
    LOCAL mi:MENUITEMINFO
    LOCAL nStream:DWORD
    LOCAL pStreamRecord:QWORD
    LOCAL dwMenuID:DWORD
    LOCAL nAudioStream:DWORD
    
    IFDEF DEBUG64
    ;PrintText 'MPMenuAudioStreamInit'
    ENDIF
    
    .IF hMediaPlayerAudioMenu != 0
        Invoke DestroyMenu, hMediaPlayerAudioMenu
        mov hMediaPlayerAudioMenu, 0
    .ENDIF
    
    Invoke CreatePopupMenu
    mov hMediaPlayerAudioMenu, rax
    
    IFDEF DEBUG64
    ;PrintDec g_pStreamTable
    ;PrintDec g_dwStreamCount
    ENDIF
    
    .IF pMI == 0
        Invoke AppendMenu, hMediaPlayerAudioMenu, MF_STRING or MF_ENABLED, IDM_UNAVAILABLE, lpszTextUnvailable
    .ELSE
    
        mov rax, g_pStreamTable
        mov pStreamRecord, rax
        mov nStream, 0
        mov nAudioStream, 1
        mov eax, 0
        .WHILE eax < g_dwStreamCount
            mov rbx, pStreamRecord
            mov eax, dword ptr [rbx].MFP_STREAM_RECORD.dwMajorType
            .IF eax == MFMT_Audio
                
                Invoke MFI_AudioStreamText, pStreamRecord, Addr szAudioStreamMenuItem, FALSE, nAudioStream
    
                IFDEF DEBUG64
                ;PrintString szAudioStreamMenuItem
                ENDIF
                
                mov eax, IDM_AS_FIRST
                add eax, nAudioStream ; start at 12201
                mov dwMenuID, eax
                .IF sdword ptr eax <= IDM_AS_LAST
                    mov rbx, pStreamRecord
                    mov eax, dword ptr [rbx].MFP_STREAM_RECORD.bSelected
                    .IF eax == TRUE 
                        Invoke AppendMenu, hMediaPlayerAudioMenu, MF_STRING or MF_ENABLED or MF_CHECKED, dwMenuID, Addr szAudioStreamMenuItem
                    .ELSE
                        Invoke AppendMenu, hMediaPlayerAudioMenu, MF_STRING or MF_ENABLED or MF_UNCHECKED, dwMenuID, Addr szAudioStreamMenuItem
                    .ENDIF
                .ENDIF
                
                inc nAudioStream
                
            .ENDIF
            
            add pStreamRecord, SIZEOF MFP_STREAM_RECORD
            inc nStream
            mov eax, nStream
        .ENDW
    
    .ENDIF
    
    ; Set Main Menu's Audio Streams Submenu
    mov mi.cbSize, SIZEOF MENUITEMINFO
    mov mi.fMask, MIIM_SUBMENU + MIIM_ID ; + MIIM_STRING
    mov mi.wID, IDM_MC_AudioStreams
    mov rax, hMediaPlayerAudioMenu
    mov mi.hSubMenu, rax
    Invoke SetMenuItemInfo, hMediaPlayerMainMenu, IDM_MC_AudioStreams, FALSE, Addr mi
    
    ; Set Context Menu's Audio Streams Submenu
    mov mi.cbSize, SIZEOF MENUITEMINFO
    mov mi.fMask, MIIM_SUBMENU + MIIM_ID ; + MIIM_STRING
    mov mi.wID, IDM_MC_AudioStreams
    mov rax, hMediaPlayerAudioMenu
    mov mi.hSubMenu, rax
    Invoke SetMenuItemInfo, hMediaPlayerContextMenu, IDM_MC_AudioStreams, FALSE, Addr mi
    
    ret
MPMenuAudioStreamInit ENDP

;------------------------------------------------------------------------------
; MPMenusUnavailable
;------------------------------------------------------------------------------
MPMenusUnavailable PROC FRAME
    
    Invoke CreatePopupMenu
    mov hMediaPlayerSpeedMenu, rax
    
    Invoke CreatePopupMenu
    mov hMediaPlayerAudioMenu, rax
    
    Invoke AppendMenu, hMediaPlayerSpeedMenu, MF_STRING or MF_ENABLED, IDM_UNAVAILABLE, lpszTextUnvailable ;Addr szMenuUnavailable
    Invoke AppendMenu, hMediaPlayerAudioMenu, MF_STRING or MF_ENABLED, IDM_UNAVAILABLE, lpszTextUnvailable ;Addr szMenuUnavailable
    
    ret
MPMenusUnavailable ENDP

;------------------------------------------------------------------------------
; MPMenuClearMRU - Clear Most Recently Used Files
;------------------------------------------------------------------------------
MPMenuClearMRU PROC FRAME hWin:QWORD
    LOCAL mi:MENUITEMINFO
    
    Invoke IniMRUClearListFromMenu, hWin, Addr MediaPlayerIniFile, IDM_FILE_Exit
    
    ;--------------------------------------------------------------------------
    ; Recreate main menu by destroying it and creating it again, as this will 
    ; fix the long menuitem width left behind from long filenames in the MRU
    ;--------------------------------------------------------------------------
    Invoke MPLangLoadMenus, g_LangID, hWin, Addr hMediaPlayerMainMenu, NULL
    Invoke MPSetMenuBitmaps, hWin
    
    ;--------------------------------------------------------------------------
    ; Set Main Menu's Play Speed Submenu
    ;--------------------------------------------------------------------------
    mov mi.cbSize, SIZEOF MENUITEMINFO
    mov mi.fMask, MIIM_SUBMENU + MIIM_ID
    mov mi.wID, IDM_MC_PlaySpeed
    mov rax, hMediaPlayerSpeedMenu
    mov mi.hSubMenu, rax
    Invoke SetMenuItemInfo, hMediaPlayerMainMenu, IDM_MC_PlaySpeed, FALSE, Addr mi
    
    ;--------------------------------------------------------------------------
    ; Set Main Menu's Audio Streams Submenu
    ;--------------------------------------------------------------------------
    mov mi.cbSize, SIZEOF MENUITEMINFO
    mov mi.fMask, MIIM_SUBMENU + MIIM_ID
    mov mi.wID, IDM_MC_AudioStreams
    mov rax, hMediaPlayerAudioMenu
    mov mi.hSubMenu, rax
    Invoke SetMenuItemInfo, hMediaPlayerMainMenu, IDM_MC_AudioStreams, FALSE, Addr mi
    
    ret
MPMenuClearMRU ENDP



