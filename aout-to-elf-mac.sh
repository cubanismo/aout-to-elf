#!/bin/sh
#
# This definitely isn't working or automated yet.  It's based on this:
# 
#   https://stackoverflow.com/questions/2568291/how-to-convert-peportable-executable-format-to-elf-in-linux
#
# However, the result just segfaults before getting to the program's first
# instruction, presumably in the loader itself somewhere.

# First examine the headers of the a.out executable.  Use -x instead of -h
# to see the start address and some other info as well.  Things to note:
#
#   start address: xxxxxxx
#     -This will be used in the linker script below
#
#   Idx Name         Size          VMA      LMA      File off    Align
#     0 .text  <textsize>  <textvaddr>          <text offset>     
#     1 .data  <datasize>  <datavaddr>          <data offset>     
#     2 .bss    <bsssize>   <bssvaddr>           <bss offset>     
# 
#     -The data above will be used both to extract the .text and .data
#      sections and to construct the linker script that builds the ELF
#      binary.
# 
objdump -x mac

# skip=<text offset> / block size(0x10), in decimal
# count=<text size> / block size(0x10), in decimal
dd if=mac of=mac.text.bin skip=2 bs=16 count=9470

# skip=<data offset> / block size(0x10), in decimal
# count=<data size> / block size(0x10), in decimal
dd if=mac of=mac.data.bin skip=9472 bs=16 count=1536

# Convert raw section data to linker script format
cat mac.text.bin | hexdump -v -e '"BYTE(0x" 1/1 "%02X" ")\n"' > mac.text.ld
cat mac.data.bin | hexdump -v -e '"BYTE(0x" 1/1 "%02X" ")\n"' > mac.data.ld

# Linker script.  Notes:
# -start is taken from start address output by objdump above.
# -text/data/bss section addresses are taken from objdump <textvaddr>,
#  <datavaddr>, <bssvaddr> output above.
# -bss uninitialized data size is taken from objdump <bsssize> output above.
cat > mac-elf.ld <<EndOfFile
_start = 0x1020;
ENTRY(_start)
OUTPUT_FORMAT("elf-i386")
SECTIONS {
    .text 0x1020 :
    {
        INCLUDE "mac.text.ld";
    }
    .data 0x26000 :
    {
        INCLUDE "mac.data.ld";
    }
    .bss 0x2c000 :
    {
        . = . + 0x4f84;
    }
}
EndOfFile
ld -m elf_i386 -o mac-elf mac-elf.ld

# XXX cleanup
rm mac.text.ld mac.text.bin mac.data.ld mac.data.bin mac-elf.ld
