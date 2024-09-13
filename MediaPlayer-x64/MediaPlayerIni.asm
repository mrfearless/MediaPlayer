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
;include advapi32.inc
includelib advapi32.lib
includelib shell32.lib
includelib kernel32.Lib

IniFilenameCreate           PROTO lpszIniFile:QWORD, lpszBaseModuleName:QWORD
IniInit                     PROTO hWin:QWORD, lpszIniFilename:QWORD

IniMRUReloadListToMenu      PROTO hWin:QWORD, lpszIniFilename:QWORD, dwMenuInsertID:DWORD, hMRUBitmap:QWORD, hMRUClearBitmap:QWORD ; Reloads the MRU list and updates the list under the File menu
IniMRULoadListToMenu        PROTO hWin:QWORD, lpszIniFilename:QWORD, dwMenuInsertID:DWORD, hMRUBitmap:QWORD, hMRUClearBitmap:QWORD ; Loads Most Recently Used (MRU) file list to the Main Menu under the File menu
IniMRUClearListFromMenu     PROTO hWin:QWORD, lpszIniFilename:QWORD, dwMenuInsertID:DWORD

IniMRUEntrySaveFilename     PROTO hWin:QWORD, lpszFilename:QWORD, lpszIniFilename:QWORD ; Saves a new MRU entry name (full filepath to file)
IniMRUEntryDeleteFilename   PROTO hWin:QWORD, lpszFilename:QWORD, lpszIniFilename:QWORD ; Deletes a new MRU entry name (full filepath to file)

IniSaveWindowPosition       PROTO hWin:QWORD, lpszIniFilename:QWORD
IniLoadWindowPosition       PROTO hWin:QWORD, lpszIniFilename:QWORD

IniGetLanguage              PROTO hWin:QWORD, lpszIniFilename:QWORD
IniSetLanguage              PROTO hWin:QWORD, lpszIniFilename:QWORD

IFNDEF SHGetSpecialFolderLocation
SHGetSpecialFolderLocation  PROTO hWin:QWORD, csidl:DWORD, ppidl:QWORD
ENDIF
;IFNDEF SHGetPathFromIDList
;SHGetPathFromIDList         PROTO pidl:QWORD, pszPath:QWORD
;ENDIF
IFNDEF lstrcpynA
lstrcpynA                   PROTO lpString1:QWORD, lpString2:QWORD, iMaxLength:DWORD
ENDIF
IFNDEF CSIDL_APPDATA
CSIDL_APPDATA equ 001ah
ENDIF
IFNDEF SHGetPathFromIDListA
SHGetPathFromIDListA        PROTO pidl:QWORD, pszPath:QWORD
ENDIF
IFNDEF SHGetPathFromIDListW
SHGetPathFromIDListW        PROTO pidl:QWORD, pszPath:QWORD
ENDIF


.CONST
MRU_MAXFILES                EQU 10
IDM_MRU                     EQU 20000
IDM_MRU_FIRST               EQU IDM_MRU - (MRU_MAXFILES +1)
IDM_MRU_LAST                EQU IDM_MRU - 1 ; 19999
IDM_MRU_SEP1                EQU IDM_MRU - (MRU_MAXFILES +8) ; 19982
IDM_MRU_CLEAR               EQU IDM_MRU - (MRU_MAXFILES +9) ; 19981
IDM_MRU_SEP2                EQU IDM_MRU - (MRU_MAXFILES +10) ; 19980

.DATA
;--------------------------------------
; Ini strings
;--------------------------------------
IFDEF __UNICODE__
szIniExt                    DB ".",0,"i",0,"n",0,"i",0
                            DB 0,0,0,0
szIniMediaPlayer            DB "M",0,"e",0,"d",0,"i",0,"a",0,"P",0,"l",0,"a",0,"y",0,"e",0,"r",0
                            DB 0,0,0,0
szIniLanguage               DB "L",0,"a",0,"n",0,"g",0,"u",0,"a",0,"g",0,"e",0
                            DB 0,0,0,0
szIniOptions                DB "O",0,"p",0,"t",0,"i",0,"o",0,"n",0,"s",0
                            DB 0,0,0,0
szIniWinPos                 DB "W",0,"i",0,"n",0,"P",0,"o",0,"s",0
                            DB 0,0,0,0
szIniValueZero              DB "0",0
                            DB 0,0,0,0
szIniValueOne               DB "1",0
                            DB 0,0,0,0
szIniDefault                DB ":",0
                            DB 0,0,0,0
szIniBackslash              DB "\",0
                            DB 0,0,0,0
szIniSpace                  DB " ",0
                            DB 0,0,0,0
szMRUSection                DB "M",0,"R",0,"U",0
                            DB 0,0,0,0
;szMRUClear                  DB "C",0,"l",0,"e",0,"a",0,"r",0," ",0,"R",0,"e",0,"c",0,"e",0,"n",0,"t",0," ",0,"F",0,"i",0,"l",0,"e",0,"s",0
;                            DB 0,0,0,0
szMRUFilename               DB 1024 dup (0)
Unicode16BitLEBOM           DB 0FFh,0FEh
szIniPlayPause              DD 023EFh ; PlayPause Glyph
                            DD 0,0,0,0
ELSE
szIniExt                    DB ".ini",0
szIniMediaPlayer            DB "MediaPlayer",0
szIniLanguage               DB "Language",0
szIniOptions                DB "Options",0
szIniWinPos                 DB "WinPos",0
szIniValueZero              DB "0",0
szIniValueOne               DB "1",0
szIniDefault                DB ":",0
szIniBackslash              DB "\",0
szIniSpace                  DB " ",0
szMRUSection                DB "MRU",0
;szMRUClear                  DB "Clear Recent Files",0
szMRUFilename               DB 512 dup (0)
ENDIF

IFDEF __UNICODE__
ModuleFullPathname          DB 1024 dup (0)
ModuleName                  DB 1024 dup (0)
ELSE
ModuleFullPathname          DB 512 dup (0)
ModuleName                  DB 512 dup (0)
ENDIF

.CODE

;------------------------------------------------------------------------------
; Create an .ini filename based on the executables name.
; 
; Example Usage:
; 
; Invoke IniFilenameCreate, Addr szIniFilename
;------------------------------------------------------------------------------
IniFilenameCreate PROC FRAME USES RBX lpszIniFile:QWORD, lpszBaseModuleName:QWORD
    LOCAL VersionInformation:OSVERSIONINFO
    LOCAL hInst:QWORD
    LOCAL ppidl:QWORD
    LOCAL Version:DWORD
    IFDEF __UNICODE__
    LOCAL hFile:QWORD
    LOCAL BytesWritten:QWORD
    LOCAL BytesRead:QWORD
    LOCAL BOMBuffer[2]:BYTE
    ENDIF
    
    IFDEF DEBUG64
    ;PrintText 'IniFilenameCreate'
    ENDIF
    
    Invoke GetModuleFileName, NULL, Addr ModuleFullPathname, SIZEOF ModuleFullPathname
    Invoke lstrcpy, Addr ModuleName, Addr ModuleFullPathname
    Invoke PathRemoveExtension, Addr ModuleName
    Invoke PathStripPath, Addr ModuleName
    
    ; Determine what OS we are running on
    mov VersionInformation.dwOSVersionInfoSize, SIZEOF OSVERSIONINFO
    Invoke GetVersionEx, Addr VersionInformation
    mov eax, VersionInformation.dwMajorVersion
    mov Version, eax
    
    .IF Version > 5 ; Vista / Win7          
        ;----------------------------------------------------------------------
        ; Glue all the bits together to make the new ini file location
        ;----------------------------------------------------------------------
        Invoke GetModuleHandle, NULL
        mov hInst, rax      
        Invoke SHGetSpecialFolderLocation, hInst, CSIDL_APPDATA, Addr ppidl
        IFDEF __UNICODE__
        Invoke SHGetPathFromIDListW, ppidl, lpszIniFile
        ELSE
        Invoke SHGetPathFromIDListA, ppidl, lpszIniFile
        ENDIF
        Invoke lstrcat, lpszIniFile, Addr szIniBackslash    ; add a backslash to this path
        Invoke lstrcat, lpszIniFile, Addr ModuleName        ; and add our app exe name
        Invoke GetFileAttributes, lpszIniFile
        .IF rax != FILE_ATTRIBUTE_DIRECTORY             
            Invoke CreateDirectory, lpszIniFile, NULL       ; create directory if needed
        .ENDIF
        Invoke lstrcat, lpszIniFile, Addr szIniBackslash    ; add a backslash to this as well       

        IFDEF __UNICODE__
        Invoke lstrcat, lpszIniFile, Addr szIniPlayPause    ; add unicode char for play/pause to our ini filename for unicode/wide
        Invoke lstrcat, lpszIniFile, Addr szIniSpace
        Invoke lstrcat, lpszIniFile, Addr ModuleName        ; add module name to our folder path
        ELSE
        Invoke lstrcat, lpszIniFile, Addr ModuleName        ; add module name to our folder path
        ENDIF
        invoke lstrcat, lpszIniFile, Addr szIniExt
        
    .ELSE ; WinXP
    
        Invoke PathRemoveExtension, Addr ModuleFullPathname
        Invoke lstrcpy, lpszIniFile, Addr ModuleFullPathname
        Invoke lstrcat, lpszIniFile, Addr szIniExt
    .ENDIF
    
    .IF lpszBaseModuleName != NULL ; save the result to address specified by user
        Invoke lstrcpy, lpszBaseModuleName, Addr ModuleName ; (2nd parameter)
    .ENDIF
    
    IFDEF __UNICODE__ 
        ;----------------------------------------------------------------------
        ; Check for Unicode BOM in ini file, create it otherwise.
        ;----------------------------------------------------------------------
        Invoke CreateFile, lpszIniFile, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
        mov hFile, rax
        .IF rax == INVALID_HANDLE_VALUE 
            ;------------------------------------------------------------------
            ; Ini file doesnt already exist, so we create it and add BOM
            ;------------------------------------------------------------------ 
            Invoke CreateFile, lpszIniFile, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, NULL, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, NULL
            mov hFile, rax
            .IF eax == INVALID_HANDLE_VALUE 
                ;--------------------------------------------------------------
                ; Error creating ini file. Not much we can do now.
                ;--------------------------------------------------------------
                IFDEF DEBUG64
                PrintText 'IniFilenameCreate CreateFile Error'
                Invoke GetLastError
                PrintDec rax
                ENDIF
            .ELSE
                ;--------------------------------------------------------------
                ; Created ini file successfully, so add Unicode BOM to file now
                ;--------------------------------------------------------------
                Invoke WriteFile, hFile, Addr Unicode16BitLEBOM, 2, Addr BytesWritten, NULL
                Invoke CloseHandle, hFile
            .ENDIF
        .ELSE
            ;------------------------------------------------------------------
            ; Ini file already exists, so check if it has a Unicode BOM marker
            ;------------------------------------------------------------------
            Invoke ReadFile, hFile, Addr BOMBuffer, 2, Addr BytesRead, NULL
            .IF rax == TRUE
                lea rbx, BOMBuffer
                xor rax, rax
                movzx eax, word ptr [rbx]
                .IF eax != 0FEFFh
                    ;----------------------------------------------------------
                    ; Ini file has no Unicode BOM at start of ini file.
                    ; Sorry folks, have to add the Unicode BOM marker for 
                    ; wide/unicode support in ini files, which will erase any 
                    ; existing ini settings that where there previously.
                    ;----------------------------------------------------------
                    Invoke WriteFile, hFile, Addr Unicode16BitLEBOM, 2, Addr BytesWritten, NULL
                .ELSE 
                    ;----------------------------------------------------------
                    ; Ini file has Unicode BOM, so all is ok.
                    ;----------------------------------------------------------
                .ENDIF
            .ELSE 
                ;--------------------------------------------------------------
                ; Error reading ini file to check if it has unicode BOM
                ;--------------------------------------------------------------
                IFDEF DEBUG64
                PrintText 'IniFilenameCreate ReadFile Error'
                Invoke GetLastError
                PrintDec rax
                ENDIF
            .ENDIF
            Invoke CloseHandle, hFile
        .ENDIF
    ENDIF
    
    mov rax, TRUE
    ret
IniFilenameCreate ENDP

;------------------------------------------------------------------------------
; Read ini settings and set global variables
;------------------------------------------------------------------------------
IniInit PROC hWin:QWORD, lpszIniFilename:QWORD
    Invoke IniGetLanguage, hWin, lpszIniFilename
    mov g_LangID, eax
    ret
IniInit ENDP

;------------------------------------------------------------------------------
; IniMRUReloadListToMenu - RELoads MRU file information from the ini file into file menu
;------------------------------------------------------------------------------
IniMRUReloadListToMenu PROC FRAME hWin:QWORD, lpszIniFilename:QWORD, dwMenuInsertID:DWORD, hMRUBitmap:QWORD, hMRUClearBitmap:QWORD
	LOCAL nMenuID:DWORD
	LOCAL hMainMenu:QWORD
    LOCAL nMRUEntry:DWORD
	
	Invoke GetMenu, hWin
	.IF rax == NULL
		mov rax, FALSE
		ret 
	.endif
	mov hMainMenu, rax
	mov nMenuID, IDM_MRU_FIRST ;19991
    mov nMRUEntry, 1
    
    RemoveMRUEntries:
    mov eax, nMRUEntry
    .IF eax < MRU_MAXFILES ; 9 MRUs max
        Invoke RemoveMenu, hMainMenu, nMenuID, MF_BYCOMMAND
		inc nMenuID
		inc nMRUEntry
		mov eax, nMRUEntry    
		jmp RemoveMRUEntries
	.ENDIF
	Invoke RemoveMenu, hMainMenu, IDM_MRU_SEP1, MF_BYCOMMAND
	Invoke RemoveMenu, hMainMenu, IDM_MRU_CLEAR, MF_BYCOMMAND
	Invoke RemoveMenu, hMainMenu, IDM_MRU_SEP2, MF_BYCOMMAND
	Invoke DrawMenuBar, hWin
    Invoke IniMRULoadListToMenu, hWin, lpszIniFilename, dwMenuInsertID, hMRUBitmap, hMRUClearBitmap
    ret
IniMRUReloadListToMenu ENDP

;------------------------------------------------------------------------------
; IniMRULoadListToMenu - Loads MRU file information from the ini file into file menu
;------------------------------------------------------------------------------
IniMRULoadListToMenu PROC FRAME hWin:QWORD, lpszIniFilename:QWORD, dwMenuInsertID:DWORD, hMRUBitmap:QWORD, hMRUClearBitmap:QWORD
	LOCAL szMRUEntry[16]:BYTE
	LOCAL nMRUEntry:DWORD
	LOCAL pWideMRUEntry:QWORD
	LOCAL nTotalMRUs:DWORD
	LOCAL nMenuID:DWORD
	LOCAL hMainMenu:QWORD

	Invoke GetMenu, hWin
	.IF rax == NULL
		mov rax, FALSE
		ret 
	.endif
	mov hMainMenu, rax
    
	mov nMenuID, IDM_MRU_FIRST ;19991
	mov nMRUEntry, 1
	mov nTotalMRUs, 0
	
	ReadMRUProfiles:
	mov eax, nMRUEntry
	.IF eax < MRU_MAXFILES ;10 ; 9 MRUs max
		Invoke dwtoa, nMRUEntry, Addr szMRUEntry
		IFDEF __UNICODE__
		Invoke MFPConvertStringToWide, Addr szMRUEntry
        mov pWideMRUEntry, rax
        Invoke lstrcpy, Addr szMRUEntry, pWideMRUEntry
        Invoke MFPConvertStringFree, pWideMRUEntry
		ENDIF
		Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUEntry, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
		.IF rax != 0
		    Invoke lstrcmp, Addr szMRUFilename, Addr szIniDefault ; If the strings are equal, the return value is zero
			;Invoke szCmp, Addr szMRUFilename, Addr szIniDefault ; If there is no match, the return value is zero.
			;.IF rax == 0
			.IF rax != 0
				Invoke InsertMenu, hMainMenu, dwMenuInsertID, MF_STRING or MF_BYCOMMAND, nMenuID, Addr szMRUFilename
				.IF hMRUBitmap != 0
				    Invoke SetMenuItemBitmaps, hMainMenu, nMenuID, MF_BYCOMMAND, hMRUBitmap, 0
				.ENDIF
				inc nTotalMRUs
			.ENDIF
		.ENDIF		
		inc nMenuID
		inc nMRUEntry
		mov eax, nMRUEntry
		jmp ReadMRUProfiles
	.ENDIF	

	.IF nTotalMRUs > 0
		Invoke InsertMenu, hMainMenu, dwMenuInsertID, MF_SEPARATOR or MF_BYCOMMAND, IDM_MRU_SEP1, NULL
		Invoke InsertMenu, hMainMenu, dwMenuInsertID, MF_STRING	or MF_BYCOMMAND, IDM_MRU_CLEAR, Addr szMRUClear
		.IF hMRUClearBitmap != 0
		    Invoke SetMenuItemBitmaps, hMainMenu, IDM_MRU_CLEAR, MF_BYCOMMAND, hMRUClearBitmap, 0
		.ENDIF
		Invoke InsertMenu, hMainMenu, dwMenuInsertID, MF_SEPARATOR or MF_BYCOMMAND, IDM_MRU_SEP2, NULL
	.ENDIF

	Invoke DrawMenuBar, hWin
	
	mov rax, TRUE
	ret
IniMRULoadListToMenu ENDP

;------------------------------------------------------------------------------
; IniMRUClearListFromMenu - Clears MRU files from the ini file and file menu
;------------------------------------------------------------------------------
IniMRUClearListFromMenu PROC FRAME hWin:QWORD, lpszIniFilename:QWORD, dwMenuInsertID:DWORD
    LOCAL szMRUEntry[16]:BYTE
    LOCAL pWideMRUEntry:QWORD
	LOCAL nMenuID:DWORD
	LOCAL hMainMenu:QWORD
    LOCAL nMRUEntry:DWORD
	
	Invoke GetMenu, hWin
	.IF eax == NULL
		mov eax, FALSE
		ret 
	.endif
	mov hMainMenu, rax
	
	mov nMenuID, IDM_MRU_FIRST ;19991
    mov nMRUEntry, 1
    
    RemoveMRUEntries:
    mov eax, nMRUEntry
    .IF eax < MRU_MAXFILES ; 9 MRUs max
        Invoke RemoveMenu, hMainMenu, nMenuID, MF_BYCOMMAND
	    Invoke dwtoa, nMRUEntry, Addr szMRUEntry
		IFDEF __UNICODE__
		Invoke MFPConvertStringToWide, Addr szMRUEntry
        mov pWideMRUEntry, rax
        Invoke lstrcpy, Addr szMRUEntry, pWideMRUEntry
        Invoke MFPConvertStringFree, pWideMRUEntry
		ENDIF
        
        Invoke WritePrivateProfileString, Addr szMRUSection, Addr szMRUEntry, NULL, lpszIniFilename
        
		inc nMenuID
		inc nMRUEntry
		mov eax, nMRUEntry    
		jmp RemoveMRUEntries
	.ENDIF
	Invoke RemoveMenu, hMainMenu, IDM_MRU_SEP1, MF_BYCOMMAND
	Invoke RemoveMenu, hMainMenu, IDM_MRU_CLEAR, MF_BYCOMMAND
	Invoke RemoveMenu, hMainMenu, IDM_MRU_SEP2, MF_BYCOMMAND

	Invoke SetMenu, hWin, hMainMenu
    Invoke DrawMenuBar, hWin

    ret
IniMRUClearListFromMenu ENDP

;------------------------------------------------------------------------------
; IniMRUEntrySaveFilename - Saves a filename to the MRU list 
;------------------------------------------------------------------------------
IniMRUEntrySaveFilename PROC FRAME hWin:QWORD, lpszFilename:QWORD, lpszIniFilename:QWORD
	LOCAL nMRUFrom:DWORD
	LOCAL nMRUTo:DWORD
	LOCAL pWideMRUFrom:QWORD
	LOCAL pWideMRUTo:QWORD
	LOCAL szMRUFrom[16]:BYTE
	LOCAL szMRUTo[16]:BYTE

	; if filename in MRU list already we delete it
	mov nMRUFrom, 1
	mov eax, nMRUFrom
	; Start Loop
	;====================
	ScanMRUEntries:
	;====================
	mov eax, nMRUFrom
	.WHILE eax < MRU_MAXFILES ;10 ; 9 MRUs
		Invoke dwtoa, nMRUFrom, Addr szMRUFrom
		IFDEF __UNICODE__
		Invoke MFPConvertStringToWide, Addr szMRUFrom
        mov pWideMRUFrom, rax
        Invoke lstrcpy, Addr szMRUFrom, pWideMRUFrom
        Invoke MFPConvertStringFree, pWideMRUFrom
		ENDIF
		Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
		.IF rax != 0
		    Invoke lstrcmp, Addr szMRUFilename, Addr szIniDefault
			;Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			;.IF rax == 0
			.IF rax != 0
			    Invoke lstrcmp, Addr szMRUFilename, lpszFilename
				;Invoke szCmp, Addr szMRUFilename, lpszFilename
				;.IF rax != 0
				.IF rax == 0
					; Loop onwards and fetch and write data
					mov eax, nMRUFrom
					mov nMRUTo, eax
					inc nMRUFrom
					mov eax, nMRUFrom
					.WHILE eax <= MRU_MAXFILES ;10
						Invoke dwtoa, nMRUFrom, Addr szMRUFrom
						Invoke dwtoa, nMRUTo, Addr szMRUTo
                		IFDEF __UNICODE__
                		Invoke MFPConvertStringToWide, Addr szMRUFrom
                        mov pWideMRUFrom, rax
                        Invoke lstrcpy, Addr szMRUFrom, pWideMRUFrom
                        Invoke MFPConvertStringFree, pWideMRUFrom
                		Invoke MFPConvertStringToWide, Addr szMRUTo
                        mov pWideMRUTo, rax
                        Invoke lstrcpy, Addr szMRUTo, pWideMRUTo
                        Invoke MFPConvertStringFree, pWideMRUTo
                		ENDIF
						Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
						.IF rax != 0
						    Invoke lstrcmp, Addr szMRUFilename, Addr szIniDefault
							;Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
							;.IF rax == 0
							.IF rax != 0
								Invoke WritePrivateProfileString, Addr szMRUSection, Addr szMRUTo, Addr szMRUFilename, lpszIniFilename	
							.ELSE
								Invoke WritePrivateProfileString, Addr szMRUSection, Addr szMRUTo, NULL, lpszIniFilename
							.ENDIF
						.ELSE
							Invoke WritePrivateProfileString, Addr szMRUSection, Addr szMRUTo, NULL, lpszIniFilename
						.ENDIF	
						inc nMRUTo
						inc nMRUFrom	
						mov eax, nMRUFrom
					.ENDW
					.BREAK
				.ENDIF
			.ENDIF
		.ENDIF
		inc nMRUFrom
		mov eax, nMRUFrom
		jmp ScanMRUEntries
	.ENDW		

	mov nMRUFrom, (MRU_MAXFILES-2) ; 8
	mov nMRUTo, (MRU_MAXFILES-1) ; 9
	; Start Loop
	;====================
	ReadMRUEntries:
	;====================
	mov eax, nMRUTo
	.WHILE eax > 0 ; 9 MRUs
		Invoke dwtoa, nMRUFrom, Addr szMRUFrom
		Invoke dwtoa, nMRUTo, Addr szMRUTo
		IFDEF __UNICODE__
		Invoke MFPConvertStringToWide, Addr szMRUFrom
        mov pWideMRUFrom, rax
        Invoke lstrcpy, Addr szMRUFrom, pWideMRUFrom
        Invoke MFPConvertStringFree, pWideMRUFrom
		Invoke MFPConvertStringToWide, Addr szMRUTo
        mov pWideMRUTo, rax
        Invoke lstrcpy, Addr szMRUTo, pWideMRUTo
        Invoke MFPConvertStringFree, pWideMRUTo
		ENDIF
		Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
		.IF rax != 0
		    Invoke lstrcmp, Addr szMRUFilename, Addr szIniDefault
			;Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			;.IF rax == 0
			.IF rax != 0
				Invoke WritePrivateProfileString, Addr szMRUSection, Addr szMRUTo, Addr szMRUFilename, lpszIniFilename
				Invoke WritePrivateProfileString, Addr szMRUSection, Addr szMRUFrom, NULL, lpszIniFilename
			.ENDIF
		.ENDIF		
		dec nMRUFrom
		dec nMRUTo	
		mov eax, nMRUTo
		jmp ReadMRUEntries
	.ENDW	
	Invoke WritePrivateProfileString, Addr szMRUSection, Addr szMRUTo, lpszFilename, lpszIniFilename
	ret
IniMRUEntrySaveFilename ENDP

;------------------------------------------------------------------------------
; IniMRUEntryDeleteFilename - Deletes an entry from the MRU file list - missing file for example
;------------------------------------------------------------------------------
IniMRUEntryDeleteFilename PROC FRAME hWin:QWORD, lpszFilename:QWORD, lpszIniFilename:QWORD
	LOCAL nMRUFrom:DWORD
	LOCAL nMRUTo:DWORD
	LOCAL pWideMRUFrom:QWORD
	LOCAL pWideMRUTo:QWORD
	LOCAL szMRUFrom[16]:BYTE
	LOCAL szMRUTo[16]:BYTE
	
	mov nMRUFrom, 1
	mov eax, nMRUFrom
	; Start Loop
	;====================
	ScanMRUEntries:
	;====================
	mov eax, nMRUFrom
	.WHILE eax < MRU_MAXFILES ;10 ; 9 MRUs
		Invoke dwtoa, nMRUFrom, Addr szMRUFrom
		IFDEF __UNICODE__
		Invoke MFPConvertStringToWide, Addr szMRUFrom
        mov pWideMRUFrom, rax
        Invoke lstrcpy, Addr szMRUFrom, pWideMRUFrom
        Invoke MFPConvertStringFree, pWideMRUFrom
        ENDIF
		Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
		.IF rax != 0
		    Invoke lstrcmp, Addr szMRUFilename, Addr szIniDefault
			;Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			;.IF rax == 0
			.IF rax != 0
			    Invoke lstrcmp, Addr szMRUFilename, lpszFilename
				;Invoke szCmp, Addr szMRUFilename, lpszFilename
				;.IF rax != 0
				.IF rax == 0
					; Loop onwards and fetch and write data
					mov eax, nMRUFrom
					mov nMRUTo, eax
					inc nMRUFrom
					mov eax, nMRUFrom
					.WHILE eax <= MRU_MAXFILES ;10
						Invoke dwtoa, nMRUFrom, Addr szMRUFrom
						Invoke dwtoa, nMRUTo, Addr szMRUTo
                		IFDEF __UNICODE__
                		Invoke MFPConvertStringToWide, Addr szMRUFrom
                        mov pWideMRUFrom, rax
                        Invoke lstrcpy, Addr szMRUFrom, pWideMRUFrom
                        Invoke MFPConvertStringFree, pWideMRUFrom
                		Invoke MFPConvertStringToWide, Addr szMRUTo
                        mov pWideMRUTo, rax
                        Invoke lstrcpy, Addr szMRUTo, pWideMRUTo
                        Invoke MFPConvertStringFree, pWideMRUTo
                		ENDIF
						Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
						.IF rax != 0
						    Invoke lstrcmp, Addr szMRUFilename, Addr szIniDefault
							;Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
							;.IF rax == 0
							.IF rax != 0
								Invoke WritePrivateProfileString, Addr szMRUSection, Addr szMRUTo, Addr szMRUFilename, lpszIniFilename	
							.ELSE
								Invoke WritePrivateProfileString, Addr szMRUSection, Addr szMRUTo, NULL, lpszIniFilename
							.ENDIF
						.ELSE
							Invoke WritePrivateProfileString, Addr szMRUSection, Addr szMRUTo, NULL, lpszIniFilename
						.ENDIF	
						inc nMRUTo
						inc nMRUFrom	
						mov eax, nMRUFrom
					.ENDW
					.BREAK
				.ENDIF
			.ENDIF
		.ENDIF
		inc nMRUFrom
		mov eax, nMRUFrom
		jmp ScanMRUEntries
	.ENDW			
	ret
IniMRUEntryDeleteFilename ENDP

;------------------------------------------------------------------------------
; IniSaveWindowPosition
;------------------------------------------------------------------------------
IniSaveWindowPosition PROC FRAME hWin:QWORD, lpszIniFilename:QWORD
    LOCAL wp:WINDOWPLACEMENT
    
    .IF g_Fullscreen == FALSE
        mov wp.iLength, SIZEOF WINDOWPLACEMENT
        Invoke GetWindowPlacement, hWin, Addr wp
        mov eax, wp.showCmd
        .IF eax == SW_RESTORE || eax == SW_SHOWNORMAL
            Invoke WritePrivateProfileStruct, Addr szIniMediaPlayer, Addr szIniWinPos, Addr wp, SIZEOF WINDOWPLACEMENT, lpszIniFilename
        .ENDIF
    .ENDIF
    
    ret
IniSaveWindowPosition ENDP

;------------------------------------------------------------------------------
; IniLoadWindowPosition
;------------------------------------------------------------------------------
IniLoadWindowPosition PROC FRAME hWin:QWORD, lpszIniFilename:QWORD
    LOCAL wp:WINDOWPLACEMENT
    
    mov wp.iLength, SIZEOF WINDOWPLACEMENT
    
    Invoke GetPrivateProfileStruct, Addr szIniMediaPlayer, Addr szIniWinPos, Addr wp, SIZEOF WINDOWPLACEMENT, lpszIniFilename
    .IF rax != 0
        Invoke SetWindowPlacement, hWin, Addr wp
    .ENDIF
    
    ret
IniLoadWindowPosition ENDP

;------------------------------------------------------------------------------
; IniGetLanguage
;------------------------------------------------------------------------------
IniGetLanguage PROC FRAME hWin:QWORD, lpszIniFilename:QWORD
    Invoke GetPrivateProfileInt, Addr szIniMediaPlayer, Addr szIniLanguage, 0, lpszIniFilename
    ret
IniGetLanguage ENDP

;------------------------------------------------------------------------------
; IniSetLanguage
;------------------------------------------------------------------------------
IniSetLanguage PROC FRAME hWin:QWORD, lpszIniFilename:QWORD
	LOCAL szLangID[16]:BYTE
	LOCAL pWideLangID:QWORD
	
    Invoke dwtoa, g_LangID, Addr szLangID
	IFDEF __UNICODE__
	Invoke MFPConvertStringToWide, Addr szLangID
    mov pWideLangID, rax
    Invoke lstrcpy, Addr szLangID, pWideLangID
    Invoke MFPConvertStringFree, pWideLangID
	ENDIF
	
    Invoke WritePrivateProfileString, Addr szIniMediaPlayer, Addr szIniLanguage, Addr szLangID, lpszIniFilename
    ret
IniSetLanguage ENDP

