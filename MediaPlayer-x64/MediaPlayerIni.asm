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
IniInit                     PROTO

IniMRULoadListToMenu        PROTO hWin:QWORD, lpszIniFilename:QWORD, qwMenuInsertID:QWORD, hMRUBitmap:QWORD ; Loads Most Recently Used (MRU) file list to the Main Menu under the File menu
IniMRUReloadListToMenu      PROTO hWin:QWORD, lpszIniFilename:QWORD, qwMenuInsertID:QWORD, hMRUBitmap:QWORD ; Reloads the MRU list and updates the list under the File menu
IniMRUEntrySaveFilename     PROTO hWin:QWORD, lpszFilename:QWORD, lpszIniFilename:QWORD ; Saves a new MRU entry name (full filepath to file)
IniMRUEntryDeleteFilename   PROTO hWin:QWORD, lpszFilename:QWORD, lpszIniFilename:QWORD ; Deletes a new MRU entry name (full filepath to file)
IniMRUEntryOpenFile         PROTO hWin:QWORD, lpszFilename:QWORD, lpszIniFilename:QWORD ; Opens a file (if it exists) based on the MRU entry name (full filepath to file) 

IniSaveWindowPosition       PROTO hWin:QWORD, lpszIniFilename:QWORD
IniLoadWindowPosition       PROTO hWin:QWORD, lpszIniFilename:QWORD

IFNDEF SHGetSpecialFolderLocation
SHGetSpecialFolderLocation  PROTO hWin:QWORD, csidl:DWORD, ppidl:QWORD
ENDIF
IFNDEF SHGetPathFromIDList
SHGetPathFromIDList         PROTO pidl:QWORD, pszPath:QWORD
ENDIF
IFNDEF lstrcpynA
lstrcpynA                   PROTO lpString1:QWORD, lpString2:QWORD, iMaxLength:DWORD
ENDIF
IFNDEF CSIDL_APPDATA
CSIDL_APPDATA equ 001ah
ENDIF



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
szIniWinPos                 DB "WinPos64",0
szIniValueZero              DB "0",0
szIniValueOne               DB "1",0
szIniDefault                DB ":",0
szIniBackslash              DB "\",0
szMRUSection                DB "MRU64",0
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
IniFilenameCreate PROC FRAME USES RCX RDI RSI lpszIniFile:QWORD, lpszBaseModuleName:QWORD
    LOCAL VersionInformation:OSVERSIONINFO
    LOCAL ModuleFullPathname[MAX_PATH]:BYTE
    LOCAL ModuleName[MAX_PATH]:BYTE
    LOCAL hInst:QWORD
    LOCAL ppidl:QWORD
    LOCAL LenFilePathName:QWORD
    LOCAL PosFullStop:QWORD
    LOCAL PosBackSlash:QWORD
    LOCAL Version:DWORD
    
    IFDEF DEBUG64
    ;PrintText 'IniFilenameCreate'
    ENDIF
    
    Invoke GetModuleFileName, NULL, Addr ModuleFullPathname, SIZEOF ModuleFullPathname
    Invoke lstrlen, Addr ModuleFullPathname         ; length of module path
    mov LenFilePathName, rax                        ; save var for later
    
    ;----------------------------------------------------------------------
    ; Find the fullstop position in the module full pathname
    ;----------------------------------------------------------------------
    mov PosFullStop, 0 
    lea rsi, ModuleFullPathname
    add rsi, LenFilePathName
    mov rcx, LenFilePathName
    .WHILE sqword ptr rcx >= 0
        movzx eax, byte ptr [rsi]
        .IF al == 46d ; 46d = 2Eh is full stop .
            mov PosFullStop, rcx ; save fullstop position
            .BREAK
        .ELSE
            dec rsi ; move down string by 1
            dec rcx ; decrease ecx counter
        .ENDIF
    .ENDW
    .IF PosFullStop == 0 ; if for some reason we dont have the position
        mov rax, FALSE       ; we should probably exit with an error
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
    lea rsi, ModuleFullPathname
    add rsi, PosFullStop
    mov rcx, PosFullStop
    .WHILE sqword ptr rcx >= 0
        movzx eax, byte ptr [rsi]
        .IF al == 92 ; 92d = 5Ch is backslash \
            mov PosBackSlash, rcx ; save backslash position
            .BREAK
        .ELSE
            dec rsi ; move down string by 1
            dec rcx ; decrease ecx counter
        .ENDIF
    .ENDW
    .IF PosBackSlash == 0 ; if for some reason we dont have the position
        mov rax, FALSE        ; we should probably exit with an error
        ret
    .ENDIF      
    
    ; Fetch just the module name based on last backslash position
    ; and the fullstop positions that we found above.
    lea rdi, ModuleName
    lea rsi, ModuleFullPathname
    add rsi, PosBackSlash
    inc rsi ; skip over the \
    
    mov rcx, PosBackSlash
    inc rcx ; skip over the \
    .WHILE sqword ptr rcx < PosFullStop
        movzx eax, byte ptr [rsi]
        mov byte ptr [rdi], al
        inc rsi
        inc rdi
        inc rcx
    .ENDW
    mov byte ptr [rdi], 0 ; zero last byte to terminate string.
    ;----------------------------------------------------------------------

    
    .IF Version > 5 ; Vista / Win7          
        ;----------------------------------------------------------------------
        ; Glue all the bits together to make the new ini file location
        ; 
        ; include shell32.inc & includelib shell32.lib required for the 
        ; SHGetSpecialFolderLocation & SHGetPathFromIDList functions
        ;----------------------------------------------------------------------
        Invoke GetModuleHandle, NULL
        mov hInst, rax      
        Invoke SHGetSpecialFolderLocation, hInst, CSIDL_APPDATA, Addr ppidl
        Invoke SHGetPathFromIDList, ppidl, lpszIniFile
        Invoke lstrcat, lpszIniFile, Addr szIniBackslash    ; add a backslash to this path
        Invoke lstrcat, lpszIniFile, Addr ModuleName    ; and add our app exe name
        Invoke GetFileAttributes, lpszIniFile
        .IF rax != FILE_ATTRIBUTE_DIRECTORY             
            Invoke CreateDirectory, lpszIniFile, NULL   ; create directory if needed
        .ENDIF
        Invoke lstrcat, lpszIniFile, Addr szIniBackslash    ; add a backslash to this as well       

        Invoke lstrcat, lpszIniFile, Addr ModuleName ; add module name to our folder path
        invoke lstrcat, lpszIniFile, Addr szIniExt
        ;----------------------------------------------------------------------
        
    .ELSE ; WinXP
        inc PosFullStop
        Invoke lstrcpynA, lpszIniFile, Addr ModuleFullPathname, dword ptr PosFullStop
        Invoke lstrcat, lpszIniFile, Addr szIniExt
    .ENDIF
    .IF lpszBaseModuleName != NULL ; save the result to address specified by user
        Invoke lstrcpy, lpszBaseModuleName, Addr ModuleName ; (2nd parameter)
    .ENDIF
    mov rax, TRUE
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
IniMRUReloadListToMenu PROC FRAME hWin:QWORD, lpszIniFilename:QWORD, qwMenuInsertID:QWORD, hMRUBitmap:QWORD
	LOCAL nMenuID:DWORD
	LOCAL hMainMenu:QWORD
    LOCAL nProfile:QWORD
	
	Invoke GetMenu, hWin
	.IF rax == NULL
		mov rax, FALSE
		ret 
	.endif
	mov hMainMenu, rax
	mov nMenuID, IDM_MRU_FIRST ;19991
    mov nProfile, 1
    
    RemoveMRUProfiles:
    mov rax, nProfile
    .IF rax < MRU_MAXFILES ; 9 MRUs max
        Invoke RemoveMenu, hMainMenu, nMenuID, MF_BYCOMMAND
		inc nMenuID
		inc nProfile
		mov rax, nProfile    
		jmp RemoveMRUProfiles
	.ENDIF
	Invoke RemoveMenu, hMainMenu, IDM_MRU_SEP, MF_BYCOMMAND
	Invoke DrawMenuBar, hMainMenu
    Invoke IniMRULoadListToMenu, hWin, lpszIniFilename, qwMenuInsertID, hMRUBitmap
    ret
IniMRUReloadListToMenu ENDP

;------------------------------------------------------------------------------
; IniMRULoadListToMenu - Loads MRU file information from the ini file into file menu
;------------------------------------------------------------------------------
IniMRULoadListToMenu PROC FRAME hWin:QWORD, lpszIniFilename:QWORD, qwMenuInsertID:QWORD, hMRUBitmap:QWORD
	LOCAL szProfile[8]:BYTE
	LOCAL nProfile:DWORD	
	LOCAL nTotalMRUs:QWORD
	LOCAL nMenuID:DWORD
	LOCAL hMainMenu:QWORD

	Invoke GetMenu, hWin
	.IF rax == NULL
		mov rax, FALSE
		ret 
	.endif
	mov hMainMenu, rax

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
		.IF rax !=0
			Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			.IF rax == 0		
				Invoke InsertMenu, hMainMenu, dword ptr qwMenuInsertID, MF_STRING or MF_BYCOMMAND, nMenuID, Addr szMRUFilename
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
		Invoke InsertMenu, hMainMenu, dword ptr qwMenuInsertID, MF_SEPARATOR or MF_BYCOMMAND, IDM_MRU_SEP, NULL
	.ENDIF

	Invoke DrawMenuBar, hMainMenu
	
	mov rax, TRUE
	ret
IniMRULoadListToMenu ENDP

;------------------------------------------------------------------------------
; IniMRUEntrySaveFilename - Saves a filename to the MRU list 
;------------------------------------------------------------------------------
IniMRUEntrySaveFilename PROC FRAME hWin:QWORD, lpszFilename:QWORD, lpszIniFilename:QWORD
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
		.IF rax !=0
			Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			.IF rax == 0		
				Invoke szCmp, Addr szMRUFilename, lpszFilename
				.IF rax != 0
					; Loop onwards and fetch and write data
					mov eax, nMRUFrom
					mov nMRUTo, eax
					inc nMRUFrom
					mov eax, nMRUFrom
					.WHILE eax <= MRU_MAXFILES ;10
						Invoke dwtoa, nMRUFrom, Addr szMRUFrom
						Invoke dwtoa, nMRUTo, Addr szMRUTo
						Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
						.IF rax !=0
							Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
							.IF rax == 0
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
		.IF rax != 0
			Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			.IF rax == 0
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
IniMRUEntryDeleteFilename PROC FRAME hWin:QWORD, lpszFilename:QWORD, lpszIniFilename:QWORD
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
		.IF rax != 0
			Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
			.IF rax == 0		
				Invoke szCmp, Addr szMRUFilename, lpszFilename
				.IF rax != 0
					; Loop onwards and fetch and write data
					mov eax, nMRUFrom
					mov nMRUTo, eax
					inc nMRUFrom
					mov eax, nMRUFrom
					.WHILE eax <= MRU_MAXFILES ;10
						Invoke dwtoa, nMRUFrom, Addr szMRUFrom
						Invoke dwtoa, nMRUTo, Addr szMRUTo
						
						Invoke GetPrivateProfileString, Addr szMRUSection, Addr szMRUFrom, Addr szIniDefault, Addr szMRUFilename, SIZEOF szMRUFilename, lpszIniFilename
						.IF rax != 0
							Invoke szCmp, Addr szMRUFilename, Addr szIniDefault
							.IF rax == 0
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



