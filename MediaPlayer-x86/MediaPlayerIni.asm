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
include advapi32.inc
includelib advapi32.lib

IniFilenameCreate           PROTO lpszIniFile:DWORD, lpszBaseModuleName:DWORD
IniInit                     PROTO

IniMRUReloadListToMenu      PROTO hWin:DWORD, lpszIniFilename:DWORD, dwMenuInsertID:DWORD, hMRUBitmap:DWORD, hMRUClearBitmap:DWORD ; Reloads the MRU list and updates the list under the File menu
IniMRULoadListToMenu        PROTO hWin:DWORD, lpszIniFilename:DWORD, dwMenuInsertID:DWORD, hMRUBitmap:DWORD, hMRUClearBitmap:DWORD ; Loads Most Recently Used (MRU) file list to the Main Menu under the File menu
IniMRUClearListFromMenu     PROTO hWin:DWORD, lpszIniFilename:DWORD, dwMenuInsertID:DWORD

IniMRUEntrySaveFilename     PROTO hWin:DWORD, lpszFilename:DWORD, lpszIniFilename:DWORD ; Saves a new MRU entry name (full filepath to file)
IniMRUEntryDeleteFilename   PROTO hWin:DWORD, lpszFilename:DWORD, lpszIniFilename:DWORD ; Deletes a new MRU entry name (full filepath to file)

IniSaveWindowPosition       PROTO hWin:DWORD, lpszIniFilename:DWORD
IniLoadWindowPosition       PROTO hWin:DWORD, lpszIniFilename:DWORD

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
szMRUClear                  DB "C",0,"l",0,"e",0,"a",0,"r",0," ",0,"R",0,"e",0,"c",0,"e",0,"n",0,"t",0," ",0,"F",0,"i",0,"l",0,"e",0,"s",0
                            DB 0,0,0,0
szMRUFilename               DB 1024 dup (0)
Unicode16BitLEBOM           DB 0FFh,0FEh
szIniPlayPause              DD 023EFh
                            DD 0,0,0,0
ELSE
szIniExt                    DB ".ini",0
szIniMediaPlayer            DB "MediaPlayer",0
szIniOptions                DB "Options",0
szIniWinPos                 DB "WinPos",0
szIniValueZero              DB "0",0
szIniValueOne               DB "1",0
szIniDefault                DB ":",0
szIniBackslash              DB "\",0
szIniSpace                  DB " ",0
szMRUSection                DB "MRU",0
szMRUClear                  DB "Clear Recent Files",0
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
IniFilenameCreate PROC USES EBX lpszIniFile:DWORD, lpszBaseModuleName:DWORD
    LOCAL VersionInformation:OSVERSIONINFO
    LOCAL hInst:DWORD
    LOCAL ppidl:DWORD
    LOCAL Version:DWORD
    IFDEF __UNICODE__
    LOCAL hFile:DWORD
    LOCAL BytesWritten:DWORD
    LOCAL BytesRead:DWORD
    LOCAL BOMBuffer[2]:BYTE
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
        mov hInst, eax      
        Invoke SHGetSpecialFolderLocation, hInst, CSIDL_APPDATA, Addr ppidl
        Invoke SHGetPathFromIDList, ppidl, lpszIniFile
        Invoke lstrcat, lpszIniFile, Addr szIniBackslash    ; add a backslash to this path
        Invoke lstrcat, lpszIniFile, Addr ModuleName        ; and add our app exe name
        Invoke GetFileAttributes, lpszIniFile
        .IF eax != FILE_ATTRIBUTE_DIRECTORY             
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
        mov hFile, eax
        .IF eax == INVALID_HANDLE_VALUE 
            ;------------------------------------------------------------------
            ; Ini file doesnt already exist, so we create it and add BOM
            ;------------------------------------------------------------------ 
            Invoke CreateFile, lpszIniFile, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, NULL, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, NULL
            mov hFile, eax
            .IF eax == INVALID_HANDLE_VALUE 
                ;--------------------------------------------------------------
                ; Error creating ini file. Not much we can do now.
                ;--------------------------------------------------------------
                IFDEF DEBUG32
                PrintText 'IniFilenameCreate CreateFile Error'
                Invoke GetLastError
                PrintDec eax
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
            .IF eax == TRUE
                lea ebx, BOMBuffer
                movzx eax, word ptr [ebx]
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
                IFDEF DEBUG32
                PrintText 'IniFilenameCreate ReadFile Error'
                Invoke GetLastError
                PrintDec eax
                ENDIF
            .ENDIF
            Invoke CloseHandle, hFile
        .ENDIF
    ENDIF
    
    mov eax, TRUE
    ret
IniFilenameCreate ENDP

;------------------------------------------------------------------------------
; Read ini settings and set global variables
;------------------------------------------------------------------------------
IniInit PROC
    
    ret
IniInit ENDP

;------------------------------------------------------------------------------
; IniMRUReloadListToMenu - RELoads MRU file information from the ini file into file menu
;------------------------------------------------------------------------------
IniMRUReloadListToMenu PROC hWin:DWORD, lpszIniFilename:DWORD, dwMenuInsertID:DWORD, hMRUBitmap:DWORD, hMRUClearBitmap:DWORD
	LOCAL nMenuID:DWORD
	LOCAL hMainMenu:DWORD
    LOCAL nMRUEntry:DWORD
	
	Invoke GetMenu, hWin
	.IF eax == NULL
		mov eax, FALSE
		ret 
	.endif
	mov hMainMenu, eax
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
IniMRULoadListToMenu PROC hWin:DWORD, lpszIniFilename:DWORD, dwMenuInsertID:DWORD, hMRUBitmap:DWORD, hMRUClearBitmap:DWORD
	LOCAL szMRUEntry[16]:BYTE
	LOCAL nMRUEntry:DWORD
	LOCAL pWideMRUEntry:DWORD
	LOCAL nTotalMRUs:DWORD
	LOCAL nMenuID:DWORD
	LOCAL hMainMenu:DWORD

	Invoke GetMenu, hWin
	.IF eax == NULL
		mov eax, FALSE
		ret 
	.endif
	mov hMainMenu, eax

	mov nMenuID, IDM_MRU_FIRST ;19991
	mov nMRUEntry, 1
	mov nTotalMRUs, 0
	
	ReadMRUEntries:
	mov eax, nMRUEntry
	.IF eax < MRU_MAXFILES ;10 ; 9 MRUs max
	    Invoke dwtoa, nMRUEntry, Addr szMRUEntry
		IFDEF __UNICODE__
		Invoke MFP_ConvertStringToWide, Addr szMRUEntry
        mov pWideMRUEntry, eax
        Invoke lstrcpy, Addr szMRUEntry, pWideMRUEntry
        Invoke MFP_ConvertStringFree, pWideMRUEntry
		ENDIF
		Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUEntry, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
		.IF eax != 0
		    Invoke lstrcmp, Addr szMRUFilename, Addr szIniDefault ; If the strings are equal, the return value is zero
			;Invoke szCmp, Addr szMRUFilename, Addr szIniDefault ; If there is no match, the return value is zero.
			;.IF eax == 0
			.IF eax != 0
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
		jmp ReadMRUEntries
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
	
	mov eax, TRUE
	ret
IniMRULoadListToMenu ENDP

;------------------------------------------------------------------------------
; IniMRUClearListFromMenu - Clears MRU files from the ini file and file menu
;------------------------------------------------------------------------------
IniMRUClearListFromMenu PROC hWin:DWORD, lpszIniFilename:DWORD, dwMenuInsertID:DWORD
    LOCAL szMRUEntry[16]:BYTE
    LOCAL pWideMRUEntry:DWORD
	LOCAL nMenuID:DWORD
	LOCAL hMainMenu:DWORD
    LOCAL nMRUEntry:DWORD
	
	Invoke GetMenu, hWin
	.IF eax == NULL
		mov eax, FALSE
		ret 
	.endif
	mov hMainMenu, eax
	
	mov nMenuID, IDM_MRU_FIRST ;19991
    mov nMRUEntry, 1
    
    RemoveMRUEntries:
    mov eax, nMRUEntry
    .IF eax < MRU_MAXFILES ; 9 MRUs max
        Invoke RemoveMenu, hMainMenu, nMenuID, MF_BYCOMMAND
	    Invoke dwtoa, nMRUEntry, Addr szMRUEntry
		IFDEF __UNICODE__
		Invoke MFP_ConvertStringToWide, Addr szMRUEntry
        mov pWideMRUEntry, eax
        Invoke lstrcpy, Addr szMRUEntry, pWideMRUEntry
        Invoke MFP_ConvertStringFree, pWideMRUEntry
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
IniMRUEntrySaveFilename PROC hWin:DWORD, lpszFilename:DWORD, lpszIniFilename:DWORD
	LOCAL nMRUFrom:DWORD
	LOCAL nMRUTo:DWORD
	LOCAL pWideMRUFrom:DWORD
	LOCAL pWideMRUTo:DWORD
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
		Invoke MFP_ConvertStringToWide, Addr szMRUFrom
        mov pWideMRUFrom, eax
        Invoke lstrcpy, Addr szMRUFrom, pWideMRUFrom
        Invoke MFP_ConvertStringFree, pWideMRUFrom
		ENDIF
		Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
		.IF eax != 0
		    Invoke lstrcmp, Addr szMRUFilename, Addr szIniDefault
			;Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			;.IF eax == 0
			.IF eax != 0
			    Invoke lstrcmp, Addr szMRUFilename, lpszFilename
				;Invoke szCmp, Addr szMRUFilename, lpszFilename
				;.IF eax != 0
				.IF eax == 0
					; Loop onwards and fetch and write data
					mov eax, nMRUFrom
					mov nMRUTo, eax
					inc nMRUFrom
					mov eax, nMRUFrom
					.WHILE eax <= MRU_MAXFILES ;10
						Invoke dwtoa, nMRUFrom, Addr szMRUFrom
						Invoke dwtoa, nMRUTo, Addr szMRUTo
                		IFDEF __UNICODE__
                		Invoke MFP_ConvertStringToWide, Addr szMRUFrom
                        mov pWideMRUFrom, eax
                        Invoke lstrcpy, Addr szMRUFrom, pWideMRUFrom
                        Invoke MFP_ConvertStringFree, pWideMRUFrom
                		Invoke MFP_ConvertStringToWide, Addr szMRUTo
                        mov pWideMRUTo, eax
                        Invoke lstrcpy, Addr szMRUTo, pWideMRUTo
                        Invoke MFP_ConvertStringFree, pWideMRUTo
                		ENDIF
						Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
						.IF eax != 0
						    Invoke lstrcmp, Addr szMRUFilename, Addr szIniDefault
							;Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
							;.IF eax == 0
							.IF eax != 0
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
		Invoke MFP_ConvertStringToWide, Addr szMRUFrom
        mov pWideMRUFrom, eax
        Invoke lstrcpy, Addr szMRUFrom, pWideMRUFrom
        Invoke MFP_ConvertStringFree, pWideMRUFrom
		Invoke MFP_ConvertStringToWide, Addr szMRUTo
        mov pWideMRUTo, eax
        Invoke lstrcpy, Addr szMRUTo, pWideMRUTo
        Invoke MFP_ConvertStringFree, pWideMRUTo
		ENDIF
		Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
		.IF eax != 0
		    Invoke lstrcmp, Addr szMRUFilename, Addr szIniDefault
			;Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			;.IF eax == 0
			.IF eax != 0
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
IniMRUEntryDeleteFilename PROC hWin:DWORD, lpszFilename:DWORD, lpszIniFilename:DWORD
	LOCAL nMRUFrom:DWORD
	LOCAL nMRUTo:DWORD
	LOCAL pWideMRUFrom:DWORD
	LOCAL pWideMRUTo:DWORD
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
		Invoke MFP_ConvertStringToWide, Addr szMRUFrom
        mov pWideMRUFrom, eax
        Invoke lstrcpy, Addr szMRUFrom, pWideMRUFrom
        Invoke MFP_ConvertStringFree, pWideMRUFrom
        ENDIF
		Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
		.IF eax != 0
		    Invoke lstrcmp, Addr szMRUFilename, Addr szIniDefault
			;Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			;.IF eax == 0
			.IF eax != 0
			    Invoke lstrcmp, Addr szMRUFilename, lpszFilename
				;Invoke szCmp, Addr szMRUFilename, lpszFilename
				;.IF eax != 0
				.IF eax == 0
					; Loop onwards and fetch and write data
					mov eax, nMRUFrom
					mov nMRUTo, eax
					inc nMRUFrom
					mov eax, nMRUFrom
					.WHILE eax <= MRU_MAXFILES ;10
						Invoke dwtoa, nMRUFrom, Addr szMRUFrom
						Invoke dwtoa, nMRUTo, Addr szMRUTo
                		IFDEF __UNICODE__
                		Invoke MFP_ConvertStringToWide, Addr szMRUFrom
                        mov pWideMRUFrom, eax
                        Invoke lstrcpy, Addr szMRUFrom, pWideMRUFrom
                        Invoke MFP_ConvertStringFree, pWideMRUFrom
                		Invoke MFP_ConvertStringToWide, Addr szMRUTo
                        mov pWideMRUTo, eax
                        Invoke lstrcpy, Addr szMRUTo, pWideMRUTo
                        Invoke MFP_ConvertStringFree, pWideMRUTo
                		ENDIF
						Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
						.IF eax != 0
						    Invoke lstrcmp, Addr szMRUFilename, Addr szIniDefault
							;Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
							;.IF eax == 0
							.IF eax != 0
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
IniSaveWindowPosition PROC hWin:DWORD, lpszIniFilename:DWORD
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
IniLoadWindowPosition PROC hWin:DWORD, lpszIniFilename:DWORD
    LOCAL wp:WINDOWPLACEMENT
    
    mov wp.iLength, SIZEOF WINDOWPLACEMENT
    
    Invoke GetPrivateProfileStruct, Addr szIniMediaPlayer, Addr szIniWinPos, Addr wp, SIZEOF WINDOWPLACEMENT, lpszIniFilename
    .IF eax != 0
        Invoke SetWindowPlacement, hWin, Addr wp
    .ENDIF
    
    ret
IniLoadWindowPosition ENDP



