3.2.3 Drive A: Functionality

The following characteristics distinguish Zip ATAPI drives that have drive A: capability. These characteristics are described in more detail in relevant
sections of this document.

- Each pin pair on the Configuration Jumper Block on the rear of the drive has been functionally defined (3.1.1), thus making the jumper block nonstandard.

- The ATA IDENTIFY PACKET DEVICE Command (A1h) has an updated Identify Drive Informatin table (Table 5-5) in Section 5.3.6. Zip ATAPI drives that support Drive A:
operation return 4002h in word 50 in lieu of 0000h (which is the value returned by Zip ATAPI drives without drive A: capability).

- New options are available for the MISCELLANEOUS CONTROL PACKET command (0Dh) to enable and disable drive A: operation (see 5.5.4).

When the drive is configured in the Drive A: mode:

- The first 32 LBS'a of the disk are not accessible (i.e., the drive adds 32 to all LBA's specified in all commands).

- Disk capacity is reduced by 32 LBA's.

- The FORMAT UNIT PACKET Command (04h) writes a DOS partition on LBA-32.

- ATA IDENTIFY PACKET DEVICE Command (A1h) reports "Floppy" at word offset 34 (see also Table 5-5).

- When the host writes data to LBA 0 that the drive's firmware evaluates as a DOS boot record***, the drive then checks the data at offset 28; if offset 28 contains
00h, the drive changes the value to 80h. The drive also checks the data at offset 36; if offset 36 contains 00h, the drive changes it to 20h. The drive makes these changes prior to writing the data to LBA 0 on the disk.

- When the host reads data from LBA 0 and the drive's firmware evaluates the retrieved data as a DOS boot record***, the drive then checks the data at offset 28; if offset 28 contains 80h, the drive changes it to 00h.
The drive also checks the data at offset 36; if offset 36 contains 20h, the drive changes it to 00h. The drive makes these changes before sending the data on to the
host.

- NON-SENSE PACKET Command (06h), Disk Status Page 02h, byte 63, bit-7, contains a one. (See Section 5.5.6)

*** The drive identifies a DOS boot record by looking for the following values:
- 55h at offset 510
- AAh at offset 411
- 29h at offset 38

---------------------------------------------------
5.5.4 ENABLE/DISABLE DRIVE A: FUNCTION

Drive A: functionality is enabled by the Operation Subcode being set to EAh, with zeros in Byte 3:

Byte 0          Operation Code, 0Dh
Byte 1          Reserved
Byte 2          Operation Subcode (EAh)
Byte 3          Reserved (All bits = 0)
Byte 4-5                Reserved
Byte 6-11               PAD

Drive A: functionality is disabled by the Operation Subcode being set to DAh, with zeros in Byte 3:

Byte 0          Operation Code, 0Dh
Byte 1          Reserved
Byte 2          Operation Subcode (DAh)
Byte 3          Reserved (All bits = 0)
Byte 4-5                Reserved
Byte 6-11               PAD
---------------------------------------------------