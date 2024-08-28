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

; https://sample-videos.com/

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include masm32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib masm32.lib

include msimg32.inc
includelib msimg32.lib

include FileDialog.inc
includelib FileDialog.lib

include MFPlayer.inc
includelib MFPlayer.lib



RGB MACRO red:REQ, green:REQ, blue:REQ
    EXITM < red or green shl 8 or blue shl 16 >
ENDM


;------------------------------------------------------------------------------
; MFPlayerTest Prototypes
;------------------------------------------------------------------------------
WinMain                     PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc                     PROTO :DWORD,:DWORD,:DWORD,:DWORD
GUIPaintBackground          PROTO hWin:DWORD
GUIPaintStatics             PROTO hWin:DWORD, lParam:DWORD, wParam:DWORD

GUIInit                     PROTO hWin:DWORD
GUIResize                   PROTO hWin:DWORD, wParam:DWORD, lParam:DWORD
GUISetDurationTime          PROTO dwMilliseconds:DWORD
GUISetPositionTime          PROTO dwMilliseconds:DWORD
GUISetTitleMediaLoaded      PROTO hWin:DWORD, lpszMediaLoaded:DWORD
GUIToggleFullscreen         PROTO hWin:DWORD
GUIFullscreenEnter          PROTO hWin:DWORD
GUIFullscreenExit           PROTO hWin:DWORD
GUIPositionUpdate           PROTO dwPositionMS:DWORD, lParam:DWORD
GUIIsClickInArea            PROTO hWin:DWORD, dwArea:DWORD, lParam:DWORD

MediaPlayerBrowseForFile    PROTO hWin:DWORD
MediaPlayerOpenFile         PROTO hWin:DWORD, lpszMediaFile:DWORD
MediaPlayerContextMenu      PROTO hWin:DWORD, wParam:WPARAM, lParam:LPARAM

MFP_OnMediaPlayerEvent      PROTO pThis:DWORD, pEventHeader:DWORD  

MFP_JustFnameExt            PROTO szFilePathName:DWORD, szFileName:DWORD

MPPaintGradient             PROTO hdc:DWORD, lpGradientRect:DWORD, GradientColorFrom:DWORD, GradientColorTo:DWORD, HorzVertGradient:DWORD
MPBrushOrgs                 PROTO hControl:DWORD, hdc:DWORD, lpdwBrushOrgX:DWORD, lpdwBrushOrgY:DWORD

CmdLineProcess              PROTO ; Process cmd line parameters to handle opening file from cmdline or shell explorer

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
    pszName       DD ?
    pszSpec       DD ?
COMDLG_FILTERSPEC ENDS
ENDIF

.CONST
;------------------------------------------------------------------------------
; MFPlayerTest Constants
;------------------------------------------------------------------------------
ICO_MAIN                EQU 100
ICO_MFPLAYER            EQU 101
BMP_PATTERN             EQU 102
BMP_FILE_MRU            EQU 103

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

MFPLAYER_LEFT           EQU 10
MFPLAYER_TOP            EQU 10
MFPLAYER_RIGHT          EQU 10
MFPLAYER_BOTTOM         EQU 78

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

.DATA
;------------------------------------------------------------------------------
; MFPlayerTest Initialized Data
;------------------------------------------------------------------------------
ClassName               DB 'DLGCLASS',0
AppName                 DB 'MediaPlayer',0
AboutMsg                DB 'github.com/mrfearless',0
szSegoeUIFont           DB 'Segoe UI',0

szMFPlayerClass         DB 'MFPlay Window Class',0
szDurationTimeEmpty     DB "--:--",0
szPositionTimeEmpty     DB "--:--",0
szSpace                 DB " ",0
szSpaceDashSpace        DB " - ",0

pMP                     DD 0 ; pMediaPlayer
pMI                     DD 0 ; pMediaItem

dwFiles                 DD 0
lpszMediaFileName       DD 0

dwDurationTimeMS        DD 0
dwPositionTimeMS        DD 0

g_Playing               DD FALSE
g_Fullscreen            DD FALSE
g_wpPrev                WINDOWPLACEMENT <>
g_PrevStyle             DD 0
g_PrevExStyle           DD 0
g_PrevMenu              DD 0
g_PrevVolume            DD 100
g_WasMaximized          DD FALSE
g_Mute                  DD FALSE
g_Shown                 DD FALSE
g_AspectMode            DD 0

MediaPlayerIniFile      DB 512 DUP (0)
szStatusBarBuffer       DB 512 DUP (0)
szDroppedFilename       DB 512 DUP (0)
szJustFilename          DB 512 DUP (0)
TitleBuffer             DB 512 DUP (0)
szMenuString            DB 512 DUP (0)

hPatternBitmap          DD 0
hPatternBrush           DD 0

; Command line processing stuff
szCmdLineFilenameDoesNotExist   DB 'The filename specified on the command line does not exist: ',0
CmdLineFilename                 DB 256 DUP (0)
CmdLineFullPathFilename         DB 512 DUP (0)
CmdLineProcessFileFlag          DD 0 ; 0 = no file to process (normal operation), 1 = file to open


szMediaFiles            DB 'Media Files',0
szMediaFilesSpec        DB '*.mp4;*.m4v;*.mov;*.mkv;*.wmv;*.avi;*.asf;*.mp3;*.m4a;*.aac;*.wma;*.wav',0
szVideoFiles            DB 'Video Files',0
szVideoFilesSpec        DB '*.mp4;*.m4v;*.mov;*.mkv;*.wmv;*.avi;*.asf',0
szAudioFiles            DB 'Audio Files',0
szAudioFilesSpec        DB '*.mp3;*.m4a;*.aac;*.wma;*.wav',0
szAllFiles              DB 'All Files (*.*)',0
szAllFilesSpec          DB '*.*',0

FileSpecs \   
COMDLG_FILTERSPEC <Offset szMediaFiles, Offset szMediaFilesSpec>
COMDLG_FILTERSPEC <Offset szVideoFiles, Offset szVideoFilesSpec>
COMDLG_FILTERSPEC <Offset szAudioFiles, Offset szAudioFilesSpec>
COMDLG_FILTERSPEC <Offset szAllFiles, Offset szAllFilesSpec>


IFNDEF MFP_DIV100
MFP_DIV100                  REAL4 0.01
ENDIF
IFNDEF MFP_DIV10000
MFP_DIV10000                REAL4 0.0001
ENDIF

.DATA?
;------------------------------------------------------------------------------
; MFPlayerTest Uninitialized Data
;------------------------------------------------------------------------------
icc                     INITCOMMONCONTROLSEX <>
hInstance               DD ?
CommandLine             DD ?
hAcc                    DD ?
hWnd                    DD ?
hMainWindow             DD ?

hIcoMain                DD ?
hIcoMFPlayer            DD ?
hBmpFileMRU             DD ?

hMediaPlayerWindow      DD ?
hMediaPlayerControls    DD ?
hMediaPlayerSeekBar     DD ?

hMediaPlayerMainMenu    DD ?
hMediaPlayerContextMenu DD ?
hMediaPlayerAspectMenu  DD ?

hMFP_Position	        DD ?
hMFP_Duration	        DD ?

hDrop                   DD ?
hPosDurFont             DD ?



