# 1. Size and geometry and partition table of ZIP drives


## 1.1 Size
Non-present disks have a capacity of 0 bytes
100MB disks have a capacity of 100663296 bytes, i.e., 196608 sectors
250MB disks have a capacity of 250640384 bytes, i.e., 489532 sectors
LS120 disks have a capacity of 126222336 bytes, i.e., 246528 sectors

> Note
Iomega measures its disk capacities in megabytes where 1 megabyte = one million bytes.
This is less than the conventional definition where 1 megabyte = 1,048,576 bytes.


## 1.2 Partition Table or not?
The ATAPI Removable Drive (ARMD) spec developed by Compaq and Phoenix Technologies describes ARMD media as big floppy disks. In particular, they have no partition table.

This is also what WinNT and Windows 95 expect: when a device reports itself as ATAPI FLOPPY, no partition table is read.

On the other hand, ZIP disks prepared by IOMEGA utilities actually have a partition table (usually having a single entry, the fourth, spanning the whole disk, so that access to such disks with partition table goes via mounting /dev/sda4 (in the SCSI case, say)). On disks for the Mac one has 6 partitions, and again the fourth can be mounted, with filesystemtype "hfs".

To reconcile these two points of view, the ATAPI2 ZIP drive comes with a jumper (called the ARMD-jumper, or, more commonly, the A: jumper) that will hide the first 32 sectors of the disk. In other words: with jumper we have a big floppy and no partition table; without jumper we have a small disk with DOS-type partition table. The jumper settings are given in the diagram below.

[diagram]

However, this is not done on older ATAPI and newer ATAPI3 ZIP drives. This means that a disk may be shifted on one machine and unshifted on another, and work in one environment and not in another.

This hiding the first 32 sectors turns the 100663296 byte (196608 sector) disk into a 100646912 byte (196576 sector) one.

Thus, in case you have problems with an ATAPI2 ZIP drive, either remove the (middle) jumper at the back of the drive and mount the partition, say /dev/hdb1, or leave the jumper and mount the full disk, say /dev/hdb.

Horrors
Manfred Spraul supplied some horrifying technical docs. It turns out that the drive changes some things in the data written to sector 0 when it thinks this data might be a DOS boot record. In particular, sector 0 may appear to have different contents depending on the drive it is read with.

BIOS
Michael Bauer observes that the behaviour of an ATAPI2 ZIP drive does not only depend on the jumper, but also on the BIOS.

> I just bought a new computer with Asus P3B-F motherboard and an ATAPI2 ZIP 100MB drive as secondary slave (/dev/hdd). Although the "A" jumper was NOT set, the partition tables of my ZIP disks could not be read and the disks had to be mounted as /dev/hdd instead of /dev/hdd4. But when I changed the BIOS setting for the secondary slave from "Auto" to "None" (which, of course, implies that the drive will not be listed by the BIOS at bootup and that it cannot be booted from), the ZIP drive no longer identifies itself to Linux as "hdd: IOMEGA ZIP 100 ATAPI Floppy", but just "hdd: IOMEGA ZIP 100 ATAPI", and access to the partition table works just fine!

The Asus web site says:

> Question: When I install IOMEGA ZIP-100 ATAPI2 on a P3B-F M/B, Win98 assigns the ZIP drive as Removable B: drive, and even if I set the jumper on the ZIP drive, it is always detected as B: drive in Win98. But if I install the ZIP-100 on a P2B M/B, it can correctly assign the ZIP-100 as Removable D: drive. What is wrong?

> Answer: P3B-F with new BIOS interface can configure the ZIP drive through BIOS setup. Please enter Main menu in BIOS to set the channel where you connect the ZIP drive to, type "ZIP-100" and change "Set device as" setting to "Hard Disk", then the ZIP-100 will be assigned to drive D: in Win98.

Apparently this drive's behavior can be set via commands as well as via jumper. (I have no docs on such commands... yet)

## 1.3 Geometry
The geometry of a SCSI drive for 100MB disks is reported (on Solaris) as 96/64/32 (on an Adaptec controller), 1024/4/48 (on an NCR controller); both geometries yield 196608 sectors. 
The geometry of an IOMEGA ZIP 100 ATAPI FLOPPY drive is reported as 96/64/32. These geometries correspond to 196608*512=100663296 bytes. 
As mentioned above, when jumpered appropriately the disk only reports 100646912 bytes. In such a case 16 KiB is inaccessible. Of course one should not use fdisk on such a disk, but if one does the geometry must be 95/64/32 or so.

The geometry of an IOMEGA ZIP 250 ATAPI FLOPPY drive is reported as 239/64/32 corresponding to 489472 sectors or 250609664 bytes. Thus, this time the drive claims 30 KiB less than a 250 MB disk.

The geometry of an LS120 drive is reported as 963/8/32 corresponding to the same 126222336 bytes that the disk reports.