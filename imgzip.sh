# Script to image Zip disks, and record information like disk serial number.
# Also included in the (binary) data is information about write-protection status/mode etc.
# Use like: imgzip.sh /dev/sg2 basename "[other options]"


# DISABLE ARRE AND AWRE! Call it twice in case of unit attention making the first invocation fail
sdparm --clear=AWRE,ARRE $1 >/dev/null
sdparm --clear=AWRE,ARRE --verbose $1

# Issue non-sense command for page 2
sg_raw --request=254 --outfile="$2_06page2.bin" $1 06 00 02 00 FE 00

# Extract the disk ID so we can create each filename prefixed with that.
DISKID=`dd if="$2_06page2.bin" bs=1 skip=22 count=18 | cat`

# Extract the (ASCII) disk serial number data to a file
dd if="$2_06page2.bin" of="`echo -n $DISKID`_$2_serial.txt" bs=1 skip=22 count=40

mv "$2_06page2.bin" "`echo -n $DISKID`_$2_06page2.bin"

# Issue non-sense command for page 0
sg_raw --request=254 --outfile="`echo -n $DISKID`_$2_06page0.bin" $1 06 00 00 00 FE 00

# Issue non-sense command for page 1
sg_raw --request=254 --outfile="`echo -n $DISKID`_$2_06page1.bin" $1 06 00 01 00 FE 00

# Print the three components of disk serial number (commented out because I couldn't get this to work...)
#echo -e -n "Disk ID: \"$DISKID\"\nDisk type: \""
#echo -n `dd if="$DISKID_$2_serial.txt" of=- bs=1 skip=18 count=7 | cat`
#echo -e -n "\"\nVendor code: \""
#sg_dd if="`echo -n $DISKID`_$2_serial.txt" of=- bs=1 skip=25 count=15 | cat
#echo -e "\""

# Image the disk. Use tee to copy output to a file as well as stdout
sg_dd if=$1 of="`echo -n $DISKID`_$2.bin" bs=512 $3 time=1 verbose=2 2>&1 | tee "`echo -n $DISKID`_$2.bin.log"

md5sum -b `echo -n $DISKID`_$2.bin >`echo -n $DISKID`_$2.bin.md5`

