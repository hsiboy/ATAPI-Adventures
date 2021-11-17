# An Introduction To Programming With ATA And ATAPI

If you're familiar with computer maintenance procedures, you're probably familiar with IDE (Integrated Drive Electronics), the typical standard for connecting hard drives and CD-ROM drives to a PC. ATA (AT Attachment) is essentially the same thing as IDE; just a different name.

Most motherboards today have two IDE controllers built-in, designated as the primary and the secondary IDE controller. These two IDE controllers use the following standard I/O addresses:

Primary IDE controller: 1F0h to 1F7h and 3F6h to 3F7h
Secondary IDE controller: 170h to 177h and 376h to 377h

Each I/O address corresponds to a register on the IDE controller. The following is a list of each I/O address used by ATA controllers and the corresponding regiuster. (I/O addys given are for the primary IDE controller, obviously, but they correspond to the same secondary IDE controller addresses. Thus, for example, the secondary IDE controller's data register is at 170h, the secondary controller's error and features register is at 171h, and so on):

1F0 (Read and Write): Data Register
1F1 (Read): Error Register
1F1 (Write): Features Register
1F2 (Read and Write): Sector Count Register
1F3 (Read and Write): LBA Low Register
1F4 (Read and Write): LBA Mid Register
1F5 (Read and Write): LBA High Register
1F6 (Read and Write): Drive/Head Register
1F7 (Read): Status Register
1F7 (Write): Command Register
3F6 (Read): Alternate Status Register
3F6 (Write): Device Control Register
The status register is an 8-bit register which contains the following bits, listed in order from left to right:

BSY (busy)
DRDY (device ready)
DF (Device Fault)
DSC (seek complete)
DRQ (Data Transfer Requested)
CORR (data corrected)
IDX (index mark)
ERR (error)
The error register is also an 8-bit register, and contains the following bits, again listed in order from left to right:

BBK (Bad Block)
UNC (Uncorrectable data error)
MC (Media Changed)
IDNF (ID mark Not Found)
MCR (Media Change Requested)
ABRT (command aborted)
TK0NF (Track 0 Not Found)
AMNF (Address Mark Not Found)
ATA commands are issued by writing the commands to the command register. More specifically, ATA commands are issued using the following steps:

1. Poll the status register until it indicates the device is not busy (BUSY will be set to 0)

2. Disable interrupts (assembler "cli" command)

3. Poll the status register until it indicates the device is ready (DRDY will be set to 1)

4. Issue the command by outputting the command opcode to the command register

5. Re-enable interrupts (assembler "sti" command)

The following program is a relatively simple assembler program to run the ATA "IDENTIFY DRIVE" command, and print out the results of this command to the screen.
`
MOV DX, 1F7h ;status register
LOOP1:
IN AL, DX ;sets AL to status register (which is 8 bits)

;If the first bit of the status register (BUSY) isn't 0, the device is busy,
;so keep looping until it isn't.

AND AL, 10000000xB
JNE LOOP1

;----------------------------------------------------------------------------

;Clear interrupts so something doesn't interrupt the drive or controller
;while this program is working.
CLI

;----------------------------------------------------------------------------

MOV DX, 1F7h ;status register again
LOOP2:
IN AL, DX ;sets AL to status register again

;If the second bit of the status register (DRDY) isn't 1, the device isn't
;ready, so keep looping until it is.

AND AL, 01000000xB
JE LOOP2

;----------------------------------------------------------------------------

MOV DX, 1F6h ;device/head register
MOV AL, 0 ;0 selects device 0 (master). 10h would select device 1 (slave).
OUT DX, AL ;selects master device

MOV DX, 1F7h ;command register
MOV AL, 0ECh ;"IDENTIFY DRIVE" command
OUT DX, AL ;sends the command!

;----------------------------------------------------------------------------

MOV DX, 1F7h ;status register
LOOP3:
IN AL, DX

AND AL, 00001000xB ;if DRQ is not high, the device doesn't have data for us
JE LOOP3 ;yet, so keep looking until it does!

;----------------------------------------------------------------------------

MOV DX, 1F0h ;data register
MOV DI, OFFSET buff ;points DI to the buffer we're using
MOV CX, 256 ;256 decimal. This controls the REP command.
CLD ;clear the direction flag so INSW increments DI (not decrements it)
REP INSW

;----------------------------------------------------------------------------

;We now have the string data in buff, so let's re-enable interrupts.

STI

;----------------------------------------------------------------------------

;...And now we can display the contents of buff!

MOV ES, SEG buff
MOV BX, OFFSET buff
MOV CX, 256 ;256 decimal
MOV AH, 2 ;"display output" option for INT 21
LOOP4:
MOV DL, [BX] ;moves the contents of the byte from "buff" into DL
INT 21h
INC BX
LOOPNZ LOOP4 ;does this 256 times, because CX was set to 256

mov ah,004C  ;terminate program
int 21h

buff db 256 DUP(?) ;buffer to hold the drive identification info
`

ATAPI (ATA Packet Interface) is an extension to ATA which essentially allows SCSI commands (commands used to control SCSI devices) to be sent to ATA devices. ATAPI is used specifically for CD-ROM drives, which, when they first started appearing for computers, were almost universally SCSI. Because SCSI controllers were expensive and clunky, the SCSI command set was eventually adopted for IDE, and typical CD-ROM drives today use ATAPI. ATAPI basically uses "packets" (similar to the packet concept of computer networking as it applies to TCP/IP, for example) to send and receive data and commands. Properly speaking, ATAPI is part of the EIDE (Enhanced IDE) standard.

A packet sent to an ATAPI device which contains a command is called a command packet. These command packets are written to the data register via the ATA interface, and that's how ATAPI devices receive their commands. The command packet has a 12-byte standard format, and the first byte of the command packet contains the actual operation code. (The remaining 11 bytes supply parameter info for the command.) Note that although the command packet is 12 bytes long, the packet is sent to the ATAPI device through word writes, not byte writes. A "word" in PC assembly language is 2 bytes, so you'll actually send the 12-byte command packet in only 6 write operations.

The "operation code" value you place in the ATAPI command packet is actually a SCSI command code. You do not use ATA commands with ATAPI devices; ATAPI devices use SCSI commands. For example, the SCSI command to eject a CD-ROM drive tray is the "START/STOP UNIT" command, which is SCSI command 1Bh. Similarly, to get an ATAPI CD-ROM drive to eject, you'd send it a command packet with 1Bh for an operation code.

ATAPI contains several commands, but the most fundamental of these is the PACKET command, which has an ATAPI opcode of A0h. The first step in sending a command to an ATAPI device is to send it the PACKET command over the regular ATA command register, just as the program above sends the IDENTIFY DEVICE command. Once this PACKET command is sent, the ATAPI interface goes into a condition called HPD0: Check_Status_A State, which means that the ATA controller is to wait for 400 nanoseconds, then poll the status register until the BSY bit is zero. If the BSY bit is one, the host is supposed to keep polling the status register until the BSY bit clears.

Once the BSY bit does clear (and DRQ is set to one), the ATAPI interface changes to HPD1: Send_Packet State. In this state, the host is supposed to send the command packet to the ATA controller's data register, one byte at a time. When all the bytes of the command packet have been sent, the host is to either transition to HPD2: Check_Status_B State (if nIEN is set to one), or to HPD3: INTRQ_Wait State (if nIEN is set to zero). Note that nIEN is the second-rightmost bit of the ATA Device Control Register. You will note that this register is write-only, so you should write to this register to set nIEN before you begin sending the ATAPI packet.

If the host does transition to HPD3: INTRQ_Wait State, all it's supposed to do is wait for INTRQ to be asserted. When INTRQ is asserted, then the host shall transition to HPD2: Check_Status_B State.

The HPD2: Check_Status_B State is where things get a little hairy. This is where you check the status register, but there are a lot of condition bits you're supposed to check. First of all, the ATAPI spec specifies that "When entering this state from the HP1 ... state, the host shall wait one PIO transfer cycle time before reading the Status register. The wait may be accomplished by reading the Alternate Status register and ignoring the result."

Once that's done, start checking the status register. First of all, if BUSY is set to 1, the host is not to leave the HPD2 state. The host is supposed to remain in HPD2 until BUSY clears to zero.

Once BUSY is zero, check DRQ. If DRQ is set to one, then the host shall transition to yet another state, called the HPD4: Transfer_Data State. However, the only time you'd need to enter HPD4 is if DRQ is 1 during the HPD2 State. If DRQ is zero now, you can skip HPD4 altogether.

If both BUSY and DRQ are zero, then, the command is probably complete. Technically, there are a few other things you're supposed to check, but we won't worry about those now.

The following is an ugly program in assembler to eject a CD-ROM drive. I haven't cleaned up the code as nicely as I should, but it does work as long as you run it in real mode (what Win9x users would call "DOS mode").

`
MOV DX, 177h ;status register
LOOP1:
IN AL, DX ;sets AL to status register (which is 8 bits)

;If the first bit of the status register (BUSY) isn't 0, the device is busy,
;so keep looping until it isn't.

AND AL, 10000000xB
JNE LOOP1

;----------------------------------------------------------------------------

;Clear interrupts so something doesn't interrupt the drive or controller
;while this program is working.
CLI

;----------------------------------------------------------------------------

MOV DX, 177h ;status register again
LOOP2:
IN AL, DX ;sets AL to status register again

;If the second bit of the status register (DRDY) isn't 1, the device isn't
;ready, so keep looping until it is.

AND AL, 01000000xB
JE LOOP2

;----------------------------------------------------------------------------

MOV DX, 176h ;device/head register
MOV AL, 0 ;0 selects device 0 (master). 10h would select device 1 (slave).
OUT DX, AL ;selects master device

;IMPORTANT: Set nIEN before you send the PACKET command!
;Let's set nIEN to 1 so we can skip the INTRQ_Wait state.

MOV DX, 3F6h ;Device Control register
MOV AL, 00001010xB ;nIEN is the second bit from the right here
OUT DX, AL ;nIEN is now one!

MOV DX, 177h ;command register
MOV AL, 0A0h ;PACKET command
OUT DX, AL ;sends the command!

;After sending the PACKET command, the host is to wait 400 nanoseconds before
;doing anything else.
MOV CX,0FFFFh
WAITLOOP:
LOOPNZ WAITLOOP

;----------------------------------------------------------------------------

MOV DX, 177h ;status register again
LOOP3:
IN AL, DX ;sets AL to status register again

;Poll until BUSY bit is clear.

AND AL, 10000000xB
JNE LOOP3

;Also, poll until DRQ is one.
MOV DX, 177h ;status register again
LOOP4:
IN AL, DX
AND AL, 00001000xB
JE LOOP4

;----------------------------------------------------------------------------
;NOW WE START SENDING THE COMMAND PACKET!!!

MOV CX, 6 ;do this 6 times because it's 6 word writes (a word is 2 bytes)
MOV DS, SEG buff
MOV SI, OFFSET buff
;DS:SI now points to the buffer which contains our ATAPI command packet
CLD ;clear direction flag so SI gets incremented, not decremented

COMPACKLOOP: ;command packet sending loop
MOV DX, 170h ;data register

;Because we're going to need to write a word (2 bytes), we can't just use an
;8-bit register like AL. For this operation, we'll need to use the full width
;of the 16-bit accumulator AX. We'll use the LODSW opcode, which loads AX
;with whatever DS:SI points to. Not only this, but if the direction flag is
;cleared (which we did a few lines above with the CLD instruction), LODSW
;also auto-increments SI.
LODSW
OUT DX, AX ;send the current word of the command packet!!!

MOV DX, 3F6h ;Alternate Status Register
IN AL, DX ;wait one I/O cycle

LOOPNZ COMPACKLOOP

;----------------------------------------------------------------------------

;Once again, let's read the Alternate Status Register and ignore the result,
;since the spec says so.

MOV DX, 3F6h
IN AL, DX

;Okay... That's done.
;Time to poll the status register until BUSY is 0 again.

MOV DX, 177h ;status register
LOOP5:
IN AL, DX

AND AL, 10000000xB
JNE LOOP5

;BUSY is zero here.
;We're also supposed to check DRQ, but hey, screw it.

STI

;----------------------------------------------------------------------------

mov ah,004C  ;terminate program
int 21h

buff db 1Bh, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0
`