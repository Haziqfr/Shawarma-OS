# Boot Process

```text
Stage 1 @ 0x7C00
    |
    ├─ Initialize CPU state
    ├─ Save boot drive
    └─ Determine boot device type
        │
        ├─ HDD
        │   │
        │   ├─ Query geometry
        │   ├─ Check LBA support
        │   │
        │   ├─ LBA supported
        │   │    └─ LBA read
        │   │
        │   └─ LBA unavailable
        │        └─ CHS read
        │
        └─ Floppy 
            │
            ├─ Probe geometry
            └─ CHS read
    │
    ▼
Stage 1.5 @ 0x7E00
    
```

# Responsibility
---
###  Stage 1 Bootloader

Initializes CPU state, configures the stack and saves the BIOS boot drive ID in memory, 
and prints boot message.

Checks if the boot drive is hard disk compatible or floppy.
If it's not a hard drive compatible boot device then it assumes a floppy 
disk and tries to probe the floppy disk's geometry and then 
it does `CHS` read to load the next stage at physical address `0x7E00`. 

Or if it's a hard drive compatible device it checks for `LBA` support.
If `LBA` is available it tries to read the next stage to physical address `0x7E00` or falls back to  CHS.
If loading succeeds it hands execution to the next stage via a `far jump`.

