11.4 Data Transfers



Figure 6 defines the relationships between the interface signals for both 16-bit and 8-bit data transfers.

```

                              |<------------ t0 -------------------->|     
                        __________________________________________   |     
 Address Valid *1 ...../                                          \________
                       |<-t1->|                            ->| t9 |<-      
                     ->|t7|<- |<----------- t2 ------------->|  ->|t8|<-   
                       |  |   |______________________________|    |  |_____
 DIOR-/DIOW-      ____________/                              \_______/     
                       |  |   |_ _ _ _ _ _ _ _ _ _ _____________     |     
 Write Data Valid *2__________/_ _ _ _ _ _ _ _ _ _/             \__________
                       |  |   |                   |<--t3---->|  |          
                       |  |   |                            ->|t4|<-  |     
                       |  |   |_ _ _ _ _ _ _ _ _ _ _ ___________     |     
 Read Data Valid  *2__________/_ _ _ _ _ _ _ _ _ _ _/        |  \__________
                       |  |   |                     |<--t5-->|  |    |     
                       |  |   |                            ->|t6|<-  |     
                       |  |   |                              |  |    |     
                       |  |__________________________________________|     
 IOCS16-          ________/                                          \_____
```

*1 Drive Address consists of signals CS1FX-, CS3FX- and DA2-0          
*2 Data consists of DD0-15 (16-bit) or DD0-7 (8-bit)                   

```
+-----------------------------------------------------------------------+
| PIO                                           | Mode 0| Mode 1| Mode 2|
| timing parameters                             |  nsec |  nsec |  nsec |
+----+------------------------------------------+-------+-------+-------|
| t0 | Cycle time                         (min) |  600  |  383  |  240  |
| t1 | Address valid to DIOR-/DIOW- setup (min) |   70  |   50  |   30  |
| t2 | DIOR-/DIOW-      16-bit            (min) |  165  |  125  |  100  |
|    |   Pulse width     8-bit            (min) |  290  |  290  |  290  |
| t3 | DIOW- data setup                   (min) |   60  |   45  |   30  |
| t4 | DIOW- data hold                    (min) |   30  |   20  |   15  |
| t5 | DIOR- data setup                   (min) |   50  |   35  |   20  |
| t6 | DIOR- data hold                    (min) |    5  |    5  |    5  |
| t7 | Addr valid to IOCS16- assertion    (max) |   90  |   50  |   40  |
| t8 | Addr valid to IOCS16- negation     (max) |   60  |   45  |   30  |
| t9 | DIOR-/DIOW- to address valid hold  (min) |   20  |   15  |   10  |
+-----------------------------------------------------------------------+
```

                                 PIO data transfer to/from drive 
