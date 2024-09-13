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

; https://sample-videos.com/

include windows.inc
include CommCtrl.inc
include shellapi.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib shell32.lib

include shlwapi.inc
includelib shlwapi.lib

include msimg32.inc
includelib msimg32.lib

include UASM64.Inc
includelib UASM64.lib

include FileDialog.inc
includelib FileDialog.lib

include MFPlayer.inc
includelib MFPlayer.lib

RGB MACRO red:REQ, green:REQ, blue:REQ
    EXITM < red or green shl 8 or blue shl 16 >
ENDM

MAKELANGID MACRO usPrimaryLanguage:REQ, usSubLanguage:REQ
    EXITM < (usSubLanguage SHL 10) OR (usPrimaryLanguage) >
ENDM

;------------------------------------------------------------------------------
; MediaPlayer Prototypes
;------------------------------------------------------------------------------
GUIPaintBackground          PROTO hWin:QWORD
GUIPaintStatics             PROTO hWin:QWORD, lParam:QWORD, wParam:QWORD

GUIInit                     PROTO hWin:QWORD
GUIResize                   PROTO hWin:QWORD, wParam:QWORD, lParam:QWORD
GUIAllowDragDrop            PROTO bAllow:QWORD

GUISetDurationTime          PROTO dwMilliseconds:DWORD
GUISetPositionTime          PROTO dwMilliseconds:DWORD
GUIPositionUpdate           PROTO dwPositionMS:DWORD, lParam:QWORD
GUISetTitleMediaLoaded      PROTO hWin:QWORD, lpszMediaLoaded:QWORD

GUIToggleFullscreen         PROTO hWin:QWORD
GUIFullscreenEnter          PROTO hWin:QWORD
GUIFullscreenExit           PROTO hWin:QWORD

GUIIsClickInArea            PROTO hWin:QWORD, qwArea:QWORD, lParam:QWORD

GUILanguageChange           PROTO hWin:QWORD

MediaPlayerBrowseForFile    PROTO hWin:QWORD
MediaPlayerOpenFile         PROTO hWin:QWORD, lpszMediaFile:QWORD
MediaPlayerContextMenu      PROTO hWin:QWORD, wParam:WPARAM, lParam:LPARAM

MediaPlayerInitEngine       PROTO hWin:QWORD

MFP_OnMediaPlayerEvent      PROTO pThis:QWORD, pEventHeader:QWORD  

MFP_JustFnameExt            PROTO szFilePathName:QWORD, szFileName:QWORD

MPPaintGradient             PROTO hdc:QWORD, lpGradientRect:QWORD, GradientColorFrom:DWORD, GradientColorTo:DWORD, HorzVertGradient:DWORD
MPBrushOrgs                 PROTO hControl:QWORD, hdc:QWORD, lpdwBrushOrgX:QWORD, lpdwBrushOrgY:QWORD

CmdLineProcess              PROTO ; Process cmd line parameters to handle opening file from cmdline or shell explorer

IFNDEF DragFinish
DragFinish PROTO hDrop:QWORD 
ENDIF

; ChangeWindowMessageFilter Prototype
ChangeWindowMessageFilter_Proto TYPEDEF PROTO message:DWORD, dwFlag:DWORD
ChangeWindowMessageFilter_Ptr TYPEDEF PTR ChangeWindowMessageFilter_Proto

; ChangeWindowMessageFilter dwFlag:
IFNDEF MSGFLT_ADD
MSGFLT_ADD EQU 1 ; Adds the message to the filter. This has the effect of allowing the message to be received.
ENDIF
IFNDEF MSGFLT_REMOVE
MSGFLT_REMOVE EQU 2 ; Removes the message from the filter. This has the effect of blocking the message.
ENDIF 

; For Drag and Drop support
IFNDEF WM_DROPFILES
WM_DROPFILES EQU 0233h
ENDIF
IFNDEF WM_COPYDATA
WM_COPYDATA EQU 004Ah
ENDIF
IFNDEF WM_COPYGLOBALDATA
WM_COPYGLOBALDATA EQU 0049h
ENDIF

;--------------------------------------
; Structures for Gradient usage
;--------------------------------------
IFNDEF TRIVERTEX
TRIVERTEX STRUCT
  x       DWORD ?
  y       DWORD ?
  Red     WORD ?
  Green   WORD ?
  Blue    WORD ?
  Alpha   WORD ?
TRIVERTEX ENDS
ENDIF

IFNDEF GRADIENT_TRIANGLE
GRADIENT_TRIANGLE STRUCT
  Vertex1         DWORD ?
  Vertex2         DWORD ?
  Vertex3         DWORD ?
GRADIENT_TRIANGLE ENDS
ENDIF

IFNDEF GRADIENT_RECT
GRADIENT_RECT STRUCT
  UpperLeft   DWORD ?
  LowerRight  DWORD ?
GRADIENT_RECT ENDS
ENDIF

IFNDEF COMDLG_FILTERSPEC
COMDLG_FILTERSPEC STRUCT
    pszName       DQ ?
    pszSpec       DQ ?
COMDLG_FILTERSPEC ENDS
ENDIF

IFNDEF WINDOWPLACEMENT
WINDOWPLACEMENT	     STRUCT 
    iLength	         DWORD ?
    flags	         DWORD ?
    showCmd	         DWORD ?
    ptMinPosition	 POINT <>
    ptMaxPosition	 POINT <>
    rcNormalPosition RECT <>
    rcDevice	     RECT <>
WINDOWPLACEMENT	     ENDS
ENDIF

.CONST
;------------------------------------------------------------------------------
; MediaPlayer Constants
;------------------------------------------------------------------------------
ICO_MAIN                EQU 100
ICO_MFPLAY_VIDEO        EQU 101
ICO_MFPLAY_AUDIO        EQU 102
BMP_PATTERN             EQU 103
BMP_FILE_MRU            EQU 104
BMP_FILE_MRU_CLEAR      EQU 105

; Main Dialog
IDD_DIALOG				EQU 1000
IDC_MFPLAYER			EQU 1002
IDC_MFPTSB              EQU 1003
IDC_MFP_Position	    EQU 1010
IDC_MFP_Duration	    EQU 1011

; Accelerators
ACCTABLE				EQU 900
ACC_FILE_OPEN			EQU 901
ACC_FILE_EXIT			EQU 902
ACC_MC_STOP				EQU 903
ACC_MC_PLAY				EQU 904
ACC_MC_STEP10F			EQU 905
ACC_MC_STEP10B			EQU 906
ACC_MC_SLOWER           EQU 907
ACC_MC_FASTER           EQU 908
ACC_MC_FULLSCREEN       EQU 909

MFPLAYER_LEFT           EQU 10 ;9;14
MFPLAYER_TOP            EQU 10 ;15;20
MFPLAYER_RIGHT          EQU 10 ;9;14
MFPLAYER_BOTTOM         EQU 78 ;110

MAINWINDOW_BACKCOLOR    EQU RGB(220,220,220)
MAINWINDOW_FS_BACKCOLOR EQU RGB(91,91,91)


MFPLAYER_BORDERCOLOR    EQU RGB(68,68,68)
MFPLAYER_FS_BORDERCOLOR EQU RGB(140,140,140)

MFPLAYER_BACKCOLOR      EQU RGB(212,229,238)
MFPLAYER_FS_BACKCOLOR   EQU RGB(22,43,55)

MFPLAYER_BACKCOLOR_FROM EQU RGB(250,250,250)
MFPLAYER_BACKCOLOR_TO   EQU RGB(212,229,238)

MFPLAYER_FS_BACKCOLOR_FROM EQU RGB(128,128,128)
MFPLAYER_FS_BACKCOLOR_TO   EQU RGB(22,43,55)

MP_AREA_PLAYER          EQU 0
MP_AREA_LOGO            EQU 1
MP_AREA_CM_PLAYER       EQU 2

MFP_DEFAULT_RATE        EQU 1000 ; x1
MPF_MAX_RATE            EQU 4000 ; x4
MPF_MIN_RATE            EQU 125

.DATA
;------------------------------------------------------------------------------
; MediaPlayer Initialized Data
;------------------------------------------------------------------------------
IFDEF __UNICODE__
ClassName               DB 'D',0,'L',0,'G',0,'C',0,'L',0,'A',0,'S',0,'S',0
                        DB 0,0,0,0
AppName                 DB 'M',0,'e',0,'d',0,'i',0,'a',0,'P',0,'l',0,'a',0,'y',0,'e',0,'r',0
                        DB 0,0,0,0
szSegoeUIFont           DB 'S',0,'e',0,'g',0,'o',0,'e',0,' ',0,'U',0,'I',0
                        DB 0,0,0,0
szDurationTimeEmpty     DB '-',0,'-',0,':',0,'-',0,'-',0
                        DB 0,0,0,0
szPositionTimeEmpty     DB '-',0,'-',0,':',0,'-',0,'-',0
                        DB 0,0,0,0
szSpaceDashSpace        DB ' ',0,'-',0,' ',0
                        DB 0,0,0,0
szUser32dll             DB 'U',0,'s',0,'e',0,'r',0,'3',0,'2',0,'.',0,'d',0,'l',0,'l',0 
                        DB 0,0,0,0
szCMF                   DB 'C',0,'h',0,'a',0,'n',0,'g',0,'e',0
                        DB 'W',0,'i',0,'n',0,'d',0,'o',0,'w',0
                        DB 'M',0,'e',0,'s',0,'s',0,'a',0,'g',0,'e',0
                        DB 'F',0,'i',0,'l',0,'t',0,'e',0,'r',0
                        DB 0,0,0,0
                        
szRatex0125             DB " ",0,"[",0,"x",0,"0",0,".",0,"1",0,"2",0,"5",0,"]",0
                        DB 0,0,0,0
szRatex025              DB " ",0,"[",0,"x",0,"0",0,".",0,"2",0,"5",0,"]",0
                        DB 0,0,0,0
szRatex05               DB " ",0,"[",0,"x",0,"0",0,".",0,"5",0,"]",0
                        DB 0,0,0,0
szRatex2                DB " ",0,"[",0,"x",0,"2",0,"]",0
                        DB 0,0,0,0
szRatex4                DB " ",0,"[",0,"x",0,"4",0,"]",0
                        DB 0,0,0,0

ELSE
ClassName               DB 'DLGCLASS',0
AppName                 DB 'MediaPlayer',0
szSegoeUIFont           DB 'Segoe UI',0
szDurationTimeEmpty     DB "--:--",0
szPositionTimeEmpty     DB "--:--",0
szSpaceDashSpace        DB " - ",0
szUser32dll             DB 'User32.dll',0 
szCMF                   DB 'ChangeWindowMessageFilter',0

szRatex0125             DB " [x0.125]",0
szRatex025              DB " [x0.25]",0
szRatex05               DB " [x0.5]",0
szRatex2                DB " [x2]",0
szRatex4                DB " [x4]",0

ENDIF

pMP                     DQ 0 ; pMediaPlayer
pMI                     DQ 0 ; pMediaItem

qwFiles                 DQ 0
lpszMediaFileName       DQ 0

dwDurationTimeMS        DD 0
dwPositionTimeMS        DD 0
dwSlowestRate           DD 0
dwFastestRate           DD 0
dwCurrentRate           DD 0

g_dwStreamCount         DD 0
g_pStreamTable          DQ 0
g_LangID                DD 0
g_Playing               DQ FALSE
g_Fullscreen            DQ FALSE
g_wpPrev                WINDOWPLACEMENT <>
g_PrevStyle             DQ 0
g_PrevExStyle           DQ 0
g_PrevMenu              DQ 0
g_PrevVolume            DD 100
g_WasMaximized          DQ FALSE
g_Mute                  DQ FALSE
g_Shown                 DQ FALSE
g_AspectMode            DQ 0
g_MediaType             DQ 0 ; 0 = video, 1 = audio
CmdLineProcessFileFlag  DQ 0 ; 0 = no file to process (normal operation), 1 = file to open
pChangeWindowMessageFilter ChangeWindowMessageFilter_Ptr 0

IFDEF __UNICODE__
MediaPlayerIniFile      DB 1024 DUP (0)
szDroppedFilename       DB 1024 DUP (0)
szJustFilename          DB 1024 DUP (0)
TitleBuffer             DB 1024 DUP (0)
szMenuString            DB 1024 DUP (0)
CmdLineFilename         DB 1024 DUP (0)
CmdLineFullPathFilename DB 1024 DUP (0)
ELSE
MediaPlayerIniFile      DB 512 DUP (0)
szDroppedFilename       DB 512 DUP (0)
szJustFilename          DB 512 DUP (0)
TitleBuffer             DB 512 DUP (0)
szMenuString            DB 512 DUP (0)
CmdLineFilename         DB 512 DUP (0)
CmdLineFullPathFilename DB 512 DUP (0)
ENDIF

hPatternBitmap          DQ 0
hPatternBrush           DQ 0

IFDEF __UNICODE__
szMediaFiles            DB 'M',0,'e',0,'d',0,'i',0,'a',0,' ',0,'F',0,'i',0,'l',0,'e',0,'s',0
                        DB 0,0,0,0
szMediaFilesSpec        DB '*',0,'.',0,'m',0,'p',0,'4',0,';',0,'*',0,'.',0,'m',0,'4',0,'v',0,';',0
                        DB '*',0,'.',0,'m',0,'o',0,'v',0,';',0,'*',0,'.',0,'m',0,'k',0,'v',0,';',0
                        DB '*',0,'.',0,'w',0,'m',0,'v',0,';',0,'*',0,'.',0,'a',0,'v',0,'i',0,';',0
                        DB '*',0,'.',0,'a',0,'s',0,'f',0,';',0,'*',0,'.',0,'m',0,'p',0,'3',0,';',0
                        DB '*',0,'.',0,'m',0,'4',0,'a',0,';',0,'*',0,'.',0,'a',0,'a',0,'c',0,';',0
                        DB '*',0,'.',0,'w',0,'m',0,'a',0,';',0,'*',0,'.',0,'w',0,'a',0,'v',0
                        DB 0,0,0,0
szVideoFiles            DB 'V',0,'i',0,'d',0,'e',0,'o',0,' ',0,'F',0,'i',0,'l',0,'e',0,'s',0
                        DB 0,0,0,0
szVideoFilesSpec        DB '*',0,'.',0,'m',0,'p',0,'4',0,';',0,'*',0,'.',0,'m',0,'4',0,'v',0,';',0
                        DB '*',0,'.',0,'m',0,'o',0,'v',0,';',0,'*',0,'.',0,'m',0,'k',0,'v',0,';',0
                        DB '*',0,'.',0,'w',0,'m',0,'v',0,';',0,'*',0,'.',0,'a',0,'v',0,'i',0,';',0
                        DB '*',0,'.',0,'a',0,'s',0,'f',0
                        DB 0,0,0,0
szAudioFiles            DB 'A',0,'u',0,'d',0,'i',0,'o',0,' ',0,'F',0,'i',0,'l',0,'e',0,'s',0
                        DB 0,0,0,0
szAudioFilesSpec        DB '*',0,'.',0,'m',0,'p',0,'3',0,';',0,'*',0,'.',0,'m',0,'4',0,'a',0,';',0
                        DB '*',0,'.',0,'a',0,'a',0,'c',0,';',0,'*',0,'.',0,'w',0,'m',0,'a',0,';',0
                        DB '*',0,'.',0,'w',0,'a',0,'v',0
                        DB 0,0,0,0
szAllFiles              DB 'A',0,'l',0,'l',0,' ',0,'F',0,'i',0,'l',0,'e',0,'s',0,' ',0,'(',0,'*',0,'.',0,'*',0,')',0
                        DB 0,0,0,0
szAllFilesSpec          DB '*',0,'.',0,'*',0
                        DB 0,0,0,0
ELSE
szMediaFiles            DB 'Media Files',0
szMediaFilesSpec        DB '*.mp4;*.m4v;*.mov;*.mkv;*.wmv;*.avi;*.asf;*.mp3;*.m4a;*.aac;*.wma;*.wav',0
szVideoFiles            DB 'Video Files',0
szVideoFilesSpec        DB '*.mp4;*.m4v;*.mov;*.mkv;*.wmv;*.avi;*.asf',0
szAudioFiles            DB 'Audio Files',0
szAudioFilesSpec        DB '*.mp3;*.m4a;*.aac;*.wma;*.wav',0
szAllFiles              DB 'All Files (*.*)',0
szAllFilesSpec          DB '*.*',0
ENDIF

FileSpecs \   
COMDLG_FILTERSPEC <Offset szMediaFiles, Offset szMediaFilesSpec>
COMDLG_FILTERSPEC <Offset szVideoFiles, Offset szVideoFilesSpec>
COMDLG_FILTERSPEC <Offset szAudioFiles, Offset szAudioFilesSpec>
COMDLG_FILTERSPEC <Offset szAllFiles, Offset szAllFilesSpec>

IFNDEF MFP_DIV100
MFP_DIV100                  REAL4 0.01
ENDIF
IFNDEF MFP_DIV1000
MFP_DIV1000                 REAL4 0.001
ENDIF
IFNDEF MFP_DIV10000
MFP_DIV10000                REAL4 0.0001
ENDIF
IFNDEF MFP_MUL100
MFP_MUL100                  REAL4 100.0
ENDIF
IFNDEF MFP_MUL1000
MFP_MUL1000                 REAL4 1000.0
ENDIF

.DATA?
;------------------------------------------------------------------------------
; MediaPlayer Uninitialized Data
;------------------------------------------------------------------------------
align 08
icc 					INITCOMMONCONTROLSEX <>
hInstance				HINSTANCE ?
CommandLine				LPSTR ?
hAcc                    DQ ?
hWnd                    HWND ?
hMainWindow             DQ ?

hIcoMain                DQ ?
hIcoMFPlayer            DQ ?
hIcoMFPlayVideo         DQ ?
hIcoMFPlayAudio         DQ ?

hMediaPlayerWindow      DQ ?
hMediaPlayerControls    DQ ?
hMediaPlayerSeekBar     DQ ?

hMediaPlayerMainMenu    DQ ?
hMediaPlayerContextMenu DQ ?
hMediaPlayerAspectMenu  DQ ?
hMediaPlayerSpeedMenu   DQ ?

hMFP_Position	        DQ ?
hMFP_Duration	        DQ ?

hDrop                   DQ ?
hPosDurFont             DQ ?




