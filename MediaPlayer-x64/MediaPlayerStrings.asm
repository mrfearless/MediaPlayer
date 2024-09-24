
MPStringsInit           PROTO
MPLoadStringLanguage    PROTO dwStringID:DWORD, lpszString:QWORD, dwStringSize:DWORD

.CONST
IFDEF __UNICODE__
LANG_STRINGSIZE_SMALL   EQU 128
ELSE
LANG_STRINGSIZE_SMALL   EQU 64
ENDIF

; Stringtable Base Language ID 
STRINGID_START          EQU 1
TIP_MPC_Stop            EQU 1
TIP_MPC_Play            EQU 2
TIP_MPC_Step            EQU 3
TIP_MPC_Fullscreen      EQU 4
TIP_MPC_VolumeToggle    EQU 5
TIP_MPC_About           EQU 6
TIP_MPC_Step10F         EQU 7
TIP_MPC_Step10B         EQU 8
TIP_MPC_PlaySpeed       EQU 9
TEXT_Unvailable         EQU 10
TEXT_MRUClear           EQU 11
STRINGID_FINISH         EQU 11

; US starts at 101
; EN starts at 151
; FR starts at 201
; DE starts at 251
; PL starts at 301
; IT starts at 351
; ES starts at 401
; UA starts at 451
; FA starts at 501

.DATA
ALIGN 4

IFNDEF MP_RTLC_RESOURCES
lpszTip_MPC_Stop		 DQ Offset szTip_MPC_Stop
lpszTip_MPC_Play		 DQ Offset szTip_MPC_Play
lpszTip_MPC_Step		 DQ Offset szTip_MPC_Step
lpszTip_MPC_Fullscreen	 DQ Offset szTip_MPC_Fullscreen
lpszTip_MPC_VolumeToggle DQ Offset szTip_MPC_VolumeToggle
lpszTip_MPC_About        DQ Offset szTip_MPC_About
lpszTip_MPC_Step10F      DQ Offset szTip_MPC_Step10F
lpszTip_MPC_Step10B      DQ Offset szTip_MPC_Step10B
lpszTip_MPC_PlaySpeed    DQ Offset szTip_MPC_PlaySpeed
lpszTextUnvailable       DQ Offset szTextUnvailable
lpszMRUClear             DQ Offset szMRUClear
ELSE
lpszTip_MPC_Stop		 DQ 0
lpszTip_MPC_Play		 DQ 0
lpszTip_MPC_Step		 DQ 0
lpszTip_MPC_Fullscreen	 DQ 0
lpszTip_MPC_VolumeToggle DQ 0
lpszTip_MPC_About        DQ 0
lpszTip_MPC_Step10F      DQ 0
lpszTip_MPC_Step10B      DQ 0
lpszTip_MPC_PlaySpeed    DQ 0
lpszTextUnvailable       DQ 0
lpszMRUClear             DQ 0
ENDIF

.DATA?
ALIGN 4

IFNDEF MP_RTLC_RESOURCES
szTip_MPC_Stop		    DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Play		    DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Step		    DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Fullscreen	DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_VolumeToggle  DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_About         DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Step10F       DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Step10B       DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_PlaySpeed     DB LANG_STRINGSIZE_SMALL DUP (?)
szTextUnvailable        DB LANG_STRINGSIZE_SMALL DUP (?)
szMRUClear              DB LANG_STRINGSIZE_SMALL DUP (?)
ENDIF


.CODE

;------------------------------------------------------------------------------
; MPStringsInit
;------------------------------------------------------------------------------
MPStringsInit PROC FRAME
    IFDEF DEBUG64
    ;PrintText 'MPStringsInit'
    ENDIF

    IFDEF MP_RTLC_RESOURCES
    Invoke MPLangGetLanguage, g_LangID, NULL, NULL, Addr g_StringTable
    Invoke MPLangLoadStringID, g_LangID, g_StringTable, TIP_MPC_Stop, Addr lpszTip_MPC_Stop
    Invoke MPLangLoadStringID, g_LangID, g_StringTable, TIP_MPC_Play, Addr lpszTip_MPC_Play
    Invoke MPLangLoadStringID, g_LangID, g_StringTable, TIP_MPC_Step, Addr lpszTip_MPC_Step
    Invoke MPLangLoadStringID, g_LangID, g_StringTable, TIP_MPC_Fullscreen, Addr lpszTip_MPC_Fullscreen
    Invoke MPLangLoadStringID, g_LangID, g_StringTable, TIP_MPC_VolumeToggle, Addr lpszTip_MPC_VolumeToggle
    Invoke MPLangLoadStringID, g_LangID, g_StringTable, TIP_MPC_About, Addr lpszTip_MPC_About
    Invoke MPLangLoadStringID, g_LangID, g_StringTable, TIP_MPC_Step10F, Addr lpszTip_MPC_Step10F
    Invoke MPLangLoadStringID, g_LangID, g_StringTable, TIP_MPC_Step10B, Addr lpszTip_MPC_Step10B
    Invoke MPLangLoadStringID, g_LangID, g_StringTable, TIP_MPC_PlaySpeed, Addr lpszTip_MPC_PlaySpeed
    Invoke MPLangLoadStringID, g_LangID, g_StringTable, TEXT_Unvailable, Addr lpszTextUnvailable
    Invoke MPLangLoadStringID, g_LangID, g_StringTable, TEXT_MRUClear, Addr lpszMRUClear
    ELSE
    Invoke MPLoadStringLanguage, TIP_MPC_Stop, Addr szTip_MPC_Stop, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Play, Addr szTip_MPC_Play, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Step, Addr szTip_MPC_Step, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Fullscreen, Addr szTip_MPC_Fullscreen, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_VolumeToggle, Addr szTip_MPC_VolumeToggle, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_About, Addr szTip_MPC_About, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Step10F, Addr szTip_MPC_Step10F, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Step10B, Addr szTip_MPC_Step10B, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_PlaySpeed, Addr szTip_MPC_PlaySpeed, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TEXT_Unvailable, Addr szTextUnvailable, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TEXT_MRUClear, Addr szMRUClear, LANG_STRINGSIZE_SMALL
    ENDIF

    ret
MPStringsInit ENDP


;------------------------------------------------------------------------------
; MPLoadStringLanguage - Load string resource for a particular language 
; Language string ID in stringtable = (((g_LangID * 50) + 100) + dwStringID)
;------------------------------------------------------------------------------
MPLoadStringLanguage PROC FRAME USES RBX dwStringID:DWORD, lpszString:QWORD, dwStringSize:DWORD
    LOCAL hRes:QWORD
    LOCAL hResData:QWORD
    LOCAL pResData:QWORD
    LOCAL dwLangIDBase:DWORD
    LOCAL dwLangStringID:DWORD
    
    .IF lpszString == 0
        mov rax, 0
        ret
    .ENDIF
    
    xor rax, rax
    mov eax, g_LangID
    mov rbx, 50
    mul rbx
    add rax, 100
    mov dwLangIDBase, eax
    add eax, dwStringID
    mov dwLangStringID, eax
    Invoke LoadString, hInstance, dwLangStringID, lpszString, dwStringSize
    
    IFDEF DEBUG64
    ;PrintDec qwLangID
    ;PrintDec qwStringID
    ;PrintDec qwLangIDBase
    ;PrintDec qwLangStringID
    ;PrintString szLangStringBuffer
    ENDIF

    ret
MPLoadStringLanguage ENDP


