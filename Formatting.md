# Introduction
You can read so many forum postings about formatting, but I think that only very few people really know what they are talking about. If you start looking for information on the web, you will find many documents and tools. But if you take a closer look, things start getting complicated very soon.

The problem is, that the whole process goes back to the DOS era and is therefore loaded with bad heritage and backward compatibility issues. I don't want to go too much into detail when it comes to these topics, but I have to mention some aspects that are important for setting up a proper filesystem.

Since this is a site about flash memory cards, this article will focus on those details that are important for memory cards. This implies a sector size of 512 bytes and MBR partitions for media sizes of less than 2TB.

Important note: This article will not tell you how to partition and format a media, and you should be familiar with the basics of partitioning and formatting. This article is just supposed to shed light on the dirty details and what can go wrong. As a conclusion, you should not mess with flash memory cards - unless you have to clean up the mess somebody else already created.

## Partitioning
You can set up a filesystem without partitioning the media. This type of format is called "Superfloppy", because floppy disks do not use partition tables. Warning: Whenever you insert a blank memory card, and Windows XP prompts you whether to format the media, this will result in a Superfloppy format.

Usually, memory cards have exactly one primary partition defined in the first entry of the partition table. Such a partition entry is a sequence of 16 bytes, so setting up a partition should not be such a big deal? Wrong! I have seen many memory cards that had an inconsistent partition entry right off the factory.

What's so difficult about this partition entry? Let's take a closer look at what information those 16 bytes hold: There is a one-byte boot flag that indicates whether the partition should be used for booting, and a one-byte partition type that gives a hint about what the partition is used for. Then there are two three-byte entries giving the partition start and partition end in CHS format, and two four-byte entries holding the sector offset as 32-bit LBA, and the length of the partition as 32-bit sector count. At first glance, it sounds simple: You just have to make sure that both entries describe the same partition, in mathematical terms: CHS start = LBA offset and CHS end = LBA offset + LBA length - 1. That would be true if the CHS addressing had no strange limitations and rules.

## CHS Addressing

The first thing you should know about CHS addressing is that sector numbers start counting from 1 up to S with a maximum of 63 sectors, meaning that there is no sector 0. Head and cylinder numbers start counting from 0 up to H-1 or C-1. The next thing to learn are the various length issues. The ATA interface uses 16/4/8 bit for CHS up to 16384/16/63 = 7.875GB. The BIOS interface uses 10/8/6 bit for CHS up to 1024/256/63 = 7.875GB. This would give a common range of 10/4/6 bit for CHS up to 1024/16/63, which leads to a total size of 504MB. DOS uses 10/8/6 bit for CHS, but can only handle a maximum of 255 heads. So DOS itself with a limit of CHS up to 1024/255/63 could address up to 7.844GB, which is the smallest size of all three schemes.

For DOS, the CHS calculation is first done as if there was no limit for the cylinder number. In case of a resulting cylinder number of 1024 or higher, a cylinder entry of 1023 simply indicates this overflow. Using only the lower 10 bit of the resulting cylinder number is not correct, but can be seen very often.

There is one rule about partitions and CHS mapping: A partition should always start and end at a cylinder boundary, i.e. starting from X/0/1 and ending at Y/H-1/S. In order not to waste too much space in front of the first partition, the first partition should start at head 1 of the first cylinder instead, i.e. at 0/1/1. On a media with only one primary partition across the whole media, this partition should be defined from 0/1/1 to C-1/H-1/S.

One very strange rule is the "last cylinder rule". Some older operating systems used the last cylinder of a disk or media for special purposes. In order not to run in any potential problems, many partitioning tools will not use the last cylinder. This also applies to the DOS fdisk.

Windows XP will usually report a geometry of C/255/63 and stick to cylinder boundaries when creating partitions. This results in steps of about 7.844MB. For smaller media, Windows XP will most likely report a geometry of C/1/1 - at least the 8GB SmartMedia from my collection, having 7.8125GB of available space, was detected with a geometry of 16000/1/1.

## Extended Translation

In order to handle "larger" storage than 504MB with DOS CHS mapping, extended translation was introduced. The geometry from the ATA interface is mapped to a different geometry for the BIOS interface, while avoiding 256 heads mappings to remain DOS compatible. This is usually done by multiplying the number of heads and dividing the number of cylinders by 2, 4, or 8. Multiplying 16 heads by 16 would give 256 heads, which cannot be addressed by DOS. Some harddisks can be configured to report 15 heads instead, which leads to a translated number of 240 heads.
Example: The Toshiba 5GB PCMCIA harddisk has a logical mapping of CHS=10490/15/63, which can be translated to CHS=655/240/63 by dividing the cylinder count by 16, while multiplying the number of heads with 16. Depending on the number of cylinders, the translation can lead to a slightly reduced capacity, but this is at most 7.38MB (15/15/63).

This is the point where the rule about partitions ending at cylinder boundaries comes in handy, because you can read the H and S values from the CHS partition end entry: H = H_end+1 and S = S_end. In case of extended translation, the number of cylinders should be more than 512 and less than 1023, while the number of heads is one of 32, 64, 128 or 240.
Example: A really bad example is the partition table on the first 2GB RiData 52x CF. The card seems to have a logical mapping of CHS=3953/16/63, but the partition end entry is 880/63/63. This is a combination of the lower 10 bit of the cylinder number and the translated head number. Correct would be either 1023/15/63 to indicate an overflow in the cylinder number, or 987/63/63 for the translated geometry of CHS=988/64/63.

### LBA

As written before, the LBA entry in the partition table could address 2TB storage. However, the original ATA interface can only use 28-bit LBA through the CHS registers. This gives a total limit of 128GB, which should be OK for current memory cards, and those of the near future. ATA harddisks already support 48-bit LBA for a long time, SCSI harddisks had 64-bit LBA even longer.

### Formatting
Formatting means setting up a file system on a media or in a partition of a media. Since we are talking about memory cards, the only filesystem of interest is FAT. Attention: Whenever you change the filesystem type, you should make sure to check the partition type in the partition entry, and change it if necessary. There are many tools that won't care about setting the partition type, but some devices might not accept the media.

## FAT Filesystems

There are three types of FAT filesystems: FAT12, FAT16 and FAT32. The only legal way to detect the type of FAT filesystem is to check the count of clusters. There is a strict rule about the count of clusters: FAT12 can have up to 4084 clusters, FAT16 can have 4085 to 65524 clusters, and FAT32 has 65525 or more clusters. The count of clusters is the number of clusters available in the filesystem. The cluster numbers used in the FAT entries start at 2 and end at "count of clusters" + 1. The two clusters with numbers 0 and 1 don't exist in the filesystem, only within the FAT. If you think this is not correct, read the official "fatgen103.doc" from Microsoft.

There is a rule that clusters should not be larger than 32kB, but for media with 512 bytes per sector, the true cluster size limit is 64kB (128 sectors per cluster). Many FAT drivers will handle this cluster size properly. This allows filesystems twice as big, these values will be given in brackets: FAT12 filesystems can have up to 127.6MB (255.2MB), FAT16 filesystems can range from 1.994MB to 2047MB (4095MB) and FAT32 filesystems have at least 31.99MB. As you can see, there is even a completely legal range from 31.99MB to 127.6MB where you can choose any of the three FAT filesystem types. Special note: You cannot create FAT filesystems of different type, but having the same total size and cluster size, because this would lead to the same count of clusters.

Based on the available size and the FAT filesystem type, an appropriate cluster size must be chosen. Then there are still some parameters that have default values, but could be modified. Attention: Each modification of the filesystem parameters increases the risk that certain FAT drivers might not recognize the filesystem. However, a properly implemented FAT driver is supposed to accept a filesystem with any parameters that are within the specifications for the chosen filesystem.

A FAT filesystem consists of several areas:

A specified number of reserved sectors holding the information about the filesystem.
A specified number of FAT copies, each having a specified number of sectors.
A number of sectors for the root directory calculated from the specified number of root directory entries.
The data area with a number of clusters that is calculated from the total number of sectors, the number of filesystem sectors and the specified cluster size.
Eventually some unused sectors within the filesystem due to rounding down the number of clusters. The count of unused sectors at the end of the filesystem is always less than the number of sectors per cluster.
Eventually sectors that are part of the partition, but not part of the filesystem. This happens if the specified number of sectors for the filesystem is less than the number of sectors specified by the partition entry. Sometimes this is used to adjust the size of the filesystem to avoid unused space after the last cluster, i.e. move the unused sectors outside the filesystem space.
Filesystem Parameters

The first parameter is the number of reserved sectors. For FAT12 and FAT16, the default value is 1. For FAT32, the default value is 32, although the filesystem information usually only takes up 9 sectors.

There are two parameters concerning the FAT: The number of FAT copies, which is supposed to be 2, and the number of sectors per FAT, which must be large enough to fit the required amount of FAT entries. However, the reserved space can be larger than required.
When setting up a filesystem, the number of sectors per FAT has to be specified. This is not as simple as it seems at first glance, especially for large FAT sizes: The space needed for the FAT reduces the number of available clusters. The lower number of clusters could be handled with a smaller FAT, but the extra clusters due to the reduced FAT size could be too much for the smaller FAT size... Windows uses a special mathematical formula to calculate the number of sectors per FAT directly without iterations, but the formula might lead to a FAT size than can be 1 or 2 sectors larger than necessary.

The last parameter is the number of root directory entries. For FAT12 the default seems to be 256, for FAT16 the default is 512. For FAT32, this value must be zero, because the root directory is part of the data area, and has an initial size of one cluster. This means, than an "empty" FAT32 filesystem is not really empty, but has one cluster occupied by the empty root directory.

### FAT12

Some people might think that FAT12 is a thing of the past. But you will find FAT12 on most regular Memory Sticks, Smart Media and even xD-Picture cards up to 64MB. Even some smaller CF cards have a FAT12 filesystem as factory default - at least until some evil device re-formats them to FAT16. Remember: FAT12 can be used up to 127.6MB without violating any rules. However, Windows will use FAT12 only on floppy disks. Whenever you format such a media with Windows, it will be formatted as FAT16 instead, with a cluster size as small as possible. This can affect the performance of the media.

### FAT16

For flash media, FAT16 was the most commonly used filesystem. But without violating any rules, it can only be used up to 2047MB. Many FAT drivers support FAT16 filesystems of up to 4095MB, but you should be aware that you use this at your own risk. Attention: Windows XP will format any volume of 512MB or larger with FAT32. Be sure to specify FAT16 if you want to create a FAT16 filesystem.

### FAT32

With increasing flash media sizes, FAT32 became more and more important. But with FAT32, two FAT copies can occupy up to 1.56% of the media, and cause a lot of processing overhead. There is a recommendation to start with a cluster size of 4kB for disks of more than 260MB and up to 8GB, and to use 32kB cluster size for disks of more than 32GB. But for photo/video recording on flash media, the cluster size should be as large as possible, to reduce the overhead for FAT handling.

Windows XP will not allow to create FAT32 filesystems larger than 32GB, but you are not supposed to format flash media on Windows, anyways. FAT32 supports up to 2TB, this limitation is due to the 32-bit values for the number of sectors. Unlike FAT12 or FAT16, FAT32 is not limited by the maximum number of clusters and the cluster size. Due to the 28-bit cluster pointers and 32-bit entries, one FAT32 structure can become up to 1GB.

## Cluster Alignment
Although memory cards report 512 bytes per sector, the internal organization will be based on much larger units. It is very hard to find information on this topic, but from what I read and observed, 16kB might be a commonly used size. Some operations like erase or write might be limited to those larger units. This means that writing only smaller portions, or writing across boundaries can slow down the performance.

Due to the many parameters of the filesystem, clusters can easily become misaligned compared to those units. In worst case, a simple formatting operation coulds ruin the card's performance. Without highly sophisticated partitioning and formatting tools - if they exist at all - you have no chance to bring back the original performance of the media. For more information, see  Cluster Alignment and Card Performance .

Cluster alignment is affected by the partition offset and the filesystem parameters. But for all these parameters, there are rules and default values. This means that in most cases, you have to break at least one rule to get the clusters aligned. The most secure way to get the clusters aligned to a certain address is by leaving all filesystem parameters set to their default values, and moving the partition start. While CF cards usually stick to the partition start at CHS=0/1/1, you will find an odd partition start on most other media types. If you re-format the partition according to the rules, the alignment will be the same. Attention: Changing the cluster size will most likely affect the alignment, because the FAT will have a different size then.