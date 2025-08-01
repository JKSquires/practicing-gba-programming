# practicing-gba-programming
A repository that I use to store and showcase finished and unfinished ideas and projects I build for the GBA in ARM.

**Note: unless a proper header is added, these programs will not work on real hardware (nor some emulators).**
I do not include the header in order to avoid copyright infringement, as it includes a bitmap of the Nintendo logo.

---

## Build Instructions

Assemble a program with the [Goldroad 1.7](https://www.gbadev.org/tools.php?showinfo=192) assembler:
```sh
goldroad.exe <file/path>.asm
```

---

## Program Descriptions

Name | Screenshot (if applicable) | Description
---- | -------------------------- | -----------
Pixels | ![pixels screenshot](pixels/screenshot.png) | This program displays a pixel of a different color on the corners of the screen. (They may be hard to see in the screenshot, but they're there!)
Line | ![line screenshot](line/screenshot.png) | This program displays any arbitrary line specified in the code. It uses my own implementation of Bresenham's line algorithm and can draw lines in all 8 octants.
VBlank Test | ![vblank_test screenshot](vblank_test/screenshot.png) | This program displays a line that extends and contracts at the top of the screen that only gets processed once per VBlank.
