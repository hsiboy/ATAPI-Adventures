# Atapi Task File

Atapi sits on top of ATA, so given that there are a finite number of physical address lines availble, these are reused. This means that where an understanding of the ATA registers has been gained, the ATAPI registers reuse these, so they have different meaning.
Also, while people harp on about ATAPI being SCSI, it isnt really. Sure, there are similarities and if that that model helps you get started great, but do yourself a favour and read the ATAPI spec and look at it as something different to SCSI, because it is.


```
+------------------------------------------------------------+
|                   Command Register block                   |
+-----------------------------+------------------------------+
|           address           |       name and function      |
+-----+-----+-----+-----+-----+-------------------+----------+
| CS0 | CS1 | DA2 | DA1 | DA0 |        Read       |   Write  |
+-----+-----+-----+-----+-----+-------------------+----------+
|  1  |  0  |  0  |  0  |  0  |         Data Register        |
+-----+-----+-----+-----+-----+-------------------+----------+
|  1  |  0  |  0  |  0  |  1  |       Error       |  feature |
+-----+-----+-----+-----+-----+-------------------+----------+
|  1  |  0  |  0  |  1  |  0  |    cause of INT   | Not Used |
+-----+-----+-----+-----+-----+-------------------+----------+
|  1  |  0  |  0  |  1  |  1  |           reserved           |
+-----+-----+-----+-----+-----+-------------------+----------+
|  1  |  0  |  1  |  0  |  0  |  Byte Count (0-7) |          |
+-----+-----+-----+-----+-----+-------------------+----------+
|  1  |  0  |  1  |  0  |  1  | Byte Count (8-15) |          |
+-----+-----+-----+-----+-----+-------------------+----------+
|  1  |  0  |  1  |  1  |  0  |    Drive Select   |          |
+-----+-----+-----+-----+-----+-------------------+----------+
|  1  |  0  |  1  |  1  |  1  |       Status      |  Command |
+-----+-----+-----+-----+-----+-------------------+----------+
```

```
+---------------------------------------------------+
|               Control Register block              |
+-----------------------------+---------------------+
|           address           |  name and function  |
+-----+-----+-----+-----+-----+----------+----------+
| CS0 | CS1 | DA2 | DA1 | DA0 | not used | not used |
+-----+-----+-----+-----+-----+----------+----------+
|  0  |  1  |  0  |  0  |  0  | not used | not used |
+-----+-----+-----+-----+-----+----------+----------+
|  0  |  1  |  0  |  0  |  1  | not used | not used |
+-----+-----+-----+-----+-----+----------+----------+
|  0  |  1  |  0  |  1  |  0  | not used | not used |
+-----+-----+-----+-----+-----+----------+----------+
|  0  |  1  |  0  |  1  |  1  | not used | not used |
+-----+-----+-----+-----+-----+----------+----------+
|  0  |  1  |  1  |  0  |  0  | not used | not used |
+-----+-----+-----+-----+-----+----------+----------+
|  0  |  1  |  1  |  0  |  1  | not used | not used |
+-----+-----+-----+-----+-----+----------+----------+
|  0  |  1  |  1  |  1  |  0  |  Status  |  Control |
+-----+-----+-----+-----+-----+----------+----------+
|  0  |  1  |  1  |  1  |  1  | Reserved | not used |
+-----+-----+-----+-----+-----+----------+----------+
```

The ATAPI status register 
