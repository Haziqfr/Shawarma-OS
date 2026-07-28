# Boot Process

```text
Stage 1 @ 0x7C00
    |
    ├─ Initialize CPU state
    ├─ Save boot drive
    ├─ Determine boot device type
    │   │
    │   ├─ HDD
    │   │   │
    │   │   ├─ Query geometry
    │   │   ├─ Check LBA support
    │   │   │
    │   │   ├─ LBA supported
    │   │   │    └─ LBA read
    │   │   │
    │   │   └─ LBA unavailable
    │   │        └─ CHS read
    │   │
    │   └─ Floppy
    │       │
    │       ├─ Probe geometry
    │       └─ CHS read
    │
    ├─ Pass Boot info
    │    ├─ Boot drive
    │    └─ LBA status
    │
 far jump
    │
    ▼

Stage 1.5 @ 0x7E00
    │
    ├─ Save boot drive and LBA status
    ├─ Reinitialize CPU state
    ├─ Get A20 Gate State
    │   │
    │   ├─ A20 Already Enabled ──┐
    │   └─ A20 Disabled          │
    │       ├─ Method 1: BIOS Interrupt
    │       ├─ Method 2: Fast A20 Port
    │       └─ Method 3: Keyboard Controller
    │                            │
    │    ┌───────────────────────┘
    │    ▼
    ├─ Verify A20 Status
    │   ├─ Disabled ──> Halt
    │   └─ Enabled  ──> Continue
    │
    ├─ Load kernel image
    │   │
    │   ├─ LBA mode
    │   │   └─ LBA read
    │   │
    │   └─ CHS mode
    │       └─ CHS read
    │
    └─ Enable Protected Mode
    │   ├─ Disable Interrupts
    │   ├─ Load GDT
    │   └─ Enable CR0 PE bit
    │
 far jump
    │
    ▼

kernel @ 0x9000 (32-bit Protected Mode)
    
```

---

# Responsibilities

---

### Stage 1 Bootloader

Initializes the CPU state, configures the stack, saves the BIOS boot
drive ID in memory,and prints boot message.

Checks if the boot drive is hard disk compatible or floppy.
If it's not a hard drive compatible boot device then it assumes a floppy
disk and tries to probe the floppy disk's geometry and then
it does `CHS` read to load the next stage at physical address `0x7E00`.

Or if it's a hard drive compatible device it checks for `LBA` support.
If `LBA` is available it tries to read the next stage to physical address
`0x7E00` or falls back to `CHS`. If loading succeeds it hands execution to
the next stage via a `far jump`.

### Stage 1.5 Bootloader

After hands of to this stage it saves `lba_status` and `boot_drive` to memory,
setups segment registers, prints message.

Checks for A20 gate, if it's disabled then it tries to enable the A20 gate through three
methods BIOS Interrupt, Fast Port, Keyboard Controller. If A20 is still disabled then
it `HALTS` and if it succeeds then it continues read the kernel image to physical memory
address `0x9000`.

If `lba_status` is equal to 2 it uses `LBA` mode to read from disk into memory,
otherwise it falls back to `CHS` mode.

Once the kernel is loaded, it prepares for protected mode by disabling interrupts, loading
the Global Descriptor Table, and enabling the `CR0` PE bit. Finally, it executes a `far jump`
to clear the instruction prefetch queue and hands off execution to the kernel at address `0x9000`.


