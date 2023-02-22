# C128 for [MiSTer](https://github.com/MiSTer-devel/Main_MiSTer/wiki)

Based on [C64_MiSTer](https://github.com/MiSTer-devel/C64_MiSTer) by sorgelig.

Based on FPGA64 by Peter Wendrich with heavy later modifications by different people.

## Features
- **C128, C64 and CP/M modes**.
- **Chipset versions selectable from original C128 flat and newer C128 DCR**.
- **Supports international versions of the C128**.
- **Optional "pure" C64 mode (disables C128 extensions)**.
- C1541 read/write/format support in raw GCR mode (\*.D64, \*.G64).
- **C1571 read/write/format support in raw GCR or MFM mode (\*.D64, \*.G64, \*.D71, \*.G71)**.
- C1581 read/write support (\*.D81).
- Parallel IEC port for faster (~20x) loading time.
- External IEC through USER_IO port, **including Fast Serial**.
- **VIC jailbars**.
- **VDC with 16k or 64k RAM and multiple colour palettes**.
- Almost all C64 cartridge formats (\*.CRT)
- Direct file injection (\*.PRG) **with detection of C128 or C64 mode**.
- Dual SID with several degree of mixing 6581/8580 from stereo to mono.
- Similar to 6581 and 8580 SID filters.
- REU 16MB and GeoRAM 4MB memory expanders.
- OPL2 sound expander.
- Pause option when OSD is opened.
- 4 joysticks mode.
- RS232 with VIC-1011 and UP9600 modes either internal or through USER_IO.
- Loadable Kernal/drive ROMs.
- Special reduced border mode for 16:9 display.
- Real-time clock.
- **Support for easy configuration of ROMs and hardware options using MRA files**.

Features marked in **bold** are unique to the C128 core, the other features are inherited from the C64 core.

### C128 features not (fully) implemented

- VIC register $D030 video manipulation tricks (eg. used by RfO part 1)
- VDC non-standard high resolution modes (eg. VGA-like modes)
- C128 specific CRT formats

## Usage

### System and drive ROMs
ROM files need to be provided. The ROM images will be loaded by the MiSTer on start up of the core.

There are two ways to provide the ROMs for the core: using boot ROM files, or using MRA files.

#### Using boot ROM files
To boot using rom files, a `boot0.rom` and `boot1.rom` file need to be placed in the `games/C128` directory:

* `boot0.rom` containing the system ROMs in this order:
  * ROM1: C64 Basic+C64 Kernal (16k total)
  * ROM4: C128 Editor+Z80 bios+C128 Kernal (16k total)
  * ROM2+3: C128 Basic (32k total)
  * Character ROM: C64+C128 or ASCII+DIN (8k)
* `boot1.rom` containing the drive ROMs in this order:
  * 2x 1541 drive ROM (64k total) (repeat 4x if it's a 16k ROM image)
  * 2x 1571 drive ROM (64k total)
  * 2x 1581 drive ROM (64k total)

Each drive's ROM is repeated twice in `boot1.rom`. The first ROM is used for drive 8, the second for drive 9. This makes it possible to use different ROMs in the two drives. The 1541 ROM is 16k and needs to be repeated 4 times to fill the 64k space.

There are two optional boot roms:
* `boot2.rom` for the optional Internal Function ROM (16 or 32k)
* `boot3.rom` for the optional External Function ROM (16 or 32k)

#### Using MRA files
MRA files make it possible to create multiple ROM configurations and easily switch between them using the MiSTer interface. Each configuration will show as a separate item in the Computer cores menu. MRA files were designed for use with the arcade cores, but they also work with computer cores. 

The MRA file configures all system and drive roms as well as (optionally) the internal and external function ROMs. It also contains a configuration parameter that configures the "auto" choice of the CIA, SID and VDC chips and how the Caps Lock key is configured, making it possible to quickly switch between a 1985 flat C128 and a C128DCR hardware setup, and the multitude of international language versions of the C128, and even a "pure" C64 mode.

Using MRA files is the more convenient way to create multiple ROM configurations with the C128 core, but requires the user to make manual changes to the MiSTer file layout as currently the `update_all` script does not support MRA files for computer cores.

The following changes need to be made on the MiSTer SD-CARD or USB drive to use the MRA files:

* Move the core's `C128_XXXXXXXX.rbf` file from the `/_Computer/` folder to a (new) `/_Computer/cores/` folder,
* Download (some of) the `*.mra` files from the [mra directory](mra/) and place them in the `/_Computer/` folder,
* Download [C128rom.zip](mra/C128rom.zip) and place that in the `/games/mame/` folder,

#### Loadable ROM
ROMs can also be loaded from the OSD via Hardware->System ROMs and Hardware->Drive ROMs menu options. These expect a ROM file with the same layout as `boot0.rom` and `boot1.rom` as described above respectively.

The Internal Function ROM can also be loaded from the OSD via Hardware->Internal Function ROM and this is similar to using the optional `boot2.rom`.

### Keyboard
* <kbd>End</kbd> - <kbd>Run stop</kbd>
* <kbd>F2</kbd>, <kbd>F4</kbd>, <kbd>F6</kbd>, <kbd>F8</kbd>, <kbd>Left</kbd>/<kbd>Up</kbd> keys automatically activate <kbd>Shift</kbd> key.
* <kbd>F9</kbd> - <kbd>&#129145;</kbd> key.
* <kbd>F10</kbd> - <kbd>=</kbd> key.
* <kbd>F11</kbd> - <kbd>Restore</kbd> key. Also special key in AR/FC carts.
* Meta keys (Win/Apple) - <kbd>C=</kbd> key.
* <kbd>PgUp</kbd> - Tape play/pause
* <kbd>PgDn</kbd> - <kbd>Line feed</kbd>
* <kbd>Print Screen</kbd> - <kbd>Display 40/80</kbd>
* <kbd>Pause/Break</kbd> - <kbd>No Scroll</kbd> (* see note below)
* Numpad <kbd>*</kbd> - <kbd>Help</kbd>

The <kbd>AltGr</kbd> key (right <kbd>Alt</kbd>) is used to access alternative function keys. Combined with <kbd>AltGr</kbd> the function keys are the C128 top-row special keys. To access these functions, press and hold <kbd>AltGr</kbd> while pressing any of the function keys:
* <kbd>AltGr</kbd>+<kbd>F1</kbd> - <kbd>Esc</kbd>
* <kbd>AltGr</kbd>+<kbd>F2</kbd> - <kbd>Alt</kbd>
* <kbd>AltGr</kbd>+<kbd>F3</kbd> - <kbd>Tab</kbd>
* <kbd>AltGr</kbd>+<kbd>F4</kbd> - <kbd>Caps Lock</kbd> or <kbd>ASCII/DIN</kbd>
* <kbd>AltGr</kbd>+<kbd>F5</kbd> - <kbd>Help</kbd>
* <kbd>AltGr</kbd>+<kbd>F6</kbd> - <kbd>Line feed</kbd>
* <kbd>AltGr</kbd>+<kbd>F7</kbd> - <kbd>40/80 display</kbd>
* <kbd>AltGr</kbd>+<kbd>F8</kbd> - <kbd>No scroll</kbd>

It is possible to access the C128 top-row cursor keys, and the numpad keys on a PC keyboard without numpad using <kbd>AltGr</kbd> combined with the similar keys:
* <kbd>AltGr</kbd>+<kbd>return</kbd> - Numpad <kbd>enter</kbd>
* <kbd>AltGr</kbd>+<kbd>1</kbd> through <kbd>0</kbd> - Numpad <kbd>1</kbd> through <kbd>0</kbd>
* <kbd>AltGr</kbd>+<kbd>-</kbd> - Numpad <kbd>-</kbd>
* <kbd>AltGr</kbd>+<kbd>+</kbd> - Numpad <kbd>+</kbd>
* <kbd>AltGr</kbd>+<kbd>.</kbd> - Numpad <kbd>.</kbd>
* <kbd>AltGr</kbd>+Cursor keys - Top-row cursor keys (** see note below)

<kbd>Shift lock</kbd> can be activated by pressing <kbd>AltGr</kbd>+<kbd>Shift</kbd>. This is a toggle, to release <kbd>Shift lock</kbd>, press the <kbd>AltGr</kbd>+<kbd>Shift</kbd> combination again.

![keyboard-mapping](keymap.gif)

Keys marked in blue are the keys sent when combined with <kbd>AltGr</kbd>.

*): The <kbd>Pause/Break</kbd> key acts like the <kbd>No scroll</kbd> key, however the <kbd>Pause/Break</kbd> PC key is special as it does not send a signal when it is released. To solve this, when the <kbd>Pause/Break</kbd> key is pressed, the <kbd>No scroll</kbd> key signal to the C128 is pulsed for short period. To hold <kbd>No scroll</kbd> on the C128 for longer, either use <kbd>AltGr</kbd>+<kbd>F8</kbd>, or quickly double press <kbd>Pause/break</kbd> and press any key to release <kbd>No scroll</kbd>.

**): When the Z80 CPU is active the top-row cursor keys become the default and <kbd>AltGr</kbd> selects the regular cursor keys.

#### Using without keyboard
If your joystick/gamepad has more than 4 buttons then you can have some limited usage of keyboard.
Joystick buttons **Mod1** and **Mod2** adds 12 frequently used keys to skip the intros and start the game.
Considering default button maps RLDU,Fire1,Fire2,Fire3,Paddle Btn, following keys are possible to enter:
* With holding **Mod1**: Cursor RLDU, Enter, Space, End, Shift+End (DLOAD"*" then RUN)
* With holding **Mod2**: 1,2,3,4,5,0,Y,N
* With holding **Mod1+Mod2**: F1,F2,F3,F4,F5,F6,F7,F8

### Internal memory
In the OSD->Hardware menu, internal memory size can be selected as 128K or 256K. The latter activates RAM in banks 2 and 3. C128 basic does not detect or use this memory however, so it will still show 122365 bytes free.

### Video mode
On a C128, the <kbd>40/80 Display</kbd> switch on the keyboard selects which video mode the system will boot on, or switch to when pressing the <kbd>Run stop</kbd>+<kbd>Restore</kbd> key combination. 

Since the MiSTer has a single video output, the video mode being shown needs to be selectable. The video output can be selected from the OSD menu or using the keyboard. Use the OSD->Video Output option to either make the video output follow the <kbd>40/80 Display</kbd> state, or select the VIC or VDC video outputs independent of the state of the <kbd>40/80 Display</kbd> switch.

### VDC/80 column mode
In OSD->Audio&Video the VDC version, memory size and colour palette can be selected.

There are four colour palettes selectable for the VDC:

* **Default**: the "standard" TTL RGBI colour palette
* **Analogue**: the palette when using resistors to convert TTL RGBI to analogue RGB
* **Monochrome**: TTL monochrome monitor, with two levels of intensity
* **Composite**: the black and white image on the composite pin of the DB9 TTL RGBI connector

The C128's VDC has a very programmable video timing signal generator, unlike the VIC, where the video signal timing is fixed in hardware. It makes it a very flexible video chip that can generate many video modes, but it has drawbacks too. For one, it means the video output will most likely not be centered on the generated MiSTer video output, and will change depending on the video mode. This is an artifact of how the VDC works and not easily fixable in the MiSTer.

Another known issue is that the VDC can generate video modes that the  MiSTer video scaler does not correctly process. These modes can cause the scaler to stop working (it will usually recover when switching video output to the VIC) or produce extreme flickering on the video output. Be careful with VDC programs using unofficial video modes if you are sensitive to that!

## Cartridges
To load a cartridge - "External function ROM" in C128 terms - it must be in .CRT format. C64 and C128 cartridges will be detected based on the CRT header and the core will start in the correct mode. 

To convert a binary ROM image into a .CRT, the [cartconv](https://vice-emu.sourceforge.io/vice_15.html) tool from Vice can be used, usually like this:

`cartconv.exe -t c128 -l 0x8000 -i cart.bin -o cart.crt`

The `-t c128` option is needed for C128 cartridges to add the header indicating this is a C128 cartridge. Otherwise the cartridge will be detected as a C64 cartridge and the core will start up in C64 mode.

The `-l 0x8000` option is needed to indicate the image should be located at address $8000. Some external ROMs might need to be located at $C000, in that case `-l 0xC000` should be used.

#### Autoload a Cartridge or Internal Function ROM
In OSD->Hardware page you can choose Boot Cartridge or Internal Function ROM, so everytime core loaded, this cartridge or ROM will be loaded too. 

### RS232

Primary function of RS232 is emulated dial-up connection to old-fashioned BBS. 

**Note:** Most turbo drive ROM kernals have no RS232 routines so most RS232 software don't work with these kernals!

### GeoRAM
Supported up to 4MB of memory. GeoRAM is connected if no other cart is loaded. It's automatically disabled when cart is loaded, then enabled when cart unloaded.

### REU
Supported standard 512KB, expanded 2MB with wrapping inside 512KB blocks (for compatibility) and linear 16MB size with full 16MB counter wrap.
Support for REU files.

GeoRAM and REU don't conflict each other and can be both enabled.

### USER_IO pins

| USER_IO | USB 3.0 name | Signal name |
|:-------:|:-------------|:------------|
|   0     |    D+        | RS232 RX    |
|   1     |    D-        | RS232 TX    |
|   2     |    TX-       | IEC /CLK    |
|   3     |    GND_d     | IEC /RESET  |
|   4     |    RX+       | IEC /DATA   |
|   5     |    RX-       | IEC /ATN    |
|   6     |    TX+       | IEC /SRQ    |

All signals are 3.3V LVTTL and must be properly converted to required levels!

The IEC /SRQ (USER_IO6) line is required for IEC fast serial operation with an external 157x or 1581 drive. You will need a MiSTer user port adapter that connects the /SRQ line. Assume a MiSTer user port to IEC adapter for does not connect this line unless it is explicitly stated that it supports the C128 fast serial protocol.

### Real-time clock

RTC is PCF8583 connected to tape port.
To get real time in GEOS, copy CP-CLOCK64-1.3 from supplied [disk](https://github.com/mister-devel/C64_MiSTer/blob/master/releases/CP-ClockF83_1.3.D64) to GEOS system disk.

### Raw GCR mode

C1541/C1571 implementation works in raw GCR mode (D64/D71 format is converted to GCR and then back when saved), so some non-standard tracks are supported if G64/G71 file format is used. Support formatting and some copiers using raw track copy. Speed zones aren't supported (yet), but system follows the speed setting, so variable speed within a track should work.
Protected disk in most cases won't work yet and still require further tuning of access times to comply with different protections.

