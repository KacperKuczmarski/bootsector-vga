nasm -f bin boot.asm -o boot.bin
echo "INFO: NASM DONE"
cd FolderC
gcc -march=i686 -mtune=generic -m32 -O2 -fPIE -ffreestanding -nostdlib -nostartfiles main.c -o main
echo "INFO: Compilation DONE"
strip -s main
echo "INFO: Strip DONE"
objcopy -O binary -j .text main main.raw
echo "INFO: Create object DONE"
cd -
cat boot.bin FolderC/main.raw > master.bin 
echo "INFO: Combine DONE"
echo "INFO: Lunching qemu"
qemu-system-x86_64 master.bin
