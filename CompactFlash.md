# CompactFlash cards and DMA/UDMA support in True IDE (tm) mode

## Introduction
CompactFlash cards have been a popular choice for boot drives in embedded PC's for several years. Depending on the state/wiring of some configuration pins in its socket, a CompactFlash card can assume three essential modes of operation: "memory mapped", "IO mapped" and "True IDE". In True IDE mode, you can attach it to the IDE channel of any stock PC IDE controller (via an appropriate passive socket adaptor) and it behaves exactly like an IDE device, at least at the interface protocol level. (U)DMA is only relevant in the TrueIDE mode. Note that most photo cameras and USB readers access the cards in "memory mapped" mode, where the (U)DMA capability is irrelevant and is certainly not required for reaching the card's full speed.

## The (U)DMA catch
Originally, CompactFlash cards in TrueIDE mode only supported PIO modes (up to PIO4) and did not support DMA (MWDMA, UDMA). The original/traditional "IDE" wiring of the CompactFlash socket reflected that status quo. Later on though, UDMA-capable CF cards have become available. If you buy an UDMA-capable CF card based on the past impression that there's nothing to go wrong with the True IDE mode, and based on the total lack of any warning in any relevant marketing and technical documentation, you have a good chance of suffering a nasty shock: you plug the card into your trusty CF-to-IDE socket, and the card appears dead!

The trouble is that, compared to PIO, the DMA modes (not just UDMA, but also MWDMA) need two more signals in the CF socket: DMA REQ and ACK. These two signals are nowadays commonly present in all "enhanced IDE" channels (usually integrated on-chip in the system south bridge), but many CF sockets on the market today lack those signals! In traditional IDE-enabled CF sockets, pin 43 is floating free and pin 44 is wired to +5V (power supply line). In a UDMA-capable socket, these should be wired to the UDMA signals, i.e. CF(43)->IDE(21) = DMA REQ and CF(44)->IDE(29) = DMA ACK.

Many of you have previously met the classic UDMA game of hide'n'seek consisting in 40wire vs. 80wire IDE cable, the automatic detection of a 40pin cable, some of you may have worked with a setup where the 40pin cable is not detected and the machine tries the higher UDMA modes (anything above UDMA2 = 33 MBps) and fails to operate reliably, some of you may have experimented with forcing higher UDMA modes on setups where a 40pin attach is normally detected, but the conductors are actually quite short and the higher transfer rates actually work... (ide_core.ignore_cable=[channel_number])

So, for those of you who are aware of that classic UDMA 40wire vs. 80wire stuff, note that this CF DMA/UDMA affair is quite a different story. If you try to run a DMA-capable CF card in an old PIO-only CF socket, the card doesn't work at all, UDMA2 doesn't help, not even MWDMA, and there's no salvation in automatic fallback to PIO. The CF card is identified by the BIOS and OS, but as soon as the BIOS or the OS attempts some UDMA transfer, that IO transaction immediately grinds to a screeching halt, maybe followed by a series of pathetic messages about timeouts and bus resets. Your only chance out of this mess is by forcing "PIO4 only" in some way, ahead of talking (U)DMA to the card at all (since the last power-up/reset).

Consequently, using a 40pin cable (CF socket wiring) doesn't help, as even that way, BIOS/Windows/Linux attempt the 40pin-compliant UDMA2 (33 MBps) and fail. There are also some higher-end CF cards of the past, featuring high transfer rates, yet uncapable of UDMA, but supporting MWDMA - those are guaranteed to fail as well, with identical symptoms.

Note that none of this can be blamed on the card. Blame it on the wiring of the CF socket. Try getting a 40wire "coarse" IDE cable and cut lines 21 and 29. Use that modified cable to attach a decent recent disk drive to a decent IDE controller (onboard Intel, discrete Promise or some such). Note that any disk drive attached using that cable fails in exactly the same way as your unfortunate CF Card.

There are cards on the market, that don't boast DMA capability in IDE mode on their label, yet they do support e.g. MWDMA. Those do not work in old sockets. OTOH, we've also seen cards labeled "Ultra4", which technically don't advertise any DMA capability at all :-) and obviosly these work just fine in PIO-only sockets. The next batch of cards with the same label do support UDMA.
If you want to know for sure, whether or not your card is (U)(MW)DMA-capable, boot Linux and ask the card via "hdparm -I /dev/hdc" (or wherever your CF card happens to sit). Obviously this only works in True IDE mode, i.e. on an IDE channel (not in a USB reader). And, you may need to tell Linux to avoid using DMA in the first place, for the respective IDE device, to be able to boot at all (see the Linux workaround below).

Workarounds
You may try modding your CF socket to support DMA. You may need to lift pin 44 of the CF socket off the PCB, to detach it from +5VSB, or cut the trace connecting to it. And, wire the two CF pins to the corresponding IDE pins in some exposed connector (if any). On many boards, this will be impossible. It's also a problem if you'd need to mod many pieces of some embedded motherboard like that.
Return the UDMA-capable CF card and try using some card that's not DMA capable (up to PIO4 only).
Try getting a configuration util or an alternative firmware for the CF card that you've purchased, which will make it advertise PIO only in its ATA capabilities (no DMA).
You can disable ATA DMA for your IDE controller in the BIOS, usually per channel (primary/secondary) and per device (master/slave). This will however only affect software that relies on BIOS services for disk access, such as bare MS-DOS (without a UDMA driver) and various bootloaders (perhaps including the NTLDR). It will not revive your Windows or Linux plagued by this flaw.
Windows XP have some registry entries to keep track of the transfer mode capabilities of the various IDE devices in the system. The keys are called MasterDeviceTimingMode and SlaveDeviceTimingMode, residing in several instances/subfolders for individual IDE channels, under the following class (registry path):
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A­-E325-11CE-BFC1-08002BE10318}\
A value of zero means auto-detect (try the highest rate possible). To limit the device to PIO4, change the value to 00000010 hexa. Obviously you need to do this "out of band" - in one of several ways:
Load the registry hive offline (in RegEdit.exe) from the target CF card attached via USB.
Clone the CF card to a full-fledged IDE drive, boot from the IDE drive (attached via a conventional IDE connector), change the registry key(s), and finally clone the IDE drive back to the affected CF card.
If the system you're using is really XP Embedded, rather than desktop XP, you can also insert the desired values for the registry keys in the Windows XP Embedded Studio (= at image creation time).

For the record, here are some other possible values and meanings for <Master|Slave>DeviceTimingMode, as reported by various anonymous sources on assorted tech support forums:

ATA133 UDMA-6	00012010
ATA100 UDMA-5	00010010
ATA66 UDMA-4	00008010
ATA44 UDMA-3	00006010
ATA44 UDMA-3	00004010
ATA33 UDMA-2	00002010
MWDMA-2	00000410
MWDMA-1	00000210
PIO4	00000010

As for Linux, you can pass some command-line arguments to the kernel at your bootloader's command prompt (Lilo or Grub). Usually all you need to do is type the name of your boot profile, followed by the additional arguments. Linux 2.4 and early Linux 2.6 accepted ide=nodma (MWDMA/UDMA disable on all IDE channels). Linux 2.6 in some earlier versions accepted e.g. ide0=nodma for the primary IDE channel. Latter Linux 2.6 versions accept an even more refined argument, in the format of ide_core.nodma=x.y , where x = channel number and y = drive number, both of them zero-based. E.g., ide_core.nodma=0.1 means "disable DMA for the primary slave". For permanent configuration, obviously you can put this on the "append" line in lilo.conf or just after the kernel image name in Grub's menu.lst. Note that historically the introduction of the latter ide_core.nodma syntax highly correlates with the moment when Libata became the default driver package even for parallel IDE in many Linux distributions. The ide_core.nodma only works for the legacy IDE driver stack, not for libata - so if your IDE drives and TrueIDE CF cards are all detected as sda/sdb/sdc/sdd etc (SCSI naming convention in Linux), rather than hda/hdb/hdc/hdd etc (IDE naming convention in Linux), try libata.dma=0 (or up to 2, which should allow DMA for all ATA devices except CFA). Alternatively, you can check your kernel's compile-time configuration, disable any Libata drivers for parallel IDE and enable the "legacy" IDE subsystem... then recompile and reinstall the kernel, which is a different story.

