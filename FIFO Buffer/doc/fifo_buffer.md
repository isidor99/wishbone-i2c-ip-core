## Uvod

_FIFO_ (_First-In First-Out_) bafer je memorijska struktura za čuvanje podataka. U bafer se podaci upisuju na jednom kraju, a čitaju na drugom. Drugim riječima, prvi upisani podatak u bafer će biti prvi pročitan. Ako je bafer pun, upis treba da bude onemogućen sve dok se ne pročita podatak koji na radu.

## Tabela portova

| Naziv porta      | Mod | Tip                                      | Opis                                                                                                                                              |
| ---------------- | --- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **clk_i**        | in  | std_logic                                | Ulazni takt signal.                                                                                                                               |
| **rst_i**        | in  | std_logic                                | Ulazni, asinhroni reset signal.                                                                                                                   |
| **wr_en_i**      | in  | std_logic                                | Ulazni signal kojim se omogućava upis u bafer. Ako se dovede logička jedinica, upis je omogućen.                                                  |
| **rd_en_i**      | in  | std_logic                                | Ulazni signal kojim se omogućava čitanje iz bafera. Ako se dovede logička jedinica, čitanje je omogućeno.                                         |
| **data_i**       | in  | std_logic_vector((g_WIDTH - 1) downto 0) | Ulazni port na koji se dovode podaci koji se upisuju u bafer.                                                                                     |
| **data_o**       | out | std_logic_vector((g_WIDTH - 1) downto 0) | Izlazni port na kojem se nalaze podaci koji se čitaju iz bafera.                                                                                  |
| **buff_full_o**  | out | std_logic                                | Izlazni port koji govori da li je bafer pun. Ako je _1_ bafer je pun. U slučaju da je bafer pun, nije moguće upisati podatke u bafer.             |
| **buff_empty_o** | out | std_logic                                | Izlazni port koji govori da li je bafer prazan. Ako je _1_ bafer je prazan. U slučaju da je bafer prazan, nije moguće pročitati podatke iz njega. |

## Generičke konstante

| Naziv       | Tip     | Opis                                                                                  |
| ----------- | ------- | ------------------------------------------------------------------------------------- |
| **g_WIDTH** | natural | Broj bita jednog podatka u baferu.                                                    |
| **g_DEPTH** | natural | Dubina bafera - ukupan broj podataka od po _g_WIDTH_ bita koji može da stane u bafer. |

## _RTL_ prikaz

![rtl_prikaz](Images\rtl_prikaz.png)

## Vremenska analiza

Na osnovu vremenske analize, dobija se da je maksimalna frekvencija taktnog signala oko _202 MHz_.
