nasm -f bin boot.asm -o boot.bin
echo "INFO: Assembly completed, running qemu"
qemu-system-x86_64 boot.bin

