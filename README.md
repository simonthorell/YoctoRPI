# Yocto för RPI

Detta VS Code projekt använder en Dev Container med byggverktyg för [Yocto](https://www.yoctoproject.org/).
För att ladda ner Yocto och allt som behövs används git verktyget [repo](https://source.android.com/docs/setup/reference/repo).
Repo använder ett [manifest](default.xml) som beskriver git repon som ska hämtas.

I detta project hämtas:
- **poky**: Grundläggande mall för Linux skapade med Yocto
- **OpenEmbedded**: Byggsystemet för Yocto, ungefär som West är för Zephyr OS.

Yocto använder lager och detta project har lagret [layer](layer).

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
bitbake core-image-minimal

```

### 4. Kör emulerat

```bash

# Kör bygget emulerat med Qemu
runqemu qemux86

```

### 5. Bygg för RPI
TBC.

### 6. Skapa RPI SD kort
TBC.


## Länkar
- [Yocto Manual (Scarthgap 5.04)](https://docs.yoctoproject.org/5.0.4/)
- [Repo](https://source.android.com/docs/setup/reference/repo)
