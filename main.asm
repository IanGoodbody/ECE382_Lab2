;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section

;Key:		.byte	0xac
;KeyLn:		.byte	0x01
;SK:			.byte	0x23					; # signal is the end of the transmition, name comes from mores code end of transmition signal
;Message:	.byte	0xef,0xc3,0xc2,0xcb,0xde,0xcd,0xd8,0xd9,0xc0,0xcd,0xd8,0xc5,0xc3,0xc2,0xdf,0x8d,0x8c,0x8c,0xf5,0xc3,0xd9,0x8c,0xc8,0xc9,0xcf,0xde,0xd5,0xdc,0xd8,0xc9,0xc8,0x8c,0xd8,0xc4,0xc9,0x8c,0xe9,0xef,0xe9,0x9f,0x94,0x9e,0x8c,0xc4,0xc5,0xc8,0xc8,0xc9,0xc2,0x8c,0xc1,0xc9,0xdf,0xdf,0xcd,0xcb,0xc9,0x8c,0xcd,0xc2,0xc8,0x8c,0xcd,0xcf,0xc4,0xc5,0xc9,0xda,0xc9,0xc8,0x8c,0xde,0xc9,0xdd,0xd9,0xc5,0xde,0xc9,0xc8,0x8c,0xca,0xd9,0xc2,0xcf,0xd8,0xc5,0xc3,0xc2,0xcd,0xc0,0xc5,0xd8,0xd5,0x8f

Key:		.byte	0xac,0xdf,0x23
KeyLn:		.byte	0x03
SK:			.byte	0x23					; # signal is the end of the transmition, name comes from mores code end of transmition signal
Message:	.byte	0xf8,0xb7,0x46,0x8c,0xb2,0x46,0xdf,0xac,0x42,0xcb,0xba,0x03,0xc7,0xba,0x5a,0x8c,0xb3,0x46,0xc2,0xb8,0x57,0xc4,0xff,0x4a,0xdf,0xff,0x12,0x9a,0xff,0x41,0xc5,0xab,0x50,0x82,0xff,0x03,0xe5,0xab,0x03,0xc3,0xb1,0x4f,0xd5,0xff,0x40,0xc3,0xb1,0x57,0xcd,0xb6,0x4d,0xdf,0xff,0x4f,0xc9,0xab,0x57,0xc9,0xad,0x50,0x80,0xff,0x53,0xc9,0xad,0x4a,0xc3,0xbb,0x50,0x80,0xff,0x42,0xc2,0xbb,0x03,0xdf,0xaf,0x42,0xcf,0xba,0x50,0x8f

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------
Start:
			mov.w	#Message, R5
			mov.w	#Key, R6
			mov.w	#0x0200, R7
			mov.w	#KeyLn, R8
			call	#decrypt_Message
End:
			jmp		End
;-------------------------------------------------------------------------------
;			Subroutines
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;Subroutine Name: decryp_tMessage
;Author: Ian R Goodbody
;Function: Decrypts a string of bytes and stores the result in memory.  Accepts
;           the address of the encrypted message, address of the key, and address
;           of the decrypted message (pass-by-reference).  Accepts the length of
;           the message by value.  Uses the decryptCharacter subroutine to decrypt
;           each byte of the message.  Stores theresults to the decrypted message
;           location.
;Inputs: R5: Message Start Pointer, R6: Key Start Pointer, R7: Output Start Pointer, R8: Key Length Pointer
;Outputs: None
;Registers destroyed: R5, R6, R7
;-------------------------------------------------------------------------------

decrypt_Message:

			push.w 	R10
			push.w	R9
			mov.b	@R8, R10			; Store the length of the key in R10

startDecrypt:
			push.w	R5					; Store message start
			mov.b	@R5, R5				; Set R5 to first message byte
			push.w	R6					; Store key start
			mov.b	@R6, R6				; Set R6 to first key byte
			push.w	R7					; Store output start

			call	#decrypt_Char
			mov.b	R7, R9
			pop.w	R7					; Retrieve start memory location
			mov.b	R9,	0(R7)			; Write message to location in memory

			pop.w	R6
			inc.w 	R6
			dec 	R10
			jnz		incMsg
rstKey:
			mov.b	@R8, R9
			sxt		R9
			sub.w	R9, R6
			mov.b	@R8, R10
incMsg:
			pop.w	R5
			cmp		@R7, &SK			; Check for end of transmition character
			jz		endSub
			inc.w	R5
			inc.w 	R7
			jmp		startDecrypt
endSub:
			pop.w	R9
			pop.w	R10

            ret

;-------------------------------------------------------------------------------
;Subroutine Name: decrypt_Char
;Author: Ian R. Goodbody
;Function: Decrypts a byte of data by XORing it with a key byte.  Returns the
;           decrypted byte in the same register the encrypted byte was passed in.
;   	    Expects both the encrypted data and key to be passed by value.
;Inputs: R5: Message Byte, R6: Key Byte
;Outputs: R7: Dectypted Byte
;Registers destroyed: R7
;-------------------------------------------------------------------------------

decrypt_Char:

			mov.b 	R5, R7
			xor.b	R6, R7

            ret


;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
