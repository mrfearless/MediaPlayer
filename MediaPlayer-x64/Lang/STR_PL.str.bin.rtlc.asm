;------------------------------------------------------------------------------
; Source Filename  : STR_PL.str.bin
; Size Uncompressed: 1980 Bytes
; Size Compressed  : 442 Bytes
; Compression Ratio: 78% (4:1)
; Compression Used : Rtl
;------------------------------------------------------------------------------

.DATA

STR_PL \
DB 052h,054h,04Ch,043h,0BCh,007h,000h,000h,0AEh,001h,000h,000h,0ABh,0B1h,000h,001h
DB 000h,000h,000h,04Fh,000h,074h,000h,000h,077h,000h,0F3h,000h,072h,000h,07Ah,000h
DB 000h,020h,000h,070h,000h,06Ch,000h,069h,000h,0A2h,06Bh,000h,048h,06Dh,000h,075h
DB 000h,058h,074h,000h,034h,0A0h,06Dh,000h,065h,000h,064h,000h,01Ch,061h,000h,03Ch
DB 088h,06Eh,000h,079h,000h,06Ch,064h,000h,06Fh,000h,014h,0D6h,06Fh,000h,01Ch,001h
DB 076h,06Fh,002h,076h,065h,000h,036h,001h,046h,055h,02Dh,000h,002h,000h,003h,05Ah
DB 000h,037h,074h,002h,045h,079h,051h,000h,06Dh,061h,000h,06Ah,000h,05Dh,04Fh,004h
DB 05Dh,061h,0B5h,002h,017h,061h,002h,05Dh,065h,02Eh,05Dh,023h,000h,003h,080h,001h
DB 0A8h,057h,000h,073h,0FAh,041h,004h,080h,001h,050h,084h,0A4h,0E0h,042h,001h,005h
DB 001h,063h,082h,0C7h,085h,0B1h,08Bh,040h,08Ah,02Fh,080h,014h,061h,080h,0CFh,07Ah
DB 000h,019h,001h,0E1h,055h,046h,000h,005h,0C0h,000h,04Bh,040h,01Ah,06Fh,042h,080h
DB 04Bh,0BBh,0C0h,07Bh,0C1h,065h,06Bh,0C0h,01Ch,03Fh,000h,025h,000h,006h,0D2h,041h
DB 0D6h,050h,042h,003h,043h,09Fh,045h,040h,024h,072h,0C2h,042h,03Fh,000h,015h,013h
DB 000h,007h,0C2h,083h,079h,0C0h,080h,064h,000h,07Ah,014h,001h,020h,042h,020h,041h
DB 0C6h,0C6h,061h,000h,063h,0B7h,040h,006h,0FFh,044h,01Bh,000h,008h,0D2h,041h,041h
DB 025h,063h,0C0h,01Eh,0AEh,073h,046h,0DCh,0FFh,0A3h,017h,000h,009h,064h,010h,06Fh
DB 060h,01Fh,0ABh,0A1h,07Ch,0E1h,01Eh,065h,0A2h,010h,069h,020h,023h,065h,060h,002h
DB 057h,01Fh,000h,01Fh,000h,01Bh,000h,00Ah,060h,000h,049h,020h,01Dh,066h,0AFh,022h
DB 010h,021h,073h,0A5h,010h,061h,090h,04Dh,066h,093h,050h,0A2h,055h,0BAh,079h,0E0h
DB 001h,072h,09Fh,00Ah,01Fh,000h,00Ah,000h,00Bh,0EAh,062h,017h,0A3h,09Fh,063h,033h
DB 0E1h,073h,075h,064h,011h,031h,000h,030h,0D5h,0A0h,000h,053h,020h,010h,06Bh,060h
DB 002h,06Eh,020h,003h,01Fh,000h,0DBh,01Fh,000h,005h,000h,00Ch,06Ah,010h,0A3h,095h
DB 065h,060h,021h,0A3h,084h,057h,0BFh,00Fh,01Fh,000h,01Fh,000h,00Dh,060h,000h,053h
DB 022h,0A4h,062h,045h,022h,050h,061h,0E4h,020h,019h,001h,064h,0A0h,00Eh,06Fh,0F0h
DB 000h,05Bh,001h,007h,0A0h,065h,0B1h,0A6h,0FFh,0C2h,01Fh,000h,0B5h,003h,000h,00Eh
DB 062h,073h,06Fh,062h,0D1h,0A1h,05Fh,06Ah,03Fh,011h,0B7h,03Fh,011h,01Fh,000h,00Ah
DB 000h,014h,0E4h,083h,0A1h,02Fh,079h,066h,00Dh,0FFh,021h,032h,0E1h,0A5h,0E3h,012h
DB 0E1h,011h,0E3h,085h,03Fh,085h,01Fh,000h,00Fh,000h

STR_PL_SIZE EQU $ - STR_PL
STR_PL_RECORDS EQU (1980 / SIZEOF STR_PL_RECORD)
