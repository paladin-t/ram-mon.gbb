## RAM MON

RAM MON is a [GB BASIC](https://paladin-t.github.io/kits/gbb/) program runs on Game Boy, which allows it to read and write to the memory bus directly. This software aids in the development of emulators and simulators, assists in homebrew cartridge production, and supports console hardware debugging.

<img src="docs/cartridge label.png" height="320">

### Running

Put "RAM MON.gb" on any Game Boy device, and launch it. Or try in [browser](https://paladin-t.github.io/ram-mon.gbb/index.html). It shows a memory bus accessing interface, and also guesses the running device type.

<img src="docs/screenshot.png" height="320">

#### Usages

- D-Pad Left/Right to move the cursor
- D-Pad Up/Down to modify the numbers
- A button to read from the specific address
- B button to write to the specific address

<img src="docs/running on gbp.jpg" height="320"> <img src="docs/running on gbc.jpg" height="320"> <img src="docs/running on gba.jpg" height="320"> <img src="docs/running on ap.jpg" height="320">

Read [Memory Map](https://gbdev.io/pandocs/Memory_Map.html) for technical details about the memory bus.

### Source Code

Open "RAM MON.gbb" with the [latest GB BASIC](https://store.steampowered.com/app/2308700/), it implements all common features. If you prefer to enable extra platform detection, such as Analogue Pocket etc. consider installing the dedicated kernel "kernel/for_ram_mon.zip" in GB BASIC for this RAM MON program. The "kernel" directory also contains the kernel's source code.

This is free and unencumbered software released into the public domain. See [`LICENSE`](LICENSE).

### Disclaimer

Before using this software, please ensure you have a proper understanding of Game Boy hardware. I am not responsible for any hardware damage or other issues resulting from improper use.
