# 40 Pin Inmterface

```
+==================================-=========================-===========+
| Host I/O                         |                         | Drive I/O |
| connector                        |                         | connector |
|----------------------------------+-------------------------+-----------|
| HOST RESET                     1 |  ----- RESET- --------> |     1     |
|                                2 |  ----- Ground --------- |     2     |
| HOST DATA BUS BIT 7            3 | <----- DD7 -----------> |     3     |
| HOST DATA BUS BIT 8            4 | <----- DD8 -----------> |     4     |
| HOST DATA BUS BIT 6            5 | <----- DD6 -----------> |     5     |
| HOST DATA BUS BIT 9            6 | <----- DD9 -----------> |     6     |
| HOST DATA BUS BIT 5            7 | <----- DD5 -----------> |     7     |
| HOST DATA BUS BIT 10           8 | <----- DD10 ----------> |     8     |
| HOST DATA BUS BIT 4            9 | <----- DD4 -----------> |     9     |
| HOST DATA BUS BIT 11          10 | <----- DD11 ----------> |     10    |
| HOST DATA BUS BIT 3           11 | <----- DD3 -----------> |     11    |
| HOST DATA BUS BIT 12          12 | <----- DD12 ----------> |     12    |
| HOST DATA BUS BIT 2           13 | <----- DD2 -----------> |     13    |
| HOST DATA BUS BIT 13          14 | <----- DD13 ----------> |     14    |
| HOST DATA BUS BIT 1           15 | <----- DD1 -----------> |     15    |
| HOST DATA BUS BIT 14          16 | <----- DD14 ----------> |     16    |
| HOST DATA BUS BIT 0           17 | <----- DD0 -----------> |     17    |
| HOST DATA BUS BIT 15          18 | <----- DD15 ----------> |     18    |
|                               19 | ------ Ground --------- |     19    |
|                               20 | ----- (key N/C) ------- |     20    |
| DMA REQUEST                   21 | <---- DMARQ ----------- |     21    |
|                               22 | ----- Ground ---------- |     22    |
| HOST I/O WRITE                23 | ----- DIOW- ----------> |     23    |
|                               24 | ----- Ground ---------  |     24    |
| HOST I/O READ                 25 | ----- DIOR- ----------> |     25    |
|                               26 | ----- Ground ---------  |     26    |
| I/O CHANNEL READY             27 | <---- IORDY ----------  |     27    |
| CABLE SELECT                  28 | *---- SPSYNC:CSEL ----* |     28    |
| DMA ACKNOWLEDGE               29 | ----- DMACK- -------->  |     29    |
|                               30 | ----- Ground --------   |     30    |
| HOST INTERRUPT REQUEST        31 | <----- INTRQ ---------  |     31    |
| HOST 16 BIT I/O               32 | <----- IOCS16- -------  |     32    |
| HOST ADDRESS BUS BIT 1        33 | ----- DA1 ----------->  |     33    |
| PASSED DIAGNOSTICS            34 | *----- PDIAG- --------* |     34    |
| HOST ADDRESS BUS BIT 0        35 | ----- DAO ----------->  |     35    |
| HOST ADDRESS BUS BIT 2        36 | ----- DA2 ----------->  |     36    |
| HOST CHIP SELECT 0            37 | ----- CS1FX- -------->  |     37    |
| HOST CHIP SELECT 1            38 | ----- CS3FX- -------->  |     38    |
| DRIVE ACTIVE/DRIVE 1 PRESENT  39 | <----- DASP- ---------* |     39    |
|                               40 | ----- Ground --------   |     40    |
|------------------------------------------------------------------------|
| *Drive intercommunication signals                                      |
+========================================================================+
```
