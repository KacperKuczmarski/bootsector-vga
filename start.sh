#export PATH=$PATH:/usr/local/i386elfgcc/bin

nasm -f bin "boot2.asm" -o "bin/boot.bin"
echo "INFO: NASM BOOT DONE"
nasm -f elf "kernel_entry.asm" -o "bin/kernel_entry.o"
echo "INFO: NASM KERNEL ENTRY DONE"
nasm "zeroes.asm" -f bin -o "bin/zeroes.bin"
#gcc -march=i686 -mtune=generic -m32 -O2 -fPIE -ffreestanding -nostdlib -nostartfiles "FolderC/main.cpp" -o "bin/main.o"
gcc -fno-pie -m32 -ffreestanding -g -c "FolderC/main.cpp" -o "bin/main.o"
#i386-elf-gcc -ffreestanding -m32 -g -c "FolderC/main.cpp" -o "bin/main.o"
echo "INFO: Compilation DONE"

export PATH=$PATH:/usr/local/i386elfgcc/bin

#strip -s "bin/main"
#echo "INFO: Strip DONE"
#objcopy -O binary -j .text "bin/main" "bin/main.o"
#echo "INFO: Create object DONE"
i386-elf-ld -o "bin/all_obj.bin" -Ttext 0x1000 "bin/kernel_entry.o" "bin/main.o" --oformat binary
echo "INFO: Linking DONE"
cat "bin/boot.bin" "bin/all_obj.bin" "bin/zeroes.bin" > "bin/master.bin" 
echo "INFO: Combine DONE"
echo "INFO: Lunching qemu"
#qemu-system-x86_64 -drive format=raw,file="bin/master.bin",index=0,if=floppy, -m 128M

qemu-system-x86_64 bin/master.bin
