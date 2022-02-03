all: bootloader

bootloader:
	nasm boot/boot.asm -f bin -o boot/boot.bin
	nasm boot/kernel_entry.asm -f elf -o boot/kernel_entry.bin
	gcc -ffreestanding -c boot/main.c -o boot/kernel.o
	$$TARGET-ld -o boot/kernel.img -Ttext 0x1000 boot/kernel_entry.bin boot/kernel.o
	$$TARGET-objcopy -O binary -j .text boot/kernel.img boot/kernel.bin
	cat boot/boot.bin boot/kernel.bin > mos-v0.0.1.img

clear:
	rm -rf boot/boot.img boot/kernel_entry.bin boot/kernel.bin boot/kernel.img boot/kernel.o boot/boot.bin

run:
	qemu-system-x86_64 -drive format=raw,file=mos-v0.0.1.img
