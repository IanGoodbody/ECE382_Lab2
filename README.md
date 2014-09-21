# Lab 2
# Encryption
#### C2C Ian Goodbody
#### ECE 382

## Objectives

The objective of this lab was to create an xor encryption and decryption method using subroutines in assembly code. The functionality required the code  to decrypt a message with a single byte key, a multiple byte key, and to decrypt a message given no knowledge of the key. The design specifications required that the program be accomplished using two subroutines. A pass-by-reference subroutine that decrypts a message stored in memory, and a pass-by-value subroutine that decrypts a message byte and key byte that was passed to it. 

## Preliminary Design

Because the functionality required a decryption using multiple length keys, it was decided implementing the multiple byte key could implement the basic functionality by setting the key length to one. Achieving modularity in the design given the subroutine requirements involved a simple xor-ing subroutine that conducting a simple xor on a pair of registers. The higher level subroutine which would cycle through a message given the addresses of a number of data values concerning the message start, the key value, and an output address. This subroutine would have to cycle through both the message and the key in order to decrypt properly. It was indicated that decrypting the B functionality message would give a clue to decrypting the second message

Finding the end of the message involved either a) counting the number of characters in the string, or b) finding an end of message character. Analysis of the first two message strings and their keys revealed the '#' character with ASCII value of 0x23 as the string terminator.

## Building and Debugging

### Deviations from the preliminary design

During the build of the basic and B functionalities the only practical problems that emerged were changing the number of inputs required by the string decrypting subroutine. In total the subroutine needed the following inputs from memory:

* The start address of the message string
* A pointer to the terminator character
* The address of the output
* A pointer to the length of the key
* A pointer to the start of the key

Additionally an effort was made to encapsulate the subroutine and make it useful later in the program registers R9 through R11 had to be stored onto the stack. It is worth noting that the registers that were destroyed, namely the input registers, could have been protected from destruction as well but because they were general purpose inputs registers that were reset almost constantly, there was no real point in doing so.

### Testing

The two test cases provided for the basic and B functionality alongside their outputs were:

Basic functionality input
```Assembly
; Basic Functionality Test
SK:			.byte	0x23
Key:		.byte	0xac
KeyLn:		.byte	0x01
Message:	.byte	0xef,0xc3,0xc2,0xcb,0xde,0xcd,0xd8,0xd9,0xc0,0xcd,0xd8,0xc5,0xc3,0xc2,0xdf,0x8d,0x8c,0x8c,0xf5,0xc3,0xd9,0x8c,0xc8,0xc9,0xcf,0xde,0xd5,0xdc,0xd8,0xc9,0xc8,0x8c,0xd8,0xc4,0xc9,0x8c,0xe9,0xef,0xe9,0x9f,0x94,0x9e,0x8c,0xc4,0xc5,0xc8,0xc8,0xc9,0xc2,0x8c,0xc1,0xc9,0xdf,0xdf,0xcd,0xcb,0xc9,0x8c,0xcd,0xc2,0xc8,0x8c,0xcd,0xcf,0xc4,0xc5,0xc9,0xda,0xc9,0xc8,0x8c,0xde,0xc9,0xdd,0xd9,0xc5,0xde,0xc9,0xc8,0x8c,0xca,0xd9,0xc2,0xcf,0xd8,0xc5,0xc3,0xc2,0xcd,0xc0,0xc5,0xd8,0xd5,0x8f
````

This produced the output
````
Congratulations!  You decrypted the ECE382 hidden message and achieved required functionality#
````

B functionality input
````Assembly
; B Functionality Test
MsgLn:		.byte	0x52
Key:		.byte	0xac,0xdf,0x23
KeyLn:		.byte	0x03
Message:	.byte	0xf8,0xb7,0x46,0x8c,0xb2,0x46,0xdf,0xac,0x42,0xcb,0xba,0x03,0xc7,0xba,0x5a,0x8c,0xb3,0x46,0xc2,0xb8,0x57,0xc4,0xff,0x4a,0xdf,0xff,0x12,0x9a,0xff,0x41,0xc5,0xab,0x50,0x82,0xff,0x03,0xe5,0xab,0x03,0xc3,0xb1,0x4f,0xd5,0xff,0x40,0xc3,0xb1,0x57,0xcd,0xb6,0x4d,0xdf,0xff,0x4f,0xc9,0xab,0x57,0xc9,0xad,0x50,0x80,0xff,0x53,0xc9,0xad,0x4a,0xc3,0xbb,0x50,0x80,0xff,0x42,0xc2,0xbb,0x03,0xdf,0xaf,0x42,0xcf,0xba,0x50,0x8f
````
and output
````
The message key length is 16 bits.  It only contains letters, periods, and spaces#
````

### A functionality

The A functionality required that a message be decrypted with no knowledge of the key besides what was given in the B functionality, the key contains 2 bytes of data and the message only contained a narrow set of values when decrypted. 

The implementation of the A functionality required a separate subroutine to check a decrypted message contained the necessary characters. In attempting to keep the program consistent, the final value of the A functionality message was xor-ed with 0x23 to check if it contained the terminator character. This produced the final byte of the key as 0xB3. The key 0x00B3 was used to decrypt the message to see if it consistently produced valid values ever other byte. This test failed and so it was concluded that the message decryption could not be ceased by looking for the termination character 0x23. The method then had to be redesigned to run the encryption for the length of the encrypted message string.

This method was designed to decrypt the string without any input besides the length of the message and the length of the key. Therefore a switch was added to the input to indicate if the key was known or not as well as the length of the message which replaced the terminator character. The subroutines were modified appropriately. The core of the hard decryption algorithm was to cycle through every possible key and test if the decryption provided characters within the acceptable ASCII ranges. This method was beyond slow but for the input provided below it successfully decrypted the message.

````Assembly
; A Functionality Test
KnowKey:	.byte	0x00
MsgLn:		.byte	0x2A
Key:		.byte	0x00, 0x00				; not used
KeyLn:		.byte	0x02
Message:	.byte	0x35,0xdf,0x00,0xca,0x5d,0x9e,0x3d,0xdb,0x12,0xca,0x5d,0x9e,0x32,0xc8,0x16,0xcc,0x12,0xd9,0x16,0x90,0x53,0xf8,0x01,0xd7,0x16,0xd0,0x17,0xd2,0x0a,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90
````

The key produced was 0xBE73 with the message
````
Fast. Neat. Average. Friendly. Good. Good.
````
Yep, zoomies were here.

## Documentation
None
