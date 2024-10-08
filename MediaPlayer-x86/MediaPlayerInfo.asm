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

MFI_MediaItemInfoText   PROTO pMediaItem:DWORD

MFI_AudioStreamText     PROTO pStreamRecord:DWORD, lpszStreamText:DWORD, bMajorType:DWORD, dwStreamNo:DWORD
MFI_VideoStreamText     PROTO pStreamRecord:DWORD, lpszStreamText:DWORD, bMajorType:DWORD, dwStreamNo:DWORD

MFI_MajorTypeToString   PROTO dwMajorType:DWORD, lpdwMajorTypeString:DWORD
MFI_AudioTypeToString   PROTO dwAudioType:DWORD, lpdwAudioTypeString:DWORD, bShortName:DWORD
MFI_VideoTypeToString   PROTO dwVideoType:DWORD, lpdwVideoTypeString:DWORD, bShortName:DWORD


.CONST
; ChannelMask
SPEAKER_FRONT_LEFT              EQU 1h
SPEAKER_FRONT_RIGHT             EQU 2h
SPEAKER_FRONT_CENTER            EQU 4h
SPEAKER_LOW_FREQUENCY           EQU 8h
SPEAKER_BACK_LEFT               EQU 10h
SPEAKER_BACK_RIGHT              EQU 20h
SPEAKER_FRONT_LEFT_OF_CENTER    EQU 40h
SPEAKER_FRONT_RIGHT_OF_CENTER   EQU 80h
SPEAKER_BACK_CENTER             EQU 100h
SPEAKER_SIDE_LEFT               EQU 200h
SPEAKER_SIDE_RIGHT              EQU 400h
SPEAKER_TOP_CENTER              EQU 800h
SPEAKER_TOP_FRONT_LEFT          EQU 1000h
SPEAKER_TOP_FRONT_CENTER        EQU 2000h
SPEAKER_TOP_FRONT_RIGHT         EQU 4000h
SPEAKER_TOP_BACK_LEFT           EQU 8000h
SPEAKER_TOP_BACK_CENTER         EQU 10000h
SPEAKER_TOP_BACK_RIGHT          EQU 20000h


.DATA
ALIGN 4

pszMediaItemInfo         DD 0

IFDEF __UNICODE__
szStreamText            DB 288 DUP (0)
ELSE
szStreamText            DB 144 DUP (0)
ENDIF

IFDEF __UNICODE__
szStream                DB "S",0,"t",0,"r",0,"e",0,"a",0,"m",0," ",0
                        DB 0,0,0,0
szMIIColon              DB ":",0
                        DB 0,0,0,0
szMIILeftBracket        DB "(",0
                        DB 0,0,0,0
szMIIRightBracket       DB ")",0
                        DB 0,0,0,0
szMIILeftSqBracket      DB "[",0
                        DB 0,0,0,0
szMIIRightSqBracket     DB "]",0
                        DB 0,0,0,0
szMIIAsterisk           DB "*",0
                        DB 0,0,0,0
szMIIQuestion           DB "?",0
                        DB 0,0,0,0
szMIISpace              DB " ",0
                        DB 0,0,0,0
szMIIDash               DB "-",0
                        DB 0,0,0,0
szMIIkbps               DB "k",0,"b",0,"p",0,"s",0
                        DB 0,0,0,0
szMIIchannels           DB "C",0,"h",0 
                        DB 0,0,0,0 ; ,"a",0,"n",0,"n",0,"e",0,"l",0,"s",0
szMIIHz                 DB "H",0,"z",0
                        DB 0,0,0,0
szMIIbits               DB "b",0,"i",0,"t",0
                        DB 0,0,0,0
                        
                        
szLFE                   DB "/",0,"L",0,"F",0,"E",0 ; Low Frequency (Subwoofer)
                        DB 0,0,0,0
sz1F                    DB "1",0,"F",0 ; Front Center
                        DB 0,0,0,0
sz2F                    DB "2",0,"F",0 ; Front Left & Right
                        DB 0,0,0,0
sz3F                    DB "3",0,"F",0 ; Front Left, Right & Center
                        DB 0,0,0,0
sz5F                    DB "5",0,"F",0 ; Front Left, Right & Center + Front Left & Right of Center
                        DB 0,0,0,0
sz1B                    DB "1",0,"B",0 ; Back Center
                        DB 0,0,0,0
sz2B                    DB "2",0,"B",0 ; Back Left & Right
                        DB 0,0,0,0
sz3B                    DB "3",0,"B",0 ; Back Left, Right & Center
                        DB 0,0,0,0
sz2S                    DB "2",0,"M",0 ; Side Left & Right
                        DB 0,0,0,0
sz1TF                   DB "1",0,"T",0,"F",0 ; Top Front Center
                        DB 0,0,0,0
sz2TF                   DB "2",0,"T",0,"F",0 ; Top Front Left & Right
                        DB 0,0,0,0
sz3TF                   DB "3",0,"T",0,"F",0 ; Top Front Left, Right & Center
                        DB 0,0,0,0
sz1TC                   DB "1",0,"T",0,"C",0 ; Top Center
                        DB 0,0,0,0
sz1TB                   DB "1",0,"T",0,"B",0 ; Top Back Center
                        DB 0,0,0,0
sz2TB                   DB "2",0,"T",0,"B",0 ; Top Back Left & Right
                        DB 0,0,0,0
sz3TB                   DB "3",0,"T",0,"B",0 ; Top Back Left, Right & Center
                        DB 0,0,0,0

szMIIfps                DB "f",0,"p",0,"s",0
                        DB 0,0,0,0
szMIIx                  DB "x",0
                        DB 0,0,0,0
szMIICRLF               DB 13,0,10,0
                        DB 0,0,0,0
                        
szMFMT_None             DB "N",0,"o",0,"n",0,"e",0
                        DB 0,0,0,0
szMFMT_Audio 	        DB "A",0,"u",0,"d",0,"i",0,"o",0
                        DB 0,0,0,0
szMFMT_Video 	        DB "V",0,"i",0,"d",0,"e",0,"o",0
                        DB 0,0,0,0
szMFMT_Stream 	        DB "S",0,"t",0,"r",0,"e",0,"a",0,"m",0
                        DB 0,0,0,0
szMFMT_Metadata 	    DB "M",0,"e",0,"t",0,"a",0,"d",0,"a",0,"t",0,"a",0
                        DB 0,0,0,0
szMFMT_Protected 	    DB "D",0,"R",0,"M",0
                        DB 0,0,0,0
szMFMT_SAMI 	        DB "S",0,"A",0,"M",0,"I",0
                        DB 0,0,0,0
szMFMT_Image 	        DB "I",0,"m",0,"a",0,"g",0,"e",0
                        DB 0,0,0,0
szMFMT_Binary 	        DB "B",0,"i",0,"n",0,"a",0,"r",0,"y",0
                        DB 0,0,0,0
szMFMT_HTML 	        DB "H",0,"T",0,"M",0,"L",0
                        DB 0,0,0,0
szMFMT_Perception 	    DB "S",0,"e",0,"n",0,"s",0,"o",0,"r",0,"/",0,"R",0,"a",0,"w",0
                        DB 0,0,0,0
szMFMT_FileTransfer 	DB "D",0,"a",0,"t",0,"a",0," ",0,"f",0,"i",0,"l",0,"e",0,"s",0
                        DB 0,0,0,0
szMFMT_Script 	        DB "S",0,"c",0,"r",0,"i",0,"p",0,"t",0
                        DB 0,0,0,0

; Audio Format
;szMFAF_Unknown          DB "U",0,"n",0,"k",0,"n",0,"o",0,"w",0,"n",0," ",0,"A",0,"u",0,"d",0,"i",0,"o",0
;                        DB 0,0,0,0
;szMFAF_MP3 	            DB "M",0,"P",0,"E",0,"G",0," ",0,"A",0,"u",0,"d",0,"i",0,"o",0," ",0,"L",0,"a",0,"y",0,"e",0,"r",0,"-",0,"3",0," ",0,"(",0,"M",0,"P",0,"3",0,")",0
;                        DB 0,0,0,0
;szMFAF_AAC 	            DB "A",0,"d",0,"v",0,"a",0,"n",0,"c",0,"e",0,"d",0," ",0,"A",0,"u",0,"d",0,"i",0,"o",0," ",0,"C",0,"o",0,"d",0,"i",0,"n",0,"g",0," ",0,"(",0,"A",0,"A",0,"C",0,")",0
;                        DB 0,0,0,0
;szMFAF_ALAC 	        DB "A",0,"p",0,"p",0,"l",0,"e",0," ",0,"L",0,"o",0,"s",0,"s",0,"l",0,"e",0,"s",0,"s",0," ",0,"A",0,"u",0,"d",0,"i",0,"o",0," ",0,"C",0,"o",0,"d",0,"e",0,"c",0," ",0,"(",0,"A",0,"L",0,"A",0,"C",0,")",0
;                        DB 0,0,0,0
;szMFAF_Dolby_AC3 	    DB "D",0,"o",0,"l",0,"b",0,"y",0," ",0,"D",0,"i",0,"g",0,"i",0,"t",0,"a",0,"l",0," ",0,"(",0,"A",0,"C",0,"-",0,"3",0,")",0
;                        DB 0,0,0,0
;szMFAF_Dolby_AC3_SP     DB "D",0,"o",0,"l",0,"b",0,"y",0," ",0,"A",0,"C",0,"-",0,"3",0," ",0,"A",0,"u",0,"d",0,"i",0,"o",0," ",0,"O",0,"v",0,"e",0,"r",0," ",0,"S",0,"/",0,"P",0,"D",0,"I",0,"F",0
;                        DB 0,0,0,0
;szMFAF_Dolby_DDPlus 	DB "D",0,"o",0,"l",0,"b",0,"y",0," ",0,"D",0,"i",0,"g",0,"i",0,"t",0,"a",0,"l",0," ",0,"P",0,"l",0,"u",0,"s",0
;                        DB 0,0,0,0
;szMFAF_Dolby_AC4        DB "D",0,"o",0,"l",0,"b",0,"y",0," ",0,"(",0,"A",0,"C",0,"-",0,"4",0,")",0
;                        DB 0,0,0,0
;szMFAF_Dolby_AC4_V1     DB "D",0,"o",0,"l",0,"b",0,"y",0," ",0,"(",0,"A",0,"C",0,"-",0,"4",0,")",0
;                        DB 0,0,0,0
;szMFAF_Dolby_AC4_V2     DB "D",0,"o",0,"l",0,"b",0,"y",0," ",0,"(",0,"A",0,"C",0,"-",0,"4",0,")",0
;                        DB 0,0,0,0
;szMFAF_Dolby_AC4_V1_ES  DB "D",0,"o",0,"l",0,"b",0,"y",0," ",0,"(",0,"A",0,"C",0,"-",0,"4",0,")",0
;                        DB 0,0,0,0
;szMFAF_Dolby_AC4_V2_ES  DB "D",0,"o",0,"l",0,"b",0,"y",0," ",0,"(",0,"A",0,"C",0,"-",0,"4",0,")",0
;                        DB 0,0,0,0
;szMFAF_DTS 	            DB "D",0,"i",0,"g",0,"i",0,"t",0,"a",0,"l",0," ",0,"T",0,"h",0,"e",0,"a",0,"t",0,"e",0,"r",0," ",0,"S",0,"y",0,"s",0,"t",0,"e",0,"m",0,"s",0," ",0,"(",0,"D",0,"T",0,"S",0,")",0
;                        DB 0,0,0,0
;szMFAF_DTS_RAW          DB "D",0,"i",0,"g",0,"i",0,"t",0,"a",0,"l",0," ",0,"T",0,"h",0,"e",0,"a",0,"t",0,"e",0,"r",0," ",0,"S",0,"y",0,"s",0,"t",0,"e",0,"m",0,"s",0," ",0,"(",0,"D",0,"T",0,"S",0,")",0
;                        DB 0,0,0,0
;szMFAF_DTS_HD           DB "Digital Theater Systems Master Audio (DTS-HD)",0
;                        DB 0,0,0,0
;szMFAF_DTS_XLL          DB "Digital Theater Systems Master Audio Lossless (DTS-XLL)",0
;                        DB 0,0,0,0
;szMFAF_DTS_LBR          DB "Digital Theater Systems (DTS-LBR)",0
;                        DB 0,0,0,0
;szMFAF_DTS_UHD          DB "Digital Theater Systems Ultra Audio (DTS-UHD)",0
;                        DB 0,0,0,0
;szMFAF_DTS_UHDY         DB "Digital Theater Systems Ultra Audio (DTS-UHDY)",0
;                        DB 0,0,0,0
;szMFAF_PCM 	            DB "Uncompressed PCM Audio",0
;                        DB 0,0,0,0
;szMFAF_LPCM             DB "DVD audio data",0
;                        DB 0,0,0,0
;szMFAF_WMASPDIF 	    DB "Windows Media Audio 9 Professional Codec Over S/PDIF",0
;                        DB 0,0,0,0
;szMFAF_WMAudio_LL       DB "Windows Media Audio 9/9.1 Lossless Codec",0
;                        DB 0,0,0,0
;szMFAF_WMAudioV8 	    DB "Windows Media Audio 8/9/9.1 Codec",0
;                        DB 0,0,0,0
;szMFAF_WMAudioV9 	    DB "Windows Media Audio 9/9.1 Professional Codec",0
;                        DB 0,0,0,0
;szMFAF_FLAC 	        DB "Free Lossless Audio Codec",0
;                        DB 0,0,0,0
;szMFAF_MPEG 	        DB "MPEG-1 Audio (MP1)",0
;                        DB 0,0,0,0
;szMFAF_MPEGH            DB "MPEG-1 Audio (MP1)",0
;                        DB 0,0,0,0
;szMFAF_MPEGH_ES         DB "MPEG-1 Audio (MP1)",0
;                        DB 0,0,0,0
;szMFAF_MSP1 	        DB "Windows Media Audio 9 Voice Codec",0
;                        DB 0,0,0,0
;szMFAF_AMR_NB 	        DB "Adaptive Multi-Rate Narrowband (AMR_NB)",0
;                        DB 0,0,0,0
;szMFAF_AMR_WB 	        DB "Adaptive Multi-Rate Wideband (AMR_WB)",0
;                        DB 0,0,0,0
;szMFAF_AMR_WP 	        DB "Adaptive Multi-Rate Wideband Plus (AMR_WP)",0
;                        DB 0,0,0,0
;szMFAF_DRM 	            DB "Encrypted Audio Data",0
;                        DB 0,0,0,0
;szMFAF_Opus 	        DB "Opus",0
;                        DB 0,0,0,0
;szMFAF_Vorbis           DB "VORBIS",0
;                        DB 0,0,0,0
;szMFAF_Float 	        DB "Uncompressed IEEE Floating-point Audio",0
;                        DB 0,0,0,0
;szMFAF_Float_SO         DB "Uncompressed IEEE Floating-point Audio",0
;                        DB 0,0,0,0
;szMFAF_RAW_AAC1 	    DB "Advanced Audio Coding (AAC) In AVI",0
;                        DB 0,0,0,0
;szMFAF_QCELP 	        DB "QCELP Audio",0
;                        DB 0,0,0,0
;szMFAF_Dolby_AC3_HDCP   DB "Dolby Digital (AC-3) (HDCP)",0
;                        DB 0,0,0,0
;szMFAF_AAC_HDCP         DB "Advanced Audio Coding (AAC) (HDCP)"
;                        DB 0,0,0,0
;szMFAF_PCM_HDCP         DB "Uncompressed PCM Audio (HDCP)",0
;                        DB 0,0,0,0
;szMFAF_ADTS_HDCP        DB "Advanced Audio Coding (AAC) (ADTS) format (HDCP)",0
;                        DB 0,0,0,0
;szMFAF_ADTS 	        DB "Audio Data Transport Stream (ADTS)",0
;                        DB 0,0,0,0

; Audio Format Short name
szMFAF_Unknown_S         DB "U",0,"n",0,"k",0,"n",0,"o",0,"w",0,"n",0
                         DB 0,0,0,0
szMFAF_MP3_S 	         DB "M",0,"P",0,"3",0
                         DB 0,0,0,0
szMFAF_AAC_S 	         DB "A",0,"A",0,"C",0
                         DB 0,0,0,0
szMFAF_ALAC_S 	         DB "A",0,"L",0,"A",0,"C",0
                         DB 0,0,0,0
szMFAF_Dolby_AC3_S 	     DB "A",0,"C",0,"-",0,"3",0
                         DB 0,0,0,0
szMFAF_Dolby_AC3_SP_S    DB "A",0,"C",0,"-",0,"3",0
                         DB 0,0,0,0
szMFAF_Dolby_DDPlus_S 	 DB "E",0,"A",0,"C",0,"-",0,"3",0
                         DB 0,0,0,0
szMFAF_Dolby_AC4_S       DB "A",0,"C",0,"-",0,"4",0
                         DB 0,0,0,0
szMFAF_Dolby_AC4_V1_S    DB "A",0,"C",0,"-",0,"4",0
                         DB 0,0,0,0
szMFAF_Dolby_AC4_V2_S    DB "A",0,"C",0,"-",0,"4",0
                         DB 0,0,0,0
szMFAF_Dolby_AC4_V1_ES_S DB "A",0,"C",0,"-",0,"4",0
                         DB 0,0,0,0
szMFAF_Dolby_AC4_V2_ES_S DB "A",0,"C",0,"-",0,"4",0
                         DB 0,0,0,0
szMFAF_DTS_S 	         DB "D",0,"T",0,"S",0
                         DB 0,0,0,0
szMFAF_DTS_RAW_S         DB "D",0,"T",0,"S",0
                         DB 0,0,0,0
szMFAF_DTS_HD_S          DB "D",0,"T",0,"S",0,"-",0,"H",0,"D",0
                         DB 0,0,0,0
szMFAF_DTS_XLL_S         DB "D",0,"T",0,"S",0,"-",0,"X",0,"L",0,"L",0
                         DB 0,0,0,0
szMFAF_DTS_LBR_S         DB "D",0,"T",0,"S",0,"-",0,"L",0,"B",0,"R",0
                         DB 0,0,0,0
szMFAF_DTS_UHD_S         DB "D",0,"T",0,"S",0,"-",0,"U",0,"H",0,"D",0
                         DB 0,0,0,0
szMFAF_DTS_UHDY_S        DB "D",0,"T",0,"S",0,"-",0,"U",0,"H",0,"D",0,"Y",0
                         DB 0,0,0,0
szMFAF_PCM_S 	         DB "P",0,"C",0,"M",0
                         DB 0,0,0,0
szMFAF_LPCM_S            DB "D",0,"V",0,"D",0,"-",0,"A",0
                         DB 0,0,0,0
szMFAF_WMASPDIF_S 	     DB "W",0,"M",0,"A",0,"P",0,"R",0,"O",0
                         DB 0,0,0,0
szMFAF_WMAudio_LL_S      DB "W",0,"M",0,"A",0,"L",0,"O",0,"S",0,"S",0,"L",0,"E",0,"S",0,"S",0
                         DB 0,0,0,0
szMFAF_WMAudioV8_S 	     DB "W",0,"M",0,"A",0,"V",0,"2",0
                         DB 0,0,0,0
szMFAF_WMAudioV9_S 	     DB "W",0,"M",0,"A",0,"P",0,"R",0,"O",0
                         DB 0,0,0,0
szMFAF_FLAC_S 	         DB "F",0,"L",0,"A",0,"C",0
                         DB 0,0,0,0
szMFAF_MPEG_S 	         DB "M",0,"P",0,"1",0
                         DB 0,0,0,0
szMFAF_MPEGH_S           DB "M",0,"P",0,"1",0
                         DB 0,0,0,0
szMFAF_MPEGH_ES_S        DB "M",0,"P",0,"1",0
                         DB 0,0,0,0
szMFAF_MSP1_S 	         DB "W",0,"M",0,"A",0,"V",0,"O",0,"I",0,"C",0,"E",0
                         DB 0,0,0,0
szMFAF_AMR_NB_S 	     DB "A",0,"M",0,"R",0,"_",0,"N",0,"B",0
                         DB 0,0,0,0
szMFAF_AMR_WB_S 	     DB "A",0,"M",0,"R",0,"_",0,"W",0,"B",0
                         DB 0,0,0,0
szMFAF_AMR_WP_S 	     DB "A",0,"M",0,"R",0,"_",0,"W",0,"P",0
                         DB 0,0,0,0
szMFAF_DRM_S 	         DB "D",0,"R",0,"M",0
                         DB 0,0,0,0
szMFAF_Opus_S 	         DB "O",0,"p",0,"u",0,"s",0
                         DB 0,0,0,0
szMFAF_Vorbis_S          DB "V",0,"O",0,"R",0,"B",0,"I",0,"S",0
                         DB 0,0,0,0
szMFAF_Float_S 	         DB "F",0,"l",0,"o",0,"a",0,"t",0
                         DB 0,0,0,0
szMFAF_Float_SO_S        DB "F",0,"l",0,"o",0,"a",0,"t",0
                         DB 0,0,0,0
szMFAF_RAW_AAC1_S 	     DB "A",0,"A",0,"C",0
                         DB 0,0,0,0
szMFAF_QCELP_S 	         DB "Q",0,"C",0,"E",0,"L",0,"P",0
                         DB 0,0,0,0
szMFAF_Dolby_AC3_HDCP_S  DB "A",0,"C",0,"-",0,"3",0
                         DB 0,0,0,0
szMFAF_AAC_HDCP_S        DB "A",0,"A",0,"C"
                         DB 0,0,0,0
szMFAF_PCM_HDCP_S        DB "P",0,"C",0,"M",0
                         DB 0,0,0,0
szMFAF_ADTS_HDCP_S       DB "A",0,"A",0,"C",0,"-",0,"A",0,"D",0,"T",0,"S",0
                         DB 0,0,0,0
szMFAF_ADTS_S	         DB "A",0,"D",0,"T",0,"S",0
                         DB 0,0,0,0

; Video Format
;szMFVF_Unknown          DB "Unknown Video",0
;                        DB 0,0,0,0
;szMFVF_M4S2 	        DB "MPEG-4 Part 2 - MPEG-4 Advanced Simple Profile (MPEG4)",0
;                        DB 0,0,0,0
;szMFVF_MP4V 	        DB "MPEG-4 Part 2 (MPEG4)",0
;                        DB 0,0,0,0
;szMFVF_H264 	        DB "H.264/MPEG-4 Part 10, AVC (H264)",0
;                        DB 0,0,0,0
;szMFVF_H265 	        DB "H.265 Video (H265)",0
;                        DB 0,0,0,0
;szMFVF_H264_ES          DB "H.264 Elementary Stream (H264)",0
;                        DB 0,0,0,0
;szMFVF_WMV1 	        DB "Windows Media Video Codec Version 7 (WMV1)",0
;                        DB 0,0,0,0
;szMFVF_WMV2 	        DB "Windows Media Video 8 Codec (WMV2)",0
;                        DB 0,0,0,0
;szMFVF_WMV3 	        DB "Windows Media Video 9 Codec (WMV3)",0
;                        DB 0,0,0,0
;szMFVF_MP4S 	        DB "MPEG-4 Part 2 - MPEG-4 Simple Profile (MPEG4)",0
;                        DB 0,0,0,0
;szMFVF_AV1 	            DB "Audio Video Interleaved (AVI) Video",0
;                        DB 0,0,0,0
;szMFVF_VP80 	        DB "On2 TrueMotion VP8/Google WebM Video (VP8)",0
;                        DB 0,0,0,0
;szMFVF_VP90 	        DB "On2 TrueMotion VP9 Video (VP9)",0
;                        DB 0,0,0,0
;szMFVF_HEVC 	        DB "H.265/MPEG-H Part 2, HEVC - Main/Main Still Picture profile (HEVC)",0
;                        DB 0,0,0,0
;szMFVF_HEVC_ES          DB "H.265/MPEG-H Part 2, HEVC - Main 10 profile (HEVC)",0
;                        DB 0,0,0,0
;szMFVF_H263 	        DB "H.263 Video (H263)",0
;                        DB 0,0,0,0
;szMFVF_MSS1 	        DB "Windows Media Screen Codec Version 1 (MSS1)",0
;                        DB 0,0,0,0
;szMFVF_MSS2 	        DB "Windows Media Video 9 Screen Codec (MSS2)",0
;                        DB 0,0,0,0
;szMFVF_MJPG 	        DB "Motion JPEG (MJPG)",0
;                        DB 0,0,0,0
;szMFVF_MPG1 	        DB "MPEG-1 Part 2, Video (MPG1)",0
;                        DB 0,0,0,0
;szMFVF_MPEG2            DB "H.262/MPEG-2 Part 2, Video (MPEG2)",0
;                        DB 0,0,0,0
;szMFVF_DV25 	        DB "DVCPRO 25 (525-60 or 625-50)",0
;                        DB 0,0,0,0
;szMFVF_DV50 	        DB "DVCPRO 50 (525-60 or 625-50)",0
;                        DB 0,0,0,0
;szMFVF_DVC 	            DB "DVC/DV Video",0
;                        DB 0,0,0,0
;szMFVF_DVH1 	        DB "DVCPRO 100 (1080/60i, 1080/50i, or 720/60P)",0
;                        DB 0,0,0,0
;szMFVF_DVHD 	        DB "HD-DVCR (1125-60 or 1250-50)",0
;                        DB 0,0,0,0
;szMFVF_DVSD 	        DB "SDL-DVCR (525-60 or 625-50)",0
;                        DB 0,0,0,0
;szMFVF_DVSL 	        DB "SD-DVCR (525-60 or 625-50)",0
;                        DB 0,0,0,0
;szMFVF_WVC1 	        DB 'SMPTE 421M ("VC-1")',0
;                        DB 0,0,0,0
;szMFVF_420O 	        DB "8-bit per channel planar YUV 4:2:0 video",0
;                        DB 0,0,0,0
;szMFVF_MP43 	        DB "Microsoft MPEG-4 version 3",0
;                        DB 0,0,0,0

; Video Format Short name
szMFVF_Unknown_S        DB "U",0,"n",0,"k",0,"n",0,"o",0,"w",0,"n",0
                        DB 0,0,0,0
szMFVF_M4S2_S 	        DB "M",0,"P",0,"E",0,"G",0,"4",0
                        DB 0,0,0,0
szMFVF_MP4V_S 	        DB "M",0,"P",0,"E",0,"G",0,"4",0
                        DB 0,0,0,0
szMFVF_H264_S 	        DB "H",0,"2",0,"6",0,"4",0
                        DB 0,0,0,0
szMFVF_H265_S 	        DB "H",0,"2",0,"6",0,"5",0
                        DB 0,0,0,0
szMFVF_H264_ES_S        DB "H",0,"2",0,"6",0,"4",0
                        DB 0,0,0,0
szMFVF_WMV1_S 	        DB "W",0,"M",0,"V",0,"1",0
                        DB 0,0,0,0
szMFVF_WMV2_S 	        DB "W",0,"M",0,"V",0,"2",0
                        DB 0,0,0,0
szMFVF_WMV3_S 	        DB "W",0,"M",0,"V",0,"3",0
                        DB 0,0,0,0
szMFVF_MP4S_S 	        DB "M",0,"P",0,"E",0,"G",0,"4",0
                        DB 0,0,0,0
szMFVF_AV1_S            DB "A",0,"V",0,"0",0,"1",0
                        DB 0,0,0,0
szMFVF_VP80_S 	        DB "V",0,"P",0,"8",0
                        DB 0,0,0,0
szMFVF_VP90_S 	        DB "V",0,"P",0,"9",0
                        DB 0,0,0,0
szMFVF_HEVC_S 	        DB "H",0,"E",0,"V",0,"C",0
                        DB 0,0,0,0
szMFVF_HEVC_ES_S        DB "H",0,"E",0,"V",0,"C",0
                        DB 0,0,0,0
szMFVF_H263_S 	        DB "H",0,"2",0,"6",0,"3",0
                        DB 0,0,0,0
szMFVF_MSS1_S 	        DB "M",0,"S",0,"S",0,"1",0
                        DB 0,0,0,0
szMFVF_MSS2_S 	        DB "M",0,"S",0,"S",0,"2",0
                        DB 0,0,0,0
szMFVF_MJPG_S 	        DB "M",0,"J",0,"P",0,"G",0
                        DB 0,0,0,0
szMFVF_MPG1_S 	        DB "M",0,"P",0,"E",0,"G",0,"1",0
                        DB 0,0,0,0
szMFVF_MPEG2_S          DB "M",0,"P",0,"E",0,"G",0,"2",0
                        DB 0,0,0,0
szMFVF_DV25_S 	        DB "D",0,"V",0,"2",0,"5",0
                        DB 0,0,0,0
szMFVF_DV50_S 	        DB "D",0,"V",0,"5",0,"0",0
                        DB 0,0,0,0
szMFVF_DVC_S 	        DB "D",0,"V",0,"C",0
                        DB 0,0,0,0
szMFVF_DVH1_S 	        DB "D",0,"V",0,"H",0,"1",0
                        DB 0,0,0,0
szMFVF_DVHD_S 	        DB "D",0,"V",0,"H",0,"D",0
                        DB 0,0,0,0
szMFVF_DVSD_S 	        DB "D",0,"V",0,"S",0,"D",0
                        DB 0,0,0,0
szMFVF_DVSL_S 	        DB "D",0,"V",0,"S",0,"L",0
                        DB 0,0,0,0
szMFVF_WVC1_S 	        DB 'W",0,"V",0,"C",0,"1',0
                        DB 0,0,0,0
szMFVF_420O_S 	        DB "4",0,"2",0,"0",0,"O",0
                        DB 0,0,0,0
szMFVF_MP43_S 	        DB "M",0,"P",0,"E",0,"G",0,"4",0
                        DB 0,0,0,0


ELSE
szStream                DB "Stream ",0

szMIIColon              DB ":",0
szMIILeftBracket        DB "(",0
szMIIRightBracket       DB ")",0
szMIILeftSqBracket      DB "[",0
szMIIRightSqBracket     DB "]",0
szMIIAsterisk           DB "*",0
szMIIQuestion           DB "?",0
szMIISpace              DB " ",0
szMIIDash               DB "-",0
szMIIkbps               DB "kbps",0
szMIIchannels           DB "Ch",0 ; annels
szMIIHz                 DB "Hz",0
szMIIbits               DB "bit",0
szLFE                   DB "/LFE",0 ; Low Frequency (Subwoofer)
sz1F                    DB "1F",0 ; Front Center
sz2F                    DB "2F",0 ; Front Left & Right
sz3F                    DB "3F",0 ; Front Left, Right & Center
sz5F                    DB "5F",0 ; Front Left, Right & Center + Front Left & Right of Center
sz1B                    DB "1B",0 ; Back Center
sz2B                    DB "2B",0 ; Back Left & Right
sz3B                    DB "3B",0 ; Back Left, Right & Center
sz2S                    DB "2M",0 ; Side Left & Right
sz1TF                   DB "1TF",0 ; Top Front Center
sz2TF                   DB "2TF",0 ; Top Front Left & Right
sz3TF                   DB "3TF",0 ; Top Front Left, Right & Center
sz1TC                   DB "1TC",0 ; Top Center
sz1TB                   DB "1TB",0 ; Top Back Center
sz2TB                   DB "2TB",0 ; Top Back Left & Right
sz3TB                   DB "3TB",0 ; Top Back Left, Right & Center

szMIIfps                DB "fps",0
szMIIx                  DB "x",0
szMIICRLF               DB 13,10,0

szMFMT_None             DB "None",0
szMFMT_Audio 	        DB "Audio",0
szMFMT_Video 	        DB "Video",0
szMFMT_Stream 	        DB "Stream",0
szMFMT_Metadata 	    DB "Metadata",0
szMFMT_Protected 	    DB "DRM",0
szMFMT_SAMI 	        DB "SAMI",0
szMFMT_Image 	        DB "Image",0
szMFMT_Binary 	        DB "Binary",0
szMFMT_HTML 	        DB "HTML",0
szMFMT_Perception 	    DB "Sensor/Raw",0
szMFMT_FileTransfer 	DB "Data files",0
szMFMT_Script 	        DB "Script",0

; Audio Format
;szMFAF_Unknown          DB "Unknown Audio",0
;szMFAF_MP3 	            DB "MPEG Audio Layer-3 (MP3)",0
;szMFAF_AAC 	            DB "Advanced Audio Coding (AAC)",0
;szMFAF_ALAC 	        DB "Apple Lossless Audio Codec (ALAC)",0
;szMFAF_Dolby_AC3 	    DB "Dolby Digital (AC-3)",0
;szMFAF_Dolby_AC3_SP     DB "Dolby AC-3 Audio Over S/PDIF",0
;szMFAF_Dolby_DDPlus 	DB "Dolby Digital Plus",0
;szMFAF_Dolby_AC4        DB "Dolby (AC-4)",0
;szMFAF_Dolby_AC4_V1     DB "Dolby (AC-4)",0
;szMFAF_Dolby_AC4_V2     DB "Dolby (AC-4)",0
;szMFAF_Dolby_AC4_V1_ES  DB "Dolby (AC-4)",0
;szMFAF_Dolby_AC4_V2_ES  DB "Dolby (AC-4)",0
;szMFAF_DTS 	            DB "Digital Theater Systems (DTS)",0
;szMFAF_DTS_RAW          DB "Digital Theater Systems (DTS)",0
;szMFAF_DTS_HD           DB "Digital Theater Systems Master Audio (DTS-HD)",0
;szMFAF_DTS_XLL          DB "Digital Theater Systems Master Audio Lossless (DTS-XLL)",0
;szMFAF_DTS_LBR          DB "Digital Theater Systems (DTS-LBR)",0
;szMFAF_DTS_UHD          DB "Digital Theater Systems Ultra Audio (DTS-UHD)",0
;szMFAF_DTS_UHDY         DB "Digital Theater Systems Ultra Audio (DTS-UHDY)",0
;szMFAF_PCM 	            DB "Uncompressed PCM Audio",0
;szMFAF_LPCM             DB "DVD audio data",0
;szMFAF_WMASPDIF 	    DB "Windows Media Audio 9 Professional Codec Over S/PDIF",0
;szMFAF_WMAudio_LL       DB "Windows Media Audio 9/9.1 Lossless Codec",0
;szMFAF_WMAudioV8 	    DB "Windows Media Audio 8/9/9.1 Codec",0
;szMFAF_WMAudioV9 	    DB "Windows Media Audio 9/9.1 Professional Codec",0
;szMFAF_FLAC 	        DB "Free Lossless Audio Codec",0
;szMFAF_MPEG 	        DB "MPEG-1 Audio (MP1)",0
;szMFAF_MPEGH            DB "MPEG-1 Audio (MP1)",0
;szMFAF_MPEGH_ES         DB "MPEG-1 Audio (MP1)",0
;szMFAF_MSP1 	        DB "Windows Media Audio 9 Voice Codec",0
;szMFAF_AMR_NB 	        DB "Adaptive Multi-Rate Narrowband (AMR_NB)",0
;szMFAF_AMR_WB 	        DB "Adaptive Multi-Rate Wideband (AMR_WB)",0
;szMFAF_AMR_WP 	        DB "Adaptive Multi-Rate Wideband Plus (AMR_WP)",0
;szMFAF_DRM 	            DB "Encrypted Audio Data",0
;szMFAF_Opus 	        DB "Opus",0
;szMFAF_Vorbis           DB "VORBIS",0
;szMFAF_Float 	        DB "Uncompressed IEEE Floating-point Audio",0
;szMFAF_Float_SO         DB "Uncompressed IEEE Floating-point Audio",0
;szMFAF_RAW_AAC1 	    DB "Advanced Audio Coding (AAC) In AVI",0
;szMFAF_QCELP 	        DB "QCELP Audio",0
;szMFAF_Dolby_AC3_HDCP   DB "Dolby Digital (AC-3) (HDCP)",0
;szMFAF_AAC_HDCP         DB "Advanced Audio Coding (AAC) (HDCP)"
;szMFAF_PCM_HDCP         DB "Uncompressed PCM Audio (HDCP)",0
;szMFAF_ADTS_HDCP        DB "Advanced Audio Coding (AAC) (ADTS) format (HDCP)",0
;szMFAF_ADTS 	        DB "Audio Data Transport Stream (ADTS)",0

; Audio Format Short name
szMFAF_Unknown_S         DB "Unknown",0
szMFAF_MP3_S 	         DB "MP3",0
szMFAF_AAC_S 	         DB "AAC",0
szMFAF_ALAC_S 	         DB "ALAC",0
szMFAF_Dolby_AC3_S 	     DB "AC-3",0
szMFAF_Dolby_AC3_SP_S    DB "AC-3",0
szMFAF_Dolby_DDPlus_S 	 DB "EAC-3",0
szMFAF_Dolby_AC4_S       DB "AC-4",0
szMFAF_Dolby_AC4_V1_S    DB "AC-4",0
szMFAF_Dolby_AC4_V2_S    DB "AC-4",0
szMFAF_Dolby_AC4_V1_ES_S DB "AC-4",0
szMFAF_Dolby_AC4_V2_ES_S DB "AC-4",0
szMFAF_DTS_S 	         DB "DTS",0
szMFAF_DTS_RAW_S         DB "DTS",0
szMFAF_DTS_HD_S          DB "DTS-HD",0
szMFAF_DTS_XLL_S         DB "DTS-XLL",0
szMFAF_DTS_LBR_S         DB "DTS-LBR",0
szMFAF_DTS_UHD_S         DB "DTS-UHD",0
szMFAF_DTS_UHDY_S        DB "DTS-UHDY",0
szMFAF_PCM_S 	         DB "PCM",0
szMFAF_LPCM_S            DB "DVD-A",0
szMFAF_WMASPDIF_S 	     DB "WMAPRO",0
szMFAF_WMAudio_LL_S      DB "WMALOSSLESS",0
szMFAF_WMAudioV8_S 	     DB "WMAV2",0
szMFAF_WMAudioV9_S 	     DB "WMAPRO",0
szMFAF_FLAC_S 	         DB "FLAC",0
szMFAF_MPEG_S 	         DB "MP1",0
szMFAF_MPEGH_S           DB "MP1",0
szMFAF_MPEGH_ES_S        DB "MP1",0
szMFAF_MSP1_S 	         DB "WMAVOICE",0
szMFAF_AMR_NB_S 	     DB "AMR_NB",0
szMFAF_AMR_WB_S 	     DB "AMR_WB",0
szMFAF_AMR_WP_S 	     DB "AMR_WP",0
szMFAF_DRM_S 	         DB "DRM",0
szMFAF_Opus_S 	         DB "Opus",0
szMFAF_Vorbis_S          DB "VORBIS",0
szMFAF_Float_S 	         DB "Float",0
szMFAF_Float_SO_S        DB "Float",0
szMFAF_RAW_AAC1_S 	     DB "AAC",0
szMFAF_QCELP_S 	         DB "QCELP",0
szMFAF_Dolby_AC3_HDCP_S  DB "AC-3",0
szMFAF_AAC_HDCP_S        DB "AAC"
szMFAF_PCM_HDCP_S        DB "PCM",0
szMFAF_ADTS_HDCP_S       DB "AAC-ADTS",0
szMFAF_ADTS_S	         DB "ADTS",0

; Video Format
;szMFVF_Unknown          DB "Unknown Video",0
;szMFVF_M4S2 	        DB "MPEG-4 Part 2 - MPEG-4 Advanced Simple Profile (MPEG4)",0
;szMFVF_MP4V 	        DB "MPEG-4 Part 2 (MPEG4)",0
;szMFVF_H264 	        DB "H.264/MPEG-4 Part 10, AVC (H264)",0
;szMFVF_H265 	        DB "H.265 Video (H265)",0
;szMFVF_H264_ES          DB "H.264 Elementary Stream (H264)",0
;szMFVF_WMV1 	        DB "Windows Media Video Codec Version 7 (WMV1)",0
;szMFVF_WMV2 	        DB "Windows Media Video 8 Codec (WMV2)",0
;szMFVF_WMV3 	        DB "Windows Media Video 9 Codec (WMV3)",0
;szMFVF_MP4S 	        DB "MPEG-4 Part 2 - MPEG-4 Simple Profile (MPEG4)",0
;szMFVF_AV1 	            DB "Audio Video Interleaved (AVI) Video",0
;szMFVF_VP80 	        DB "On2 TrueMotion VP8/Google WebM Video (VP8)",0
;szMFVF_VP90 	        DB "On2 TrueMotion VP9 Video (VP9)",0
;szMFVF_HEVC 	        DB "H.265/MPEG-H Part 2, HEVC - Main/Main Still Picture profile (HEVC)",0
;szMFVF_HEVC_ES          DB "H.265/MPEG-H Part 2, HEVC - Main 10 profile (HEVC)",0
;szMFVF_H263 	        DB "H.263 Video (H263)",0
;szMFVF_MSS1 	        DB "Windows Media Screen Codec Version 1 (MSS1)",0
;szMFVF_MSS2 	        DB "Windows Media Video 9 Screen Codec (MSS2)",0
;szMFVF_MJPG 	        DB "Motion JPEG (MJPG)",0
;szMFVF_MPG1 	        DB "MPEG-1 Part 2, Video (MPG1)",0
;szMFVF_MPEG2            DB "H.262/MPEG-2 Part 2, Video (MPEG2)",0
;szMFVF_DV25 	        DB "DVCPRO 25 (525-60 or 625-50)",0
;szMFVF_DV50 	        DB "DVCPRO 50 (525-60 or 625-50)",0
;szMFVF_DVC 	            DB "DVC/DV Video",0
;szMFVF_DVH1 	        DB "DVCPRO 100 (1080/60i, 1080/50i, or 720/60P)",0
;szMFVF_DVHD 	        DB "HD-DVCR (1125-60 or 1250-50)",0
;szMFVF_DVSD 	        DB "SDL-DVCR (525-60 or 625-50)",0
;szMFVF_DVSL 	        DB "SD-DVCR (525-60 or 625-50)",0
;szMFVF_WVC1 	        DB 'SMPTE 421M ("VC-1")',0
;szMFVF_420O 	        DB "8-bit per channel planar YUV 4:2:0 video",0
;szMFVF_MP43 	        DB "Microsoft MPEG-4 version 3",0

; Video Format Short name
szMFVF_Unknown_S        DB "Unknown",0
szMFVF_M4S2_S 	        DB "MPEG4",0
szMFVF_MP4V_S 	        DB "MPEG4",0
szMFVF_H264_S 	        DB "H264",0
szMFVF_H265_S 	        DB "H265",0
szMFVF_H264_ES_S        DB "H264",0
szMFVF_WMV1_S 	        DB "WMV1",0
szMFVF_WMV2_S 	        DB "WMV2",0
szMFVF_WMV3_S 	        DB "WMV3",0
szMFVF_MP4S_S 	        DB "MPEG4",0
szMFVF_AV1_S            DB "AV01",0
szMFVF_VP80_S 	        DB "VP8",0
szMFVF_VP90_S 	        DB "VP9",0
szMFVF_HEVC_S 	        DB "HEVC",0
szMFVF_HEVC_ES_S        DB "HEVC",0
szMFVF_H263_S 	        DB "H263",0
szMFVF_MSS1_S 	        DB "MSS1",0
szMFVF_MSS2_S 	        DB "MSS2",0
szMFVF_MJPG_S 	        DB "MJPG",0
szMFVF_MPG1_S 	        DB "MPEG1",0
szMFVF_MPEG2_S          DB "MPEG2",0
szMFVF_DV25_S 	        DB "DV25",0
szMFVF_DV50_S 	        DB "DV50",0
szMFVF_DVC_S 	        DB "DVC",0
szMFVF_DVH1_S 	        DB "DVH1",0
szMFVF_DVHD_S 	        DB "DVHD",0
szMFVF_DVSD_S 	        DB "DVSD",0
szMFVF_DVSL_S 	        DB "DVSL",0
szMFVF_WVC1_S 	        DB 'WVC1',0
szMFVF_420O_S 	        DB "420O",0
szMFVF_MP43_S 	        DB "MPEG4",0

ENDIF


.CODE

;------------------------------------------------------------------------------
; MFI_MediaItemInfoText
;------------------------------------------------------------------------------
MFI_MediaItemInfoText PROC USES EBX pMediaItem:DWORD
    LOCAL nStream:DWORD
    LOCAL pStreamRecord:DWORD
    LOCAL dwMajorType:DWORD
    
    Invoke MFPMediaItem_StreamTable, pMediaItem, Addr g_dwStreamCount, Addr g_pStreamTable
    IFDEF DEBUG32
    .IF g_dwStreamCount > 0
        mov eax, g_dwStreamCount
        mov ebx, SIZEOF MFP_STREAM_RECORD
        mul ebx
        DbgDump g_pStreamTable, eax
    .ENDIF
    ENDIF

    .IF pszMediaItemInfo != 0
        Invoke GlobalFree, pszMediaItemInfo
        mov pszMediaItemInfo, 0
    .ENDIF
    
    mov eax, g_dwStreamCount
    inc eax ; add 1 for filename
    ; Calc size required to hold text for all stream information
    ; 'Stream 0 Audio (en): MP3 132kbps 6Channels 48000kHz 16bit
    ; 'Stream 1 Video: MP4 286kbps 25fps 1280x720 
    ; STREAMNAME_LENGTH + STREAMLANG_LENGTH + " ():" = 32+32 +4 = 68
    ; Audio format: WMALOSSLESS = 12 (+1 space)
    ; kilobps: 8 + 5 = 13
    ; channels: 2 + Channels + space = 11
    ; Samples: 10
    ; Bitdepth: 6
    ; = 68+12+13+11+10+6 (123) 128 per stream (x2 for unicode) + CRLF for each stream
    IFDEF __UNICODE__
    mov ebx, 288
    ELSE
    mov ebx, 144
    ENDIF
    mul ebx
    add eax, 8 ; just in case for nulls etc
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
    mov pszMediaItemInfo, eax
    
    Invoke lstrcpy, pszMediaItemInfo, Addr szJustFilename
    Invoke lstrcat, pszMediaItemInfo, Addr szMIIColon
    Invoke lstrcat, pszMediaItemInfo, Addr szMIICRLF
    
    mov eax, g_pStreamTable
    mov pStreamRecord, eax
    
    mov eax, 0
    mov nStream, 0
    .WHILE eax < g_dwStreamCount
        
        .IF g_dwStreamCount > 2
            ; Stream Selection
            Invoke lstrcat, pszMediaItemInfo, Addr szMIILeftSqBracket
            mov ebx, pStreamRecord
            mov eax, [ebx].MFP_STREAM_RECORD.bSelected
            .IF eax == TRUE
                Invoke lstrcat, pszMediaItemInfo, Addr szMIIAsterisk
            .ELSE
                Invoke lstrcat, pszMediaItemInfo, Addr szMIIDash ;szMIISpace
            .ENDIF
            Invoke lstrcat, pszMediaItemInfo, Addr szMIIRightSqBracket
            Invoke lstrcat, pszMediaItemInfo, Addr szMIISpace
        .ENDIF
        
        mov ebx, pStreamRecord
        mov eax, [ebx].MFP_STREAM_RECORD.dwMajorType
        mov dwMajorType, eax
        
        .IF dwMajorType == MFMT_Audio
        
            Invoke MFI_AudioStreamText, pStreamRecord, Addr szStreamText, TRUE, nStream
            Invoke lstrcat, pszMediaItemInfo, Addr szStreamText
        
        .ELSEIF dwMajorType == MFMT_Video
        
            Invoke MFI_VideoStreamText, pStreamRecord, Addr szStreamText, TRUE, nStream
            Invoke lstrcat, pszMediaItemInfo, Addr szStreamText

        .ENDIF
        
        mov eax, nStream
        inc eax 
        .IF eax != g_dwStreamCount
            Invoke lstrcat, pszMediaItemInfo, Addr szMIICRLF
        .ENDIF
        
        add pStreamRecord, SIZEOF MFP_STREAM_RECORD
        inc nStream
        mov eax, nStream
    .ENDW
    
    IFDEF DEBUG32
    PrintStringByAddr pszMediaItemInfo
    ENDIF
    
    ret
MFI_MediaItemInfoText ENDP

;------------------------------------------------------------------------------
; MFI_AudioStreamText
;------------------------------------------------------------------------------
MFI_AudioStreamText PROC USES EBX pStreamRecord:DWORD, lpszStreamText:DWORD, bMajorType:DWORD, dwStreamNo:DWORD
    LOCAL dwStreamID:DWORD
    LOCAL lpszStreamLang:DWORD
    LOCAL pszwString:DWORD
    LOCAL dwMajorType:DWORD
    LOCAL dwSubType:DWORD
    LOCAL lpszMajorType:DWORD
    LOCAL lpszSubType:DWORD
    LOCAL dwBitRate:DWORD
    LOCAL dwChannels:DWORD
    LOCAL dwSpeakers:DWORD
    LOCAL dwSamplesPerSec:DWORD
    LOCAL dwBitsPerSample:DWORD
    LOCAL szStreamNumber[12]:BYTE
    LOCAL szBitRate[16]:BYTE
    LOCAL szChannels[8]:BYTE
    LOCAL szSpeakers[48]:BYTE
    LOCAL szSamplesPerSec[16]:BYTE
    LOCAL szBitsPerSample[8]:BYTE
    
    IFDEF DEBUG32
    ;PrintText 'MFI_AudioStreamText'
    ENDIF
    
    IFDEF DEBUG32
    ;PrintText 'Stream Number'
    ENDIF
    ; Stream Number
    ;mov ebx, pStreamRecord
    ;mov eax, [ebx].MFP_STREAM_RECORD.dwStreamID
    ;mov dwStreamID, eax
    .IF bMajorType == FALSE
        Invoke dwtoa, dwStreamNo, Addr szStreamNumber ;dwStreamID
        IFDEF __UNICODE__
        Invoke MFPConvertStringToWide, Addr szStreamNumber
        mov pszwString, eax
        Invoke lstrcpy, lpszStreamText, pszwString
        Invoke MFPConvertStringFree, pszwString
        ELSE
        Invoke lstrcpy, lpszStreamText, Addr szStreamNumber
        ENDIF
    .ENDIF
    
    IFDEF DEBUG32
    ;PrintText 'Stream Type'
    ENDIF
    ; Stream Type
    .IF bMajorType == TRUE
        ;Invoke lstrcat, lpszStreamText, Addr szMIISpace
        mov ebx, pStreamRecord
        mov eax, [ebx].MFP_STREAM_RECORD.dwMajorType
        mov dwMajorType, eax
        Invoke MFI_MajorTypeToString, dwMajorType, Addr lpszMajorType
        Invoke lstrcpy, lpszStreamText, lpszMajorType
    .ENDIF
    
    IFDEF DEBUG32
    ;PrintText 'Stream Language'
    ENDIF
    ; Stream Language
    mov ebx, pStreamRecord
    lea eax, [ebx].MFP_STREAM_RECORD.szStreamLang
    mov lpszStreamLang, eax
    Invoke lstrlen, lpszStreamLang
    .IF eax != 0
        Invoke lstrcat, lpszStreamText, Addr szMIISpace
        Invoke lstrcat, lpszStreamText, Addr szMIILeftBracket
        IFDEF __UNICODE__
        Invoke lstrcat, lpszStreamText, lpszStreamLang
        ELSE
        Invoke MFPConvertStringToAnsi, lpszStreamLang
        mov lpszStreamLang, eax
        Invoke lstrcat, lpszStreamText, lpszStreamLang
        Invoke MFPConvertStringFree, lpszStreamLang
        ENDIF
        Invoke lstrcat, lpszStreamText, Addr szMIIRightBracket
    .ENDIF
    Invoke lstrcat, lpszStreamText, Addr szMIIColon
    Invoke lstrcat, lpszStreamText, Addr szMIISpace
    
    IFDEF DEBUG32
    ;PrintText 'Audio Type'
    ENDIF
    ; Audio Type
    mov ebx, pStreamRecord
    mov eax, [ebx].MFP_STREAM_RECORD.dwSubType
    mov dwSubType, eax
    Invoke MFI_AudioTypeToString, dwSubType, Addr lpszSubType, TRUE
    Invoke lstrcat, lpszStreamText, lpszSubType
    Invoke lstrcat, lpszStreamText, Addr szMIISpace
    
    IFDEF DEBUG32
    ;PrintText 'Bitrate - kbps'
    ENDIF
    ; Bitrate - kbps
    mov ebx, pStreamRecord
    mov eax, [ebx].MFP_STREAM_RECORD.dwBitRate
    .IF eax != 0
        mov dwBitRate, eax
        Invoke dwtoa, dwBitRate, Addr szBitRate
        IFDEF __UNICODE__
        Invoke MFPConvertStringToWide, Addr szBitRate
        mov pszwString, eax
        Invoke lstrcat, lpszStreamText, pszwString
        Invoke MFPConvertStringFree, pszwString
        ELSE
        Invoke lstrcat, lpszStreamText, Addr szBitRate
        ENDIF
        Invoke lstrcat, lpszStreamText, Addr szMIIkbps
        Invoke lstrcat, lpszStreamText, Addr szMIISpace
    .ENDIF
    
    IFDEF DEBUG32
    ;PrintText 'Channels'
    ENDIF
    ; Channels
    mov ebx, pStreamRecord
    mov eax, [ebx].MFP_STREAM_RECORD.dwChannels
    .IF eax != 0
        mov dwChannels, eax
        Invoke dwtoa, dwChannels, Addr szChannels
        IFDEF __UNICODE__
        Invoke MFPConvertStringToWide, Addr szChannels
        mov pszwString, eax
        Invoke lstrcat, lpszStreamText, pszwString
        Invoke MFPConvertStringFree, pszwString
        ELSE
        Invoke lstrcat, lpszStreamText, Addr szChannels
        ENDIF
        Invoke lstrcat, lpszStreamText, Addr szMIIchannels
        Invoke lstrcat, lpszStreamText, Addr szMIISpace
    .ENDIF
    
    IFDEF DEBUG32
    ;PrintText 'Speaker'
    ENDIF
    ; Speaker
    mov ebx, pStreamRecord
    mov eax, [ebx].MFP_STREAM_RECORD.dwSpeakers
    .IF eax != 0
        mov dwSpeakers, eax ; 3F2M/LFE
        
        ; zero out szSpeakers
        mov eax, 0
        lea ebx, szSpeakers
        mov [ebx+0], eax
        mov [ebx+4], eax
        mov [ebx+8], eax
        mov [ebx+12], eax
        mov [ebx+16], eax
        mov [ebx+20], eax
        mov [ebx+24], eax
        mov [ebx+28], eax
        mov [ebx+32], eax
        mov [ebx+36], eax
        mov [ebx+40], eax
        mov [ebx+44], eax
        
    SpeakersFront:
        mov eax, dwSpeakers
        and eax, SPEAKER_FRONT_LEFT or SPEAKER_FRONT_RIGHT or SPEAKER_FRONT_CENTER or SPEAKER_FRONT_LEFT_OF_CENTER or SPEAKER_FRONT_RIGHT_OF_CENTER
        .IF eax == SPEAKER_FRONT_LEFT or SPEAKER_FRONT_RIGHT or SPEAKER_FRONT_CENTER or SPEAKER_FRONT_LEFT_OF_CENTER or SPEAKER_FRONT_RIGHT_OF_CENTER
            Invoke lstrcat, Addr szSpeakers, Addr sz5F
            jmp SpeakersSide
        .ENDIF
        mov eax, dwSpeakers
        and eax, SPEAKER_FRONT_LEFT or SPEAKER_FRONT_RIGHT or SPEAKER_FRONT_CENTER
        .IF eax == SPEAKER_FRONT_LEFT or SPEAKER_FRONT_RIGHT or SPEAKER_FRONT_CENTER
            Invoke lstrcat, Addr szSpeakers, Addr sz3F
            jmp SpeakersSide
        .ENDIF
        mov eax, dwSpeakers
        and eax, SPEAKER_FRONT_LEFT or SPEAKER_FRONT_RIGHT
        .IF eax == SPEAKER_FRONT_LEFT or SPEAKER_FRONT_RIGHT
            Invoke lstrcat, Addr szSpeakers, Addr sz2F
            jmp SpeakersSide
        .ENDIF
        mov eax, dwSpeakers
        and eax, SPEAKER_FRONT_CENTER
        .IF eax == SPEAKER_FRONT_CENTER
            Invoke lstrcat, Addr szSpeakers, Addr sz1F
            jmp SpeakersSide
        .ENDIF
    SpeakersSide:
        mov eax, dwSpeakers
        and eax, SPEAKER_SIDE_LEFT or SPEAKER_SIDE_RIGHT
        .IF eax == SPEAKER_SIDE_LEFT or SPEAKER_SIDE_RIGHT
            Invoke lstrcat, Addr szSpeakers, Addr sz2S
            jmp SpeakersBack
        .ENDIF
    SpeakersBack:
        mov eax, dwSpeakers
        and eax, SPEAKER_BACK_LEFT or SPEAKER_BACK_RIGHT or SPEAKER_BACK_CENTER
        .IF eax == SPEAKER_BACK_LEFT or SPEAKER_BACK_RIGHT or SPEAKER_BACK_CENTER
            Invoke lstrcat, Addr szSpeakers, Addr sz3B
            jmp SpeakersTopFront
        .ENDIF
        mov eax, dwSpeakers
        and eax, SPEAKER_BACK_LEFT or SPEAKER_BACK_RIGHT
        .IF eax == SPEAKER_BACK_LEFT or SPEAKER_BACK_RIGHT
            Invoke lstrcat, Addr szSpeakers, Addr sz2B
            jmp SpeakersTopFront
        .ENDIF
        mov eax, dwSpeakers
        and eax, SPEAKER_BACK_CENTER
        .IF eax == SPEAKER_BACK_CENTER
            Invoke lstrcat, Addr szSpeakers, Addr sz1B
            jmp SpeakersTopFront
        .ENDIF
    SpeakersTopFront:
        mov eax, dwSpeakers
        and eax, SPEAKER_TOP_FRONT_LEFT or SPEAKER_TOP_FRONT_RIGHT or SPEAKER_TOP_FRONT_CENTER
        .IF eax == SPEAKER_TOP_FRONT_LEFT or SPEAKER_TOP_FRONT_RIGHT or SPEAKER_TOP_FRONT_CENTER
            Invoke lstrcat, Addr szSpeakers, Addr sz3TF
            jmp SpeakersTopCenter
        .ENDIF
        mov eax, dwSpeakers
        and eax, SPEAKER_TOP_FRONT_LEFT or SPEAKER_TOP_FRONT_RIGHT
        .IF eax == SPEAKER_TOP_FRONT_LEFT or SPEAKER_TOP_FRONT_RIGHT
            Invoke lstrcat, Addr szSpeakers, Addr sz2TF
            jmp SpeakersTopCenter
        .ENDIF
        mov eax, dwSpeakers
        and eax, SPEAKER_TOP_FRONT_CENTER
        .IF eax == SPEAKER_TOP_FRONT_CENTER
            Invoke lstrcat, Addr szSpeakers, Addr sz1TF
            jmp SpeakersTopCenter
        .ENDIF
    SpeakersTopCenter:
        mov eax, dwSpeakers
        and eax, SPEAKER_TOP_CENTER
        .IF eax == SPEAKER_TOP_CENTER
            Invoke lstrcat, Addr szSpeakers, Addr sz1TC
            jmp SpeakersTopBack
        .ENDIF
    SpeakersTopBack:
        mov eax, dwSpeakers
        and eax, SPEAKER_TOP_BACK_LEFT or SPEAKER_TOP_BACK_RIGHT or SPEAKER_TOP_BACK_CENTER
        .IF eax == SPEAKER_TOP_BACK_LEFT or SPEAKER_TOP_BACK_RIGHT or SPEAKER_TOP_BACK_CENTER
            Invoke lstrcat, Addr szSpeakers, Addr sz3TB
            jmp SpeakersLFE
        .ENDIF
        mov eax, dwSpeakers
        and eax, SPEAKER_TOP_BACK_LEFT or SPEAKER_TOP_BACK_RIGHT
        .IF eax == SPEAKER_TOP_BACK_LEFT or SPEAKER_TOP_BACK_RIGHT
            Invoke lstrcat, Addr szSpeakers, Addr sz2TB
            jmp SpeakersLFE
        .ENDIF
        mov eax, dwSpeakers
        and eax, SPEAKER_TOP_BACK_CENTER
        .IF eax == SPEAKER_TOP_BACK_CENTER
            Invoke lstrcat, Addr szSpeakers, Addr sz1TB
            jmp SpeakersLFE
        .ENDIF
    SpeakersLFE:
        mov eax, dwSpeakers
        and eax, SPEAKER_LOW_FREQUENCY
        .IF eax == SPEAKER_LOW_FREQUENCY
            Invoke lstrcat, Addr szSpeakers, Addr szLFE
        .ENDIF
        
        Invoke lstrcat, lpszStreamText, Addr szSpeakers
        Invoke lstrcat, lpszStreamText, Addr szMIISpace
        
    .ENDIF
    
    IFDEF DEBUG32
    ;PrintText 'Samples per second'
    ENDIF
    ; Samples per second
    mov ebx, pStreamRecord
    mov eax, [ebx].MFP_STREAM_RECORD.dwSamplesPerSec
    .IF eax != 0
        mov dwSamplesPerSec, eax
        Invoke dwtoa, dwSamplesPerSec, Addr szSamplesPerSec
        IFDEF __UNICODE__
        Invoke MFPConvertStringToWide, Addr szSamplesPerSec
        mov pszwString, eax
        Invoke lstrcat, lpszStreamText, pszwString
        Invoke MFPConvertStringFree, pszwString
        ELSE
        Invoke lstrcat, lpszStreamText, Addr szSamplesPerSec
        ENDIF
        Invoke lstrcat, lpszStreamText, Addr szMIIHz
        Invoke lstrcat, lpszStreamText, Addr szMIISpace
    .ENDIF
    
    IFDEF DEBUG32
    ;PrintText 'Bits per sample'
    ENDIF
    ; Bits per sample
    mov ebx, pStreamRecord
    mov eax, [ebx].MFP_STREAM_RECORD.dwBitsPerSample
    .IF eax != 0
        mov dwBitsPerSample, eax
        Invoke dwtoa, dwBitsPerSample, Addr szBitsPerSample
        IFDEF __UNICODE__
        Invoke MFPConvertStringToWide, Addr szBitsPerSample
        mov pszwString, eax
        Invoke lstrcat, lpszStreamText, pszwString
        Invoke MFPConvertStringFree, pszwString
        ELSE
        Invoke lstrcat, lpszStreamText, Addr szBitsPerSample
        ENDIF
        Invoke lstrcat, lpszStreamText, Addr szMIIbits
    .ENDIF
    ret
MFI_AudioStreamText ENDP

;------------------------------------------------------------------------------
; MFI_VideoStreamText
;------------------------------------------------------------------------------
MFI_VideoStreamText PROC USES EBX pStreamRecord:DWORD, lpszStreamText:DWORD, bMajorType:DWORD, dwStreamNo:DWORD
    LOCAL dwStreamID:DWORD
    LOCAL lpszStreamLang:DWORD
    LOCAL pszwString:DWORD
    LOCAL dwMajorType:DWORD
    LOCAL dwSubType:DWORD
    LOCAL lpszMajorType:DWORD
    LOCAL lpszSubType:DWORD
    LOCAL dwBitRate:DWORD
    LOCAL dwFrameRate:DWORD
    LOCAL dwFrameWidth:DWORD
    LOCAL dwFrameHeight:DWORD
    LOCAL szStreamNumber[12]:BYTE
    LOCAL szBitRate[16]:BYTE
    LOCAL szFrameRate[16]:BYTE
    LOCAL szFrameWidth[16]:BYTE
    LOCAL szFrameHeight[16]:BYTE
    
    IFDEF DEBUG32
    ;PrintText 'MFI_VideoStreamText'
    ENDIF
    
    IFDEF DEBUG32
    ;PrintText 'Stream Number'
    ENDIF
    ; Stream Number
    ;mov ebx, pStreamRecord
    ;mov eax, [ebx].MFP_STREAM_RECORD.dwStreamID
    ;mov dwStreamID, eax
    .IF bMajorType == FALSE
        Invoke dwtoa, dwStreamNo, Addr szStreamNumber ; dwStreamID
        IFDEF __UNICODE__
        Invoke MFPConvertStringToWide, Addr szStreamNumber
        mov pszwString, eax
        Invoke lstrcpy, lpszStreamText, pszwString
        Invoke MFPConvertStringFree, pszwString
        ELSE
        Invoke lstrcpy, lpszStreamText, Addr szStreamNumber
        ENDIF
    .ENDIF
    
    IFDEF DEBUG32
    ;PrintText 'Stream Type'
    ENDIF
    ; Stream Type
    .IF bMajorType == TRUE
        ;Invoke lstrcat, lpszStreamText, Addr szMIISpace
        mov ebx, pStreamRecord
        mov eax, [ebx].MFP_STREAM_RECORD.dwMajorType
        mov dwMajorType, eax
        Invoke MFI_MajorTypeToString, dwMajorType, Addr lpszMajorType
        Invoke lstrcpy, lpszStreamText, lpszMajorType
    .ENDIF
    
    IFDEF DEBUG32
    ;PrintText 'Stream Language'
    ENDIF
    ; Stream Language
    mov ebx, pStreamRecord
    lea eax, [ebx].MFP_STREAM_RECORD.szStreamLang
    mov lpszStreamLang, eax
    Invoke lstrlen, lpszStreamLang
    .IF eax != 0
        Invoke lstrcat, lpszStreamText, Addr szMIISpace
        Invoke lstrcat, lpszStreamText, Addr szMIILeftBracket
        IFDEF __UNICODE__
        Invoke lstrcat, lpszStreamText, lpszStreamLang
        ELSE
        Invoke MFPConvertStringToAnsi, lpszStreamLang
        mov lpszStreamLang, eax
        Invoke lstrcat, lpszStreamText, lpszStreamLang
        Invoke MFPConvertStringFree, lpszStreamLang
        ENDIF
        Invoke lstrcat, lpszStreamText, Addr szMIIRightBracket
    .ENDIF
    Invoke lstrcat, lpszStreamText, Addr szMIIColon
    Invoke lstrcat, lpszStreamText, Addr szMIISpace
    
    IFDEF DEBUG32
    ;PrintText 'Video Type'
    ENDIF
    ; Audio Type
    mov ebx, pStreamRecord
    mov eax, [ebx].MFP_STREAM_RECORD.dwSubType
    mov dwSubType, eax
    Invoke MFI_VideoTypeToString, dwSubType, Addr lpszSubType, TRUE
    Invoke lstrcat, lpszStreamText, lpszSubType
    Invoke lstrcat, lpszStreamText, Addr szMIISpace
    
    IFDEF DEBUG32
    ;PrintText 'Bitrate - kbps'
    ENDIF
    mov ebx, pStreamRecord
    mov eax, [ebx].MFP_STREAM_RECORD.dwBitRate
    .IF eax != 0
        mov dwBitRate, eax
        Invoke dwtoa, dwBitRate, Addr szBitRate
        IFDEF __UNICODE__
        Invoke MFPConvertStringToWide, Addr szBitRate
        mov pszwString, eax
        Invoke lstrcat, lpszStreamText, pszwString
        Invoke MFPConvertStringFree, pszwString
        ELSE
        Invoke lstrcat, lpszStreamText, Addr szBitRate
        ENDIF
        Invoke lstrcat, lpszStreamText, Addr szMIIkbps
        Invoke lstrcat, lpszStreamText, Addr szMIISpace
    .ENDIF
    
    IFDEF DEBUG32
    ;PrintText 'Frame rate'
    ENDIF
    mov ebx, pStreamRecord
    mov eax, [ebx].MFP_STREAM_RECORD.dwFrameRate
    .IF eax != 0
    mov dwFrameRate, eax
        Invoke dwtoa, dwFrameRate, Addr szFrameRate
        IFDEF __UNICODE__
        Invoke MFPConvertStringToWide, Addr szFrameRate
        mov pszwString, eax
        Invoke lstrcat, lpszStreamText, pszwString
        Invoke MFPConvertStringFree, pszwString
        ELSE
        Invoke lstrcat, lpszStreamText, Addr szFrameRate
        ENDIF
        Invoke lstrcat, lpszStreamText, Addr szMIIfps
        Invoke lstrcat, lpszStreamText, Addr szMIISpace
    .ENDIF
    
    IFDEF DEBUG32
    ;PrintText 'Frame width and height'
    ENDIF
    mov ebx, pStreamRecord
    mov eax, [ebx].MFP_STREAM_RECORD.dwFrameWidth
    .IF eax != 0
    mov dwFrameWidth, eax
        Invoke dwtoa, dwFrameWidth, Addr szFrameWidth
        IFDEF __UNICODE__
        Invoke MFPConvertStringToWide, Addr szFrameWidth
        mov pszwString, eax
        Invoke lstrcat, lpszStreamText, pszwString
        Invoke MFPConvertStringFree, pszwString
        ELSE
        Invoke lstrcat, lpszStreamText, Addr szFrameWidth
        ENDIF
        Invoke lstrcat, lpszStreamText, Addr szMIIx
        
        mov ebx, pStreamRecord
        mov eax, [ebx].MFP_STREAM_RECORD.dwFrameHeight
        mov dwFrameHeight, eax
        Invoke dwtoa, dwFrameHeight, Addr szFrameHeight
        IFDEF __UNICODE__
        Invoke MFPConvertStringToWide, Addr szFrameHeight
        mov pszwString, eax
        Invoke lstrcat, lpszStreamText, pszwString
        Invoke MFPConvertStringFree, pszwString
        ELSE
        Invoke lstrcat, lpszStreamText, Addr szFrameHeight
        ENDIF
    .ENDIF
    
    ret

MFI_VideoStreamText ENDP

;------------------------------------------------------------------------------
; MFI_MajorTypeToString
; Returns a pointer to a string representing the major type
;------------------------------------------------------------------------------
MFI_MajorTypeToString PROC USES EBX dwMajorType:DWORD, lpdwMajorTypeString:DWORD
    
    .IF lpdwMajorTypeString == 0
        mov eax, FALSE
        ret
    .ENDIF
    
    mov ebx, lpdwMajorTypeString
    mov eax, dwMajorType
    .IF eax == MFMT_None
        lea eax, szMFMT_None
    .ELSEIF eax == MFMT_Audio
        lea eax, szMFMT_Audio
    .ELSEIF eax == MFMT_Video  
        lea eax, szMFMT_Video
    .ELSEIF eax == MFMT_Stream
        lea eax, szMFMT_Stream
    .ELSEIF eax == MFMT_Metadata
        lea eax, szMFMT_Metadata
    .ELSEIF eax == MFMT_Protected
        lea eax, szMFMT_Protected
    .ELSEIF eax == MFMT_SAMI 	
        lea eax, szMFMT_SAMI
    .ELSEIF eax == MFMT_Image 	
        lea eax, szMFMT_Image
    .ELSEIF eax == MFMT_Binary 	 
        lea eax, szMFMT_Binary
    .ELSEIF eax == MFMT_HTML 
        lea eax, szMFMT_HTML
    .ELSEIF eax == MFMT_Perception
        lea eax, szMFMT_Perception
    .ELSEIF eax == MFMT_FileTransfer
        lea eax, szMFMT_FileTransfer
    .ELSEIF eax == MFMT_Script 	  
        lea eax, szMFMT_Script
    .ELSE
        lea eax, szMFMT_None
    .ENDIF
    mov [ebx], eax
    
    mov eax, TRUE
    ret
MFI_MajorTypeToString ENDP

;------------------------------------------------------------------------------
; MFI_AudioTypeToString
; Returns a pointer to a string representing the audio subtype
;------------------------------------------------------------------------------
MFI_AudioTypeToString PROC USES EBX dwAudioType:DWORD, lpdwAudioTypeString:DWORD, bShortName:DWORD
    
    .IF lpdwAudioTypeString == 0
        mov eax, FALSE
        ret
    .ENDIF

    .IF bShortName == FALSE
;        mov ebx, lpdwAudioTypeString
;        mov eax, dwAudioType
;        .IF eax == MFAF_Unknown
;            lea eax, szMFAF_Unknown
;        .ELSEIF eax == MFAF_MP3
;            lea eax, szMFAF_MP3
;        .ELSEIF eax == MFAF_AAC
;            lea eax, szMFAF_AAC
;        .ELSEIF eax == MFAF_ALAC
;            lea eax, szMFAF_ALAC
;        .ELSEIF eax == MFAF_Dolby_AC3
;            lea eax, szMFAF_Dolby_AC3
;        .ELSEIF eax == MFAF_Dolby_AC3_SP
;            lea eax, szMFAF_Dolby_AC3_SP
;        .ELSEIF eax == MFAF_Dolby_DDPlus
;            lea eax, szMFAF_Dolby_DDPlus
;        .ELSEIF eax == MFAF_Dolby_AC4
;            lea eax, szMFAF_Dolby_AC4
;        .ELSEIF eax == MFAF_Dolby_AC4_V1
;            lea eax, szMFAF_Dolby_AC4_V1
;        .ELSEIF eax == MFAF_Dolby_AC4_V2
;            lea eax, szMFAF_Dolby_AC4_V2
;        .ELSEIF eax == MFAF_Dolby_AC4_V1_ES
;            lea eax, szMFAF_Dolby_AC4_V1_ES
;        .ELSEIF eax == MFAF_Dolby_AC4_V2_ES
;            lea eax, szMFAF_Dolby_AC4_V2_ES
;        .ELSEIF eax == MFAF_DTS
;            lea eax, szMFAF_DTS
;        .ELSEIF eax == MFAF_DTS_RAW
;            lea eax, szMFAF_DTS_RAW
;        .ELSEIF eax == MFAF_DTS_HD 
;            lea eax, szMFAF_DTS_HD
;        .ELSEIF eax == MFAF_DTS_XLL
;            lea eax, szMFAF_DTS_XLL
;        .ELSEIF eax == MFAF_DTS_LBR
;            lea eax, szMFAF_DTS_LBR
;        .ELSEIF eax == MFAF_DTS_UHD
;            lea eax, szMFAF_DTS_UHD
;        .ELSEIF eax == MFAF_DTS_UHDY
;            lea eax, szMFAF_DTS_UHDY
;        .ELSEIF eax == MFAF_WMASPDIF
;            lea eax, szMFAF_WMASPDIF
;        .ELSEIF eax == MFAF_WMAudio_LL
;            lea eax, szMFAF_WMAudio_LL
;        .ELSEIF eax == MFAF_WMAudioV8
;            lea eax, szMFAF_WMAudioV8
;        .ELSEIF eax == MFAF_WMAudioV9
;            lea eax, szMFAF_WMAudioV9
;        .ELSEIF eax == MFAF_FLAC
;            lea eax, szMFAF_FLAC
;        .ELSEIF eax == MFAF_PCM
;            lea eax, szMFAF_PCM
;        .ELSEIF eax == MFAF_LPCM
;            lea eax, szMFAF_LPCM
;        .ELSEIF eax == MFAF_MPEG
;            lea eax, szMFAF_MPEG
;        .ELSEIF eax == MFAF_MSP1
;            lea eax, szMFAF_MSP1
;        .ELSEIF eax == MFAF_AMR_NB
;            lea eax, szMFAF_AMR_NB
;        .ELSEIF eax == MFAF_AMR_WB
;            lea eax, szMFAF_AMR_WB
;        .ELSEIF eax == MFAF_AMR_WP
;            lea eax, szMFAF_AMR_WP
;        .ELSEIF eax == MFAF_DRM
;            lea eax, szMFAF_DRM
;        .ELSEIF eax == MFAF_Opus
;            lea eax, szMFAF_Opus
;        .ELSEIF eax == MFAF_Vorbis
;            lea eax, szMFAF_Vorbis
;        .ELSEIF eax == MFAF_Float
;            lea eax, szMFAF_Float
;        .ELSEIF eax == MFAF_Float_SO
;            lea eax, szMFAF_Float_SO
;        .ELSEIF eax == MFAF_RAW_AAC1
;            lea eax, szMFAF_RAW_AAC1
;        .ELSEIF eax == MFAF_QCELP
;            lea eax, szMFAF_QCELP
;        .ELSEIF eax == MFAF_Dolby_AC3_HDCP
;            lea eax, szMFAF_Dolby_AC3_HDCP
;        .ELSEIF eax == MFAF_AAC_HDCP
;            lea eax, szMFAF_AAC_HDCP
;        .ELSEIF eax == MFAF_PCM_HDCP
;            lea eax, szMFAF_PCM_HDCP
;        .ELSEIF eax == MFAF_ADTS_HDCP
;            lea eax, szMFAF_ADTS_HDCP
;        .ELSEIF eax == MFAF_ADTS
;            lea eax, szMFAF_ADTS
;        .ELSE
;            lea eax, szMFAF_Unknown
;        .ENDIF
    .ELSE ; Shortname
        mov ebx, lpdwAudioTypeString
        mov eax, dwAudioType
        .IF eax == MFAF_Unknown
            lea eax, szMFAF_Unknown_S
        .ELSEIF eax == MFAF_MP3
            lea eax, szMFAF_MP3_S
        .ELSEIF eax == MFAF_AAC
            lea eax, szMFAF_AAC_S
        .ELSEIF eax == MFAF_ALAC
            lea eax, szMFAF_ALAC_S
        .ELSEIF eax == MFAF_Dolby_AC3
            lea eax, szMFAF_Dolby_AC3_S
        .ELSEIF eax == MFAF_Dolby_AC3_SP
            lea eax, szMFAF_Dolby_AC3_SP_S
        .ELSEIF eax == MFAF_Dolby_DDPlus
            lea eax, szMFAF_Dolby_DDPlus_S
        .ELSEIF eax == MFAF_Dolby_AC4
            lea eax, szMFAF_Dolby_AC4_S
        .ELSEIF eax == MFAF_Dolby_AC4_V1
            lea eax, szMFAF_Dolby_AC4_V1_S
        .ELSEIF eax == MFAF_Dolby_AC4_V2
            lea eax, szMFAF_Dolby_AC4_V2_S
        .ELSEIF eax == MFAF_Dolby_AC4_V1_ES
            lea eax, szMFAF_Dolby_AC4_V1_ES_S
        .ELSEIF eax == MFAF_Dolby_AC4_V2_ES
            lea eax, szMFAF_Dolby_AC4_V2_ES_S
        .ELSEIF eax == MFAF_DTS
            lea eax, szMFAF_DTS_S
        .ELSEIF eax == MFAF_DTS_RAW
            lea eax, szMFAF_DTS_RAW_S
        .ELSEIF eax == MFAF_DTS_HD 
            lea eax, szMFAF_DTS_HD_S
        .ELSEIF eax == MFAF_DTS_XLL
            lea eax, szMFAF_DTS_XLL_S
        .ELSEIF eax == MFAF_DTS_LBR
            lea eax, szMFAF_DTS_LBR_S
        .ELSEIF eax == MFAF_DTS_UHD
            lea eax, szMFAF_DTS_UHD_S
        .ELSEIF eax == MFAF_DTS_UHDY
            lea eax, szMFAF_DTS_UHDY_S
        .ELSEIF eax == MFAF_WMASPDIF
            lea eax, szMFAF_WMASPDIF_S
        .ELSEIF eax == MFAF_WMAudio_LL
            lea eax, szMFAF_WMAudio_LL_S
        .ELSEIF eax == MFAF_WMAudioV8
            lea eax, szMFAF_WMAudioV8_S
        .ELSEIF eax == MFAF_WMAudioV9
            lea eax, szMFAF_WMAudioV9_S
        .ELSEIF eax == MFAF_FLAC
            lea eax, szMFAF_FLAC_S
        .ELSEIF eax == MFAF_PCM
            lea eax, szMFAF_PCM_S
        .ELSEIF eax == MFAF_LPCM
            lea eax, szMFAF_LPCM_S
        .ELSEIF eax == MFAF_MPEG
            lea eax, szMFAF_MPEG_S
        .ELSEIF eax == MFAF_MSP1
            lea eax, szMFAF_MSP1_S
        .ELSEIF eax == MFAF_AMR_NB
            lea eax, szMFAF_AMR_NB_S
        .ELSEIF eax == MFAF_AMR_WB
            lea eax, szMFAF_AMR_WB_S
        .ELSEIF eax == MFAF_AMR_WP
            lea eax, szMFAF_AMR_WP_S
        .ELSEIF eax == MFAF_DRM
            lea eax, szMFAF_DRM_S
        .ELSEIF eax == MFAF_Opus
            lea eax, szMFAF_Opus_S
        .ELSEIF eax == MFAF_Vorbis
            lea eax, szMFAF_Vorbis_S
        .ELSEIF eax == MFAF_Float
            lea eax, szMFAF_Float_S
        .ELSEIF eax == MFAF_Float_SO
            lea eax, szMFAF_Float_SO_S
        .ELSEIF eax == MFAF_QCELP
            lea eax, szMFAF_QCELP_S
        .ELSEIF eax == MFAF_Dolby_AC3_HDCP
            lea eax, szMFAF_Dolby_AC3_HDCP_S
        .ELSEIF eax == MFAF_AAC_HDCP
            lea eax, szMFAF_AAC_HDCP_S
        .ELSEIF eax == MFAF_PCM_HDCP
            lea eax, szMFAF_PCM_HDCP_S
        .ELSEIF eax == MFAF_ADTS_HDCP
            lea eax, szMFAF_ADTS_HDCP_S
        .ELSEIF eax == MFAF_ADTS
            lea eax, szMFAF_ADTS_S
        .ELSE
            lea eax, szMFAF_Unknown_S
        .ENDIF
    .ENDIF
    mov [ebx], eax
    
    mov eax, TRUE
    ret
MFI_AudioTypeToString ENDP

;------------------------------------------------------------------------------
; MFI_VideoTypeToString
; Returns a pointer to a string representing the video subtype
;------------------------------------------------------------------------------
MFI_VideoTypeToString PROC USES EBX dwVideoType:DWORD, lpdwVideoTypeString:DWORD, bShortName:DWORD
    
    .IF lpdwVideoTypeString == 0
        mov eax, FALSE
        ret
    .ENDIF

    .IF bShortName == FALSE
;        mov ebx, lpdwVideoTypeString
;        mov eax, dwVideoType
;        .IF eax == MFVF_Unknown
;            lea eax, szMFVF_Unknown
;        .ELSEIF eax == MFVF_M4S2
;            lea eax, szMFVF_M4S2
;        .ELSEIF eax == MFVF_MP4V
;            lea eax, szMFVF_MP4V
;        .ELSEIF eax == MFVF_H264
;            lea eax, szMFVF_H264
;        .ELSEIF eax == MFVF_H265
;            lea eax, szMFVF_H265
;        .ELSEIF eax == MFVF_H264_ES
;            lea eax, szMFVF_H264_ES
;        .ELSEIF eax == MFVF_WMV1
;            lea eax, szMFVF_WMV1
;        .ELSEIF eax == MFVF_WMV2
;            lea eax, szMFVF_WMV2
;        .ELSEIF eax == MFVF_WMV3
;            lea eax, szMFVF_WMV3
;        .ELSEIF eax == MFVF_MP4S
;            lea eax, szMFVF_MP4S
;        .ELSEIF eax == MFVF_AV1 
;            lea eax, szMFVF_AV1
;        .ELSEIF eax == MFVF_VP80
;            lea eax, szMFVF_VP80
;        .ELSEIF eax == MFVF_VP90
;            lea eax, szMFVF_VP90
;        .ELSEIF eax == MFVF_HEVC
;            lea eax, szMFVF_HEVC
;        .ELSEIF eax == MFVF_HEVC_ES
;            lea eax, szMFVF_HEVC_ES
;        .ELSEIF eax == MFVF_H263
;            lea eax, szMFVF_H263
;        .ELSEIF eax == MFVF_MSS1
;            lea eax, szMFVF_MSS1
;        .ELSEIF eax == MFVF_MSS2
;            lea eax, szMFVF_MSS2
;        .ELSEIF eax == MFVF_MJPG
;            lea eax, szMFVF_MJPG
;        .ELSEIF eax == MFVF_MPG1
;            lea eax, szMFVF_MPG1
;        .ELSEIF eax == MFVF_MPEG2
;            lea eax, szMFVF_MPEG2
;        .ELSEIF eax == MFVF_DV25
;            lea eax, szMFVF_DV25
;        .ELSEIF eax == MFVF_DV50
;            lea eax, szMFVF_DV50
;        .ELSEIF eax == MFVF_DVC 
;            lea eax, szMFVF_DVC
;        .ELSEIF eax == MFVF_DVH1
;            lea eax, szMFVF_DVH1
;        .ELSEIF eax == MFVF_DVHD
;            lea eax, szMFVF_DVHD
;        .ELSEIF eax == MFVF_DVSD
;            lea eax, szMFVF_DVSD
;        .ELSEIF eax == MFVF_DVSL
;            lea eax, szMFVF_DVSL
;        .ELSEIF eax == MFVF_WVC1
;            lea eax, szMFVF_WVC1
;        .ELSEIF eax == MFVF_420O
;            lea eax, szMFVF_420O
;        .ELSEIF eax == MFVF_MP43
;            lea eax, szMFVF_MP43
;        .ELSE
;            lea eax, szMFVF_Unknown
;        .ENDIF
    .ELSE
        mov ebx, lpdwVideoTypeString
        mov eax, dwVideoType
        .IF eax == MFVF_Unknown
            lea eax, szMFVF_Unknown_S
        .ELSEIF eax == MFVF_M4S2
            lea eax, szMFVF_M4S2_S
        .ELSEIF eax == MFVF_MP4V
            lea eax, szMFVF_MP4V_S
        .ELSEIF eax == MFVF_H264
            lea eax, szMFVF_H264_S
        .ELSEIF eax == MFVF_H265
            lea eax, szMFVF_H265_S
        .ELSEIF eax == MFVF_H264_ES
            lea eax, szMFVF_H264_ES_S
        .ELSEIF eax == MFVF_WMV1
            lea eax, szMFVF_WMV1_S
        .ELSEIF eax == MFVF_WMV2
            lea eax, szMFVF_WMV2_S
        .ELSEIF eax == MFVF_WMV3
            lea eax, szMFVF_WMV3_S
        .ELSEIF eax == MFVF_MP4S
            lea eax, szMFVF_MP4S_S
        .ELSEIF eax == MFVF_AV1 
            lea eax, szMFVF_AV1_S
        .ELSEIF eax == MFVF_VP80
            lea eax, szMFVF_VP80_S
        .ELSEIF eax == MFVF_VP90
            lea eax, szMFVF_VP90_S
        .ELSEIF eax == MFVF_HEVC
            lea eax, szMFVF_HEVC_S
        .ELSEIF eax == MFVF_HEVC_ES
            lea eax, szMFVF_HEVC_ES_S
        .ELSEIF eax == MFVF_H263
            lea eax, szMFVF_H263_S
        .ELSEIF eax == MFVF_MSS1
            lea eax, szMFVF_MSS1_S
        .ELSEIF eax == MFVF_MSS2
            lea eax, szMFVF_MSS2_S
        .ELSEIF eax == MFVF_MJPG
            lea eax, szMFVF_MJPG_S
        .ELSEIF eax == MFVF_MPG1
            lea eax, szMFVF_MPG1_S
        .ELSEIF eax == MFVF_MPEG2
            lea eax, szMFVF_MPEG2_S
        .ELSEIF eax == MFVF_DV25
            lea eax, szMFVF_DV25_S
        .ELSEIF eax == MFVF_DV50
            lea eax, szMFVF_DV50_S
        .ELSEIF eax == MFVF_DVC 
            lea eax, szMFVF_DVC_S
        .ELSEIF eax == MFVF_DVH1
            lea eax, szMFVF_DVH1_S
        .ELSEIF eax == MFVF_DVHD
            lea eax, szMFVF_DVHD_S
        .ELSEIF eax == MFVF_DVSD
            lea eax, szMFVF_DVSD_S
        .ELSEIF eax == MFVF_DVSL
            lea eax, szMFVF_DVSL_S
        .ELSEIF eax == MFVF_WVC1
            lea eax, szMFVF_WVC1_S
        .ELSEIF eax == MFVF_420O
            lea eax, szMFVF_420O_S
        .ELSEIF eax == MFVF_MP43
            lea eax, szMFVF_MP43_S
        .ELSE
            lea eax, szMFVF_Unknown_S
        .ENDIF
    .ENDIF
    mov [ebx], eax
    
    mov eax, TRUE
    ret
MFI_VideoTypeToString ENDP



