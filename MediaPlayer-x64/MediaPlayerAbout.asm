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

MediaPlayerAboutDlgProc         PROTO hWin:HWND, iMsg:DWORD, wParam:WPARAM, lParam:LPARAM

;--------------------------------------
; Resource IDs for AboutDlg.dlg dialog
;--------------------------------------
IDD_AboutDlg                    EQU 17000
IDC_ABOUT_EXIT                  EQU 17001
IDC_ABOUT_BANNER                EQU 17002
IDC_WEBSITE_URL                 EQU 17003
IDC_TxtInfo                     EQU 17004
IDC_TxtVersion                  EQU 17005

.DATA
mrfearless_github               DB "https://github.com/mrfearless",0
szShellOpen                     DB "open",0
szAboutBoxInfoText              DB "MediaPlayer uses the custom MFPlayer.lib library functions,",13,10
                                DB "which wrap the methods of the MFPlay COM Objects: ",13,10
                                DB "IMFMediaPlayer and IMFMediaItem.",13,10,13,10
                                DB "MFPlay is a Microsoft Media Foundation API",13,10
                                DB "for creating media playback applications.",0

.DATA?
hWebsiteURL                     DQ ?
hAboutBanner                    DQ ?
hTxtInfo                        DQ ?
hTxtVersion                     DQ ?



.CODE
;------------------------------------------------------------------------------
; MediaPlayer About Dialog Procedure
;------------------------------------------------------------------------------
MediaPlayerAboutDlgProc PROC FRAME USES RBX hWin:HWND, iMsg:DWORD, wParam:WPARAM, lParam:LPARAM
    ; SS_NOTIFY equ 00000100h in resource editor - in radasm resource editor directly edit dword value to get this added to static control
    LOCAL hFont:QWORD
    LOCAL lfnt:LOGFONT
    
    mov eax, iMsg
    .IF eax == WM_INITDIALOG
        Invoke SendMessage, hWin, WM_SETICON, ICON_SMALL, hIcoMain
        .IF rax != NULL
            Invoke DeleteObject, rax
        .ENDIF
        Invoke SendDlgItemMessage, hWin, IDC_ABOUT_BANNER,  STM_SETIMAGE, IMAGE_ICON, hIcoMFPlayer
        .IF rax != NULL
            Invoke DeleteObject, rax
        .ENDIF
        
        Invoke GetDlgItem, hWin, IDC_WEBSITE_URL
        mov hWebsiteURL, rax
        Invoke GetDlgItem, hWin, IDC_TxtInfo
        mov hTxtInfo, rax
        Invoke GetDlgItem, hWin, IDC_TxtVersion
        mov hTxtVersion, rax
        Invoke GetDlgItem, hWin, IDC_ABOUT_BANNER
        mov hAboutBanner, rax

        Invoke SetWindowText, hTxtInfo, Addr szAboutBoxInfoText
        
        ;----------------------------------------------------------------------
        ; Change class for these controls to show a hand when mouse over.
        ; These controls also have SS_NOTIFY equ 00000100h set so they will
        ; respond to a mouse click and send a WM_COMMAND message which allows
        ; us to fake a hyperlink to open browser at desired website
        ;----------------------------------------------------------------------
        Invoke LoadCursor, 0, IDC_HAND
        Invoke SetClassLongPtr, hWebsiteURL, GCL_HCURSOR, rax
        Invoke LoadCursor, 0, IDC_HAND
        Invoke SetClassLongPtr, hAboutBanner, GCL_HCURSOR, rax
        
    .ELSEIF eax == WM_CTLCOLORDLG
        invoke SetBkMode, wParam, WHITE_BRUSH
        invoke GetStockObject, WHITE_BRUSH
        ret
        
    .ELSEIF eax == WM_CTLCOLORSTATIC ; set to transparent background for listed controls
        mov rax, lParam
        .IF rax == hWebsiteURL || rax == hTxtInfo || rax == hTxtVersion
            Invoke SetTextColor, wParam, 0h ;0FFFFFFh
            Invoke SetBkMode, wParam, OPAQUE
            Invoke GetStockObject, WHITE_BRUSH
            ret
       .ENDIF
        
    .ELSEIF eax == WM_CLOSE
        Invoke EndDialog, hWin, NULL
        
    .ELSEIF eax == WM_COMMAND
        mov rax, wParam
        and rax, 0FFFFh
        .IF eax == IDC_ABOUT_EXIT
            Invoke SendMessage, hWin, WM_CLOSE, NULL, NULL
        .ENDIF
        mov rax, lParam
        .IF rax == hWebsiteURL || rax == hAboutBanner
            Invoke ShellExecute, hWin, Addr szShellOpen, Addr mrfearless_github, NULL, NULL, SW_SHOW
        .ENDIF
    .ELSE
        mov rax, FALSE
        ret
    .ENDIF
    
    mov rax, TRUE
    ret
MediaPlayerAboutDlgProc ENDP


