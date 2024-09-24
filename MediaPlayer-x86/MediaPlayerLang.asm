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

; Dev mode enables the use of MPLangDump, which reads each menu language 
; resource and outputs it to a binary file. 
; 
; Each language is defined by a LANGID_ constant and has an entry in the table
; MP_LANG_TABLE.
; 
; In dev mode, this just allows us to fetch each menu resource and write it to
; a binary file (with MPLangDump). For example:
;
; .\Lang\MM_EN.mnu.bin
;
; In non dev mode (normal production), the resources are not compiled into the
; exe, instead a compressed binary stored in asm hex format in used, for 
; example (compressed with RTL using an unreleased utility):
;
; include .\Lang\MM_EN.mnu.bin.rtlc.asm
; 
; The compressed data for the menu is referenced in each language record in the 
; MP_LANG_TABLE. The compressed binary is stored in memory, and on first access 
; to a particular language record, it is decompressed and the menus are created 
; by using LoadMenuIndirect.
;
; The main resource file has a define conditional in it to determine if the  
; menu resources are included or not, this is set in the RC command line as:
; /d MP_RTLC_RESOURCES
; 
; Checklist to add a language:
; - Add an IDLANG_langname constant
; - Add the LANG_ and SUBLANG_ ids from the resource.h file
; - Add a MP_LANG_RECORD to the MP_LANG_TABLE (one for dev mode and for non dev)
; - Create the main menu language resource using notepad++ with encoding for UTF-16 LE BOM 
; - Create the context menu language resource using notepad++ with encoding for UTF-16 LE BOM
; - Add them to the main resource file
; - Add language entry for the new language to each main menu resource file:
;   MENUITEM "Polski",IDM_LANG_Polish
; - Add the language constant for the new language to each main menu resource file:
;   #define IDM_LANG_Polish 10054
; - Add the menu item constant to the source files: IDM_LANG_Polish EQU 10054
; - Add processing in WndProc for IDM_LANG_Polish selection
; - Add processing in MPSetMenuBitmaps to set checkmark for language selection
; - Turn on dev mode
; - Turn off unicode
; - Temporarily disable MP_RTLC_RESOURCES in rc file or from RC command line 
; - Call MPLangDump to generate the binaries
; - Compress .bin binaries to rtlc.asm output with utility
; - Add line below to include compressed file:
;   include .\Lang\MM_PL.mnu.bin.rtlc.asm
; - Turn off dev mode
; - Turn on unicode
; - Re-enable MP_RTLC_RESOURCES in rc file or from RC command line

;MP_DEVMODE EQU 1

MPLangLoadStringID          PROTO dwLangID:DWORD, pStringTable:DWORD, dwStringID:DWORD, lpdwString:DWORD
MPLangLoadMenus             PROTO dwLangID:DWORD, hWin:DWORD, lpHandleMainMenu:DWORD, lpHandleContextMenu:DWORD
MPLangGetLanguage           PROTO dwLangID:DWORD, lpdwMenuMain:DWORD, lpdwMenuContext:DWORD, lpdwStrings:DWORD
IFDEF MP_DEVMODE
MPLangDump PROTO
ENDIF

IFNDEF MP_LANG_RECORD
MP_LANG_RECORD              STRUCT
    dwLangID                DD ?
    pMenuMain               DD ?
    pMenuMainSrc            DD ?
    pMenuContext            DD ?
    pMenuContextSrc         DD ?
    pStrings                DD ?
    pStringsSrc             DD ?
    dwMaxStringSize         DD ?
    wLanguage               DW ?
    szCC                    DB 4 DUP (?)
MP_LANG_RECORD              ENDS
ENDIF

MP_LANG_MAXSTRING_SIZE      EQU 128

IFNDEF MP_LANG_STRING_RECORD
MP_LANG_STRING_RECORD       STRUCT
    dwStringID              DD 0
    szString                DB MP_LANG_MAXSTRING_SIZE DUP (?)
MP_LANG_STRING_RECORD       ENDS
ENDIF

.CONST
LANG_TOTAL_STRINGS          EQU 11 ; modify this to the amount of strings in the string resource for a language
LANG_MAX_IDS                EQU 50 ; maximum string id's for a language
; String id for a language is calculated as:
; LangStringID = (IDLANG x LANG_MAX_IDS) + 100 + StringID
; string id 1 of french lang for max 100 ids = (IDLANG_FRENCH x LANG_MAX_IDS) + 100 +1 
; = (2 x 50) + 100 +1 = 201

IDM_MENU                EQU 10000
IDM_CONTEXTMENU         EQU 11000

; Languages Supported:
IDLANG_DEFAULT          EQU 0
IDLANG_ENGLISH          EQU 1
IDLANG_FRENCH           EQU 2
IDLANG_GERMAN           EQU 3
IDLANG_POLISH           EQU 4
IDLANG_ITALIAN          EQU 5
IDLANG_SPANISH          EQU 6
IDLANG_UKRAINIAN        EQU 7
IDLANG_PERSIAN          EQU 8

; Primary
LANG_NEUTRAL            EQU 000h
LANG_ENGLISH            EQU 009h
LANG_FRENCH             EQU 00Ch
LANG_GERMAN             EQU 007h
LANG_POLISH             EQU 015h
LANG_ITALIAN            EQU 010h
LANG_SPANISH            EQU 00Ah
LANG_UKRAINIAN          EQU 022h
LANG_PERSIAN            EQU 029h

; Sublang
SUBLANG_NEUTRAL         EQU 000h
SUBLANG_DEFAULT         EQU 001h
SUBLANG_ENGLISH_US      EQU 001h
SUBLANG_ENGLISH_UK      EQU 002h
SUBLANG_FRENCH          EQU 001h
SUBLANG_GERMAN          EQU 001h
SUBLANG_POLISH_POLAND   EQU 001h
SUBLANG_ITALIAN         EQU 001h
SUBLANG_SPANISH         EQU 001h
SUBLANG_UKRAINIAN_UKRAINE EQU 001h
SUBLANG_PERSIAN_IRAN    EQU 001h

.DATA
ALIGN 4

IFDEF MP_DEVMODE
szMM                        DB "MM_",0
szMC                        DB "MC_",0
szSTR                       DB "STR_",0
szLangBackslash             DB "\",0
szLangFolder                DB "\Lang\",0
szLangUnderscore            DB "\",0
szLangExtBin                DB ".bin",0
szLangExtLng                DB ".lng",0
szLangExtMnu                DB ".mnu.bin",0
szLangExtStr                DB ".str.bin",0
szLangResID                 DB 16 DUP (0)
szLangLangID                DB 16 DUP (0)
szLangFilename              DB MAX_PATH DUP (0)
ENDIF

IFDEF MP_RTLC_RESOURCES
include .\Lang\MM_DEF.mnu.bin.rtlc.asm
include .\Lang\MM_EN.mnu.bin.rtlc.asm
include .\Lang\MM_FR.mnu.bin.rtlc.asm
include .\Lang\MM_DE.mnu.bin.rtlc.asm
include .\Lang\MM_PL.mnu.bin.rtlc.asm
include .\Lang\MM_IT.mnu.bin.rtlc.asm
include .\Lang\MM_ES.mnu.bin.rtlc.asm
include .\Lang\MM_UA.mnu.bin.rtlc.asm
include .\Lang\MM_FA.mnu.bin.rtlc.asm

include .\Lang\MC_DEF.mnu.bin.rtlc.asm
include .\Lang\MC_EN.mnu.bin.rtlc.asm
include .\Lang\MC_FR.mnu.bin.rtlc.asm
include .\Lang\MC_DE.mnu.bin.rtlc.asm
include .\Lang\MC_PL.mnu.bin.rtlc.asm
include .\Lang\MC_IT.mnu.bin.rtlc.asm
include .\Lang\MC_ES.mnu.bin.rtlc.asm
include .\Lang\MC_UA.mnu.bin.rtlc.asm
include .\Lang\MC_FA.mnu.bin.rtlc.asm

include .\Lang\STR_DEF.str.bin.rtlc.asm
include .\Lang\STR_EN.str.bin.rtlc.asm
include .\Lang\STR_FR.str.bin.rtlc.asm
include .\Lang\STR_DE.str.bin.rtlc.asm
include .\Lang\STR_PL.str.bin.rtlc.asm
include .\Lang\STR_IT.str.bin.rtlc.asm
include .\Lang\STR_ES.str.bin.rtlc.asm
include .\Lang\STR_UA.str.bin.rtlc.asm
include .\Lang\STR_FA.str.bin.rtlc.asm
ENDIF

IFDEF MP_RTLC_RESOURCES
;               dwLangID            pMenuMain pMenuMainSrc    pMenuContext pMenuContextSrc pStrings pStringsSrc     Max wLanguage                                        CC
;               ------------------- --------- --------------- ------------ --------------- -------- --------------- --- ------------------------------------------------ ---
MP_LANG_TABLE \
MP_LANG_RECORD <IDLANG_DEFAULT,     0,        Offset MM_DEF,  0,           Offset MC_DEF,  0,       Offset STR_DEF, 52, 0,                                              "DEF">
MP_LANG_RECORD <IDLANG_ENGLISH,     0,        Offset MM_EN,   0,           Offset MC_EN,   0,       Offset STR_EN,  52, MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_UK),   "EN">
MP_LANG_RECORD <IDLANG_FRENCH,      0,        Offset MM_FR,   0,           Offset MC_FR,   0,       Offset STR_FR,  84, MAKELANGID(LANG_FRENCH, SUBLANG_FRENCH),        "FR">
MP_LANG_RECORD <IDLANG_GERMAN,      0,        Offset MM_DE,   0,           Offset MC_DE,   0,       Offset STR_DE,  84, MAKELANGID(LANG_GERMAN, SUBLANG_GERMAN),        "DE">
MP_LANG_RECORD <IDLANG_POLISH,      0,        Offset MM_PL,   0,           Offset MC_PL,   0,       Offset STR_PL,  82, MAKELANGID(LANG_POLISH, SUBLANG_POLISH_POLAND), "PL">
MP_LANG_RECORD <IDLANG_ITALIAN,     0,        Offset MM_IT,   0,           Offset MC_IT,   0,       Offset STR_IT,  80, MAKELANGID(LANG_ITALIAN, SUBLANG_ITALIAN),      "IT">
MP_LANG_RECORD <IDLANG_SPANISH,     0,        Offset MM_ES,   0,           Offset MC_ES,   0,       Offset STR_ES,  88, MAKELANGID(LANG_SPANISH, SUBLANG_SPANISH),      "ES">
MP_LANG_RECORD <IDLANG_UKRAINIAN,   0,        Offset MM_UA,   0,           Offset MC_UA,   0,       Offset STR_UA,  72, MAKELANGID(LANG_UKRAINIAN,SUBLANG_UKRAINIAN_UKRAINE),"UA">
MP_LANG_RECORD <IDLANG_PERSIAN,     0,        Offset MM_FA,   0,           Offset MC_FA,   0,       Offset STR_FA,  70, MAKELANGID(LANG_PERSIAN,SUBLANG_PERSIAN_IRAN),  "FA">
MP_LANG_RECORD <0, 0, 0, 0, 0, 0, 0, 0>
MP_LANG_RECORD_COUNT DD (($-MP_LANG_TABLE) / SIZEOF MP_LANG_RECORD) -1
ELSE
;               dwLangID                          Max wLanguage                                        CC
;               -------------------               --- ------------------------------------------------ ---
MP_LANG_TABLE \
MP_LANG_RECORD <IDLANG_DEFAULT,     0,0,0,0,0,0,  52, 0,                                              "DEF">
MP_LANG_RECORD <IDLANG_ENGLISH,     0,0,0,0,0,0,  52, MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_UK),   "EN">
MP_LANG_RECORD <IDLANG_FRENCH,      0,0,0,0,0,0,  84, MAKELANGID(LANG_FRENCH, SUBLANG_FRENCH),        "FR">
MP_LANG_RECORD <IDLANG_GERMAN,      0,0,0,0,0,0,  84, MAKELANGID(LANG_GERMAN, SUBLANG_GERMAN),        "DE">
MP_LANG_RECORD <IDLANG_POLISH,      0,0,0,0,0,0,  82, MAKELANGID(LANG_POLISH, SUBLANG_POLISH_POLAND), "PL">
MP_LANG_RECORD <IDLANG_ITALIAN,     0,0,0,0,0,0,  80, MAKELANGID(LANG_ITALIAN, SUBLANG_ITALIAN),      "IT">
MP_LANG_RECORD <IDLANG_SPANISH,     0,0,0,0,0,0,  88, MAKELANGID(LANG_SPANISH, SUBLANG_SPANISH),      "ES">
MP_LANG_RECORD <IDLANG_UKRAINIAN,   0,0,0,0,0,0,  72, MAKELANGID(LANG_UKRAINIAN,SUBLANG_UKRAINIAN_UKRAINE),"UA">
MP_LANG_RECORD <IDLANG_PERSIAN,     0,0,0,0,0,0,  70, MAKELANGID(LANG_PERSIAN,SUBLANG_PERSIAN_IRAN),  "FA">
MP_LANG_RECORD <0, 0, 0, 0, 0, 0, 0, 0, 0>
MP_LANG_RECORD_COUNT DD (($-MP_LANG_TABLE) / SIZEOF MP_LANG_RECORD) -1
ENDIF

.CODE

;------------------------------------------------------------------------------
; MPLangLoadStringID
;------------------------------------------------------------------------------
MPLangLoadStringID PROC USES EBX ECX dwLangID:DWORD, pStringTable:DWORD, dwStringID:DWORD, lpdwString:DWORD
    LOCAL pLangRecord:DWORD
    LOCAL nLangRecord:DWORD
    LOCAL bLangRecordFound:DWORD
    LOCAL pStringRecord:DWORD
    LOCAL nStringRecord:DWORD
    LOCAL bStringRecordFound:DWORD
    LOCAL dwMaxStringSize:DWORD
    
    lea eax, MP_LANG_TABLE
    mov pLangRecord, eax
    
    mov bLangRecordFound, FALSE
    mov nLangRecord, 0
    mov eax, 0
    .WHILE eax < MP_LANG_RECORD_COUNT
        mov ebx, pLangRecord
        mov eax, [ebx].MP_LANG_RECORD.dwLangID
        .IF eax == dwLangID
            mov bLangRecordFound, TRUE
            .BREAK
        .ENDIF
        add pLangRecord, SIZEOF MP_LANG_RECORD
        inc nLangRecord
        mov eax, nLangRecord
    .ENDW
    
    ; Get Max string size
    .IF bLangRecordFound == TRUE
        mov ebx, pLangRecord
        mov eax, [ebx].MP_LANG_RECORD.dwMaxStringSize
        mov dwMaxStringSize, eax
        
        ; Get max string size and dword stringid for total length of string record
        add eax, SIZEOF DWORD
        mov ecx, eax
        
        mov eax, pStringTable
        mov pStringRecord, eax
        mov bStringRecordFound, FALSE
        mov nStringRecord, 0
        mov eax, 0
        .WHILE eax < LANG_TOTAL_STRINGS
            mov ebx, pStringRecord
            mov eax, dword ptr [ebx]
            .IF eax == dwStringID
                mov bStringRecordFound, TRUE
                .BREAK
            .ENDIF
            add pStringRecord, ecx
            inc nStringRecord
            mov eax, nStringRecord
        .ENDW
        
        .IF bStringRecordFound == TRUE
            mov ebx, lpdwString
            mov eax, pStringRecord
            add eax, SIZEOF DWORD
            mov [ebx], eax
            mov eax, TRUE
            ret
        .ENDIF
    .ENDIF
    
    mov eax, FALSE    
    ret
MPLangLoadStringID ENDP

;------------------------------------------------------------------------------
; MPLangLoadMenus
;------------------------------------------------------------------------------
MPLangLoadMenus PROC USES EBX dwLangID:DWORD, hWin:DWORD, lpHandleMainMenu:DWORD, lpHandleContextMenu:DWORD
    LOCAL pMM:DWORD
    LOCAL pCM:DWORD
    LOCAL hMenu:DWORD
    
    IFDEF DEBUG32
    PrintText 'MPLangLoadMenus'
    ENDIF
    
    .IF lpHandleMainMenu == 0 && lpHandleContextMenu == 0
        mov eax, FALSE
        ret
    .ENDIF

    mov pMM, 0
    mov pMM, 0
    mov hMenu, 0
        
    Invoke MPLangGetLanguage, dwLangID, Addr pMM, Addr pCM, NULL
    .IF eax == TRUE
        .IF lpHandleMainMenu != 0
            .IF pMM != 0
                ;PrintDec pMM
                ; Delete Previously Loaded Menu
                mov ebx, lpHandleMainMenu
                mov eax, [ebx]
                .IF eax != 0
                    Invoke DestroyMenu, eax
                .ENDIF
                ; Load New Menu
                Invoke LoadMenuIndirectW, pMM
                .IF eax != 0
                    mov hMenu, eax
                    Invoke SetMenu, hWin, hMenu
                    Invoke DrawMenuBar, hWin
                    mov eax, hMenu
                .ENDIF
                mov ebx, lpHandleMainMenu
                mov [ebx], eax
            .ENDIF
        .ENDIF
        .IF lpHandleContextMenu != 0
            .IF pCM != 0
                ; Delete Previously Loaded Menu
                mov ebx, lpHandleContextMenu
                mov eax, [ebx]
                .IF eax != 0
                    Invoke DestroyMenu, eax
                .ENDIF
                ; Load New Menu
                Invoke LoadMenuIndirectW, pCM
                .IF eax != 0
                    mov hMenu, eax
                    Invoke GetSubMenu, hMenu, 0
                .ENDIF
                mov ebx, lpHandleContextMenu
                mov [ebx], eax
            .ENDIF
        .ENDIF
        mov eax, TRUE
        ret
    .ELSE
        ; MPLangGetLanguage Failed
        .IF lpHandleMainMenu != 0
            mov ebx, lpHandleMainMenu
            mov eax, 0
            mov [ebx], eax
        .ENDIF
        .IF lpHandleContextMenu != 0
            mov ebx, lpHandleContextMenu
            mov eax, 0
            mov [ebx], eax
        .ENDIF
        mov eax, FALSE
        ret
    .ENDIF
    
    ret
MPLangLoadMenus ENDP

;------------------------------------------------------------------------------
; Get language record for specified dwLangID and returns the pointers to the
; uncompressed data via the parameters provided. A parameters can be NULL if
; you do not need that resource. First time access to a lang record will
; decompress it.
;------------------------------------------------------------------------------
MPLangGetLanguage PROC USES EBX dwLangID:DWORD, lpdwMenuMain:DWORD, lpdwMenuContext:DWORD, lpdwStrings:DWORD
    LOCAL pLangRecord:DWORD
    LOCAL nLangRecord:DWORD
    LOCAL bLangRecordFound:DWORD
    LOCAL pMenuMain:DWORD
    LOCAL pMenuMainSrc:DWORD
    LOCAL pMenuContext:DWORD
    LOCAL pMenuContextSrc:DWORD
    LOCAL pStrings:DWORD
    LOCAL pStringsSrc:DWORD
    LOCAL dwMenuSize:DWORD
    LOCAL pMenu:DWORD
    LOCAL wLanguage:WORD
    LOCAL hRes:DWORD
    LOCAL dwResSize:DWORD
    LOCAL hResData:DWORD
    LOCAL pResData:DWORD
    LOCAL hMenu:DWORD
    
    IFDEF DEBUG32
    PrintText 'MPLangGetLanguage'
    ENDIF
    
    lea eax, MP_LANG_TABLE
    mov pLangRecord, eax
    
    mov bLangRecordFound, FALSE
    mov nLangRecord, 0
    mov eax, 0
    .WHILE eax < MP_LANG_RECORD_COUNT
        mov ebx, pLangRecord
        movzx eax, word ptr [ebx].MP_LANG_RECORD.wLanguage
        mov wLanguage, ax
        mov eax, [ebx].MP_LANG_RECORD.dwLangID
        .IF eax == dwLangID
            mov bLangRecordFound, TRUE
            .BREAK
        .ENDIF
        
        add pLangRecord, SIZEOF MP_LANG_RECORD
        inc nLangRecord
        mov eax, nLangRecord
    .ENDW
    
    
    IFNDEF MP_RTLC_RESOURCES ; Use normal menu resources
    .IF bLangRecordFound == TRUE
    
        Invoke FindResourceEx, NULL, RT_MENU, IDM_MENU, wLanguage
        .IF eax != 0
            mov hRes, eax
            Invoke SizeofResource, hInstance, hRes
            mov dwResSize, eax
            Invoke LoadResource, hInstance, hRes
            .IF eax != 0
                mov hResData, eax
                Invoke LockResource, hResData
                .IF eax != 0
                    mov pResData, eax
                    .IF lpdwMenuMain != 0
                        mov ebx, lpdwMenuMain
                        mov [ebx], eax
                    .ENDIF
                .ENDIF
            .ENDIF
        .ENDIF
        
        Invoke FindResourceEx, NULL, RT_MENU, IDM_CONTEXTMENU, wLanguage
        .IF eax != 0
            mov hRes, eax
            Invoke SizeofResource, hInstance, hRes
            mov dwResSize, eax
            Invoke LoadResource, hInstance, hRes
            .IF eax != 0
                mov hResData, eax
                Invoke LockResource, hResData
                .IF eax != 0
                    mov pResData, eax
                    .IF lpdwMenuContext != 0
                        mov ebx, lpdwMenuContext
                        mov [ebx], eax
                    .ENDIF
                .ENDIF
            .ENDIF
        .ENDIF
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    
    ELSE ; Production - Use compressed resources
    
    .IF bLangRecordFound == TRUE

        mov ebx, pLangRecord
        mov eax, [ebx].MP_LANG_RECORD.pMenuMain
        mov pMenuMain, eax
        mov eax, [ebx].MP_LANG_RECORD.pMenuMainSrc
        mov pMenuMainSrc, eax
        mov eax, [ebx].MP_LANG_RECORD.pMenuContext
        mov pMenuContext, eax
        mov eax, [ebx].MP_LANG_RECORD.pMenuContextSrc
        mov pMenuContextSrc, eax
        mov eax, [ebx].MP_LANG_RECORD.pStrings
        mov pStrings, eax
        mov eax, [ebx].MP_LANG_RECORD.pStringsSrc
        mov pStringsSrc, eax
        
        .IF lpdwMenuMain != NULL
            .IF pMenuMain == NULL
                ;PrintText 'RTLC_DecompressMem for pMenuMain'
                Invoke RTLC_DecompressMem, pMenuMainSrc, 0, Addr dwMenuSize
                mov pMenu, eax
                ;PrintDec pMenu
                ;DbgDump pMenu, dwMenuSize
                mov ebx, pLangRecord
                mov eax, pMenu
                mov [ebx].MP_LANG_RECORD.pMenuMain, eax
            .ELSE
                mov eax, pMenuMain
            .ENDIF
            mov ebx, lpdwMenuMain
            mov [ebx], eax
        .ENDIF
        
        .IF lpdwMenuContext != NULL
            .IF pMenuContext == NULL
                ;PrintText 'RTLC_DecompressMem for pMenuContextSrc'
                Invoke RTLC_DecompressMem, pMenuContextSrc, 0, 0
                ;PrintDec eax
                mov ebx, pLangRecord
                mov [ebx].MP_LANG_RECORD.pMenuContext, eax
            .ELSE
                mov eax, pMenuContext
            .ENDIF
            mov ebx, lpdwMenuContext
            mov [ebx], eax
        .ENDIF
        
        .IF lpdwStrings != NULL
            .IF pStrings == NULL
                Invoke RTLC_DecompressMem, pStringsSrc, 0, NULL
                mov ebx, pLangRecord
                mov [ebx].MP_LANG_RECORD.pStrings, eax
            .ELSE
                mov eax, pStrings    
            .ENDIF
            mov ebx, lpdwStrings
            mov [ebx], eax
        .ENDIF
        mov eax, TRUE

    .ELSE
        mov eax, FALSE
    .ENDIF
    
    ENDIF

    
    ret
MPLangGetLanguage ENDP

IFDEF MP_DEVMODE
;------------------------------------------------------------------------------
; MPLangDump
;------------------------------------------------------------------------------
MPLangDump PROC USES EBX
    LOCAL hRes:DWORD
    LOCAL hResData:DWORD
    LOCAL pResData:DWORD
    LOCAL dwSizeRes:DWORD
    LOCAL pLangRecord:DWORD
    LOCAL nLangRecord:DWORD
    LOCAL wLanguage:WORD
    LOCAL pszCC:DWORD
    LOCAL hFile:DWORD
    LOCAL BytesWritten:DWORD
    LOCAL pStringBlock:DWORD
    LOCAL dwStringBlockSize:DWORD
    LOCAL pString:DWORD
    LOCAL nString:DWORD
    LOCAL nStringTotal:DWORD
    LOCAL dwLangID:DWORD
    LOCAL dwLangStringID:DWORD
    LOCAL nTotalCount:DWORD
    LOCAL dwMaxStringSize:DWORD
    LOCAL dwMaxStringSizePre:DWORD
    LOCAL dwLongestStringSize:DWORD
    
    lea eax, MP_LANG_TABLE
    mov pLangRecord, eax
    
    mov nLangRecord, 0
    mov eax, 0
    .WHILE eax < MP_LANG_RECORD_COUNT
        mov ebx, pLangRecord
        mov eax, [ebx].MP_LANG_RECORD.dwLangID
        mov dwLangID, eax
        lea eax, [ebx].MP_LANG_RECORD.szCC
        mov pszCC, eax
        movzx eax, word ptr [ebx].MP_LANG_RECORD.wLanguage
        mov wLanguage, ax
        .IF ax == -1
            jmp MPLangDumpNextRecord
        .ENDIF
        
        ;----------------------------------------------------------------------
        ; Main Menu Resources
        ;----------------------------------------------------------------------
        
        ;----------------------------------------------------------------------
        ; Create filename for lang record resource
        ;----------------------------------------------------------------------
        Invoke GetCurrentDirectory, MAX_PATH, Addr szLangFilename
        Invoke lstrcat, Addr szLangFilename, Addr szLangFolder
        Invoke lstrcat, Addr szLangFilename, Addr szMM
        Invoke lstrcat, Addr szLangFilename, pszCC
        Invoke lstrcat, Addr szLangFilename, Addr szLangExtMnu
        IFDEF DEBUG32
        PrintString szLangFilename
        ENDIF
        
        ;----------------------------------------------------------------------
        ; Find Menu Language Resource & Write it to file 
        ;----------------------------------------------------------------------
        Invoke FindResourceEx, NULL, RT_MENU, IDM_MENU, wLanguage
        .IF eax != 0
            mov hRes, eax
            Invoke SizeofResource, hInstance, hRes
            .IF eax != 0
                mov dwSizeRes, eax
                Invoke LoadResource, hInstance, hRes
                .IF eax != 0
                    mov hResData, eax
                    Invoke LockResource, hResData
                    .IF eax != 0
                        mov pResData, eax
                        
                        ;------------------------------------------------------
                        ; Create output file
                        ;------------------------------------------------------
                        Invoke CreateFile, Addr szLangFilename, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
                        .IF eax == INVALID_HANDLE_VALUE
                            IFDEF DEBUG32
                            PrintText 'MPLangDump CreateFile Failed'
                            ENDIF
                            mov eax, FALSE
                            ret
                        .ENDIF
                        mov hFile, eax
                        
                        ;------------------------------------------------------
                        ; Write out data bytes to file
                        ;------------------------------------------------------
                        Invoke WriteFile, hFile, pResData, dwSizeRes, Addr BytesWritten, NULL
                        .IF eax == 0
                            .IF hFile != 0
                                Invoke CloseHandle, hFile
                            .ENDIF
                            mov eax, FALSE
                            ret
                        .ENDIF
                        
                        ;------------------------------------------------------
                        ; Cleanup
                        ;------------------------------------------------------
                        Invoke CloseHandle, hFile
                        
                    .ENDIF
                .ENDIF
            .ENDIF
        .ENDIF
        
        ;----------------------------------------------------------------------
        ; Context Menu Resources
        ;----------------------------------------------------------------------
        
        ;----------------------------------------------------------------------
        ; Create filename for lang record resource
        ;----------------------------------------------------------------------
        Invoke GetCurrentDirectory, MAX_PATH, Addr szLangFilename
        Invoke lstrcat, Addr szLangFilename, Addr szLangFolder
        Invoke lstrcat, Addr szLangFilename, Addr szMC
        Invoke lstrcat, Addr szLangFilename, pszCC
        Invoke lstrcat, Addr szLangFilename, Addr szLangExtMnu
        IFDEF DEBUG32
        PrintString szLangFilename
        ENDIF
        
        ;----------------------------------------------------------------------
        ; Find Menu Language Resource & Write it to file 
        ;----------------------------------------------------------------------
        Invoke FindResourceEx, NULL, RT_MENU, IDM_CONTEXTMENU, wLanguage
        .IF eax != 0
            mov hRes, eax
            Invoke SizeofResource, hInstance, hRes
            .IF eax != 0
                mov dwSizeRes, eax
                Invoke LoadResource, hInstance, hRes
                .IF eax != 0
                    mov hResData, eax
                    Invoke LockResource, hResData
                    .IF eax != 0
                        mov pResData, eax
                        
                        ;------------------------------------------------------
                        ; Create output file
                        ;------------------------------------------------------
                        Invoke CreateFile, Addr szLangFilename, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
                        .IF eax == INVALID_HANDLE_VALUE
                            IFDEF DEBUG32
                            PrintText 'MPLangDump CreateFile Failed'
                            ENDIF
                            mov eax, FALSE
                            ret
                        .ENDIF
                        mov hFile, eax
                        
                        ;------------------------------------------------------
                        ; Write out data bytes to file
                        ;------------------------------------------------------
                        Invoke WriteFile, hFile, pResData, dwSizeRes, Addr BytesWritten, NULL
                        .IF eax == 0
                            .IF hFile != 0
                                Invoke CloseHandle, hFile
                            .ENDIF
                            mov eax, FALSE
                            ret
                        .ENDIF
                        
                        ;------------------------------------------------------
                        ; Cleanup
                        ;------------------------------------------------------
                        Invoke CloseHandle, hFile
                        
                    .ENDIF
                .ENDIF
            .ENDIF
        .ENDIF
        
        ;----------------------------------------------------------------------
        ; String Resource
        ;----------------------------------------------------------------------
        mov ebx, pLangRecord
        mov eax, [ebx].MP_LANG_RECORD.dwMaxStringSize
        mov dwMaxStringSizePre, eax
        .IF eax == 0
            mov eax, MP_LANG_MAXSTRING_SIZE
        .ENDIF
        mov dwMaxStringSize, eax
        
        mov eax, STRINGID_FINISH
        sub eax, STRINGID_START
        add eax, 1
        mov nStringTotal, eax
        mov ebx, MP_LANG_MAXSTRING_SIZE
        mul ebx
        mov dwStringBlockSize, eax
        
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
        mov pStringBlock, eax
        mov pString, eax
        
        mov dwLongestStringSize, 0
        mov nTotalCount, 0
        
        mov eax, STRINGID_START
        mov nString, STRINGID_START
        .WHILE eax <= STRINGID_FINISH
            mov ebx, pString
            
            mov eax, dwLangID
            mov ebx, LANG_MAX_IDS ;50
            mul ebx
            add eax, 100
            add eax, nString
            mov dwLangStringID, eax
            mov ebx, pString
            Invoke LoadStringW, hInstance, dwLangStringID, Addr [ebx].MP_LANG_STRING_RECORD.szString, MP_LANG_MAXSTRING_SIZE
            .IF eax != 0
                add eax, 1 ; for nulls
                shl eax, 1 ; unicode chars to bytes
                .IF eax > dwLongestStringSize
                    mov dwLongestStringSize, eax
                .ENDIF
                
                ; Save ID to structure
                mov ebx, pString
                mov eax, nString
                mov [ebx], eax
                
                inc nTotalCount
                mov eax, dwMaxStringSize
                add eax, SIZEOF DWORD ; skip past ID
                add pString, eax
            .ENDIF
            inc nString
            mov eax, nString
        .ENDW
        
        mov eax, dwLongestStringSize
        .IF eax > dwMaxStringSizePre
            IFDEF DEBUG32
            PrintText 'WARNING Max String Size Should be changed to:'
            PrintStringByAddr pszCC
            PrintDec dwLongestStringSize
            ENDIF
        .ENDIF
        
        ; Get actual count of entries and size of block
        mov eax, nTotalCount
        mov ebx, dwMaxStringSize ;SIZEOF MP_LANG_STRING_RECORD
        add ebx, SIZEOF DWORD ; for ID
        mul ebx
        mov dwStringBlockSize, eax
        IFDEF DEBUG32
        PrintDec dwStringBlockSize
        ENDIF
        
        ;----------------------------------------------------------------------
        ; Create filename for lang record resource
        ;----------------------------------------------------------------------
        Invoke GetCurrentDirectory, MAX_PATH, Addr szLangFilename
        Invoke lstrcat, Addr szLangFilename, Addr szLangFolder
        Invoke lstrcat, Addr szLangFilename, Addr szSTR
        Invoke lstrcat, Addr szLangFilename, pszCC
        Invoke lstrcat, Addr szLangFilename, Addr szLangExtStr
        IFDEF DEBUG32
        PrintString szLangFilename
        ENDIF
        
        ;----------------------------------------------------------------------
        ; Create output file
        ;----------------------------------------------------------------------
        Invoke CreateFile, Addr szLangFilename, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
        .IF eax == INVALID_HANDLE_VALUE
            IFDEF DEBUG32
            PrintText 'MPLangDump CreateFile Failed'
            ENDIF
            mov eax, FALSE
            ret
        .ENDIF
        mov hFile, eax
        
        ;----------------------------------------------------------------------
        ; Write out data bytes to file
        ;----------------------------------------------------------------------
        Invoke WriteFile, hFile, pStringBlock, dwStringBlockSize, Addr BytesWritten, NULL
        .IF eax == 0
            .IF hFile != 0
                Invoke CloseHandle, hFile
            .ENDIF
            mov eax, FALSE
            ret
        .ENDIF
        
        ;----------------------------------------------------------------------
        ; Cleanup
        ;----------------------------------------------------------------------
        Invoke CloseHandle, hFile
        
MPLangDumpNextRecord:
        
        add pLangRecord, SIZEOF MP_LANG_RECORD
        inc nLangRecord
        mov eax, nLangRecord
    .ENDW

    
    mov eax, TRUE
    ret
MPLangDump ENDP
ENDIF



















