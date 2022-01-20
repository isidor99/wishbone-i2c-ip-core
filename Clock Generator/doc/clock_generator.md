## Uvod

_Clock Generator_ generiše takt signal u zavisnosti od selekcionog ulaza. Ulazni sistemski takt signal može imati frekvencijski raspon do Hz do Ghz

## Tabela portova

| Naziv porta      | Mod | Tip                                      | Opis                                                                                                                                              |
| ---------------- | --- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **clk_i**      | in  | std_logic                              | Ulazni takt signal.                                                                                                                               |
| **rst_i**      | in  | std_logic                              | Ulazni, asinhroni reset signal.                                                                                                                   |
| **enb_i**      | in  | std_logic                              | Ulazni signal za omogućavanje, u neaktivnom stanju izlaz je na visokom logičkom nivou                                   |
| **sel_i**      | in  | std_logic_vector (1 downto 0)          | Selekcion ulaz za odabir moda rada <br/>&emsp; 00 = Standard Mode 100 kHz <br/> &emsp; 01 = Fast-Mode 400 kHz <br/> &emsp; 10 = Fast-Mode Plus 1 MHz|
| **sysclk_i**   | in  | std_logic_vector (31 downto 0)         | Vrijednost sistemskog takta (System Clock Register)|
| **clk_o**       | out  | std_logic | Izlazni takt |


## Sigurne vrijednosti za sysclk_i
| Frekvencija | Mod rada|
|-------------|---------|
| **200 kHz** | Standard Mode|
|**20 MHz**   | svi|
|**50 MHz**   | svi|
|**200 MHz**   | svi|
|**500 MHz**   | svi|
|**1 GHz**   | svi|


## _RTL_ prikaz

![rtl_prikaz](Images\rtl_view.png)
