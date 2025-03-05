#!/bin/bash

# Ensamblar el código
nasm -f bin bootloader.asm -o bootloader.img

# Ejecutar en QEMU
qemu-system-x86_64 -drive format=raw,file=bootloader.img,index=0,if=floppy

