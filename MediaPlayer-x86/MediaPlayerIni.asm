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

IniMRULoadListToMenu        PROTO hWin:DWORD, lpszIniFilename:DWORD, dwMenuInsertID:DWORD, hMRUBitmap:DWORD ; Loads Most Recently Used (MRU) file list to the Main Menu under the File menu
IniMRUReloadListToMenu      PROTO hWin:DWORD, lpszIniFilename:DWORD, dwMenuInsertID:DWORD, hMRUBitmap:DWORD ; Reloads the MRU list and updates the list under the File menu
IniMRUEntrySaveFilename     PROTO hWin:DWORD, lpszFilename:DWORD, lpszIniFilename:DWORD ; Saves a new MRU entry name (full filepath to file)
IniMRUEntryDeleteFilename   PROTO hWin:DWORD, lpszFilename:DWORD, lpszIniFilename:DWORD ; Deletes a new MRU entry name (full filepath to file)
IniMRUEntryOpenFile         PROTO hWin:DWORD, lpszFilename:DWORD, lpszIniFilename:DWORD ; Opens a file (if it exists) based on the MRU entry name (full filepath to file) 

IniSaveWindowPosition       PROTO hWin:DWORD, lpszIniFilename:DWORD
IniLoadWindowPosition       PROTO hWin:DWORD, lpszIniFilename:DWORD

.CONST
MRU_MAXFILES                EQU 10
IDM_MRU                     EQU 20000
IDM_MRU_FIRST               EQU IDM_MRU - (MRU_MAXFILES +1)
IDM_MRU_LAST                EQU IDM_MRU - 1 ; 19999
IDM_MRU_SEP                 EQU IDM_MRU - (MRU_MAXFILES +10) ; 19980

.DATA
;--------------------------------------
; Ini strings
;--------------------------------------
szIniExt                    DB ".ini",0
szIniMediaPlayer            DB "MediaPlayer",0
szIniOptions                DB "Options",0
szIniWinPos                 DB "WinPos",0
szIniValueZero              DB "0",0
szIniValueOne               DB "1",0
szIniDefault                DB ":",0
szIniBackslash              DB "\",0
szMRUSection                DB "MRU",0
szMRUFilename               DB MAX_PATH dup (0)

.CODE

;------------------------------------------------------------------------------
; Create an .ini filename based on the executables name.
; 
; Example Usage:
; 
; Invoke IniFilenameCreate, Addr szIniFilename
;
; 22/01/2014 - Added lpszBaseModuleName param (optional) if not NULL will copy
; the base module name to this buffer.
;------------------------------------------------------------------------------
IniFilenameCreate PROC USES ECX EDI ESI lpszIniFile:DWORD, lpszBaseModuleName:DWORD
    LOCAL VersionInformation:OSVERSIONINFO
    LOCAL ModuleFullPathname[MAX_PATH]:BYTE
    LOCAL ModuleName[MAX_PATH]:BYTE
    LOCAL hInst:DWORD
    LOCAL ppidl:DWORD
    LOCAL LenFilePathName:DWORD
    LOCAL PosFullStop:DWORD
    LOCAL PosBackSlash:DWORD
    LOCAL Version:DWORD
    
    Invoke GetModuleFileName, NULL, Addr ModuleFullPathname, Sizeof ModuleFullPathname
    Invoke lstrlen, Addr ModuleFullPathname         ; length of module path
    mov LenFilePathName, eax                        ; save var for later
    
    ;----------------------------------------------------------------------
    ; Find the fullstop position in the module full pathname
    ;----------------------------------------------------------------------
    mov PosFullStop, 0 
    lea esi, ModuleFullPathname
    add esi, LenFilePathName
    mov ecx, LenFilePathName
    .WHILE ecx >= 0
        movzx eax, byte ptr [esi]
        .IF al == 46d ; 46d = 2Eh is full stop .
            mov PosFullStop, ecx ; save fullstop position
            .BREAK
        .ELSE
            dec esi ; move down string by 1
            dec ecx ; decrease ecx counter
        .ENDIF
    .ENDW
    .IF PosFullStop == 0 ; if for some reason we dont have the position
        mov eax, FALSE       ; we should probably exit with an error
        ret
    .ENDIF
    ;----------------------------------------------------------------------
    
    ; Determine what OS we are running on
    mov VersionInformation.dwOSVersionInfoSize, SIZEOF OSVERSIONINFO
    Invoke GetVersionEx, Addr VersionInformation
    mov eax, VersionInformation.dwMajorVersion
    mov Version, eax
    
    ;----------------------------------------------------------------------
    ; Find the backslash position in the module full pathname
    ;----------------------------------------------------------------------
    mov PosBackSlash, 0
    lea esi, ModuleFullPathname
    add esi, PosFullStop
    mov ecx, PosFullStop
    .WHILE ecx >= 0
        movzx eax, byte ptr [esi]
        .IF al == 92 ; 92d = 5Ch is backslash \
            mov PosBackSlash, ecx ; save backslash position
            .BREAK
        .ELSE
            dec esi ; move down string by 1
            dec ecx ; decrease ecx counter
        .ENDIF
    .ENDW
    .IF PosBackSlash == 0 ; if for some reason we dont have the position
        mov eax, FALSE        ; we should probably exit with an error
        ret
    .ENDIF      
    
    ; Fetch just the module name based on last backslash position
    ; and the fullstop positions that we found above.
    lea edi, ModuleName
    lea esi, ModuleFullPathname
    add esi, PosBackSlash
    inc esi ; skip over the \
    
    mov ecx, PosBackSlash
    inc ecx ; skip over the \
    .WHILE ecx < PosFullStop
        movzx eax, byte ptr [esi]
        mov byte ptr [edi], al
        inc esi
        inc edi
        inc ecx
    .ENDW
    mov byte ptr [edi], 0 ; zero last byte to terminate string.
    ;----------------------------------------------------------------------

    
    .IF Version > 5 ; Vista / Win7          
        ;----------------------------------------------------------------------
        ; Glue all the bits together to make the new ini file location
        ; 
        ; include shell32.inc & includelib shell32.lib required for the 
        ; SHGetSpecialFolderLocation & SHGetPathFromIDList functions
        ;----------------------------------------------------------------------
        Invoke GetModuleHandle, NULL
        mov hInst, eax      
        Invoke SHGetSpecialFolderLocation, hInst, CSIDL_APPDATA, Addr ppidl
        Invoke SHGetPathFromIDList, ppidl, lpszIniFile
        Invoke lstrcat, lpszIniFile, Addr szIniBackslash    ; add a backslash to this path
        Invoke lstrcat, lpszIniFile, Addr ModuleName    ; and add our app exe name
        Invoke GetFileAttributes, lpszIniFile
        .IF eax != FILE_ATTRIBUTE_DIRECTORY             
            Invoke CreateDirectory, lpszIniFile, NULL   ; create directory if needed
        .ENDIF
        Invoke lstrcat, lpszIniFile, Addr szIniBackslash    ; add a backslash to this as well       

        Invoke lstrcat, lpszIniFile, Addr ModuleName ; add module name to our folder path
        invoke lstrcat, lpszIniFile, Addr szIniExt
        ;----------------------------------------------------------------------
        
    .ELSE ; WinXP
        inc PosFullStop
        Invoke lstrcpyn, lpszIniFile, Addr ModuleFullPathname, PosFullStop
        Invoke lstrcat, lpszIniFile, Addr szIniExt
    .ENDIF
    .IF lpszBaseModuleName != NULL ; save the result to address specified by user
        Invoke lstrcpy, lpszBaseModuleName, Addr ModuleName ; (2nd parameter)
    .ENDIF
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
IniMRUReloadListToMenu PROC hWin:DWORD, lpszIniFilename:DWORD, dwMenuInsertID:DWORD, hMRUBitmap:DWORD
	LOCAL nMenuID:DWORD
	LOCAL hMainMenu:DWORD
    LOCAL nProfile:DWORD
	
	Invoke GetMenu, hWin
	.IF eax == NULL
		mov eax, FALSE
		ret 
	.endif
	mov hMainMenu, eax
	mov nMenuID, IDM_MRU_FIRST ;19991
    mov nProfile, 1
    
    RemoveMRUProfiles:
    mov eax, nProfile
    .IF eax < MRU_MAXFILES ; 9 MRUs max
        Invoke RemoveMenu, hMainMenu, nMenuID, MF_BYCOMMAND
		inc nMenuID
		inc nProfile
		mov eax, nProfile    
		jmp RemoveMRUProfiles
	.ENDIF
	Invoke RemoveMenu, hMainMenu, IDM_MRU_SEP, MF_BYCOMMAND
	Invoke DrawMenuBar, hMainMenu
    Invoke IniMRULoadListToMenu, hWin, lpszIniFilename, dwMenuInsertID, hMRUBitmap
    ret
IniMRUReloadListToMenu ENDP

;------------------------------------------------------------------------------
; IniMRULoadListToMenu - Loads MRU file information from the ini file into file menu
;------------------------------------------------------------------------------
IniMRULoadListToMenu PROC hWin:DWORD, lpszIniFilename:DWORD, dwMenuInsertID:DWORD, hMRUBitmap:DWORD
	LOCAL szProfile[8]:BYTE
	LOCAL nProfile:DWORD	
	LOCAL nTotalMRUs:DWORD
	LOCAL nMenuID:DWORD
	LOCAL hMainMenu:DWORD

	Invoke GetMenu, hWin
	.IF eax == NULL
		mov eax, FALSE
		ret 
	.endif
	mov hMainMenu, eax

;    .IF hBmpFileMRU == 0
;        Invoke LoadBitmap, hInstance, BMP_FILE_MRU
;        mov hBmpFileMRU, eax
;    .ENDIF
    
	mov nMenuID, IDM_MRU_FIRST ;19991
	mov nProfile, 1
	mov nTotalMRUs, 0
	
	ReadMRUProfiles:
	mov eax, nProfile
	.IF eax < MRU_MAXFILES ;10 ; 9 MRUs max
		Invoke dwtoa, nProfile, Addr szProfile
		Invoke GetPrivateProfileString, Addr szMRUSection, Addr szProfile, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
		.IF eax !=0
			Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			.IF eax == 0		
				Invoke InsertMenu, hMainMenu, dwMenuInsertID, MF_STRING or MF_BYCOMMAND, nMenuID, Addr szMRUFilename
				.IF hMRUBitmap != 0
				    Invoke SetMenuItemBitmaps, hMainMenu, nMenuID, MF_BYCOMMAND, hMRUBitmap, 0
				.ENDIF
				inc nTotalMRUs
			.ENDIF
		.ENDIF		
		inc nMenuID
		inc nProfile
		mov eax, nProfile
		jmp ReadMRUProfiles
	.ENDIF	

	.IF nTotalMRUs > 0
		Invoke InsertMenu, hMainMenu, dwMenuInsertID, MF_SEPARATOR or MF_BYCOMMAND, IDM_MRU_SEP, NULL
	.ENDIF

	Invoke DrawMenuBar, hMainMenu
	
	mov eax, TRUE
	ret
IniMRULoadListToMenu ENDP

;------------------------------------------------------------------------------
; IniMRUEntrySaveFilename - Saves a filename to the MRU list 
;------------------------------------------------------------------------------
IniMRUEntrySaveFilename PROC hWin:DWORD, lpszFilename:DWORD, lpszIniFilename:DWORD
	LOCAL nMRUFrom:DWORD
	LOCAL nMRUTo:DWORD
	LOCAL szMRUFrom[8]:BYTE
	LOCAL szMRUTo[8]:BYTE

	; if filename in MRU list already we delete it
	mov nMRUFrom, 1
	mov eax, nMRUFrom
	; Start Loop
	;====================
	ScanMRUProfiles:
	;====================
	mov eax, nMRUFrom
	.WHILE eax < MRU_MAXFILES ;10 ; 9 MRUs
		Invoke dwtoa, nMRUFrom, Addr szMRUFrom
		Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
		.IF eax !=0
			Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			.IF eax == 0		
				Invoke szCmp, Addr szMRUFilename, lpszFilename
				.IF eax != 0
					; Loop onwards and fetch and write data
					mov eax, nMRUFrom
					mov nMRUTo, eax
					inc nMRUFrom
					mov eax, nMRUFrom
					.WHILE eax <= MRU_MAXFILES ;10
						Invoke dwtoa, nMRUFrom, Addr szMRUFrom
						Invoke dwtoa, nMRUTo, Addr szMRUTo
						Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
						.IF eax !=0
							Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
							.IF eax == 0
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
		jmp ScanMRUProfiles
	.ENDW		

	mov nMRUFrom, (MRU_MAXFILES-2) ; 8
	mov nMRUTo, (MRU_MAXFILES-1) ; 9
	; Start Loop
	;====================
	ReadMRUProfiles:
	;====================
	mov eax, nMRUTo
	.WHILE eax > 0 ; 9 MRUs
		Invoke dwtoa, nMRUFrom, Addr szMRUFrom
		Invoke dwtoa, nMRUTo, Addr szMRUTo
		Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
		.IF eax != 0
			Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			.IF eax == 0
				Invoke WritePrivateProfileString, Addr szMRUSection, Addr szMRUTo, Addr szMRUFilename, lpszIniFilename
				Invoke WritePrivateProfileString, Addr szMRUSection, Addr szMRUFrom, NULL, lpszIniFilename
			.ENDIF
		.ENDIF		
		dec nMRUFrom
		dec nMRUTo	
		mov eax, nMRUTo
		jmp ReadMRUProfiles
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
	LOCAL szMRUFrom[8]:BYTE
	LOCAL szMRUTo[8]:BYTE
	
	mov nMRUFrom, 1
	mov eax, nMRUFrom
	; Start Loop
	;====================
	ScanMRUProfiles:
	;====================
	mov eax, nMRUFrom
	.WHILE eax < MRU_MAXFILES ;10 ; 9 MRUs
		Invoke dwtoa, nMRUFrom, Addr szMRUFrom
		Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
		.IF eax != 0
			Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			.IF eax == 0		
				Invoke szCmp, Addr szMRUFilename, lpszFilename
				.IF eax != 0
					; Loop onwards and fetch and write data
					mov eax, nMRUFrom
					mov nMRUTo, eax
					inc nMRUFrom
					mov eax, nMRUFrom
					.WHILE eax <= MRU_MAXFILES ;10
						Invoke dwtoa, nMRUFrom, Addr szMRUFrom
						Invoke dwtoa, nMRUTo, Addr szMRUTo
						
						Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
						.IF eax != 0
							Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
							.IF eax == 0
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
		jmp ScanMRUProfiles
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



