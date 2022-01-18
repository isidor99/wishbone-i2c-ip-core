## Uvod

_Clock Generator_ vrsi preslikavanje sistemskog takta u zavisnosti od selekcionog ulaza

## Tabela portova

| Naziv porta      | Mod | Tip                                      | Opis                                                                                                                                              |
| ---------------- | --- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **clk_i**        | in  | std_logic                              | Ulazni takt signal.                                                                                                                               |
| **rst_i**        | in  | std_logic                              | Ulazni, asinhroni reset signal.                                                                                                                   |
| **enb_i**      | in  | std_logic                                | Ulazni signal za omogućivanje, u neaktivnom stanju izlaz je na visokom logičkom nivou                                   |
| **sel_i**      | in  | std_logic_vector (1 downto 0)            | Selekcion ulaz za odabir moda rada <br/>&emsp; 00 = Standard Mode 100 kHz <br/> &emsp; 01 = Fast-Mode 400 kHz <br/> &emsp; 10 = Fast-Mode Plus 1 MHz|
| **clk_o**       | out  | std_logic | Izlazni takt |

## Generičke konstante

| Naziv       | Tip     | Opis                                                                                  |
| ----------- | ------- | ------------------------------------------------------------------------------------- |
| **g_SYSTEM_CLOCK** | integer | Vrijednost sistemskog takta        |

## _RTL_ prikaz

![rtl_prikaz](Images\rtl_view.png)