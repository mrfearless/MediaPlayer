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

include RtlCompression_x86.inc
includelib RtlCompression_x86.lib

; Bitmap Create Functions
BitmapCreateFromCompressedRes   PROTO hInst:DWORD, dwResourceID:DWORD
BitmapCreateFromCompressedMem   PROTO lpCompressedBitmapData:DWORD, dwCompressedBitmapDataLength:DWORD
BitmapCreateFromMem             PROTO pBitmapData:DWORD

IconCreateFromCompressedRes     PROTO hInst:DWORD, dwResourceID:DWORD
IconCreateFromCompressedMem     PROTO lpCompressedIconData:DWORD, dwCompressedIconDataLength:DWORD
IconCreateFromMem               PROTO pIconData:DWORD, iIcon:DWORD

RTLC_DecompressMem              PROTO lpCompressedData:DWORD, dwCompressedDataLength:DWORD, lpdwDecompressedDataLength:DWORD

RTLC_HEADER             STRUCT
    RTLCSignature       DD ?
    dwUncompressedSize  DD ?
    dwCompresssedSize   DD ?
RTLC_HEADER             ENDS

.CONST
RTLC_HEADER_SIZE        EQU SIZEOF RTLC_HEADER

.DATA
ALIGN 4

IFDEF __UNICODE__
szMemoryDisplayDC       DB 'D',0,'I',0,'S',0,'P',0,'L',0,'A',0,'Y',0
                        DB 0,0,0,0
ELSE
szMemoryDisplayDC       DB 'DISPLAY',0
ENDIF
HEADER_SIG_RTLC         DD 'CLTR' ; 'RTLC'
szHEADER_SIG_RTLC       DB 'RTLC',0

.CODE

;------------------------------------------------------------------------------
; BitmapCreateFromCompressedRes - Creates a bitmap from a compressed bitmap 
; resource by uncompressing the data & creating a bitmap from that data.
;
; Calls:BitmapCreateFromCompressedMem
;
; Returns: HBITMAP or NULL
;------------------------------------------------------------------------------
BitmapCreateFromCompressedRes PROC hInst:DWORD, dwResourceID:DWORD
    LOCAL hRes:DWORD
    LOCAL lpCompressedBitmapData:DWORD
    LOCAL dwCompressedBitmapDataLength:DWORD
    LOCAL lpDecompressedBitmapData:DWORD
    LOCAL hBitmap:DWORD
    
    Invoke FindResource, hInst, dwResourceID, RT_RCDATA ; get compressed bitmap as raw data
    .IF eax != NULL
        mov hRes, eax
        Invoke SizeofResource, hInst, hRes
        .IF eax != 0
            mov dwCompressedBitmapDataLength, eax
            Invoke LoadResource, hInst, hRes
            .IF eax != NULL
                Invoke LockResource, eax
                .IF eax != NULL
                    mov lpCompressedBitmapData, eax
                    
                    Invoke BitmapCreateFromCompressedMem, lpCompressedBitmapData, dwCompressedBitmapDataLength
                    .IF eax != NULL
                        mov hBitmap, eax
                        mov eax, hBitmap
                        ret
                    .ELSE
                        ;PrintText 'Failed to decompress data'
                        mov eax, NULL
                    .ENDIF
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov eax, NULL
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov eax, NULL
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov eax, NULL
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov eax, NULL
    .ENDIF    
    
    ret
BitmapCreateFromCompressedRes ENDP

;------------------------------------------------------------------------------
; BitmapCreateFromCompressedMem - Creates a bitmap from a compressed bitmap 
; data stored in memory by uncompressing the data & creating a bitmap from that 
; data.
;
; Calls: RTLC_DecompressMem, BitmapCreateFromMem
;
; Returns: HBITMAP or NULL
;------------------------------------------------------------------------------
BitmapCreateFromCompressedMem PROC lpCompressedBitmapData:DWORD, dwCompressedBitmapDataLength:DWORD
    LOCAL lpDecompressedBitmapData:DWORD
    LOCAL dwDecompressedDataSize:DWORD
    LOCAL hBitmap:DWORD

    .IF lpCompressedBitmapData == NULL || dwCompressedBitmapDataLength == 0
        mov eax, NULL
        ret
    .ENDIF
    
    Invoke RTLC_DecompressMem, lpCompressedBitmapData, dwCompressedBitmapDataLength, Addr dwDecompressedDataSize
    .IF eax != NULL
        mov lpDecompressedBitmapData, eax
        Invoke BitmapCreateFromMem, lpDecompressedBitmapData
        .IF eax != NULL
            mov hBitmap, eax
            .IF lpDecompressedBitmapData != 0
                Invoke GlobalFree, lpDecompressedBitmapData
            .ENDIF
            mov eax, hBitmap
            ret
        .ELSE
            ;PrintText 'Failed to create bitmap from data'
            .IF lpDecompressedBitmapData != 0
                Invoke GlobalFree, lpDecompressedBitmapData
            .ENDIF
        .ENDIF
    .ENDIF
    mov eax, NULL
    ret
BitmapCreateFromCompressedMem ENDP

;------------------------------------------------------------------------------
; BitmapCreateFromMem - Create a bitmap from bitmap data stored in memory.
;
; http://www.masmforum.com/board/index.php?topic=16267.msg134453#msg134453
;
; Returns: HBITMAP or NULL
;------------------------------------------------------------------------------
BitmapCreateFromMem PROC USES ECX EDX pBitmapData:DWORD
    LOCAL hDC:DWORD
    LOCAL hBmp:DWORD

    Invoke CreateDC, Addr szMemoryDisplayDC, NULL, NULL, NULL
    test eax, eax
    jz @f
    mov hDC, eax
    mov edx, pBitmapData
    lea ecx, [edx + SIZEOF BITMAPFILEHEADER]  ; start of the BITMAPINFOHEADER header
    mov eax, BITMAPFILEHEADER.bfOffBits[edx]
    add edx, eax
    Invoke CreateDIBitmap, hDC, ecx, CBM_INIT, edx, ecx, DIB_RGB_COLORS
    mov hBmp, eax
    Invoke DeleteDC, hDC
    mov eax, hBmp
@@:
    ret
BitmapCreateFromMem ENDP

;------------------------------------------------------------------------------
; IconCreateFromCompressedRes - Creates an icon from a compressed icon 
; resource by uncompressing the data & creating an icon from that data.
;
; Calls:IconCreateFromCompressedMem
;
; Returns: HBITMAP or NULL
;------------------------------------------------------------------------------
IconCreateFromCompressedRes PROC hInst:DWORD, dwResourceID:DWORD
    LOCAL hRes:DWORD
    LOCAL lpCompressedIconData:DWORD
    LOCAL dwCompressedIconDataLength:DWORD
    LOCAL lpDecompressedIconData:DWORD
    LOCAL hIcon:DWORD
    
    Invoke FindResource, hInst, dwResourceID, RT_RCDATA ; get compressed icon as raw data
    .IF eax != NULL
        mov hRes, eax
        Invoke SizeofResource, hInst, hRes
        .IF eax != 0
            mov dwCompressedIconDataLength, eax
            Invoke LoadResource, hInst, hRes
            .IF eax != NULL
                Invoke LockResource, eax
                .IF eax != NULL
                    mov lpCompressedIconData, eax
                    
                    Invoke IconCreateFromCompressedMem, lpCompressedIconData, dwCompressedIconDataLength
                    .IF eax != NULL
                        mov hIcon, eax
                        mov eax, hIcon
                        ret
                    .ELSE
                        ;PrintText 'Failed to decompress data'
                        mov eax, NULL
                    .ENDIF
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov eax, NULL
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov eax, NULL
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov eax, NULL
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov eax, NULL
    .ENDIF    
    
    ret
IconCreateFromCompressedRes ENDP

;------------------------------------------------------------------------------
; IconCreateFromCompressedMem - Creates an icon from a compressed icon 
; data stored in memory by uncompressing the data & creating an icon from that 
; data.
;
; Calls: RTLC_DecompressMem, IconCreateFromMem
;
; Returns: HBITMAP or NULL
;------------------------------------------------------------------------------
IconCreateFromCompressedMem PROC lpCompressedIconData:DWORD, dwCompressedIconDataLength:DWORD
    LOCAL lpDecompressedIconData:DWORD
    LOCAL dwDecompressedDataSize:DWORD
    LOCAL hIcon:DWORD

    .IF lpCompressedIconData == NULL || dwCompressedIconDataLength == 0
        mov eax, NULL
        ret
    .ENDIF
    
    Invoke RTLC_DecompressMem, lpCompressedIconData, dwCompressedIconDataLength, Addr dwDecompressedDataSize
    .IF eax != NULL
        mov lpDecompressedIconData, eax
        Invoke IconCreateFromMem, lpDecompressedIconData, 0
        .IF eax != NULL
            mov hIcon, eax
            .IF lpDecompressedIconData != 0
                Invoke GlobalFree, lpDecompressedIconData
            .ENDIF
            mov eax, hIcon
            ret
        .ELSE
            ;PrintText 'Failed to create bitmap from data'
            .IF lpDecompressedIconData != 0
                Invoke GlobalFree, lpDecompressedIconData
            .ENDIF
        .ENDIF
    .ENDIF
    mov eax, NULL
    ret
IconCreateFromCompressedMem ENDP

;------------------------------------------------------------------------------
;IconCreateFromMem
; Creates an icon from icon data stored in the DATA or CONST SECTION
; (The icon data is an ICO file stored directly in the executable)
;
; Parameters
;   pIconData = Pointer to the ico file data
;   iIcon = zero based index of the icon to load
;
; If successful will return an icon handle, this handle must be freed
; using DestroyIcon when it is no longer needed. The size of the icon
; is returned in EDX, the high order word contains the width and the
; low order word the height.
; 
; Returns 0 if there is an error.
; If the index is greater than the number of icons in the file EDX will
; be set to the number of icons available otherwise EDX is 0. To find
; the number of available icons set the index to -1
;
;http://www.masmforum.com/board/index.php?topic=16267.msg134434#msg134434
;------------------------------------------------------------------------------
IconCreateFromMem PROC USES EDX pIconData:DWORD, iIcon:DWORD
    LOCAL sz[2]:DWORD

    xor eax, eax
    mov edx, [pIconData]
    or edx, edx
    jz ERRORCATCH

    movzx eax, WORD PTR [edx+4]
    cmp eax, [iIcon]
    ja @F
        ERRORCATCH:
        push eax
        invoke SetLastError, ERROR_RESOURCE_NAME_NOT_FOUND
        pop edx
        xor eax, eax
        ret
    @@:

    mov eax, [iIcon]
    shl eax, 4
    add edx, eax
    add edx, 6

    movzx eax, BYTE PTR [edx]
    mov [sz], eax
    movzx eax, BYTE PTR [edx+1]
    mov [sz+4], eax

    mov eax, [edx+12]
    add eax, [pIconData]
    mov edx, [edx+8]

    invoke CreateIconFromResourceEx, eax, edx, 1, 030000h, [sz], [sz+4], 0

    mov edx,[sz]
    shl edx,16
    mov dx, word ptr [sz+4]

    ret

IconCreateFromMem ENDP

;------------------------------------------------------------------------------
; RTLC_DecompressMem - Decompress memory that was previously compressed with 
; RTL compression using RTLC_CompressMem.
;------------------------------------------------------------------------------
RTLC_DecompressMem PROC USES EBX lpCompressedData:DWORD, dwCompressedDataLength:DWORD, lpdwDecompressedDataLength:DWORD
    LOCAL DecompressedDataSize:DWORD
    LOCAL DecompressedData:DWORD
    LOCAL CompressedDataSize:DWORD
    LOCAL CompressedData:DWORD
    LOCAL WorkSpaceSize:DWORD
    LOCAL FragmentSpaceSize:DWORD
    LOCAL pWorkSpace:DWORD
    
    IFDEF DEBUG32
    ;PrintText 'RTLC_DecompressMem'
    ENDIF
    
    mov DecompressedData, 0
    mov CompressedData, 0
    mov pWorkSpace, 0
    
    ;--------------------------------------------------------------------------
    ; Basic checks
    ;--------------------------------------------------------------------------
    .IF lpCompressedData == NULL ;|| dwCompressedDataLength == 0
        IFDEF DEBUG32
        PrintText 'RTLC_DecompressMem NULL data or 0 size'
        ENDIF
        .IF lpdwDecompressedDataLength != 0
            mov ebx, lpdwDecompressedDataLength
            mov eax, 0
            mov [ebx], eax
        .ENDIF
        mov eax, NULL
        ret
    .ENDIF

    ;----------------------------------------------------------------------
    ; Check for header signature, get uncompressed data size and compressed 
    ; data size and adjust pointer to skip over header.
    ;----------------------------------------------------------------------
    mov ebx, lpCompressedData
    mov eax, [ebx]
    .IF eax != HEADER_SIG_RTLC
        .IF lpdwDecompressedDataLength != 0
            mov ebx, lpdwDecompressedDataLength
            mov eax, 0
            mov [ebx], eax
        .ENDIF
        mov eax, NULL
        ret
    .ENDIF
    mov eax, [ebx+4]
    mov DecompressedDataSize, eax
    mov eax, [ebx+8]
    mov CompressedDataSize, eax
    
;    mov eax, CompressedDataSize
;    .IF eax > dwCompressedDataLength
;        IFDEF DEBUG32
;        PrintText 'RTLC_DecompressMem CompressedDataSize greater than dwCompressedDataLength'
;        ENDIF
;        .IF lpdwDecompressedDataLength != 0
;            mov ebx, lpdwDecompressedDataLength
;            mov eax, 0
;            mov [ebx], eax
;        .ENDIF
;        mov eax, NULL
;        ret
;    .ENDIF
    
    mov eax, lpCompressedData
    mov CompressedData, eax
    add CompressedData, RTLC_HEADER_SIZE

    
    ;----------------------------------------------------------------------
    ; Obtain the size of workspace
    ;----------------------------------------------------------------------
    Invoke RtlGetCompressionWorkSpaceSize, COMPRESSION_FORMAT_LZNT1 or COMPRESSION_ENGINE_MAXIMUM, Addr WorkSpaceSize, Addr FragmentSpaceSize
    .IF eax != STATUS_SUCCESS
        IFDEF DEBUG32
        PrintText 'RTLC_DecompressMem RtlGetCompressionWorkSpaceSize Error'
        ENDIF
        .IF lpdwDecompressedDataLength != 0
            mov ebx, lpdwDecompressedDataLength
            mov eax, 0
            mov [ebx], eax
        .ENDIF
        mov eax, NULL
        ret
    .ENDIF
        
    ;----------------------------------------------------------------------
    ; Allocate memory for workspace 
    ;----------------------------------------------------------------------
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, WorkSpaceSize
    .IF eax == NULL
        IFDEF DEBUG32
        PrintText 'RTLC_DecompressMem GlobalAlloc WorkSpaceSize Error'
        ENDIF
        .IF lpdwDecompressedDataLength != 0
            mov ebx, lpdwDecompressedDataLength
            mov eax, 0
            mov [ebx], eax
        .ENDIF
        mov eax, NULL
        ret
    .ENDIF
    mov pWorkSpace, eax
        
    ;--------------------------------------------------------------------------
    ; Alloc buffer required
    ;--------------------------------------------------------------------------
    mov eax, DecompressedDataSize 
    add eax, 4 ; we add four extra to give us 4 null bytes in case compressed
    ; data is an ansi or unicode string or something that requires null endings
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
    .IF eax == NULL
        IFDEF DEBUG32
        PrintText 'RTLC_DecompressMem GlobalAlloc Failed'
        ENDIF
        .IF pWorkSpace != 0
            Invoke GlobalFree, pWorkSpace
        .ENDIF
        .IF lpdwDecompressedDataLength != 0
            mov ebx, lpdwDecompressedDataLength
            mov eax, 0
            mov [ebx], eax
        .ENDIF
        mov eax, NULL
        ret
    .ENDIF
    mov DecompressedData, eax
        
    ;--------------------------------------------------------------------------
    ; Decompress
    ;--------------------------------------------------------------------------
    Invoke RtlDecompressBuffer, COMPRESSION_FORMAT_LZNT1, DecompressedData, DecompressedDataSize, CompressedData, CompressedDataSize, Addr DecompressedDataSize
    .IF eax == STATUS_SUCCESS
        IFDEF DEBUG32
        ;PrintText 'RTLC_DecompressMem RtlDecompressBuffer Success'
        ENDIF
        .IF pWorkSpace != 0
            Invoke GlobalFree, pWorkSpace
        .ENDIF
        .IF lpdwDecompressedDataLength != 0
            mov ebx, lpdwDecompressedDataLength
            mov eax, DecompressedDataSize
            mov [ebx], eax
        .ENDIF
        mov eax, DecompressedData
        ret

    .ELSE
        IFDEF DEBUG32
        ;PrintText 'RTLC_DecompressMem RtlDecompressBuffer Failure'
        ENDIF
        .IF pWorkSpace != 0
            Invoke GlobalFree, pWorkSpace
        .ENDIF
        .IF DecompressedData != 0
            Invoke GlobalFree, DecompressedData
        .ENDIF
        .IF lpdwDecompressedDataLength != 0
            mov ebx, lpdwDecompressedDataLength
            mov eax, 0
            mov [ebx], eax
        .ENDIF
        mov eax, NULL
        ret
        
    .ENDIF

    ret
RTLC_DecompressMem ENDP






