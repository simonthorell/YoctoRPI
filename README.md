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
source /yocto/sources/poky/oe-init-build-env /yocto/build

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
runqemu qemux86-64

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

# Se var programmet är installerat
whereis hello-world

# Se vilka bibliotek programmet använder
ddl hello-world

# Se information om tjänsten
systemctl status hello-world

# Starta tjänsten igen
systemctl start hell-world

# Se loggen för tjänsten
journalctl -u hello-world
```

## Konfigurera kärnan

Testa köra menukonfig för att konfigurera kärnan

```bash
bitbake -c menuconfig virtual/kernel 
```

## Övning

Skapa en egen SystemD som skickar http post anrop till t.ex [webhook.site](https://webhook.site/) eller annan webhook testsida. Vill du använda någon mer avanserad tjänst för att koppla upp enheten t.ex. Leshan eller en MQTT broker direkt i [docker-compose.yml](docker-compose.yml) så går det också utmärkt.

Skapa projekt på github med receptet och skicka in adressen som inlämning.

## Lösningsförslag

Kopiera receptet [hello-world](meta-lager/recipes-example/hello-world_0.1.bb) till [hello-internet](meta-lager/recipes-example/hello-internet_0.1.bb)

Ta bort c programmet hello-world och ändra systemD tjänsten så den heter `hello-internet.service` och postar data direkt med wget.

## Länkar
- [Yocto Manual (Scarthgap 5.04)](https://docs.yoctoproject.org/5.0.4/)
- [Repo](https://source.android.com/docs/setup/reference/repo)
- [YouTube - Raspberry Pi Serial Connect to USB via FTDI](https://www.youtube.com/watch?v=ONvNtz2w-qE)
- [webhook.site](https://webhook.site/) 
