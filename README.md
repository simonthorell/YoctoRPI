# Yocto för RPI

Detta VS Code projekt använder en Dev Container med byggverktyg för [Yocto](https://www.yoctoproject.org/).
För att ladda ner Yocto och allt som behövs används git verktyget [repo](https://source.android.com/docs/setup/reference/repo).
Repo använder ett [manifest](default.xml) som beskriver git repon som ska hämtas.

I detta project hämtas:
- **poky**: Grundläggande mall för Linux skapade med Yocto
- **OpenEmbedded**: ___meta_openembedded___, Byggsystemet för Yocto, ungefär som West är för Zephyr OS.
- **RaspberryPi**: ___meta_raspberrupy___, Hårdvarulager för RPI enheter

Yocto använder lager och detta project har [meta-lager](meta-lager). 

## Steg för steg

### 1. Setup 

Kör endast detta steg första gången.

Öppna bash i dev-containern och kör dessa kommandon rad för rad:

```bash
# Gå till yocto mappen
cd /yocto

# Använd repo för att lägga till git dependancies från manifestet 
repo init -u /yocto/project -m /yocto/project/default.xml

# Ladda ner git dependancies
repo sync

```

### 2. Starta byggmiljön

Detta steg måste göras varje gång man öppnar en ny terminal.

```bash

# Starta byggmiljön
source /yocto/sources/poky/oe-init-build-env /yocto/project

```

### 3. Bygg en egen Linux

Detta tar långt tid. Bitbake cachar bra så det gåt att avbryta med `ctrl+c`.

```bash

# Bygg en minimal Linux med Bitbake
bitbake -k core-image-minimal

```

### 4. Kör emulerat

QEMU finns med i Yocto: [runqemu](https://docs.yoctoproject.org/5.0.4/dev-manual/qemu.html)

`nographic` argumentent gör att qemu körs direkt i terminalen. För att avsluta tryck `Ctrl + A` följt av `X`. Alternativt `Ctrl + A` och `C` för att köra kommandot `quit`. 

Utan `nographic` kan man öppna `/dev/ttyS1` med `Ctrl + Alt 2` på samma sätt som om man skulle ha anslutit via serie port: [YouTube](https://www.youtube.com/watch?v=ONvNtz2w-qE).

Lösenordet vid inloggning är `root`

```bash

# Kör bygget emulerat med Qemu
runqemu qemux86-64 nographic

```

### 5. Bygg för RPI

Enligt: [meta-raspberrypi](https://github.com/agherzan/meta-raspberrypi)

```bash
# Bygg för rpi5 64bit
MACHINE=raspberrypi5 bitbake -k core-image-base
```

### 6. Skapa RPI SD kort

För att skriva till ett sdkort:
- Skaffa programmet BalenaEtcher
- Spara image från /yocto/tmp/deploy/images/raspberrypi5/core-image-base-raspberrypi5.rootfs.wic.bz2
- Använd balenaEtcher för att skriva imagen till ett SDKort

## Exempel recept med c program som körs med systemD

Receptet [hello-world](meta-lager/recipes-example/hello-world_0.1.bb) läggs till [custom-distro](meta-lager/conf/distro/custom-distro.conf) och byggs när `DISTRO=custom-distro`.

Receptet har två filer:
- [hello-world.c](meta-lager/recipes-example/hello-world/files/hello-world.c) som är ett hello world program i c.
- [hello-world.service](meta-lager/recipes-example/hello-world/files/hello-world.service) som kör c programmet en gång vid uppstart.

I QEMU eller på en RPI kan du köra programmet:

```bash
# Kör programmet
hello-world

# Se information om tjänsten
systemctl status hello-world

# Starta tjänsten igen
systemctl start hell-world

# Se loggen för tjänsten
journalctl -u hello-world
```

## Konfigurera kärnan

Testa köra menukonfig för att konfigurera kärnan enligt: https://github.com/bluez/bluez/wiki/test%E2%80%90runner

```bash
bitbake -c menuconfig virtual/kernel 
```

## Övning 1

Skapa en egen SystemD som skickar http post anrop till t.ex [webhook.site](https://webhook.site/) eller annan webhook testsida. Vill du använda någon mer avanserad tjänst för att koppla upp enheten t.ex. Leshan eller en MQTT broker direkt i [docker-compose.yml](docker-compose.yml) så går det också utmärkt.

Skapa projekt på github med receptet och skicka in adressen som inlämning.

## Lösningsförslag

Kopiera receptet [hello-world](meta-lager/recipes-example/hello-world_0.1.bb) till [hello-internet](meta-lager/recipes-example/hello-internet_0.1.bb)

Ta bort c programmet hello-world och ändra systemD tjänsten så den heter `hello-internet.service` och postar data direkt med wget.

## Övning 2, Bluetooth

Bygg yocto igen för att få med BlueZ stacken och kernel konfigurationen för att köra bluetooth.

Kör scripter rad för rad. **Kopiera inte hela script**.

### Steg 1 - Starta QEMU

Det finns två alternativ för att köra detta.

### Alternativ 1 - Bygg själv

Funkar inte detta så ladda ner en imagefil från Nackadmin och kör Alternativ 2.

```bash
# Bygg för custom-distro om det inte redan är satt i konfigurationen 
DISTRO=custom-distro bitbake -k core-image-base
```

Kör igång med egen image

```bash
# Kör qemu
runqemu qemux86-64 nographic
```

#### Alternativ 2 - Nedladdad image

Ladda ner image och packa up i projektets mapp.

```bash
# Kör qemu med imagen
runqemu qemux86-64 nographic /yocto/project/core-image-base-qemux86-64.rootfs.ext4
```

Du ska nu vara inne i QEMU emulatorn. Lösenord för inloggning är `root`.

För att avsluta QEMU tryck först `CTRL + A` sen `X` eller Forsätt med nästa steg.

### Steg 2 - Starta Bluetooth

Du ska nu vara inne i QEMU emulatorn efter **Steg 1**.

Använd [systemd](https://man7.org/linux/man-pages/man1/systemd.1.html):

```bash
# Kolla att "bluetooth" körs
systemctl status bluetooth

# Om inte, starta
systemctl start bluetooth
```

### Steg 3 - Kolla loggar

Forsätt inne i QEMU efter **Steg 2**.
Detta steg gör inget. Det bara kollar att allt fungerar.

```bash
# Kika i loggen för systemd tjänsten "bluetooth" med -u
journalctl -u bluetooth

# Kolla även i systemets logg med dmesg
# För att inte visa allt, pipa dmesg till grep med "-i bluetooth"
dmesg | grep -i bluetooth
```

Det bör inte ha funnits några fel i loggarna.

### Steg 4 - Starta virtuella Bluetooth enheter

Forsätt inne i QEMU efter **Steg 2** eller **Steg 3**

`btvirt` startar virtuella bluetoothenheter.
Vi kör med BLE (Bluetooth LE (Low Energy)) som med i Bluetooth 4.
Det finns också Bluetooth classic.

```bash
# btvirt är blockande och kommer att köras i "foreground" 
btvirt -U2

# Stoppa btvirt processen och flytta den bakgrunden
# Tryck: CTRL + Z

# Kolla att processen finns i bakgrunden
jobs

# Forsätt btvirt processen i bakgrunden
bg

# Kolla att btvirt körs i bakgrunden
jobs
```

Det är även möjligt att starta en process direkt i bakgrunden med t.ex: `btvirt -U2 &`.

### Steg 5 - BluetoothCTL

I detta steg ska vi ansluta bluetooth enhterna till varandra.
Kör vidare i QEMU

```bash
# Starta tmux
tmux

# Dela skärmen i två "panes"
# Tryck CTRL + B and then %

# Kör igång bluetoothCTL consollen
bluetoothctl

# Visa bluetooth enheterna
list
# Notera MAC adressen för enheten som inte är default

# Byt till andra sidan i tmux
# Tryck CTRL + B och sen →

# Öppna bluetoothctl på högra sidan
bluetoothctl

# Välj den andra MAC addressen (byt ut på raden nedan)
select 00:AA:01:00:00:01 

# Visa egenskaperna
show

# Hoppa tillbaka till första panelen
# Tryck CTRL + B och sen ←

# Visa egenskaperna i första panelen också
show
```

Du bör nu köra tmux med två paneler som kör bluetoothctl med en default BT controller var. 

### Steg 6 - Anslut enheterna till varandra

Fortsätt från steg 5.

Du kommer behöva hoppa mellan panelerna i `tmux`.

1. Starta båda BT enheterna `power on`
2. Starta den ena som discoverable (advertising) med `discoverable on`
   * Detta är _peripheral_ enheten. Den än är even servern. 
3. Sök efter enheter med den andra: `scan on`
   * Detta är _central_ enheten. Den är även klienten.
4. Enheterna hittar varandra. Kan behövas omstart av systemet annars.
4. Parkoppla med _central_ enheten. Den som scannade. Kör: `pair` (MAC adress)
5. Verifera parkopplingen. En fråga ska dyka upp.
6. Lita på enheten med _central_ enheten: `trust` (MAC adress)
7. Anslut med _central_ till _peripheral_: `connect` (MAC adress)

Här tar tyvärr linux delen av övningen slut då jag inte lyckas få de virtuella btvirt enheterna att ansluta till varandra. Någon som har någon idè varför?

Fortsätt gärna i python med Bleak på egna datorn om möjligt. Testa skapa en _peripheral_ och en _central_.

Alternativt, hoppa över till Zephyr och Renode och gå igenom denna guide [Developing and testing BLE products on nRF52840 in Renode and Zephyr](https://renode.io/news/developing-and-testing-ble-on-nrf52840-with-renode-and-zephyr/). Använd gärna [ZephyrDevContainer](https://github.com/nakerlund/ZephyrDevContainer) som bas för att bygga Zephyr samplen som föreslås i guiden.

## Länkar

### Webhooks
- [webhook.site](https://webhook.site/) 

### Yocto and Building
- [Yocto Manual (Scarthgap 5.04)](https://docs.yoctoproject.org/5.0.4/)
- [Repo](https://source.android.com/docs/setup/reference/repo)

### Youtube - Linux
- [Tmux in 100 seconds](https://www.youtube.com/watch?v=vtB1J_zCv8I&t=172s)
- [100+ Linux Things you Need to Know](https://www.youtube.com/watch?v=LKCVKw9CzFo)
- [YouTube - Raspberry Pi Serial Connect to USB via FTDI](https://www.youtube.com/watch?v=ONvNtz2w-qE)
- [Wireshark](https://www.youtube.com/watch?v=a_4MjV_-7Sw)

### Linux CLI Övningar
- [Linux Journey](https://linuxjourney.com/)
- [Labex Labs](https://github.com/labex-labs/linux-basic-commands-practice-online)
