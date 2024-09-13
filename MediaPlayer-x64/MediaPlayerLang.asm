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

MPLangLoadMenus             PROTO dwLangID:DWORD, hWin:QWORD, lpHandleMainMenu:QWORD, lpHandleContextMenu:QWORD
MPLangGetLanguage           PROTO dwLangID:DWORD, lpqwMenuMain:QWORD, lpqwMenuContext:QWORD, lpqwStrings:QWORD
IFDEF MP_DEVMODE
MPLangDump PROTO
ENDIF

IFNDEF MP_LANG_RECORD
MP_LANG_RECORD              STRUCT 8
    dwLangID                DD ?
    pMenuMain               DQ ?
    pMenuMainSrc            DQ ?
    pMenuContext            DQ ?
    pMenuContextSrc         DQ ?
    pStrings                DQ ?
    pStringsSrc             DQ ?
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

; Primary
LANG_NEUTRAL            EQU 000h
LANG_ENGLISH            EQU 009h
LANG_FRENCH             EQU 00Ch
LANG_GERMAN             EQU 007h
LANG_POLISH             EQU 015h
LANG_ITALIAN            EQU 010h
LANG_SPANISH            EQU 00Ah

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

.DATA
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

include .\Lang\MC_DEF.mnu.bin.rtlc.asm
include .\Lang\MC_EN.mnu.bin.rtlc.asm
include .\Lang\MC_FR.mnu.bin.rtlc.asm
include .\Lang\MC_DE.mnu.bin.rtlc.asm
include .\Lang\MC_PL.mnu.bin.rtlc.asm
include .\Lang\MC_IT.mnu.bin.rtlc.asm
include .\Lang\MC_ES.mnu.bin.rtlc.asm

include .\Lang\STR_DEF.str.bin.rtlc.asm
include .\Lang\STR_EN.str.bin.rtlc.asm
include .\Lang\STR_FR.str.bin.rtlc.asm
include .\Lang\STR_DE.str.bin.rtlc.asm
include .\Lang\STR_PL.str.bin.rtlc.asm
include .\Lang\STR_IT.str.bin.rtlc.asm
include .\Lang\STR_ES.str.bin.rtlc.asm
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
MP_LANG_RECORD <0, 0, 0, 0, 0, 0, 0, 0, 0>
MP_LANG_RECORD_COUNT DD (($-MP_LANG_TABLE) / SIZEOF MP_LANG_RECORD) -1
ENDIF

.CODE

;------------------------------------------------------------------------------
; MPLangLoadMenus
;------------------------------------------------------------------------------
MPLangLoadMenus PROC FRAME USES RBX dwLangID:DWORD, hWin:QWORD, lpHandleMainMenu:QWORD, lpHandleContextMenu:QWORD
    LOCAL pMM:QWORD
    LOCAL pCM:QWORD
    LOCAL hMenu:QWORD
    
    IFDEF DEBUG64
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
                mov rbx, lpHandleMainMenu
                mov rax, [rbx]
                .IF rax != 0
                    Invoke DestroyMenu, rax
                .ENDIF
                ; Load New Menu
                Invoke LoadMenuIndirectW, pMM
                .IF rax != 0
                    mov hMenu, rax
                    Invoke SetMenu, hWin, hMenu
                    Invoke DrawMenuBar, hWin
                    mov rax, hMenu
                .ENDIF
                mov rbx, lpHandleMainMenu
                mov [rbx], rax
            .ENDIF
        .ENDIF
        .IF lpHandleContextMenu != 0
            .IF pCM != 0
                ; Delete Previously Loaded Menu
                mov rbx, lpHandleContextMenu
                mov rax, [rbx]
                .IF rax != 0
                    Invoke DestroyMenu, rax
                .ENDIF
                ; Load New Menu
                Invoke LoadMenuIndirectW, pCM
                .IF rax != 0
                    mov hMenu, rax
                    Invoke GetSubMenu, hMenu, 0
                .ENDIF
                mov rbx, lpHandleContextMenu
                mov [rbx], rax
            .ENDIF
        .ENDIF
        mov eax, TRUE
        ret
    .ELSE
        ; MPLangGetLanguage Failed
        .IF lpHandleMainMenu != 0
            mov rbx, lpHandleMainMenu
            mov rax, 0
            mov [rbx], rax
        .ENDIF
        .IF lpHandleContextMenu != 0
            mov rbx, lpHandleContextMenu
            mov rax, 0
            mov [rbx], rax
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
MPLangGetLanguage PROC FRAME USES RBX dwLangID:DWORD, lpqwMenuMain:QWORD, lpqwMenuContext:QWORD, lpqwStrings:QWORD
    LOCAL pLangRecord:QWORD
    LOCAL nLangRecord:DWORD
    LOCAL bLangRecordFound:DWORD
    LOCAL pMenuMain:QWORD
    LOCAL pMenuMainSrc:QWORD
    LOCAL pMenuContext:QWORD
    LOCAL pMenuContextSrc:QWORD
    LOCAL pStrings:QWORD
    LOCAL pStringsSrc:QWORD
    LOCAL qwMenuSize:QWORD
    LOCAL pMenu:QWORD
    LOCAL wLanguage:WORD
    LOCAL hRes:QWORD
    LOCAL qwResSize:QWORD
    LOCAL hResData:QWORD
    LOCAL pResData:QWORD
    LOCAL hMenu:QWORD
    
    IFDEF DEBUG64
    PrintText 'MPLangGetLanguage'
    ENDIF
    
    lea rax, MP_LANG_TABLE
    mov pLangRecord, rax
    
    mov bLangRecordFound, FALSE
    mov nLangRecord, 0
    mov eax, 0
    .WHILE eax < MP_LANG_RECORD_COUNT
        mov rbx, pLangRecord
        movzx eax, word ptr [rbx].MP_LANG_RECORD.wLanguage
        mov wLanguage, ax
        mov eax, dword ptr [rbx].MP_LANG_RECORD.dwLangID
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
        .IF rax != 0
            mov hRes, rax
            Invoke SizeofResource, hInstance, hRes
            mov qwResSize, rax
            Invoke LoadResource, hInstance, hRes
            .IF rax != 0
                mov hResData, rax
                Invoke LockResource, hResData
                .IF rax != 0
                    mov pResData, rax
                    .IF lpqwMenuMain != 0
                        mov rbx, lpqwMenuMain
                        mov [rbx], rax
                    .ENDIF
                .ENDIF
            .ENDIF
        .ENDIF
        
        Invoke FindResourceEx, NULL, RT_MENU, IDM_CONTEXTMENU, wLanguage
        .IF rax != 0
            mov hRes, eax
            Invoke SizeofResource, hInstance, hRes
            mov qwResSize, rax
            Invoke LoadResource, hInstance, hRes
            .IF rax != 0
                mov hResData, rax
                Invoke LockResource, hResData
                .IF rax != 0
                    mov pResData, rax
                    .IF lpqwMenuContext != 0
                        mov rbx, lpqwMenuContext
                        mov [rbx], rax
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

        mov rbx, pLangRecord
        mov rax, [rbx].MP_LANG_RECORD.pMenuMain
        mov pMenuMain, rax
        mov rax, [rbx].MP_LANG_RECORD.pMenuMainSrc
        mov pMenuMainSrc, rax
        mov rax, [rbx].MP_LANG_RECORD.pMenuContext
        mov pMenuContext, rax
        mov rax, [rbx].MP_LANG_RECORD.pMenuContextSrc
        mov pMenuContextSrc, rax
        mov rax, [rbx].MP_LANG_RECORD.pStrings
        mov pStrings, rax
        mov rax, [rbx].MP_LANG_RECORD.pStringsSrc
        mov pStringsSrc, rax
        
        .IF lpqwMenuMain != NULL
            .IF pMenuMain == NULL
                ;PrintText 'RTLC_DecompressMem for pMenuMain'
                Invoke RTLC_DecompressMem, pMenuMainSrc, 0, Addr qwMenuSize
                mov pMenu, rax
                ;PrintDec pMenu
                ;DbgDump pMenu, dwMenuSize
                mov rbx, pLangRecord
                mov rax, pMenu
                mov [rbx].MP_LANG_RECORD.pMenuMain, rax
            .ELSE
                mov rax, pMenuMain
            .ENDIF
            mov rbx, lpqwMenuMain
            mov [rbx], rax
        .ENDIF
        
        .IF lpqwMenuContext != NULL
            .IF pMenuContext == NULL
                ;PrintText 'RTLC_DecompressMem for pMenuContextSrc'
                Invoke RTLC_DecompressMem, pMenuContextSrc, 0, 0
                ;PrintDec eax
                mov rbx, pLangRecord
                mov [rbx].MP_LANG_RECORD.pMenuContext, rax
            .ELSE
                mov rax, pMenuContext
            .ENDIF
            mov rbx, lpqwMenuContext
            mov [rbx], rax
        .ENDIF
        
        .IF lpqwStrings != NULL
            .IF pStrings == NULL
                Invoke RTLC_DecompressMem, pStringsSrc, 0, NULL
                mov rbx, pLangRecord
                mov [rbx].MP_LANG_RECORD.pStrings, rax
            .ELSE
                mov rax, pStrings    
            .ENDIF
            mov rbx, lpqwStrings
            mov [rbx], rax
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
MPLangDump PROC FRAME USES RBX
    LOCAL hRes:QWORD
    LOCAL hResData:QWORD
    LOCAL pResData:QWORD
    LOCAL dwSizeRes:DWORD
    LOCAL pLangRecord:QWORD
    LOCAL nLangRecord:DWORD
    LOCAL wLanguage:WORD
    LOCAL pszCC:QWORD
    LOCAL hFile:QWORD
    LOCAL BytesWritten:DWORD
    LOCAL pStringBlock:QWORD
    LOCAL dwStringBlockSize:DWORD
    LOCAL pString:QWORD
    LOCAL nString:DWORD
    LOCAL nStringTotal:DWORD
    LOCAL dwLangID:DWORD
    LOCAL dwLangStringID:DWORD
    LOCAL nTotalCount:DWORD
    LOCAL dwMaxStringSize:DWORD
    LOCAL dwMaxStringSizePre:DWORD
    LOCAL dwLongestStringSize:DWORD
    
    lea rax, MP_LANG_TABLE
    mov pLangRecord, rax
    
    mov nLangRecord, 0
    mov eax, 0
    .WHILE eax < MP_LANG_RECORD_COUNT
        mov rbx, pLangRecord
        mov eax, dword ptr [rbx].MP_LANG_RECORD.dwLangID
        mov dwLangID, eax
        lea rax, [rbx].MP_LANG_RECORD.szCC
        mov pszCC, rax
        movzx eax, word ptr [rbx].MP_LANG_RECORD.wLanguage
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
        IFDEF DEBUG64
        PrintString szLangFilename
        ENDIF
        
        ;----------------------------------------------------------------------
        ; Find Menu Language Resource & Write it to file 
        ;----------------------------------------------------------------------
        Invoke FindResourceEx, NULL, RT_MENU, IDM_MENU, wLanguage
        .IF rax != 0
            mov hRes, rax
            Invoke SizeofResource, hInstance, hRes
            .IF rax != 0
                mov dwSizeRes, eax
                Invoke LoadResource, hInstance, hRes
                .IF rax != 0
                    mov hResData, rax
                    Invoke LockResource, hResData
                    .IF rax != 0
                        mov pResData, rax
                        
                        ;------------------------------------------------------
                        ; Create output file
                        ;------------------------------------------------------
                        Invoke CreateFile, Addr szLangFilename, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
                        .IF rax == INVALID_HANDLE_VALUE
                            IFDEF DEBUG64
                            PrintText 'MPLangDump CreateFile Failed'
                            ENDIF
                            mov eax, FALSE
                            ret
                        .ENDIF
                        mov hFile, rax
                        
                        ;------------------------------------------------------
                        ; Write out data bytes to file
                        ;------------------------------------------------------
                        Invoke WriteFile, hFile, pResData, dwSizeRes, Addr BytesWritten, NULL
                        .IF rax == 0
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
        IFDEF DEBUG64
        PrintString szLangFilename
        ENDIF
        
        ;----------------------------------------------------------------------
        ; Find Menu Language Resource & Write it to file 
        ;----------------------------------------------------------------------
        Invoke FindResourceEx, NULL, RT_MENU, IDM_CONTEXTMENU, wLanguage
        .IF rax != 0
            mov hRes, rax
            Invoke SizeofResource, hInstance, hRes
            .IF rax != 0
                mov dwSizeRes, eax
                Invoke LoadResource, hInstance, hRes
                .IF rax != 0
                    mov hResData, rax
                    Invoke LockResource, hResData
                    .IF rax != 0
                        mov pResData, rax
                        
                        ;------------------------------------------------------
                        ; Create output file
                        ;------------------------------------------------------
                        Invoke CreateFile, Addr szLangFilename, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
                        .IF rax == INVALID_HANDLE_VALUE
                            IFDEF DEBUG64
                            PrintText 'MPLangDump CreateFile Failed'
                            ENDIF
                            mov eax, FALSE
                            ret
                        .ENDIF
                        mov hFile, rax
                        
                        ;------------------------------------------------------
                        ; Write out data bytes to file
                        ;------------------------------------------------------
                        Invoke WriteFile, hFile, pResData, dwSizeRes, Addr BytesWritten, NULL
                        .IF rax == 0
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
        mov rbx, pLangRecord
        mov eax, dword ptr [rbx].MP_LANG_RECORD.dwMaxStringSize
        mov dwMaxStringSizePre, eax
        ;.IF eax == 0
            mov eax, MP_LANG_MAXSTRING_SIZE
        ;.ENDIF
        mov dwMaxStringSize, eax
        
        mov eax, STRINGID_FINISH
        sub eax, STRINGID_START
        add eax, 1
        mov nStringTotal, eax
        mov ebx, MP_LANG_MAXSTRING_SIZE
        mul ebx
        mov dwStringBlockSize, eax
        
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
        mov pStringBlock, rax
        mov pString, rax
        
        mov dwLongestStringSize, 0
        mov nTotalCount, 0
        
        mov eax, STRINGID_START
        mov nString, STRINGID_START
        .WHILE eax <= STRINGID_FINISH
            mov rbx, pString
            
            mov eax, dwLangID
            mov ebx, LANG_MAX_IDS ;50
            mul ebx
            add eax, 100
            add eax, nString
            mov dwLangStringID, eax
            mov rbx, pString
            Invoke LoadStringW, hInstance, dwLangStringID, Addr [rbx].MP_LANG_STRING_RECORD.szString, MP_LANG_MAXSTRING_SIZE
            .IF rax != 0
                add rax, 1 ; for nulls
                shl rax, 1 ; unicode chars to bytes
                .IF eax > dwLongestStringSize
                    mov dwLongestStringSize, eax
                .ENDIF
                
                ; Save ID to structure
                mov rbx, pString
                mov eax, nString
                mov [rbx], eax
                
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
            IFDEF DEBUG64
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
        
        ;----------------------------------------------------------------------
        ; Create filename for lang record resource
        ;----------------------------------------------------------------------
        Invoke GetCurrentDirectory, MAX_PATH, Addr szLangFilename
        Invoke lstrcat, Addr szLangFilename, Addr szLangFolder
        Invoke lstrcat, Addr szLangFilename, Addr szSTR
        Invoke lstrcat, Addr szLangFilename, pszCC
        Invoke lstrcat, Addr szLangFilename, Addr szLangExtStr
        IFDEF DEBUG64
        PrintString szLangFilename
        ENDIF
        
        ;----------------------------------------------------------------------
        ; Create output file
        ;----------------------------------------------------------------------
        Invoke CreateFile, Addr szLangFilename, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
        .IF rax == INVALID_HANDLE_VALUE
            IFDEF DEBUG64
            PrintText 'MPLangDump CreateFile Failed'
            ENDIF
            mov eax, FALSE
            ret
        .ENDIF
        mov hFile, rax
        
        ;----------------------------------------------------------------------
        ; Write out data bytes to file
        ;----------------------------------------------------------------------
        Invoke WriteFile, hFile, pStringBlock, dwStringBlockSize, Addr BytesWritten, NULL
        .IF rax == 0
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



















