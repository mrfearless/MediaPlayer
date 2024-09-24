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

include RtlCompression_x64.inc
includelib RtlCompression_x64.lib

; Bitmap Create Functions
BitmapCreateFromCompressedRes   PROTO hInst:QWORD, qwResourceID:QWORD
BitmapCreateFromCompressedMem   PROTO lpCompressedBitmapData:QWORD, dwCompressedBitmapDataLength:DWORD
BitmapCreateFromMem             PROTO pBitmapData:QWORD

IconCreateFromCompressedRes     PROTO hInst:QWORD, qwResourceID:QWORD
IconCreateFromCompressedMem     PROTO lpCompressedIconData:QWORD, dwCompressedIconDataLength:DWORD
IconCreateFromMem               PROTO pIconData:QWORD, iIcon:QWORD

RTLC_DecompressMem              PROTO lpCompressedData:QWORD, dwCompressedDataLength:DWORD, lpdwDecompressedDataLength:QWORD

RTLC_HEADER             STRUCT
    RTLCSignature       DD ?
    dwUncompressedSize  DD ?
    dwCompresssedSize   DD ?
RTLC_HEADER             ENDS


IFNDEF BITMAPINFOHEADER
BITMAPINFOHEADER	STRUCT 8
biSize	            DWORD	?
biWidth	            SDWORD	?
biHeight	        SDWORD	?
biPlanes	        WORD	?
biBitCount	        WORD	?
biCompression	    DWORD	?
biSizeImage	        DWORD	?
biXPelsPerMeter	    SDWORD	?
biYPelsPerMeter	    SDWORD	?
biClrUsed	        DWORD	?
biClrImportant	    DWORD	?
BITMAPINFOHEADER	ENDS
ENDIF

IFNDEF BITMAPFILEHEADER
BITMAPFILEHEADER	STRUCT 8
bfType	            WORD	?
bfSize	            DWORD	?
bfReserved1	        WORD	?
bfReserved2	        WORD	?
bfOffBits	        DWORD	?
BITMAPFILEHEADER	ENDS
ENDIF

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
BitmapCreateFromCompressedRes PROC FRAME hInst:QWORD, qwResourceID:QWORD
    LOCAL hRes:QWORD
    LOCAL lpCompressedBitmapData:QWORD
    LOCAL dwCompressedBitmapDataLength:DWORD
    LOCAL lpDecompressedBitmapData:QWORD
    LOCAL hBitmap:QWORD
    
    Invoke FindResource, hInst, qwResourceID, RT_RCDATA ; get compressed bitmap as raw data
    .IF rax != NULL
        mov hRes, rax
        Invoke SizeofResource, hInst, hRes
        .IF rax != 0
            mov dwCompressedBitmapDataLength, eax
            Invoke LoadResource, hInst, hRes
            .IF rax != NULL
                Invoke LockResource, rax
                .IF rax != NULL
                    mov lpCompressedBitmapData, rax
                    
                    Invoke BitmapCreateFromCompressedMem, lpCompressedBitmapData, dwCompressedBitmapDataLength
                    .IF rax != NULL
                        mov hBitmap, rax
                        mov rax, hBitmap
                        ret
                    .ELSE
                        ;PrintText 'Failed to decompress data'
                        mov rax, NULL
                    .ENDIF
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov rax, NULL
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov rax, NULL
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov rax, NULL
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov rax, NULL
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
BitmapCreateFromCompressedMem PROC FRAME lpCompressedBitmapData:QWORD, dwCompressedBitmapDataLength:DWORD
    LOCAL lpDecompressedBitmapData:QWORD
    LOCAL dwDecompressedDataSize:DWORD
    LOCAL hBitmap:QWORD

    .IF lpCompressedBitmapData == NULL || dwCompressedBitmapDataLength == 0
        mov rax, NULL
        ret
    .ENDIF
    
    Invoke RTLC_DecompressMem, lpCompressedBitmapData, dwCompressedBitmapDataLength, Addr dwDecompressedDataSize
    .IF eax != NULL
        mov lpDecompressedBitmapData, rax
        Invoke BitmapCreateFromMem, lpDecompressedBitmapData
        .IF rax != NULL
            mov hBitmap, rax
            .IF lpDecompressedBitmapData != 0
                Invoke GlobalFree, lpDecompressedBitmapData
            .ENDIF
            mov rax, hBitmap
            ret
        .ELSE
            ;PrintText 'Failed to create bitmap from data'
            .IF lpDecompressedBitmapData != 0
                Invoke GlobalFree, lpDecompressedBitmapData
            .ENDIF
        .ENDIF
    .ENDIF
    mov rax, NULL
    ret
BitmapCreateFromCompressedMem ENDP

;------------------------------------------------------------------------------
; BitmapCreateFromMem - Create a bitmap from bitmap data stored in memory.
;
; http://www.masmforum.com/board/index.php?topic=16267.msg134453#msg134453
;
; Returns: HBITMAP or NULL
;------------------------------------------------------------------------------
BitmapCreateFromMem PROC FRAME USES RCX RDX pBitmapData:QWORD
    LOCAL hDC:QWORD
    LOCAL hBmp:QWORD
    LOCAL lpInfoHeader:QWORD
    LOCAL lpInitBits:QWORD

    ;Invoke GetDC,hWnd
    Invoke CreateDC, Addr szMemoryDisplayDC, NULL, NULL, NULL
    test    rax,rax
    jz      @f
    mov     hDC,rax
    mov     rdx,pBitmapData
    lea     rcx,[rdx + SIZEOF BITMAPFILEHEADER]  ; start of the BITMAPINFOHEADER header
    mov lpInfoHeader, rcx
    xor rax, rax
    mov     eax, dword ptr BITMAPFILEHEADER.bfOffBits[rdx]
    add     rdx,rax
    mov lpInitBits, rdx
    Invoke  CreateDIBitmap, hDC, lpInfoHeader, CBM_INIT, lpInitBits, lpInfoHeader, DIB_RGB_COLORS
    mov     hBmp,rax
    ;Invoke  ReleaseDC,hWnd,hDC
    Invoke DeleteDC, hDC
    mov     rax,hBmp
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
IconCreateFromCompressedRes PROC FRAME hInst:QWORD, qwResourceID:QWORD
    LOCAL hRes:QWORD
    LOCAL lpCompressedIconData:QWORD
    LOCAL dwCompressedIconDataLength:DWORD
    LOCAL lpDecompressedIconData:QWORD
    LOCAL hIcon:QWORD
    
    Invoke FindResource, hInst, qwResourceID, RT_RCDATA ; get compressed icon as raw data
    .IF rax != NULL
        mov hRes, rax
        Invoke SizeofResource, hInst, hRes
        .IF rax != 0
            mov dwCompressedIconDataLength, eax
            Invoke LoadResource, hInst, hRes
            .IF rax != NULL
                Invoke LockResource, rax
                .IF rax != NULL
                    mov lpCompressedIconData, rax
                    
                    Invoke IconCreateFromCompressedMem, lpCompressedIconData, dwCompressedIconDataLength
                    .IF rax != NULL
                        mov hIcon, rax
                        mov rax, hIcon
                        ret
                    .ELSE
                        ;PrintText 'Failed to decompress data'
                        mov rax, NULL
                    .ENDIF
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov rax, NULL
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov rax, NULL
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov rax, NULL
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov rax, NULL
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
IconCreateFromCompressedMem PROC FRAME lpCompressedIconData:QWORD, dwCompressedIconDataLength:DWORD
    LOCAL lpDecompressedIconData:QWORD
    LOCAL dwDecompressedDataSize:DWORD
    LOCAL hIcon:QWORD

    .IF lpCompressedIconData == NULL || dwCompressedIconDataLength == 0
        mov rax, NULL
        ret
    .ENDIF
    
    Invoke RTLC_DecompressMem, lpCompressedIconData, dwCompressedIconDataLength, Addr dwDecompressedDataSize
    .IF rax != NULL
        mov lpDecompressedIconData, rax
        Invoke IconCreateFromMem, lpDecompressedIconData, 0
        .IF rax != NULL
            mov hIcon, rax
            .IF lpDecompressedIconData != 0
                Invoke GlobalFree, lpDecompressedIconData
            .ENDIF
            mov rax, hIcon
            ret
        .ELSE
            ;PrintText 'Failed to create bitmap from data'
            .IF lpDecompressedIconData != 0
                Invoke GlobalFree, lpDecompressedIconData
            .ENDIF
        .ENDIF
    .ENDIF
    mov rax, NULL
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
IconCreateFromMem PROC FRAME USES RDX pIconData:QWORD, iIcon:QWORD
    LOCAL sz[2]:DWORD
    LOCAL pbIconBits:QWORD
    LOCAL cbIconBits:DWORD
    LOCAL cxDesired:DWORD
    LOCAL cyDesired:DWORD

    xor rax, rax
    mov rdx, [pIconData]
    or rdx, rdx
    jz ERRORCATCH

    movzx rax, WORD PTR [rdx+4]
    cmp rax, [iIcon]
    ja @F
        ERRORCATCH:
        push rax
        invoke SetLastError, ERROR_RESOURCE_NAME_NOT_FOUND
        pop rdx
        xor rax, rax
        ret
    @@:

    mov rax, [iIcon]
    shl rax, 4
    add rdx, rax
    add rdx, 6

    movzx eax, BYTE PTR [rdx]
    mov [sz], eax
    mov cxDesired, eax
    movzx eax, BYTE PTR [rdx+1]
    mov [sz+4], eax
    mov cyDesired, eax

    mov rdx, [pIconData]
    mov rax, [iIcon]
    shl rax, 4
    add rdx, rax
    add rdx, 6
    xor eax, eax
    mov eax, dword ptr [rdx+8]
    mov cbIconBits, eax
    
    mov rdx, [pIconData]
    mov rax, [iIcon]
    shl rax, 4
    add rdx, rax
    add rdx, 6
    xor eax, eax
    mov eax, dword ptr [rdx+12]
    add rax, [pIconData]
    mov pbIconBits, rax

    Invoke CreateIconFromResourceEx, pbIconBits, cbIconBits, 1, 030000h, cxDesired, cyDesired, 0
    
    xor rdx, rdx
    mov edx,[sz]
    shl edx,16
    mov dx, word ptr [sz+4]

    ret
IconCreateFromMem ENDP

;------------------------------------------------------------------------------
; RTLC_DecompressMem - Decompress memory that was previously compressed with 
; RTL compression using RTLC_CompressMem.
;------------------------------------------------------------------------------
RTLC_DecompressMem PROC FRAME USES RBX lpCompressedData:QWORD, dwCompressedDataLength:DWORD, lpdwDecompressedDataLength:QWORD
    LOCAL DecompressedDataSize:DWORD
    LOCAL DecompressedData:QWORD
    LOCAL CompressedDataSize:DWORD
    LOCAL CompressedData:QWORD
    LOCAL WorkSpaceSize:DWORD
    LOCAL FragmentSpaceSize:DWORD
    LOCAL pWorkSpace:QWORD
    
    IFDEF DEBUG64
    ;PrintText 'RTLC_DecompressMem'
    ENDIF
    
    mov DecompressedData, 0
    mov CompressedData, 0
    mov pWorkSpace, 0
    
    ;--------------------------------------------------------------------------
    ; Basic checks
    ;--------------------------------------------------------------------------
    .IF lpCompressedData == NULL ;|| dwCompressedDataLength == 0
        IFDEF DEBUG64
        PrintText 'RTLC_DecompressMem NULL data or 0 size'
        ENDIF
        .IF lpdwDecompressedDataLength != 0
            mov rbx, lpdwDecompressedDataLength
            mov eax, 0
            mov dword ptr [rbx], eax
        .ENDIF
        mov rax, NULL
        ret
    .ENDIF

    ;----------------------------------------------------------------------
    ; Check for header signature, get uncompressed data size and compressed 
    ; data size and adjust pointer to skip over header.
    ;----------------------------------------------------------------------
    mov rbx, lpCompressedData
    mov eax, dword ptr [rbx]
    .IF eax != HEADER_SIG_RTLC
        .IF lpdwDecompressedDataLength != 0
            mov rbx, lpdwDecompressedDataLength
            mov eax, 0
            mov dword ptr [rbx], eax
        .ENDIF
        mov rax, NULL
        ret
    .ENDIF
    mov eax, dword ptr [rbx+4]
    mov DecompressedDataSize, eax
    mov eax, dword ptr [rbx+8]
    mov CompressedDataSize, eax
    
;    mov eax, CompressedDataSize
;    .IF eax > dwCompressedDataLength
;        IFDEF DEBUG64
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
    
    mov rax, lpCompressedData
    mov CompressedData, rax
    add CompressedData, RTLC_HEADER_SIZE

    
    ;----------------------------------------------------------------------
    ; Obtain the size of workspace
    ;----------------------------------------------------------------------
    Invoke RtlGetCompressionWorkSpaceSize, COMPRESSION_FORMAT_LZNT1 or COMPRESSION_ENGINE_MAXIMUM, Addr WorkSpaceSize, Addr FragmentSpaceSize
    .IF rax != STATUS_SUCCESS
        IFDEF DEBUG64
        PrintText 'RTLC_DecompressMem RtlGetCompressionWorkSpaceSize Error'
        ENDIF
        .IF lpdwDecompressedDataLength != 0
            mov rbx, lpdwDecompressedDataLength
            mov eax, 0
            mov dword ptr [rbx], eax
        .ENDIF
        mov rax, NULL
        ret
    .ENDIF
        
    ;----------------------------------------------------------------------
    ; Allocate memory for workspace 
    ;----------------------------------------------------------------------
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, WorkSpaceSize
    .IF rax == NULL
        IFDEF DEBUG64
        PrintText 'RTLC_DecompressMem GlobalAlloc WorkSpaceSize Error'
        ENDIF
        .IF lpdwDecompressedDataLength != 0
            mov rbx, lpdwDecompressedDataLength
            mov eax, 0
            mov dword ptr [rbx], eax
        .ENDIF
        mov rax, NULL
        ret
    .ENDIF
    mov pWorkSpace, rax
        
    ;--------------------------------------------------------------------------
    ; Alloc buffer required
    ;--------------------------------------------------------------------------
    mov eax, DecompressedDataSize 
    add eax, 4 ; we add four extra to give us 4 null bytes in case compressed
    ; data is an ansi or unicode string or something that requires null endings
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
    .IF rax == NULL
        IFDEF DEBUG64
        PrintText 'RTLC_DecompressMem GlobalAlloc Failed'
        ENDIF
        .IF pWorkSpace != 0
            Invoke GlobalFree, pWorkSpace
        .ENDIF
        .IF lpdwDecompressedDataLength != 0
            mov rbx, lpdwDecompressedDataLength
            mov eax, 0
            mov dword ptr [rbx], eax
        .ENDIF
        mov rax, NULL
        ret
    .ENDIF
    mov DecompressedData, rax
        
    ;--------------------------------------------------------------------------
    ; Decompress
    ;--------------------------------------------------------------------------
    Invoke RtlDecompressBuffer, COMPRESSION_FORMAT_LZNT1, DecompressedData, DecompressedDataSize, CompressedData, CompressedDataSize, Addr DecompressedDataSize
    .IF rax == STATUS_SUCCESS
        IFDEF DEBUG64
        ;PrintText 'RTLC_DecompressMem RtlDecompressBuffer Success'
        ENDIF
        .IF pWorkSpace != 0
            Invoke GlobalFree, pWorkSpace
        .ENDIF
        .IF lpdwDecompressedDataLength != 0
            mov rbx, lpdwDecompressedDataLength
            mov eax, DecompressedDataSize
            mov dword ptr [rbx], eax
        .ENDIF
        mov rax, DecompressedData
        ret

    .ELSE
        IFDEF DEBUG64
        ;PrintText 'RTLC_DecompressMem RtlDecompressBuffer Failure'
        ENDIF
        .IF pWorkSpace != 0
            Invoke GlobalFree, pWorkSpace
        .ENDIF
        .IF DecompressedData != 0
            Invoke GlobalFree, DecompressedData
        .ENDIF
        .IF lpdwDecompressedDataLength != 0
            mov rbx, lpdwDecompressedDataLength
            mov eax, 0
            mov dword ptr [rbx], eax
        .ENDIF
        mov rax, NULL
        ret
        
    .ENDIF

    ret
RTLC_DecompressMem ENDP






