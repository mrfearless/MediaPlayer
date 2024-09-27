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

include shlwapi.inc
includelib shlwapi.lib

include msimg32.inc
includelib msimg32.lib

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
; MFPlayerTest Prototypes
;------------------------------------------------------------------------------
WinMain                     PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc                     PROTO :DWORD,:DWORD,:DWORD,:DWORD
GUIPaintBackground          PROTO hWin:DWORD
GUIPaintStatics             PROTO hWin:DWORD, lParam:DWORD, wParam:DWORD

GUIInit                     PROTO hWin:DWORD
GUIResize                   PROTO hWin:DWORD, wParam:DWORD, lParam:DWORD
GUIAllowDragDrop            PROTO bAllow:DWORD

GUISetDurationTime          PROTO dwMilliseconds:DWORD
GUISetPositionTime          PROTO dwMilliseconds:DWORD
GUIPositionUpdate           PROTO dwPositionMS:DWORD, lParam:DWORD
GUISetPlaySpeed             PROTO dwMenuID:DWORD, dwPlayRate:DWORD

GUISetTitleMediaLoaded      PROTO hWin:DWORD, lpszMediaLoaded:DWORD
GUIToggleFullscreen         PROTO hWin:DWORD
GUIFullscreenEnter          PROTO hWin:DWORD
GUIFullscreenExit           PROTO hWin:DWORD
GUIHideControlsCheck        PROTO
GUIShowControlsCheck        PROTO lParam:LPARAM

GUIIsClickInArea            PROTO hWin:DWORD, dwArea:DWORD, lParam:DWORD
GUILanguageChange           PROTO hWin:DWORD

MediaPlayerBrowseForFile    PROTO hWin:DWORD
MediaPlayerOpenFile         PROTO hWin:DWORD, lpszMediaFile:DWORD
MediaPlayerContextMenu      PROTO hWin:DWORD, wParam:WPARAM, lParam:LPARAM

MediaPlayerInitEngine       PROTO hWin:DWORD

MFP_OnMediaPlayerEvent      PROTO pThis:DWORD, pEventHeader:DWORD
MFP_Event_MediaItemSet      PROTO pEventHeader:DWORD
MFP_Event_RateSet           PROTO pEventHeader:DWORD

MFP_SelectAudioStream       PROTO pMediaItem:DWORD, dwStreamIndex:DWORD

MFP_JustFnameExt            PROTO szFilePathName:DWORD, szFileName:DWORD

MPPaintGradient             PROTO hdc:DWORD, lpGradientRect:DWORD, GradientColorFrom:DWORD, GradientColorTo:DWORD, HorzVertGradient:DWORD
MPBrushOrgs                 PROTO hControl:DWORD, hdc:DWORD, lpdwBrushOrgX:DWORD, lpdwBrushOrgY:DWORD

CmdLineProcess              PROTO ; Process cmd line parameters to handle opening file from cmdline or shell explorer
CmdLineProcessOption        PROTO

IsOSUsingRTL                PROTO

IFNDEF GetLocaleInfoEx
GetLocaleInfoEx PROTO lpLocaleName:DWORD, LCType:DWORD, lpLCData:DWORD, cchData:DWORD
ENDIF
IFNDEF GetUserDefaultLocaleName
GetUserDefaultLocaleName PROTO lpLocaleName:DWORD, cchLocaleName:DWORD
ENDIF

IFDEF __UNICODE__
Arg_GetArgumentW            PROTO lpszArgumentList:DWORD, lpszDestination:DWORD, nArgument:DWORD
Arg_GetCommandLineExW       PROTO nArgument:DWORD, lpszArgumentBuffer:DWORD
ENDIF

; ChangeWindowMessageFilter Prototype
ChangeWindowMessageFilter_Proto TYPEDEF PROTO STDCALL message:DWORD, dwFlag:DWORD
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
    pszName       DD ?
    pszSpec       DD ?
COMDLG_FILTERSPEC ENDS
ENDIF

IFNDEF CL_OPTION
CL_OPTION       STRUCT
    lpszOption  DD ?
    lpdwFlag    DD ?
    lpdwValue   DD ?
CL_OPTION       ENDS
ENDIF

.CONST
;------------------------------------------------------------------------------
; MFPlayerTest Constants
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
ACC_MC_STEP10F_         EQU 907
ACC_MC_STEP10B_         EQU 908
ACC_MC_FULLSCREEN       EQU 909
ACC_MC_STREAM1          EQU 911
ACC_MC_STREAM2          EQU 912
ACC_MC_STREAM3          EQU 913
ACC_MC_STREAM4          EQU 914
ACC_MC_STREAM5          EQU 915
ACC_MC_STREAM6          EQU 916
ACC_MC_STREAM7          EQU 917
ACC_MC_STREAM8          EQU 918
ACC_MC_STREAM9          EQU 919
ACC_MC_TOGGLEPLAY       EQU 920

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

MFP_DEFAULT_RATE        EQU 1000 ; x1
MPF_MAX_RATE            EQU 4000 ; x4
MPF_MIN_RATE            EQU 125

MP_HIDECONTROLS_TIMEOUT EQU 3000

.DATA
ALIGN 4

;------------------------------------------------------------------------------
; MFPlayerTest Initialized Data
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
szRatex075              DB " ",0,"[",0,"x",0,"0",0,".",0,"7",0,"5",0,"]",0
                        DB 0,0,0,0
szRatex125              DB " ",0,"[",0,"x",0,"1",0,".",0,"2",0,"5",0,"]",0
                        DB 0,0,0,0
szRatex15               DB " ",0,"[",0,"x",0,"1",0,".",0,"5",0,"]",0
                        DB 0,0,0,0
szRatex175              DB " ",0,"[",0,"x",0,"1",0,".",0,"7",0,"5",0,"]",0
                        DB 0,0,0,0
szRatex2                DB " ",0,"[",0,"x",0,"2",0,"]",0
                        DB 0,0,0,0
szRatex3                DB " ",0,"[",0,"x",0,"3",0,"]",0
                        DB 0,0,0,0
szRatex4                DB " ",0,"[",0,"x",0,"4",0,"]",0
                        DB 0,0,0,0

szShellExplore          DB "e",0,"x",0,"p",0,"l",0,"o",0,"r",0,"e",0
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
szRatex075              DB " [x0.75]",0
szRatex125              DB " [x1.25]",0
szRatex15               DB " [x1.5]",0
szRatex175              DB " [x1.75]",0
szRatex2                DB " [x2]",0
szRatex3                DB " [x3]",0
szRatex4                DB " [x4]",0

szShellExplore          DB "explore",0
ENDIF

szCLClose               DB "close",0
szCLMinimized           DB "minimized",0
szCLFullscreen          DB "fullscreen",0
szCLVolume              DB "volume:",0


pMP                     DD 0        ; pMediaPlayer
pMI                     DD 0        ; pMediaItem

dwFiles                 DD 0
lpszMediaFileName       DD 0        ; Current media item filename

dwPrevPositionMS        DD 0        ; Used to save/restore position
dwDurationTimeMS        DD 0        ; Duration in milliseconds for media item
dwPositionTimeMS        DD 0        ; Position in milliseconds for media item
dwSlowestRate           DD 0        ; Slowest playback rate for media item
dwFastestRate           DD 0        ; Faster playback rate for media item
dwCurrentRate           DD 0        ; Current playback rate

g_CL_Close              DD FALSE    ; Command Line /Close Parameter
g_CL_Minimized          DD FALSE    ; Command Line /Minimized Parameter
g_CL_Fullscreen         DD FALSE    ; Command Line /Fullscreen Parameter
g_CL_Volume             DD FALSE    ; Command Line /Volume:X Parameter
g_SelectStream          DD FALSE    ; Flag for switching audio streams
g_dwStreamCount         DD 0        ; Total count of streams in media item
g_pStreamTable          DD 0        ; Pointer to an array of MFP_STREAM_RECORD entries
g_LangID                DD 0        ; Language ID current in use
g_LangRTL               DD FALSE    ; Using Right To Left layout for langauges that require it 
g_Playing               DD FALSE    ; Currently playing
g_Fullscreen            DD FALSE    ; Fullscreen or not
g_HideControls          DD FALSE    ; Hide controls when fullscreen after 3 seconds
g_wpPrev                WINDOWPLACEMENT <>
g_CursorPos             POINT <>
g_PrevStyle             DD 0        ; Used to save/restore Style flags
g_PrevExStyle           DD 0        ; Used to save/restore ExStyle flags
g_PrevMenu              DD 0        ; Used to save/restore menu
g_PrevVolume            DD 100      ; Used to save/restore current media player volume
g_PrevState             DD 0        ; Previously media player state: playing, paused, stopped etc
g_WasMaximized          DD FALSE    ; Used to determine if main window was maximized previously.
g_Mute                  DD FALSE    ; Volume is muted
g_Shown                 DD FALSE    ; Main window is visible
g_AspectMode            DD 0        ; Aspect mode used
g_MediaType             DD 0        ; 0 = video, 1 = audio
g_StringTable           DD 0        ; Pointer to uncompressed data that is the string table for current langauge
CmdLineProcessFileFlag  DD 0        ; 0 = no file to process (normal operation), 1 = file to open
pChangeWindowMessageFilter ChangeWindowMessageFilter_Ptr 0

; Command Line Options
; Currently support: /Close, /Minimized, /Fullscreen and /Volume:xx
g_CLOptions \
CL_OPTION <Offset szCLClose,        Offset g_CL_Close,      0>
CL_OPTION <Offset szCLMinimized,    Offset g_CL_Minimized,  0>
CL_OPTION <Offset szCLFullscreen,   Offset g_CL_Fullscreen, 0>
CL_OPTION <Offset szCLVolume,       Offset g_CL_Volume,     Offset g_PrevVolume>
dwTotalCLOptions DD (($ - g_CLOptions) / SIZEOF CL_OPTION)

; Buffers
IFDEF __UNICODE__
MediaPlayerIniFile      DB 1024 DUP (0)
MediaPlayerIniFolder    DB 1024 DUP (0)
szDroppedFilename       DB 1024 DUP (0)
szJustFilename          DB 1024 DUP (0)
TitleBuffer             DB 1024 DUP (0)
szMenuString            DB 1024 DUP (0)
CmdLineFilename         DB 1024 DUP (0)
CmdLineFullPathFilename DB 1024 DUP (0)
szCmdLineOptionBuffer   DB 64 DUP (0)
ELSE
MediaPlayerIniFile      DB 512 DUP (0)
MediaPlayerIniFolder    DB 512 DUP (0)
szDroppedFilename       DB 512 DUP (0)
szJustFilename          DB 512 DUP (0)
TitleBuffer             DB 512 DUP (0)
szMenuString            DB 512 DUP (0)
CmdLineFilename         DB 512 DUP (0)
CmdLineFullPathFilename DB 512 DUP (0)
szCmdLineOptionBuffer   DB 32 DUP (0)
ENDIF

hPatternBitmap          DD 0
hPatternBrush           DD 0

; FileDialog file specs
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
IFNDEF MFP_DIV125
MFP_DIV125                  REAL4 0.008
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
hIcoMFPlayVideo         DD ?
hIcoMFPlayAudio         DD ?

hMediaPlayerWindow      DD ?
hMediaPlayerControls    DD ?
hMediaPlayerSeekBar     DD ?

hMediaPlayerMainMenu    DD ?
hMediaPlayerContextMenu DD ?
hMediaPlayerAspectMenu  DD ?
hMediaPlayerSpeedMenu   DD ?
hMediaPlayerAudioMenu   DD ?

hMFP_Position	        DD ?
hMFP_Duration	        DD ?

hDrop                   DD ?
hPosDurFont             DD ?



