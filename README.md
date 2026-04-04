## RAM MON

RAM MON is a GB BASIC program runs on GameBoy, which allows it to read and write to the memory bus directly.

### Running

Put "RAM MON.gb" on any GameBoy device, and launch it. It shows a memory bus accessing interface, and also guesses the running device type.

![](docs/screenshot.png)

#### Usages

- D-Pad Left/Right to move the cursor
- D-Pad Up/Down to modify the numbers
- A button to read from the specific address
- B button to write to the specific address

<img src="docs/running on gbc.jpg" height="480"> <img src="docs/running on ap.jpg" height="480"> <img src="docs/running on gba.jpg" height="480">

### Source Code

Open "RAM MON.gbb" with the latest GB BASIC. Or see the source code as follows:

```bas
' This program reads and writes value at specific RAM address,
' which could be used as an extension RAM test tool.

' Initialization.
option SCREEN_MODE, TEXT_MODE
fill tile(0, 256) = #0

let readonly = false ' Flag to indicate if current memory address is read-only.
let addr = 0xc000    ' Default memory address to start with (WRAM 0).
let value = 0x00     ' Default value to read/write.
let cursor = 2       ' Cursor position (0-1 for value, 2-5 for address).
let w                ' Temporary variables for address manipulation.
let x
let y
let z
gosub LoadAddr       ' Load previously saved address from file.

' Draw title bar and UI elements.
locate 0, 0
print "%c", 28;
for i = 0 to 17
  print "%c", 14;
next
print "%c", 29;
print "%c RAM MON-GB BASIC %c", 15, 15;
print "%c", 30;
for i = 0 to 17
  print "%c", 14;
next
print "%c", 31;

locate 0, 4
print " ADDR   VAL"

locate 0, 13
print " %c,%c to move cursor", 4, 3
print " %c,%c to modify", 1, 2
print " A to read"
print " B to write"

' Set up button event handlers.
on btnd(UP_BTN) gosub Up_
on btnd(DOWN_BTN) gosub Down_
on btnd(LEFT_BTN) gosub Left_
on btnd(RIGHT_BTN) gosub Right_
on btnd(A_BTN) gosub A_
on btnd(B_BTN) gosub B_

' Main program loop.
gosub ShowCursor
gosub RefreshAddr
gosub RefreshVal
gosub RefreshDeviceRegisters

loop:
  update
  goto loop

' Refresh the device registers.
RefreshDeviceRegisters:
  ' The CPU register.
  x = addressof("_cpu")
  y = peek(x)
  locate 1, 10
  print "%x", x
  locate 5, 10
  print "%x, ", y
  locate 5, 10
  print ": "
  ' The GBA register.
  x = addressof("_is_GBA")
  y = peek(x)
  locate 11, 10
  print "%x", x
  locate 15, 10
  print "%x", y
  locate 15, 10
  print ": "
  ' The device type register.
  x = addressof("device_type")
  y = peek(x)
  locate 1, 11
  print "%x", x
  locate 5, 11
  print "%x", y
  locate 5, 11
  print ": "
  ' Query device type.
  locate 11, 11
  if query IS_GBB then
    if query IS_AGB then
      print "GBB(A)"
    else if query IS_CGB then
      print "GBB(C)"
    else if query IS_SGB then
      print "GBB(S)"
    else
      print "GBB"
    end if
  else if query IS_AGB then
    print "AGB"
  else if query IS_CGB then
    print "CGB"
  else if query IS_SGB then
    print "SGB"
  else
    print "GB"
  end if

  return

' Hide the cursor at current position.
HideCursor:
  if cursor <= 1 then ' Modifying value.
    x = 9 - cursor
  else ' Modifying address.
    x = 6 - cursor
  end if
  locate x, 5
  print " "
  locate x, 7
  print " "
  return
' Show the cursor at current position.
ShowCursor:
  if cursor <= 1 then ' Modifying value.
    x = 9 - cursor
  else ' Modifying address.
    x = 6 - cursor
  end if
  locate x, 5
  print "%c", 1
  locate x, 7
  print "%c", 2
  return

' Refresh the address display and identify memory region.
RefreshAddr:
  locate 1, 6
  print "%x", addr
  locate 1, 8
  print "                   ";
  locate 1, 8
  readonly = false
  if addr >= 0x0000 and addr <= 0x3fff then
    print "16KB ROM bank 0"
    readonly = true
  else if addr >= 0x4000 and addr <= 0x7fff then
    print "16KB ROM bank n"
    readonly = true
  else if addr >= 0x8000 and addr <= 0x9fff then
    print "8KB VRAM"
  else if addr >= 0xa000 and addr <= 0xbfff then
    print "8KB SRAM"
  else if addr >= 0xc000 and addr <= 0xcfff then
    print "4KB WRAM 0"
  else if addr >= 0xd000 and addr <= 0xdfff then
    print "4KB WRAM n"
  else if addr >= 0xe000 and addr <= 0xfdff then
    print "Echo RAM(C000-DDFF)";
  else if addr >= 0xfe00 and addr <= 0xfe9f then
    print "OAM";
  ' ... Begin of extension memory region checks ...
  else if addr = 0xfea0 then
    print "Ext. EXTF"
  else if addr = 0xfea1 then
    print "Ext. PLTF"
  else if addr = 0xfea2 then
    print "Ext. LOCF"
  else if addr = 0xfea3 then
    print "Ext. Reserved"
  else if addr = 0xfea4 then
    print "Ext. TCHX"
  else if addr = 0xfea5 then
    print "Ext. TCHY"
  else if addr = 0xfea6 then
    print "Ext. TCHF"
  else if addr = 0xfea7 then
    print "Ext. Reserved"
  else if addr = 0xfea8 then
    print "Ext. KEYM"
  else if addr = 0xfea9 then
    print "Ext. KEYC"
  else if addr >= 0xfeaa and addr <= 0xfeab then
    print "Ext. Reserved"
  else if addr = 0xfeac then
    print "Ext. STMF"
  else if addr = 0xfead then
    print "Ext. STMB"
  else if addr = 0xfeae then
    print "Ext. Reserved"
  else if addr = 0xfeaf then
    print "Ext. TRSF"
  else if addr >= 0xfeb0 and addr <= 0xfeef then
    print "Ext. TRSC"
  else if addr >= 0xfef0 and addr <= 0xfeff then
    print "Ext. Reserved"
  ' ... End of extension memory region checks ...
  else if addr = 0xff40 then
    print "LCDC"
    readonly = true
  else if addr >= 0xff00 and addr <= 0xff7f then
    print "I/O registers"
  else if addr >= 0xff80 and addr <= 0xfffe then
    print "HRAM"
  else if addr = 0xffff then
    print "IE"
  else
    print "Unknown"
    readonly = true
  end if
  locate 11, 6
  if readonly then
    print "Readonly"
  else
    print "        "
  end if
  return
' Refresh the value display in hexadecimal.
RefreshVal:
  x = value band 0x0f            ' Get lower nibble.
  y = (value band 0xf0) rshift 4 ' Get upper nibble.
  locate 8, 6
  if y <= 9 then
    print "%c", 48 + y;
  else
    print "%c", 55 + y;
  end if
  if x <= 9 then
    print "%c", 48 + x;
  else
    print "%c", 55 + x;
  end if
  return

' Load address from file.
LoadAddr:
  fopen 0
    x = fread 0, 0
    y = fread 0, 1
    z = fread 0, 2
    addr = y + (z lshift 8)
  fclose 0
  if not x then
    addr = 0xc000 ' Default if file doesn't exist.
  end if
  return
' Save address to file.
SaveAddr:
  fopen 0
    fwrite 0, 0, 1
    y = addr band 0xff
    z = (addr band 0xff00) rshift 8
    fwrite 0, 1, y
    fwrite 0, 2, z
  fclose 0
  return

' Handle Up button - increment value at cursor position.
Up_:
  select case cursor
    case 0 ' Lower nibble of value.
      x = value band 0x0f
      y = value band 0xf0
      x = x + 1
      if x > 15 then
        x = 0
      end if
      value = x bor y
      gosub RefreshVal
    case 1 ' Upper nibble of value.
      x = value band 0x0f
      y = (value band 0xf0) rshift 4
      y = y + 1
      if y > 15 then
        y = 0
      end if
      value = x bor (y lshift 4)
      gosub RefreshVal
    ' ... Cases for address nibbles ...
    case 2
      w = addr band 0x000f
      x = addr band 0x00f0
      y = addr band 0x0f00
      z = addr band 0xf000
      w = w + 1
      if w > 15 then
        w = 0
      end if
      addr = w bor x bor y bor z
      gosub RefreshAddr
    case 3
      w = addr band 0x000f
      x = (addr band 0x00f0) rshift 4
      y = addr band 0x0f00
      z = addr band 0xf000
      x = x + 1
      if x > 15 then
        x = 0
      end if
      addr = w bor (x lshift 4) bor y bor z
      gosub RefreshAddr
    case 4
      w = addr band 0x000f
      x = addr band 0x00f0
      y = (addr band 0x0f00) rshift 8
      z = addr band 0xf000
      y = y + 1
      if y > 15 then
        y = 0
      end if
      addr = w bor x bor (y lshift 8) bor z
      gosub RefreshAddr
    case 5
      w = addr band 0x000f
      x = addr band 0x00f0
      y = addr band 0x0f00
      z = ((addr band 0xf000) rshift 12) band 0x000f
      z = z + 1
      if z > 15 then
        z = 0
      end if
      addr = w bor x bor y bor (z lshift 12)
      gosub RefreshAddr
  end select
  return
' Handle Down button - decrement value at cursor position.
Down_:
  select case cursor
    case 0 ' Lower nibble of value.
      x = value band 0xf0
      y = value band 0x0f
      y = y - 1
      if y < 0 then
        y = 15
      end if
      value = x bor y
      gosub RefreshVal
    case 1 ' Upper nibble of value.
      x = (value band 0xf0) rshift 4
      y = value band 0x0f
      x = x - 1
      if x < 0 then
        x = 15
      end if
      value = (x lshift 4) bor y
      gosub RefreshVal
    ' ... Cases for address nibbles ...
    case 2
      w = addr band 0x000f
      x = addr band 0x00f0
      y = addr band 0x0f00
      z = addr band 0xf000
      w = w - 1
      if w < 0 then
        w = 15
      end if
      addr = w bor x bor y bor z
      gosub RefreshAddr
    case 3
      w = addr band 0x000f
      x = (addr band 0x00f0) rshift 4
      y = addr band 0x0f00
      z = addr band 0xf000
      x = x - 1
      if x < 0 then
        x = 15
      end if
      addr = w bor (x lshift 4) bor y bor z
      gosub RefreshAddr
    case 4
      w = addr band 0x000f
      x = addr band 0x00f0
      y = (addr band 0x0f00) rshift 8
      z = addr band 0xf000
      y = y - 1
      if y < 0 then
        y = 15
      end if
      addr = w bor x bor (y lshift 8) bor z
      gosub RefreshAddr
    case 5
      w = addr band 0x000f
      x = addr band 0x00f0
      y = addr band 0x0f00
      z = ((addr band 0xf000) rshift 12) band 0x000f
      z = z - 1
      if z < 0 then
        z = 15
      end if
      addr = w bor x bor y bor (z lshift 12)
      gosub RefreshAddr
  end select
  return
' Handle Left button - move cursor left.
Left_:
  gosub HideCursor
  cursor = cursor + 1
  if cursor > 5 then
    cursor = 0
  end if
  gosub ShowCursor
  return
' Handle Right button - move cursor right.
Right_:
  gosub HideCursor
  cursor = cursor - 1
  if cursor < 0 then
    cursor = 5
  end if
  gosub ShowCursor
  return
' Handle A button - read value from memory.
A_:
  value = peek(addr)
  gosub RefreshVal
  gosub SaveAddr
  return
' Handle B button - write value to memory.
B_:
  if readonly then
    return ' Don't write to read-only memory.
  end if
  poke(addr, value)
  value = peek(addr) ' Read back to confirm.
  gosub RefreshVal
  gosub SaveAddr
  return
```
