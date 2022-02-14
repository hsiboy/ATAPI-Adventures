# ATA Registers

The Command Block Registers are used for sending commands to the drive or
posting status from the drive.
The Control Block Registers are used for drive control and to post alternate
status.
Table 6 lists these registers and the addresses that select them.

Logic conventions are: 
* A = signal asserted;
* N = signal negated;
* x = does not matter which it is.

## I/O port functions/selection addresses
 ```
+===============================-==========================================+
| Addresses                     |                Functions                 |
|-------------------------------+------------------------------------------|
|      |      |     |     |     |     READ (DIOR-)    |   WRITE (DIOW-)    |
|CS1FX-|CS3FX-| DA2 | DA1 | DA0 |------------------------------------------|
|      |      |     |     |     |        Control block registers           |
|------+------+-----+-----+-----+------------------------------------------|
| N    | N    | x   | x   | x   | Data bus high imped |   Not used         |
| N    | A    | 0   | x   | X   | Data bus high imped |   Not used         |
| N    | A    | 1   | 0   | x   | Data bus high imped |   Not used         |
| N    | A    | 1   | 1   | 0   | Alternate status    |   Device control.  |
| N    | A    | 1   | 1   | 1   | Drive address       |   Not used         |
|-------------------------------+------------------------------------------|
|                               |           Command block registers        |
|-------------------------------+------------------------------------------|
| A    | N    | 0   | 0   | 0   | Data                | Data               |
| A    | N    | 0   | 0   | 1   | Error register      | Features           |
| A    | N    | 0   | 1   | 0   | Sector count        | Sector count       |
| A    | N    | 0   | 1   | 1   | Sector number       | Sector number.     |
| A    | N    | 0   | 1   | 1   | * LBA bits 0- 7     | * LBA bits 0- 7.   |
| A    | N    | 1   | 0   | 0   | Cylinder low        | Cylinder low.      |
| A    | N    | 1   | 0   | 0   | * LBA bits 8-15     | * LBA bits 8-15.   |
| A    | N    | 1   | 0   | 1   | Cylinder high       | Cylinder high.     |
| A    | N    | 1   | 0   | 1   | * LBA bits 16-23    | * LBA bits 16-23   |
| A    | N    | 1   | 1   | 0   | Drive/head          | Drive/head         |
| A    | N    | 1   | 1   | 0   | * LBA bits 24-27    | * LBA bits 24-27   |
| A    | N    | 1   | 1   | 1   | Status              | Command            |
| A    | A    | x   | x   | x   | Invalid address     | Invalid address    |
|--------------------------------------------------------------------------|
| * Mapping of registers in LBA mode                                       |
+==========================================================================+
```
