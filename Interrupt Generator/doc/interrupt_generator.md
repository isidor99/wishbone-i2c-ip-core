## Uvod

_Interrupt generator_ generiše _interrupt_ tako što na svom izlazu generiše visok, odnosno nizak logički nivo u slučaju da je došlo do prekida ili ne.

## Tabela portova

| Naziv porta      | Mod | Tip                                      | Opis                                                                                                                                              |
| ---------------- | --- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **clk_i**      | in  | std_logic                              | ulazni takt signal                                                                                                                               |
| **int_enable_i**      | in  | std_logic                              | ulazni signal za omogućenje prekida                                                                                                                  |
| **int_ack_i**      | in  | std_logic                              | ulazni signal za brisanje prekida                                   |
| **arlo_i**      | in  | std_logic  | ulaz koji definiše da li je izgubljena arbitraža|
| **int_o**       | out  | std_logic | izlazni signal |

## _RTL_ prikaz

![rtl_prikaz](Images/rtl_viewer.png)
