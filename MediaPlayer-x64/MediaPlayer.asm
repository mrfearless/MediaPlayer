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

.686
.MMX
.XMM
.x64

option casemap : none
option win64 : 11
option frame : auto
option stackbase : rsp

_WIN64 EQU 1
WINVER equ 0501h

MP_PATTERN_BACKGROUND EQU 1 ; comment out to allow pattern backgrounds

;DEBUG64 EQU 1
;
;IFDEF DEBUG64
;    PRESERVEXMMREGS equ 1
;    includelib \UASM\lib\x64\Debug64.lib
;    DBG64LIB equ 1
;    DEBUGEXE textequ <'\UASM\bin\DbgWin.exe'>
;    include \UASM\include\debug64.inc
;    .DATA
;    RDBG_DbgWin	DB DEBUGEXE,0
;    .CODE
;ENDIF

include MediaPlayer.inc

include MediaPlayerIni.asm      ; ini file settings
include MediaPlayerAbout.asm    ; About dialog box

include MediaPlayerMenus.asm    ; Context menu and main menu bitmaps etc
include MediaPlayerWindow.asm   ; MFPlay video window for rendering videos
include MediaPlayerLabels.asm   ; Label controls for position and duration
include MediaPlayerVolume.asm   ; Volume Slider Control
include MediaPlayerSeekBar.asm  ; Seek Bar Control
include MediaPlayerControls.asm ; Toolbars & toolbar buttons for main MFPlay features


.CODE

;------------------------------------------------------------------------------
; Startup
;------------------------------------------------------------------------------
WinMainCRTStartup PROC FRAME
	Invoke GetModuleHandle, NULL
	mov hInstance, rax
	
    Invoke LoadAccelerators, hInstance, ACCTABLE
    mov hAcc, rax
	
	Invoke GetCommandLine
	mov CommandLine, rax
	Invoke InitCommonControls
	mov icc.dwSize, sizeof INITCOMMONCONTROLSEX
    mov icc.dwICC, ICC_COOL_CLASSES or ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES
    Invoke InitCommonControlsEx, offset icc
    
    Invoke CmdLineProcess
    
	Invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	Invoke ExitProcess, eax
    ret
WinMainCRTStartup ENDP
	
;------------------------------------------------------------------------------
; WinMain
;------------------------------------------------------------------------------
WinMain PROC FRAME hInst:HINSTANCE, hPrev:HINSTANCE, CmdLine:LPSTR, iShow:DWORD
	LOCAL msg:MSG
	LOCAL wcex:WNDCLASSEX
	
	mov wcex.cbSize, sizeof WNDCLASSEX
	mov wcex.style, CS_HREDRAW or CS_VREDRAW
	lea rax, WndProc
	mov wcex.lpfnWndProc, rax
	mov wcex.cbClsExtra, 0
	mov wcex.cbWndExtra, DLGWINDOWEXTRA
	mov rax, hInst
	mov wcex.hInstance, rax
	mov wcex.hbrBackground, NULL
	mov wcex.lpszMenuName, IDM_MENU ;NULL 
	lea rax, ClassName
	mov wcex.lpszClassName, rax
	Invoke LoadIcon, hInst, ICO_MAIN
	mov hIcoMain, rax
	mov wcex.hIcon, rax
	mov wcex.hIconSm, rax
	Invoke LoadCursor, NULL, IDC_ARROW
	mov wcex.hCursor, rax
	Invoke RegisterClassEx, addr wcex
	Invoke CreateDialogParam, hInstance, IDD_DIALOG, 0, Addr WndProc, 0
	mov hWnd, rax
	
	Invoke ShowWindow, hWnd, SW_SHOWNORMAL
	Invoke UpdateWindow, hWnd
	
	.WHILE (TRUE)
		Invoke GetMessage, addr msg, NULL, 0, 0
		.BREAK .IF (!rax)		
        Invoke TranslateAccelerator, hWnd, hAcc, addr msg
        .IF rax == 0
            Invoke IsDialogMessage, hWnd, addr msg
            .IF rax == 0
                Invoke TranslateMessage, addr msg
                Invoke DispatchMessage, addr msg
            .ENDIF
        .ENDIF
	.ENDW
	
	mov rax, msg.wParam
	ret	
WinMain ENDP

;------------------------------------------------------------------------------
; WndProc - Main Window Message Loop
;------------------------------------------------------------------------------
WndProc PROC FRAME hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_INITDIALOG
        Invoke GUIInit, hWin
		
		
	.ELSEIF eax == WM_COMMAND
        mov rax, wParam
        and rax, 0FFFFh
		.IF eax == IDM_FILE_EXIT
			Invoke SendMessage, hWin, WM_CLOSE, 0, 0
			
        .ELSEIF eax == IDM_HELP_ABOUT
            Invoke DialogBoxParam, hInstance, IDD_AboutDlg, hWin, Addr MediaPlayerAboutDlgProc, NULL
			
        .ELSEIF eax == IDM_FILE_OPEN || eax == IDM_CM_Open || eax == ACC_FILE_OPEN
            Invoke MediaPlayerBrowseForFile, hMainWindow
            .IF eax == TRUE
                Invoke MediaPlayerOpenFile, hMainWindow, lpszMediaFileName
            .ENDIF
            
        .ELSEIF eax == IDM_CM_Stop || eax == IDM_MC_STOP || eax == ACC_MC_STOP
            .IF pMI != 0
                Invoke MFPMediaPlayer_Stop, pMP
            .ENDIF
            
        .ELSEIF eax == IDM_CM_Pause || eax == IDM_MC_PAUSE
            .IF pMI != 0
                Invoke MFPMediaPlayer_Pause, pMP
                Invoke SetFocus, hMediaPlayerWindow
            .ENDIF
            
        .ELSEIF eax == IDM_CM_Play || eax == IDM_MC_PLAY || eax == ACC_MC_PLAY
            .IF pMI != 0
                Invoke MFPMediaPlayer_Play, pMP
            .ENDIF
            
        .ELSEIF eax == IDM_CM_Step || eax == IDM_MC_STEP
            .IF pMI != 0
                Invoke MFPMediaPlayer_Step, pMP
            .ENDIF
            
        .ELSEIF eax == IDM_CM_Fullscreen || eax == IDM_MC_FULLSCREEN
            Invoke GUIToggleFullscreen, hMainWindow
        
        .ELSEIF eax == IDM_CM_Exit || eax == ACC_FILE_EXIT
            Invoke SendMessage, hWin, WM_CLOSE, 0, 0
            
        ;----------------------------------------------------------------------
        ; Set Aspect Ratio
        ;----------------------------------------------------------------------
        .ELSEIF eax == IDM_AM_STRETCH
            .IF pMP != 0
                Invoke MFPMediaPlayer_SetAspectRatioMode, pMP, MFVideoARMode_None
                .IF rax == TRUE
                    Invoke MFPMediaPlayer_UpdateVideo, pMP
                    Invoke UpdateWindow, hMediaPlayerWindow
                    Invoke SendMessage, hMPC_ToolbarScreen, TB_CHANGEBITMAP, IDC_MPC_Aspect, TBID_MPC_A_STRETCH
                .ELSE
                    IFDEF DEBUG64
                    PrintText 'MFVideoARMode_None failed'
                    ENDIF
                .ENDIF
            .ENDIF
            
        .ELSEIF eax == IDM_AM_NORMAL
            .IF pMP != 0
                Invoke MFPMediaPlayer_SetAspectRatioMode, pMP, (MFVideoARMode_PreservePixel or MFVideoARMode_PreservePicture)
                .IF rax == TRUE
                    Invoke MFPMediaPlayer_UpdateVideo, pMP
                    Invoke UpdateWindow, hMediaPlayerWindow
                    Invoke SendMessage, hMPC_ToolbarScreen, TB_CHANGEBITMAP, IDC_MPC_Aspect, TBID_MPC_A_NORMAL
                .ELSE
                    IFDEF DEBUG64
                    PrintText 'MFVideoARMode_PreservePixel or MFVideoARMode_PreservePicture failed'
                    ENDIF
                .ENDIF
            .ENDIF
			
        ;----------------------------------------------------------------------
        ; Most Recently Used (MRU) File On The File Menu
        ;----------------------------------------------------------------------
		.ELSEIF eax >= IDM_MRU_FIRST && eax <= IDM_MRU_LAST
			Invoke GetMenuString, hMediaPlayerMainMenu, eax, Addr szMenuString, SIZEOF szMenuString, MF_BYCOMMAND
			.IF rax != 0
			    Invoke lstrlen, Addr szMenuString
			    .IF rax != 0
			        Invoke MediaPlayerOpenFile, hMainWindow, Addr szMenuString
				.ENDIF
			.ENDIF
            
		.ENDIF

    ;--------------------------------------------------------------------------
    ; Drag and drop support
    ;--------------------------------------------------------------------------
    .ELSEIF eax == WM_DROPFILES
        mov rax, wParam
        mov hDrop, rax
        Invoke DragQueryFile, hDrop, 0, Addr szDroppedFilename, SIZEOF szDroppedFilename
        .IF rax != 0
            Invoke MediaPlayerOpenFile, hMainWindow, Addr szDroppedFilename
        .ENDIF
        mov rax, 0
        ret

    ;--------------------------------------------------------------------------
    ; If user clicks on Play Logo (which does have a play icon) then we allow
    ; it to play the media, if no media then we open a file and play it.
    ;--------------------------------------------------------------------------
    .ELSEIF eax == WM_LBUTTONUP
        Invoke GUIIsClickInArea, hWin, MP_AREA_LOGO, lParam
        .IF rax == TRUE
            .IF pMI != 0
                Invoke MFPMediaPlayer_Play, pMP
            .ELSE    
                Invoke MediaPlayerBrowseForFile, hMainWindow
                .IF rax == TRUE
                    Invoke MediaPlayerOpenFile, hMainWindow, lpszMediaFileName
                .ENDIF
            .ENDIF
            Invoke SetFocus, hMediaPlayerWindow
        .ENDIF
        mov rax, 0
        ret

    ;--------------------------------------------------------------------------
    ; Quick way to open a file is to double click background
    ;--------------------------------------------------------------------------
    .ELSEIF eax == WM_LBUTTONDBLCLK
        Invoke GUIIsClickInArea, hWin, MP_AREA_PLAYER, lParam
        .IF rax == TRUE
            Invoke MediaPlayerBrowseForFile, hMainWindow
            .IF rax == TRUE
                Invoke MediaPlayerOpenFile, hMainWindow, lpszMediaFileName
            .ENDIF
            Invoke SetFocus, hMediaPlayerWindow
        .ENDIF
        mov rax, 0
        ret        
    ;--------------------------------------------------------------------------
    ; Toggle Fullscreen
    ;--------------------------------------------------------------------------
    .ELSEIF eax == WM_GETDLGCODE
        mov rax, DLGC_WANTALLKEYS or DLGC_WANTARROWS
        ret

    .ELSEIF eax == WM_KEYDOWN
        .IF wParam == VK_F11
            Invoke GUIToggleFullscreen, hMainWindow
            mov rax, 0
            ret
        .ELSEIF wParam == VK_ESCAPE
            .IF g_Fullscreen == TRUE
                Invoke GUIFullscreenExit, hMainWindow
                mov rax, 0
                ret
            .ELSE
                Invoke DefWindowProc, hWin, uMsg, wParam, lParam
                ret
            .ENDIF
        .ELSE
            Invoke DefWindowProc, hWin, uMsg, wParam, lParam
            ret
        .ENDIF


    ;--------------------------------------------------------------------------
    ; Draw the background frame and logo
    ;--------------------------------------------------------------------------
    .ELSEIF eax == WM_ERASEBKGND
        mov rax, 1
        ret
    
    .ELSEIF eax == WM_PAINT
        Invoke GUIPaintBackground, hWin
        ret

    ;--------------------------------------------------------------------------
    ; Resizing of GUI and limiting of the minimum size
    ;--------------------------------------------------------------------------
    .ELSEIF eax == WM_SIZE
        Invoke GUIResize, hWin, wParam, lParam
        mov rax, 0
        ret
    
    .ELSEIF eax == WM_GETMINMAXINFO
        mov rbx, lParam
        mov [rbx].MINMAXINFO.ptMinTrackSize.x, 630
        mov [rbx].MINMAXINFO.ptMinTrackSize.y, 450
        mov rax, 0
        ret

    ;--------------------------------------------------------------------------
    ; For command line or shell explorer opening of a file
    ;--------------------------------------------------------------------------
    .ELSEIF eax == WM_WINDOWPOSCHANGED ; wait till window is shown and visible
        mov rbx, lParam
        mov eax, (WINDOWPOS ptr [rbx]).flags
        and eax, SWP_SHOWWINDOW
        .IF eax == SWP_SHOWWINDOW && g_Shown == FALSE
            mov g_Shown, TRUE
            Invoke PostMessage, hWin, WM_APP, 0, 0
        .ENDIF
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        xor eax, eax
        ret
        
    .ELSEIF eax == WM_APP ; process file from command line
        .IF CmdLineProcessFileFlag == 1
            Invoke MediaPlayerOpenFile, hMainWindow, Addr CmdLineFilename
        .ENDIF
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ret   

    ;--------------------------------------------------------------------------
    ; Show context menu
    ;--------------------------------------------------------------------------
    .ELSEIF eax == WM_CONTEXTMENU
        Invoke GUIIsClickInArea, hWin, MP_AREA_CM_PLAYER, lParam
        .IF rax == TRUE
            Invoke MPContextMenuTrack, hWin, wParam, lParam
        .ELSE
            Invoke DefWindowProc, hWin, uMsg, wParam, lParam
            ret
        .ENDIF

	.ELSEIF eax == WM_CLOSE
		Invoke DestroyWindow, hWin
		
    .ELSEIF eax == WM_DESTROY
        .IF pMP != 0
            Invoke MFPMediaPlayer_Free, Addr pMP
        .ENDIF
        Invoke IniSaveWindowPosition, hWin, Addr MediaPlayerIniFile
        Invoke PostQuitMessage, NULL
		
	.ELSE
		Invoke DefWindowProc, hWin, uMsg, wParam, lParam
		ret
	.ENDIF
	xor rax, rax
	ret
WndProc ENDP

;------------------------------------------------------------------------------
; GUIPaintBackground
;------------------------------------------------------------------------------
GUIPaintBackground PROC FRAME hWin:QWORD
    LOCAL ps:PAINTSTRUCT
    LOCAL rect:RECT
    LOCAL rectplayer:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:QWORD
    LOCAL hBufferBitmapOld:QWORD
    LOCAL hBrush:QWORD
    LOCAL hBrushOld:QWORD
    LOCAL xpos:DWORD
    LOCAL ypos:DWORD
    
    Invoke BeginPaint, hWin, Addr ps
    mov hdc, rax
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect                       ; Get dimensions of area to buffer
    Invoke CopyRect, Addr rectplayer, Addr rect
    Invoke CreateCompatibleDC, hdc                              ; Create memory dc for our buffer
    mov hdcMem, rax
    
    Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom ; Create bitmap of size that matches dimensions
    mov hBufferBitmap, rax
    Invoke SelectObject, hdcMem, hBufferBitmap                  ; Select our created buffer bitmap into our memory dc
    mov hBufferBitmapOld, rax
    
    ;----------------------------------------------------------
    ; Adjust rectlangles
    ;----------------------------------------------------------
    add rectplayer.left, MFPLAYER_LEFT
    inc rectplayer.left
    add rectplayer.top, MFPLAYER_TOP
    inc rectplayer.top
    sub rectplayer.right, MFPLAYER_RIGHT
    sub rectplayer.right, 2
    sub rectplayer.bottom, MFPLAYER_BOTTOM
    sub rectplayer.bottom, 2
    
    ;----------------------------------------------------------
    ; Draw background color first
    ;----------------------------------------------------------
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, rax
    Invoke SelectObject, hdcMem, hBrush
    mov hBrushOld, rax
    .IF g_Fullscreen == FALSE
        Invoke SetDCBrushColor, hdcMem, MAINWINDOW_BACKCOLOR
        Invoke FillRect, hdcMem, Addr rect, hBrush
    .ELSE
        Invoke SetDCBrushColor, hdcMem, MAINWINDOW_FS_BACKCOLOR
        Invoke FillRect, hdcMem, Addr rect, hBrush
    .ENDIF
    
    ;----------------------------------------------------------
    ; Use pattern brush to texture our background
    ;----------------------------------------------------------
    .IF hPatternBrush != 0
        Invoke SelectObject, hdcMem, hPatternBrush
        Invoke PatBlt, hdcMem, 0, 0, rect.right, rect.bottom, PATINVERT ;+ DSTINVERT
    .ENDIF
    
    ;----------------------------------------------------------
    ; Draw player background and frame
    ;----------------------------------------------------------
    Invoke SelectObject, hdcMem, hBrush
    mov hBrushOld, rax
    .IF g_Fullscreen == FALSE
        Invoke MPPaintGradient, hdcMem, Addr rectplayer, MFPLAYER_BACKCOLOR_FROM, MFPLAYER_BACKCOLOR_TO, 1
        Invoke SetDCBrushColor, hdcMem, MFPLAYER_BORDERCOLOR
        Invoke FrameRect, hdcMem, Addr rectplayer, hBrush
    .ELSE
        Invoke MPPaintGradient, hdcMem, Addr rectplayer, MFPLAYER_FS_BACKCOLOR_FROM, MFPLAYER_FS_BACKCOLOR_TO, 1
        Invoke SetDCBrushColor, hdcMem, MFPLAYER_FS_BORDERCOLOR
        Invoke FrameRect, hdcMem, Addr rectplayer, hBrush
    .ENDIF
    Invoke SelectObject, hdcMem, hBrushOld
    Invoke DeleteObject, hBrush
    
    ;----------------------------------------------------------
    ; Draw logo icon
    ;----------------------------------------------------------
    mov eax, rect.right
    sub eax, rect.left
    shr eax, 1
    
    mov ebx, 256
    shr ebx, 1
    
    sub eax, ebx
    mov xpos, eax
    
    mov eax, rectplayer.bottom
    sub eax, rectplayer.top
    shr eax, 1
    
    mov ebx, 256
    shr ebx, 1
    
    sub eax, ebx
    add eax, 20
    mov ypos, eax

    Invoke DrawIconEx, hdcMem, xpos, ypos, hIcoMFPlayer, 0, 0, 0, NULL, DI_NORMAL
    
    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Finish Double Buffering & Cleanup
    ;----------------------------------------------------------    

    Invoke SelectObject, hdcMem, hBufferBitmapOld
    Invoke DeleteObject, hBufferBitmap
    Invoke DeleteDC, hdcMem                                     ; Delete double buffer hdc
    
    Invoke EndPaint, hWin, Addr ps
    mov rax, 0

    ret
GUIPaintBackground ENDP

;------------------------------------------------------------------------------
; GUIInit - Initialize some GUI stuff
;------------------------------------------------------------------------------
GUIInit PROC FRAME hWin:QWORD
    LOCAL hVideoWindow:QWORD

    mov rax, hWin
    mov hMainWindow, rax
    
    Invoke IniFilenameCreate, Addr MediaPlayerIniFile, NULL
    Invoke IniInit
    
    Invoke GetWindowLongPtr, hWin, GWL_STYLE
    mov g_PrevStyle, rax
    
    Invoke GUISetTitleMediaLoaded, hWin, 0
    
    Invoke DragAcceptFiles, hWin, TRUE
    
    ;--------------------------------------------------------------------------
    ; Load and set icons
    ;--------------------------------------------------------------------------
    Invoke SendMessage, hWin, WM_SETICON, ICON_BIG, hIcoMain
    Invoke SendMessage, hWin, WM_SETICON, ICON_SMALL, hIcoMain
    Invoke LoadImage, hInstance, ICO_MFPLAYER, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR
    mov hIcoMFPlayer, rax
    
    ;--------------------------------------------------------------------------
    ; Load pattern for background
    ;--------------------------------------------------------------------------
    IFDEF MP_PATTERN_BACKGROUND
    Invoke LoadImage, hInstance, BMP_PATTERN, IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR
    mov hPatternBitmap, rax
    Invoke CreatePatternBrush, hPatternBitmap
    mov hPatternBrush, rax
    ENDIF
    
    ;--------------------------------------------------------------------------
    ; Menus
    ;--------------------------------------------------------------------------
    Invoke GetMenu, hWin
    mov hMediaPlayerMainMenu, rax
    
    Invoke MPMainMenuInit, hWin
    Invoke MPContextMenuInit, hWin
    
    Invoke LoadImage, hInstance, BMP_FILE_MRU, IMAGE_BITMAP, 0, 0, LR_SHARED or LR_DEFAULTCOLOR
    mov hBmpFileMRU, rax
    Invoke IniMRULoadListToMenu, hWin, Addr MediaPlayerIniFile, IDM_FILE_EXIT, hBmpFileMRU
    
    ;--------------------------------------------------------------------------
    ; Set Fonts 
    ;--------------------------------------------------------------------------
    Invoke CreateFont, -12, 0, 0, 0, FW_REGULAR, FALSE, FALSE, FALSE, 0, OUT_TT_PRECIS, 0, PROOF_QUALITY, 0, Addr szSegoeUIFont
    mov hPosDurFont, rax
    
    ;--------------------------------------------------------------------------
    ; MediaPlayerLabel
    ;--------------------------------------------------------------------------
    Invoke MediaPlayerLabelCreate, hWin, 10, 555, 70, 26, IDC_MFP_Position, 0
    mov hMFP_Position, rax
    
    Invoke MediaPlayerLabelCreate, hWin, 782, 555, 70, 26, IDC_MFP_Duration, DT_RIGHT
    mov hMFP_Duration, rax
    
    Invoke SendMessage, hMFP_Position, WM_SETFONT, hPosDurFont, TRUE
    Invoke SendMessage, hMFP_Duration, WM_SETFONT, hPosDurFont, TRUE
    
    ;--------------------------------------------------------------------------
    ; MediaPlayerControls from dialog
    ;--------------------------------------------------------------------------
    Invoke CreateDialogParam, hInstance, IDD_MediaPlayerControls, hWin, Addr MediaPlayerControlsProc, NULL
    mov hMediaPlayerControls, rax
    Invoke SetWindowPos, hMediaPlayerControls, 0, 150, 630, 0, 0, SWP_NOSIZE or SWP_NOZORDER
    
    ;--------------------------------------------------------------------------
    ; MediaPlayerWindow
    ;--------------------------------------------------------------------------
    Invoke MediaPlayerWindowCreate, hWin, 15, 20, 925, 630, IDC_MFPLAYER
    mov hMediaPlayerWindow, rax

    Invoke MFPMediaPlayer_Init, hMediaPlayerWindow, Addr MFP_OnMediaPlayerEvent, Addr pMP
    
    ;--------------------------------------------------------------------------
    ; MediaPlayerSeekBar
    ;--------------------------------------------------------------------------
    Invoke MediaPlayerSeekBarCreate, hWin, MFPLAYER_LEFT, 635, 924, 20, IDC_MFPTSB, 12 ; 12
    mov hMediaPlayerSeekBar, rax
    
    ;--------------------------------------------------------------------------
    ; MediaPlayerVolume
    ;--------------------------------------------------------------------------
    Invoke MediaPlayerVolumeCreate, hMPC_ToolbarVolume, 38, 1, 118, 34, IDC_MPC_VolumeSlider, 8
    mov hMPC_VolumeSlider, rax
    
    ;--------------------------------------------------------------------------
    ; Initialize some controls
    ;--------------------------------------------------------------------------
    Invoke MPSBInit, hMediaPlayerSeekBar, hMediaPlayerWindow, pMP, Addr GUIPositionUpdate, NULL
    Invoke MPVInit, hMPC_VolumeSlider, pMP
    
    Invoke IniLoadWindowPosition, hWin, Addr MediaPlayerIniFile
    
    ret
GUIInit ENDP

;------------------------------------------------------------------------------
; GUIResize - Resize GUI window and controls
;------------------------------------------------------------------------------
GUIResize PROC FRAME hWin:QWORD, wParam:QWORD, lParam:QWORD
    LOCAL dwClientWidth:DWORD
    LOCAL dwClientHeight:DWORD
    LOCAL dwControlsWidth:DWORD
    LOCAL dwControlsHeight:DWORD
    LOCAL dwPlayerWidth:DWORD
    LOCAL dwPlayerHeight:DWORD
    LOCAL dwPlayerWidth_:DWORD
    LOCAL dwPlayerHeight_:DWORD
    LOCAL dwXPos:DWORD
    LOCAL dwYPos:DWORD
    LOCAL dwHeight:DWORD
    LOCAL dwWidth:DWORD
    LOCAL rectplayer:RECT
    LOCAL rectcontrols:RECT
    LOCAL recttimeseekbar:RECT
    LOCAL recttime:RECT
    LOCAL rectduration:RECT
    LOCAL rect:RECT
    
    Invoke GetWindowRect, hMediaPlayerWindow, Addr rectplayer
    Invoke GetClientRect, hMediaPlayerControls, Addr rectcontrols
    Invoke ScreenToClient, hWin, Addr rectplayer
    Invoke GetClientRect, hMediaPlayerSeekBar, Addr recttimeseekbar
    Invoke GetClientRect, hMFP_Duration, Addr rectduration

    mov rax, lParam
    and rax, 0FFFFh
    mov dwClientWidth, eax
    mov rax, lParam
    shr rax, 16d
    mov dwClientHeight, eax
    
    .IF dwClientWidth == 0 && dwClientHeight == 0
        Invoke GetClientRect, hWin, Addr rect
        mov eax, rect.right
        sub eax, rect.left
        mov dwClientWidth, eax
        mov eax, rect.bottom
        sub eax, rect.top
        mov dwClientHeight, eax
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; MediaPlayer Window
    ;--------------------------------------------------------------------------
    mov eax, MFPLAYER_LEFT
    mov dwXPos, eax
    mov eax, MFPLAYER_TOP
    mov dwYPos, eax
    
    mov eax, dwClientWidth
    .IF g_Fullscreen == FALSE
        sub eax, MFPLAYER_LEFT
        sub eax, MFPLAYER_RIGHT
    .ENDIF
    mov dwPlayerWidth, eax
    sub dwPlayerWidth, 2
    
    mov eax, dwClientHeight
    sub eax, MFPLAYER_TOP
    sub eax, MFPLAYER_BOTTOM
    mov dwPlayerHeight, eax
    
    .IF g_Fullscreen == FALSE
        Invoke SetWindowPos, hMediaPlayerWindow, HWND_TOP, dwXPos, dwYPos, dwPlayerWidth, dwPlayerHeight, SWP_NOZORDER
    .ELSE
        mov eax, dwPlayerHeight
        add eax, MFPLAYER_TOP
        mov dwPlayerHeight_, eax
        
        mov eax, dwPlayerWidth
        add eax, 2
        mov dwPlayerWidth_, eax
        
        Invoke SetWindowPos, hMediaPlayerWindow, HWND_TOP, 0, 0, dwPlayerWidth_, dwPlayerHeight_, SWP_NOZORDER
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; MediaPlayer Seek Bar
    ;--------------------------------------------------------------------------
    mov eax, MFPLAYER_LEFT
    inc eax
    mov dwXPos, eax
    
    mov eax, dwPlayerHeight
    add eax, MFPLAYER_TOP
    add eax, 5
    mov dwYPos, eax
    
    mov eax, recttimeseekbar.bottom
    sub eax, recttimeseekbar.top
    mov dwHeight, eax
    mov dwPlayerHeight_, eax
    
    mov eax, dwClientWidth
    sub eax, MFPLAYER_LEFT
    sub eax, MFPLAYER_RIGHT
    mov dwPlayerWidth, eax
    sub dwPlayerWidth, 2
    mov eax, dwPlayerWidth
    dec eax
    mov dwPlayerWidth_, eax
    
    Invoke SetWindowPos, hMediaPlayerSeekBar, HWND_TOP, dwXPos, dwYPos, dwPlayerWidth_, dwPlayerHeight_, SWP_NOZORDER
    
    ;--------------------------------------------------------------------------
    ; MediaPlayer Controls
    ;--------------------------------------------------------------------------
    mov eax, rectcontrols.right
    sub eax, rectcontrols.left
    mov dwControlsWidth, eax
    
    mov eax, rectcontrols.bottom
    sub eax, rectcontrols.top
    mov dwControlsHeight, eax
    
    mov eax, dwPlayerWidth
    shr eax, 1
    mov ebx, dwControlsWidth
    shr ebx, 1
    sub eax, ebx
    add eax, MFPLAYER_LEFT
    mov dwXPos, eax
    
    mov eax, dwPlayerHeight
    add eax, MFPLAYER_TOP
    add eax, 25
    mov dwYPos, eax
    Invoke SetWindowPos, hMediaPlayerControls, HWND_TOP, dwXPos, dwYPos, 0, 0, SWP_NOSIZE or SWP_NOZORDER

    ;--------------------------------------------------------------------------
    ; MediaPlayer Time & Duration Edit Controls (Labels)
    ;--------------------------------------------------------------------------
    mov eax, dwPlayerHeight
    add eax, MFPLAYER_TOP
    add eax, 37
    mov dwYPos, eax

    mov eax, MFPLAYER_LEFT
    inc eax
    mov dwXPos, eax
    Invoke SetWindowPos, hMFP_Position, HWND_TOP, dwXPos, dwYPos, 0, 0, SWP_NOSIZE or SWP_NOZORDER
    
    mov ebx, rectduration.right
    sub ebx, rectduration.left

    mov eax, dwClientWidth
    sub eax, MFPLAYER_RIGHT
    sub eax, ebx
    mov dwXPos, eax
    dec dwXPos
    dec dwXPos
    dec dwXPos
    Invoke SetWindowPos, hMFP_Duration, HWND_TOP, dwXPos, dwYPos, 0, 0, SWP_NOSIZE or SWP_NOZORDER
    
    ;--------------------------------------------------------------------------
    ; Refresh controls that are using PatBlt
    ;--------------------------------------------------------------------------
    Invoke InvalidateRect, hMediaPlayerSeekBar, NULL, TRUE
    Invoke InvalidateRect, hMediaPlayerControls, NULL, TRUE
    Invoke InvalidateRect, hMFP_Position, NULL, TRUE
    Invoke InvalidateRect, hMFP_Duration, NULL, TRUE
    
    ret
GUIResize ENDP

;------------------------------------------------------------------------------
; GUISetDurationTime - Set text label showing duration of media item
;------------------------------------------------------------------------------
GUISetDurationTime PROC FRAME dwMilliseconds:DWORD
    LOCAL szDurationTime[32]:BYTE
    
    .IF dwMilliseconds != -1
        Invoke MFPConvertMSTimeToTimeString, dwMilliseconds, Addr szDurationTime, 1
        Invoke SetWindowText, hMFP_Duration, Addr szDurationTime
    .ELSE
        Invoke SetWindowText, hMFP_Duration, Addr szDurationTimeEmpty
    .ENDIF
 
    ret
GUISetDurationTime ENDP

;------------------------------------------------------------------------------
; GUISetPositionTime - set text label showing current position of media item
;------------------------------------------------------------------------------
GUISetPositionTime PROC FRAME dwMilliseconds:DWORD
    LOCAL szPositionTime[32]:BYTE
    
    .IF dwMilliseconds != -1
        Invoke MFPConvertMSTimeToTimeString, dwMilliseconds, Addr szPositionTime, 1
        Invoke SetWindowText, hMFP_Position, Addr szPositionTime
    .ELSE
        Invoke SetWindowText, hMFP_Position, Addr szPositionTimeEmpty
    .ENDIF
 
    ret
GUISetPositionTime ENDP

;------------------------------------------------------------------------------
; GUISetTitleMediaLoaded - Change title bar to show file loaded
;------------------------------------------------------------------------------
GUISetTitleMediaLoaded PROC FRAME hWin:QWORD, lpszMediaLoaded:QWORD
    Invoke lstrcpy, Addr TitleBuffer, Addr AppName
    .IF lpszMediaLoaded != 0
        Invoke lstrcat, Addr TitleBuffer, Addr szSpaceDashSpace
        Invoke MFP_JustFnameExt, lpszMediaLoaded, Addr szJustFilename
        Invoke lstrcat, Addr TitleBuffer, Addr szJustFilename
    .ENDIF
    Invoke SetWindowText, hWin, Addr TitleBuffer
    ret
GUISetTitleMediaLoaded ENDP

;------------------------------------------------------------------------------
; GUIToggleFullscreen - fullscreen enter and exit
;------------------------------------------------------------------------------
GUIToggleFullscreen PROC FRAME hWin:QWORD
    .IF g_Fullscreen == TRUE
        Invoke GUIFullscreenExit, hWin
    .ELSE
        Invoke GUIFullscreenEnter, hWin
    .ENDIF
    ret
GUIToggleFullscreen ENDP

;------------------------------------------------------------------------------
; GUIFullscreenEnter - fullscreen for current monitor
;------------------------------------------------------------------------------
GUIFullscreenEnter PROC FRAME hWin:QWORD
    LOCAL pt:POINT
    LOCAL qwStyle:QWORD
    LOCAL dwWidth:DWORD
    LOCAL dwHeight:DWORD
    LOCAL hMonitor:QWORD
    LOCAL mi:MONITORINFO
    
    ; https://stackoverflow.com/questions/2382464/win32-full-screen-and-hiding-taskbar
    ; https://www.codeproject.com/Questions/108841/How-to-hide-menu-bar
    ; https://stackoverflow.com/questions/7193197/is-there-a-graceful-way-to-handle-toggling-between-fullscreen-and-windowed-mode
    ; https://devblogs.microsoft.com/oldnewthing/20100412-00/?p=14353
    
    IFDEF DEBUG64
    ;PrintText 'GUIFullscreenEnter'
    ENDIF
    
    ;----------------------------------------------------------------------
    ; Get current monitor information
    ;----------------------------------------------------------------------
    Invoke RtlZeroMemory, Addr mi, SIZEOF MONITORINFO
    Invoke MonitorFromWindow, hWin, MONITOR_DEFAULTTONEAREST
    mov hMonitor, rax
    mov mi.cbSize, SIZEOF MONITORINFO
    Invoke GetMonitorInfo, hMonitor, Addr mi
    .IF rax == TRUE
        ;----------------------------------------------------------------------
        ; Save previous styles, menu and window placement
        ;----------------------------------------------------------------------
        Invoke GetWindowLongPtr, hWin, GWL_STYLE
        mov g_PrevStyle, rax
        Invoke GetWindowLongPtr, hWin, GWL_EXSTYLE
        mov g_PrevExStyle, rax
        Invoke GetMenu, hWin
        mov g_PrevMenu, rax
        mov g_wpPrev.iLength, SIZEOF WINDOWPLACEMENT
        Invoke GetWindowPlacement, hWin, Addr g_wpPrev
        Invoke IsZoomed, hWin
        mov g_WasMaximized, rax
        
        ;----------------------------------------------------------------------
        ; Set new fullscreen style
        ;----------------------------------------------------------------------
        Invoke SetMenu, hWin, NULL
        mov qwStyle, WS_POPUP or WS_VISIBLE
        Invoke SetWindowLongPtr, hWin, GWL_STYLE, qwStyle
        xor rax, rax
        mov eax, mi.rcMonitor.right
        sub eax, mi.rcMonitor.left
        mov dwWidth, eax
        xor rax, rax
        mov eax, mi.rcMonitor.bottom
        sub eax, mi.rcMonitor.top
        mov dwHeight, eax
        Invoke SetWindowPos, hWin, 0, mi.rcMonitor.left, mi.rcMonitor.top, dwWidth, dwHeight, SWP_FRAMECHANGED or SWP_NOACTIVATE ;or SWP_SHOWWINDOW or 
        
        mov g_Fullscreen, TRUE
        
        Invoke GUIResize, hWin, 0, 0
        Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke UpdateWindow, hWin

    .ENDIF
    
    ret
GUIFullscreenEnter ENDP

;------------------------------------------------------------------------------
; GUIFullscreenExit - restore from fullscreen
;------------------------------------------------------------------------------
GUIFullscreenExit PROC FRAME USES rbx hWin:QWORD
    LOCAL qwStyle:QWORD
    LOCAL dwWidth:DWORD
    LOCAL dwHeight:DWORD
    LOCAL rect:RECT
    
    IFDEF DEBUG64
    ;PrintText 'GUIFullscreenExit'
    ENDIF
    
    ;----------------------------------------------------------------------
    ; Reset to normal window style and position
    ;----------------------------------------------------------------------
    Invoke SetWindowLongPtr, hWin, GWL_STYLE, g_PrevStyle
    .IF g_PrevMenu != NULL
        Invoke SetMenu, hWin, g_PrevMenu
    .ENDIF
    Invoke SetWindowPlacement, hWin, Addr g_wpPrev
    Invoke SetWindowPos, hWin, 0, 0, 0, 0, 0, SWP_FRAMECHANGED or SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE
    Invoke SetWindowPos, hWin, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW or SWP_NOACTIVATE
    mov g_Fullscreen, FALSE

    Invoke GUIResize, hWin, 0, 0
    Invoke InvalidateRect, hWin, NULL, TRUE
    Invoke UpdateWindow, hWin
    
    ret
GUIFullscreenExit ENDP

;------------------------------------------------------------------------------
; GUIIsClickInArea (WM_LBUTTONUP & WM_LBUTTONDBLCLK)
;------------------------------------------------------------------------------
GUIIsClickInArea PROC FRAME USES rbx hWin:QWORD, qwArea:QWORD, lParam:QWORD
    LOCAL rect:RECT
    LOCAL rectplayer:RECT
    LOCAL rectlogo:RECT
    LOCAL pt:POINT
    
    IFDEF DEBUG64
    ;PrintText 'GUIIsClickInArea'
    ENDIF
    
    mov rax, lParam
    and rax, 0FFFFh
    mov pt.x, eax
    mov rax, lParam
    shr rax, 16d
    mov pt.y, eax
    
    .IF qwArea == MP_AREA_CM_PLAYER ; coming from WM_CONTEXT uses screen coords
        Invoke ScreenToClient, hWin, Addr pt
    .ENDIF
    
    Invoke GetClientRect, hWin, Addr rect
    Invoke CopyRect, Addr rectplayer, Addr rect
    Invoke CopyRect, Addr rectlogo, Addr rect
    
    add rectplayer.left, MFPLAYER_LEFT
    inc rectplayer.left
    add rectplayer.top, MFPLAYER_TOP
    inc rectplayer.top
    sub rectplayer.right, MFPLAYER_RIGHT
    sub rectplayer.right, 2
    sub rectplayer.bottom, MFPLAYER_BOTTOM
    sub rectplayer.bottom, 2
    
    mov eax, rect.right
    sub eax, rect.left
    shr eax, 1
    mov ebx, 256
    shr ebx, 1
    sub eax, ebx
    mov rectlogo.left, eax
    add eax, 256
    mov rectlogo.right, eax
    mov eax, rectplayer.bottom
    sub eax, rectplayer.top
    shr eax, 1
    mov ebx, 256
    shr ebx, 1
    sub eax, ebx
    add eax, 20
    mov rectlogo.top, eax
    add eax, 256
    mov rectlogo.bottom, eax
    
    mov rax, qwArea
    .IF rax == MP_AREA_PLAYER || rax == MP_AREA_CM_PLAYER ; player area
        Invoke PtInRect, Addr rectplayer, pt ;pt.x, pt.y
        
    .ELSEIF rax == MP_AREA_LOGO ; just the logo area
        Invoke PtInRect, Addr rectlogo, pt ;pt.x, pt.y
    
    .ELSE
        mov rax, FALSE
    .ENDIF
    
    ret
GUIIsClickInArea ENDP

;------------------------------------------------------------------------------
; MediaPlayerBrowseForFile
;------------------------------------------------------------------------------
MediaPlayerBrowseForFile PROC FRAME hWin:QWORD

    .IF qwFiles != 0 && lpszMediaFileName != 0
        Invoke GlobalFree, lpszMediaFileName
        mov lpszMediaFileName, 0
        mov qwFiles, 0
    .ENDIF
    
    Invoke FileOpenDialogA, NULL, NULL, NULL, NULL, 4, Addr FileSpecs, hWin, FALSE, Addr qwFiles, Addr lpszMediaFileName
    .IF eax == TRUE
        .IF qwFiles != 0 && lpszMediaFileName != 0
            mov eax, TRUE
        .ELSE
            mov eax, FALSE
        .ENDIF
    .ENDIF
    ret
MediaPlayerBrowseForFile ENDP

;------------------------------------------------------------------------------
; MediaPlayerOpenFile
;------------------------------------------------------------------------------
MediaPlayerOpenFile PROC FRAME hWin:QWORD, lpszMediaFile:QWORD
    LOCAL dwState:DWORD
    .IF pMP != 0
        Invoke MFPMediaPlayer_GetState, pMP, Addr dwState
        .IF rax == TRUE 
            .IF dwState == MFP_MEDIAPLAYER_STATE_PLAYING
                Invoke MFPMediaPlayer_Stop, pMP
            .ENDIF
            .IF pMI != 0
                Invoke MFPMediaPlayer_ClearMediaItem, pMP
                Invoke MFPMediaItem_Release, pMI
                mov pMI, 0
            .ENDIF
            Invoke MFPMediaPlayer_CreateMediaItemA, pMP, lpszMediaFile, 0, Addr pMI
            .IF rax == TRUE
                Invoke MFPMediaPlayer_SetMediaItem, pMP, pMI
                Invoke SetFocus, hMediaPlayerWindow
                Invoke GUISetTitleMediaLoaded, hWin, lpszMediaFile
                
                ; Update MRU
                Invoke IniMRUEntrySaveFilename, hWin, lpszMediaFile, Addr MediaPlayerIniFile
                Invoke IniMRUReloadListToMenu, hWin, Addr MediaPlayerIniFile, IDM_FILE_EXIT, hBmpFileMRU
                
            .ELSE
                Invoke GUISetTitleMediaLoaded, hWin, 0
                Invoke GUISetDurationTime, -1
                Invoke GUISetPositionTime, -1
            .ENDIF
        .ENDIF
    .ENDIF

    ret
MediaPlayerOpenFile ENDP

;------------------------------------------------------------------------------
; MFP_OnMediaPlayerEvent - Notification event callback for when the media 
; player does something: loads a media item, play, pause, step, stop etc
;------------------------------------------------------------------------------
MFP_OnMediaPlayerEvent PROC FRAME USES RBX lpThis:QWORD, pEventHeader:QWORD
    LOCAL pbFeature:DWORD
    LOCAL pbSelected:DWORD
    LOCAL pMediaItem:QWORD
    
    mov rbx, pEventHeader
    mov eax, dword ptr [rbx].MFP_EVENT_HEADER.eEventType
    
    .IF eax == MFP_EVENT_TYPE_PLAY
        IFDEF DEBUG64
        PrintText 'MFP_EVENT_TYPE_PLAY'
        ENDIF
        mov g_Playing, TRUE
        Invoke GUISetDurationTime, dwDurationTimeMS
        Invoke GUISetPositionTime, dwPositionTimeMS
        Invoke MPSBStart, hMediaPlayerSeekBar
        Invoke MediaPlayerControlsUpdate, hMediaPlayerControls

    .ELSEIF eax == MFP_EVENT_TYPE_PAUSE
        IFDEF DEBUG64
        PrintText 'MFP_EVENT_TYPE_PAUSE'
        ENDIF
        Invoke MediaPlayerControlsUpdate, hMediaPlayerControls
        
    .ELSEIF eax == MFP_EVENT_TYPE_STOP
        IFDEF DEBUG64
        PrintText 'MFP_EVENT_TYPE_STOP'
        ENDIF
        mov g_Playing, FALSE
        mov dwPositionTimeMS, 0
        Invoke MPSBStop, hMediaPlayerSeekBar
        Invoke MediaPlayerControlsUpdate, hMediaPlayerControls

    .ELSEIF eax == MFP_EVENT_TYPE_POSITION_SET

    .ELSEIF eax == MFP_EVENT_TYPE_RATE_SET

    .ELSEIF eax == MFP_EVENT_TYPE_MEDIAITEM_CREATED
        IFDEF DEBUG64
        PrintText 'MFP_EVENT_TYPE_MEDIAITEM_CREATED'
        ENDIF
        mov rbx, pEventHeader
        mov rax, [rbx].MFP_MEDIAITEM_CREATED_EVENT.pMediaItem
        mov pMediaItem, rax
        Invoke MFPMediaItem_HasVideo, pMediaItem, Addr pbFeature, Addr pbSelected
        .IF rax == FALSE || pbFeature == FALSE
            Invoke MFPMediaItem_HasAudio, pMediaItem, Addr pbFeature, Addr pbSelected
            .IF rax == TRUE && pbFeature == TRUE ; just an audio track
                IFDEF DEBUG64
                PrintText 'Audio Track Loaded'
                ENDIF
            .ENDIF
        .ENDIF

    .ELSEIF eax == MFP_EVENT_TYPE_MEDIAITEM_SET
        IFDEF DEBUG64
        PrintText 'MFP_EVENT_TYPE_MEDIAITEM_SET'
        ENDIF
        mov rbx, pEventHeader
        mov rax, [rbx].MFP_MEDIAITEM_SET_EVENT.pMediaItem
        mov pMediaItem, rax
        Invoke MFPMediaItem_HasVideo, pMediaItem, Addr pbFeature, Addr pbSelected
        .IF rax == FALSE || pbFeature == FALSE
            Invoke MFPMediaItem_HasAudio, pMediaItem, Addr pbFeature, Addr pbSelected
            .IF rax == TRUE && pbFeature == TRUE ; just an audio track
                IFDEF DEBUG64
                PrintText 'Audio Track Loaded '
                ENDIF
            .ENDIF
        .ENDIF
        
        Invoke MFPMediaPlayer_GetDuration, pMP, Addr dwDurationTimeMS
        .IF rax == TRUE
            Invoke GUISetDurationTime, dwDurationTimeMS
            Invoke GUISetPositionTime, 0
            mov dwPositionTimeMS, 0
            Invoke MPSBSetDurationMS, hMediaPlayerSeekBar, dwDurationTimeMS
            Invoke MPSBSetPositionMS, hMediaPlayerSeekBar, 0
        .ELSE
            Invoke GUISetDurationTime, -1
            Invoke GUISetPositionTime, -1
        .ENDIF
        Invoke MFPMediaPlayer_Play, pMP

    .ELSEIF eax == MFP_EVENT_TYPE_FRAME_STEP
        IFDEF DEBUG64
        PrintText 'MFP_EVENT_TYPE_FRAME_STEP'
        ENDIF
        Invoke MediaPlayerControlsUpdate, hMediaPlayerControls

    .ELSEIF eax == MFP_EVENT_TYPE_MEDIAITEM_CLEARED
        IFDEF DEBUG64
        PrintText 'MFP_EVENT_TYPE_MEDIAITEM_CLEARED'
        ENDIF

    .ELSEIF eax == MFP_EVENT_TYPE_MF

    .ELSEIF eax == MFP_EVENT_TYPE_ERROR
        IFDEF DEBUG64
        PrintText 'MFP_EVENT_TYPE_ERROR'
        ENDIF

    .ELSEIF rax == MFP_EVENT_TYPE_PLAYBACK_ENDED
        IFDEF DEBUG64
        PrintText 'MFP_EVENT_TYPE_PLAYBACK_ENDED'
        ENDIF
        ;Invoke MPSBStop, hMediaPlayerSeekBar
        ;Invoke MediaPlayerControlsUpdate, hMediaPlayerControls
        Invoke MFPMediaPlayer_Stop, pMP

    .ELSEIF eax == MFP_EVENT_TYPE_ACQUIRE_USER_CREDENTIAL
        
    .ENDIF
    xor rax, rax
    ret
MFP_OnMediaPlayerEvent ENDP

;------------------------------------------------------------------------------
; GUIPositionUpdate - called from the MediaPlayerSeekBar control via the timer
; in the _MPSBTimerProc at specific intervals.
;------------------------------------------------------------------------------
GUIPositionUpdate PROC FRAME dwPositionMS:DWORD, lParam:QWORD
    Invoke GUISetPositionTime, dwPositionMS
    ret
GUIPositionUpdate ENDP

;------------------------------------------------------------------------------
; MFP_JustFnameExt - Strip filepath name to just filename with extension.
;------------------------------------------------------------------------------
MFP_JustFnameExt PROC FRAME USES RSI RDI szFilePathName:QWORD, szFileName:QWORD
    LOCAL LenFilePathName:QWORD
    LOCAL nPosition:QWORD
    
    Invoke lstrlen, szFilePathName
    mov LenFilePathName, rax
    mov nPosition, rax
    
    .IF LenFilePathName == 0
        mov rdi, szFileName
        mov byte ptr [rdi], 0
        mov rax, FALSE
        ret
    .ENDIF
    
    mov rsi, szFilePathName
    add rsi, rax
    
    mov rax, nPosition
    .WHILE rax != 0
        movzx eax, byte ptr [rsi]
        .IF al == '\' || al == ':' || al == '/'
            inc rsi
            .BREAK
        .ENDIF
        dec rsi
        dec nPosition
        mov rax, nPosition
    .ENDW
    mov rdi, szFileName
    mov rax, nPosition
    .WHILE rax != LenFilePathName
        movzx eax, byte ptr [rsi]
        mov byte ptr [rdi], al
        inc rdi
        inc rsi
        inc nPosition
        mov rax, nPosition
    .ENDW
    mov byte ptr [rdi], 0h ; null out filename
    
    mov rax, TRUE
    ret
MFP_JustFnameExt ENDP

;------------------------------------------------------------------------------
; MPPaintGradient - MediaPlayer PaintGradient
;
; Paint a Gradient in a rectangle in a dc 
;------------------------------------------------------------------------------
MPPaintGradient PROC FRAME USES RBX hdc:QWORD, lpGradientRect:QWORD, GradientColorFrom:DWORD, GradientColorTo:DWORD, HorzVertGradient:DWORD
    LOCAL hBrush:QWORD
    LOCAL clrRed:DWORD
    LOCAL clrGreen:DWORD
    LOCAL clrBlue:DWORD
    LOCAL mesh:GRADIENT_RECT
    LOCAL vertex[3]:TRIVERTEX
    
    mov eax, GradientColorFrom
    .IF eax == GradientColorTo
        Invoke CreateSolidBrush, GradientColorFrom
        mov hBrush, rax
        Invoke FillRect, hdc, lpGradientRect, hBrush
        Invoke DeleteObject, hBrush
        ret
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Seperate GradientFrom ColorRef to 3 dwords for Red, Green & Blue
    ;--------------------------------------------------------------------------
    mov eax, GradientColorFrom
    xor ebx, ebx
    mov bh, al
    mov clrRed, ebx
    xor ebx, ebx
    mov bh, ah
    mov clrGreen, ebx
    xor ebx, ebx
    shr eax, 16d
    mov bh, al
    mov clrBlue, ebx

    ;--------------------------------------------------------------------------
    ; Populate vertex 1 structure
    ;-------------------------------------------------------------------------- 
    ; fill x from rect left
    mov rbx, lpGradientRect
    mov eax, [rbx].RECT.left
    lea rbx, vertex ; point to 1st vertex
    mov [rbx].TRIVERTEX.x, eax

    ; fill y from rect top
    mov rbx, lpGradientRect
    mov eax, [rbx].RECT.top
    lea rbx, vertex ; point to 1st vertex
    mov [rbx].TRIVERTEX.y, eax

    ; fill colors from seperated colorref
    mov [rbx].TRIVERTEX.Alpha, 0
    mov eax, clrRed
    mov [rbx].TRIVERTEX.Red, ax
    mov eax, clrGreen
    mov [rbx].TRIVERTEX.Green, ax
    mov eax, clrBlue
    mov [rbx].TRIVERTEX.Blue, ax

    ;--------------------------------------------------------------------------
    ; Seperate GradientFrom ColorRef to 3 dwords for Red, Green & Blue
    ;--------------------------------------------------------------------------   
    mov eax, GradientColorTo
    xor rbx, rbx
    mov bh, al
    mov clrRed, ebx
    xor rbx, rbx
    mov bh, ah
    mov clrGreen, ebx
    xor rbx, rbx
    shr eax, 16d
    mov bh, al
    mov clrBlue, ebx    

    ;--------------------------------------------------------------------------
    ; Populate vertex 2 structure
    ;--------------------------------------------------------------------------
    ; fill x from rect right
    mov rbx, lpGradientRect
    mov eax, [rbx].RECT.right
    lea rbx, vertex
    add rbx, sizeof TRIVERTEX ; point to 2nd vertex
    mov [rbx].TRIVERTEX.x, eax
    
    ; fill x from rect right
    mov rbx, lpGradientRect
    mov eax, [rbx].RECT.bottom
    lea rbx, vertex
    add rbx, sizeof TRIVERTEX ; point to 2nd vertex
    mov [rbx].TRIVERTEX.y, eax
    
    ; fill colors from seperated colorref
    mov [rbx].TRIVERTEX.Alpha, 0
    mov eax, clrRed
    mov [rbx].TRIVERTEX.Red, ax
    mov eax, clrGreen
    mov [rbx].TRIVERTEX.Green, ax
    mov eax, clrBlue
    mov [rbx].TRIVERTEX.Blue, ax

    ;--------------------------------------------------------------------------
    ; Set the mesh (gradient rectangle) point
    ;--------------------------------------------------------------------------
    mov mesh.UpperLeft, 0
    mov mesh.LowerRight, 1

    ;--------------------------------------------------------------------------
    ; Call GradientFill function
    ;--------------------------------------------------------------------------
    Invoke GradientFill, hdc, Addr vertex, 2, Addr mesh, 1, HorzVertGradient ; Horz = 0, Vert = 1

    ret
MPPaintGradient ENDP

IFDEF MP_PATTERN_BACKGROUND
;------------------------------------------------------------------------------
; MPBrushOrgs
;
; Get brush org co-ordinates relative to controls root ancestor.
;
; Used in SetBrushOrgEx calls for setting offsets of a brush to paint with
; in a control relative to its placement within a parent. The parent is painted 
; with the same brush. Using this for a texture/pattern/brush will appear as if
; it is seamless when applied to all controls backgrounds.
;
; Parameters:
;
; * hControl - handle to the control/window to get the brush coordinates for
; 
; * hdc - dc to adjust. Optional can be null.
;
; * lpdwBrushOrgX - pointer to a DWORD variable to store the Brush Org X coord 
;
; * lpdwBrushOrgY - pointer to a DWORD variable to store the Brush Org Y coord 
;
; Returns:
;
; TRUE if successful or FALSE otherwise.
;
; Notes:
;
; After painting an area with a brush. FillRect, PatBlt etc, that you have 
; adjusted with SetBrushOrgEx (or if you specify a hdc parameter in this 
; function which calls SetBrushOrgEx for you), you should reset the brush
; coords with a call to SetBrushOrgEx like so:
;
; Invoke SetBrushOrgEx, dc_just_used, 0, 0, 0 ; reset the brush origin  
;
; Example:

;    Invoke MPBrushOrgs, hWin, hdcMem, 0, 0
;    Invoke SelectObject, hdcMem, hPatternBrush
;    Invoke PatBlt, hdcMem, 0, 0, rect.right, rect.bottom, PATINVERT
;    Invoke SetBrushOrgEx, hdcMem, 0, 0, 0 ; reset the brush origin 
;
;------------------------------------------------------------------------------
MPBrushOrgs PROC FRAME USES RBX hControl:QWORD, dc:QWORD, lpdwBrushOrgX:QWORD, lpdwBrushOrgY:QWORD
    LOCAL rect:RECT
    LOCAL hParent:QWORD
    LOCAL dwBrushOrgX:DWORD
    LOCAL dwBrushOrgY:DWORD
    
    .IF hControl == 0
        mov rax, FALSE
        ret
    .ENDIF
    
    Invoke GetWindowRect, hControl, Addr rect
    Invoke GetAncestor, hControl, GA_ROOT
    mov hParent, rax
    Invoke MapWindowPoints, HWND_DESKTOP, hParent, Addr rect, 2
    mov eax, rect.left
    neg eax
    mov dwBrushOrgX, eax
    mov eax, rect.top
    neg eax
    mov dwBrushOrgY, eax
    
    .IF lpdwBrushOrgX != 0
        mov rbx, lpdwBrushOrgX
        mov eax, dwBrushOrgX
        mov [rbx], eax
    .ENDIF
    .IF lpdwBrushOrgY != 0
        mov rbx, lpdwBrushOrgY
        mov eax, dwBrushOrgY
        mov [rbx], eax
    .ENDIF
    .IF dc != 0
        Invoke SetBrushOrgEx, dc, dwBrushOrgX, dwBrushOrgY, 0
    .ENDIF
    
    mov eax, TRUE
    ret
MPBrushOrgs ENDP
ENDIF


;------------------------------------------------------------------------------
; CmdLineProcess - has user passed a file at the command line 
;------------------------------------------------------------------------------
CmdLineProcess PROC FRAME
    Invoke getcl_ex, 1, Addr CmdLineFilename
    .IF rax == 1
        mov CmdLineProcessFileFlag, 1 ; filename specified, attempt to open it
    .ELSE
        mov CmdLineProcessFileFlag, 0 ; do nothing, continue as normal
    .ENDIF
    ret
CmdLineProcess ENDP




end WinMainCRTStartup
