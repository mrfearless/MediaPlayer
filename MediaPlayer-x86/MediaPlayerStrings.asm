
MPStringsInit           PROTO
MPLoadStringLanguage    PROTO dwStringID:DWORD, lpszString:DWORD, dwStringSize:DWORD

.CONST
IFDEF __UNICODE__
LANG_STRINGSIZE_SMALL   EQU 128
ELSE
LANG_STRINGSIZE_SMALL   EQU 64
ENDIF

; Stringtable Base Language ID 
TIP_MPC_Open            EQU 1
TIP_MPC_Stop            EQU 2
TIP_MPC_Pause           EQU 3
TIP_MPC_Play            EQU 4
TIP_MPC_Step            EQU 5
TIP_MPC_Fullscreen      EQU 6
TIP_MPC_Exit            EQU 7
TIP_MPC_VolumeToggle    EQU 8
TIP_MPC_Aspect          EQU 9
TIP_MPC_About           EQU 10
TIP_MPC_Step10F         EQU 11
TIP_MPC_Step10B         EQU 12
TIP_MPC_Faster          EQU 13
TIP_MPC_Slower          EQU 14
TEXT_MRUClear           EQU 20

; US starts at 101
; EN starts at 151
; FR starts at 201
; DE starts at 251
; PL starts at 301
; IT starts at 351

.DATA


.DATA?
szTip_MPC_Open		    DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Stop		    DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Pause		    DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Play		    DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Step		    DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Fullscreen	DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Exit		    DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_VolumeToggle  DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Aspect        DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_About         DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Step10F       DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Step10B       DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Faster        DB LANG_STRINGSIZE_SMALL DUP (?)
szTip_MPC_Slower        DB LANG_STRINGSIZE_SMALL DUP (?)
szMRUClear              DB LANG_STRINGSIZE_SMALL DUP (?)

.CODE

;------------------------------------------------------------------------------
; MPStringsInit
;------------------------------------------------------------------------------
MPStringsInit PROC
    IFDEF DEBUG32
    ;PrintText 'MPStringsInit'
    ENDIF

    Invoke MPLoadStringLanguage, TIP_MPC_Open, Addr szTip_MPC_Open, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Stop, Addr szTip_MPC_Stop, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Pause, Addr szTip_MPC_Pause, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Play, Addr szTip_MPC_Play, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Step, Addr szTip_MPC_Step, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Fullscreen, Addr szTip_MPC_Fullscreen, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Exit, Addr szTip_MPC_Exit, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_VolumeToggle, Addr szTip_MPC_VolumeToggle, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Aspect, Addr szTip_MPC_Aspect, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_About, Addr szTip_MPC_About, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Step10F, Addr szTip_MPC_Step10F, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Step10B, Addr szTip_MPC_Step10B, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Faster, Addr szTip_MPC_Faster, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TIP_MPC_Slower, Addr szTip_MPC_Slower, LANG_STRINGSIZE_SMALL
    Invoke MPLoadStringLanguage, TEXT_MRUClear, Addr szMRUClear, LANG_STRINGSIZE_SMALL
    
    IFDEF DEBUG32
    ;PrintDec eax
    ;PrintDec lpszMRUClear
    ;PrintStringByAddr lpszMRUClear
    ENDIF
    
    ret
MPStringsInit ENDP


;------------------------------------------------------------------------------
; MPLoadStringLanguage - Load string resource for a particular language 
; Language string ID in stringtable = (((g_LangID * 50) + 100) + dwStringID)
;------------------------------------------------------------------------------
MPLoadStringLanguage PROC USES EBX dwStringID:DWORD, lpszString:DWORD, dwStringSize:DWORD
    LOCAL hRes:DWORD
    LOCAL hResData:DWORD
    LOCAL pResData:DWORD
    LOCAL dwLangIDBase:DWORD
    LOCAL dwLangStringID:DWORD
    
    .IF lpszString == 0
        mov eax, 0
        ret
    .ENDIF
    
    mov eax, g_LangID
    mov ebx, 50
    mul ebx
    add eax, 100
    mov dwLangIDBase, eax
    add eax, dwStringID
    mov dwLangStringID, eax
    Invoke LoadString, hInstance, dwLangStringID, lpszString, dwStringSize
    
    IFDEF DEBUG32
    ;PrintDec dwLangID
    ;PrintDec dwStringID
    ;PrintDec dwLangIDBase
    ;PrintDec dwLangStringID
    ;PrintString szLangStringBuffer
    ENDIF

    ret
MPLoadStringLanguage ENDP


