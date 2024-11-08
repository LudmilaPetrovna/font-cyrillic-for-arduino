echo "(reading font from 48.rom (must be in current dir)"
dd if=48.rom of=spectrum.ch8 skip=15616 count=768 bs=1
