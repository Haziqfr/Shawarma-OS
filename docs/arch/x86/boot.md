# The ShawarmaOS x86 Boot Protocol

## GENESIS PAGE

| OFFSET/SIZE | PROTO | NAME |
| :---: | :---: | :---: |
| 000/004 | ALL | magic |
| 004/002 | ALL | version |
| 006/001 | ALL | e820_entries |
| 007/001 | - | reserved |
| 008/400 | ALL | e820_table |
| 408/5F8 | ALL | reserved |
