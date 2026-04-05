#!/bin/bash
echo "Building, a moment please..."

# Prepare environment.
if [ -z "$gbdk" ]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    gbdk="gbdk/mac/bin"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    gbdk="gbdk/linux/bin"
  else
    echo "Unsupported OS: $OSTYPE"
    exit 1
  fi
fi

# Colorizer.
color_echo() {
  local color=$1
  local message=$2
  local reset='\033[0m'

  case $color in
    "2F")
      echo -e "\033[42;37m${message}${reset}"
      ;;
    "3F")
      echo -e "\033[46;37m${message}${reset}"
      ;;
    *)
      echo -e "${message}"
      ;;
  esac
}

# To clear build cache only.
if [ "$1" == "clear" ]; then
  echo "Cleaning build artifacts..."
  rm -rf "temp"
  rm -f "for_ram_mon.gb" "for_ram_mon.sym"
  echo "Clean done."
  exit 0
fi

# Get the build options.
rebuild=1
if [ "$1" = "/y" ]; then
  echo "Rebuild all."
elif [ "$1" = "/n" ]; then
  rebuild=0
  echo "Not rebuild all."
else
  read -p "Rebuild all? [y/n] " i
  if [ "$i" != "y" ]; then
    rebuild=0
  fi
fi

withcrashhandler=1

# Set the variables.
main="main"
bootstrap="bootstrap"
builtin="builtin"

macros="-DVM_TOTAL_CONTEXT_STACK_SIZE=1024 -DVM_MAX_CONTEXTS=16 -DVM_HEAP_SIZE=1024"
cflag="-Wf\"--max-allocs-per-node 50000\" -Wf\"--opt-code-speed\" $macros -Wf-Isrc -Wa-Isrc -Wa-Isrc/drv/hUGE/player-gbdk"

libs="-Wl-lsrc/drv/hUGE/lib/hUGEDriver.lib -Wl-ksrc/drv/hUGE/lib"
carty="-Wl-yt0x1b -Wm-yc"
nbanks="-Wl-yo16 -Wm-ya16 -autobank"
symbols="-Wl-j -Wl-m -Wl-w -Wm-yS"
lflag="$libs $carty $nbanks $symbols"

# Build.
color_echo "2F" "Building..."
mkdir -p "temp"

if [ $rebuild -eq 1 ]; then
  color_echo "3F" "1. Compile the libs..."
  "$gbdk/lcc" $cflag -c -o "temp/exception.o" "src/utils/exception.c"
  "$gbdk/lcc" $cflag -c -o "temp/font.o" "src/utils/font.s"
  "$gbdk/lcc" $cflag -c -o "temp/graphics.o" "src/utils/graphics.s"
  "$gbdk/lcc" $cflag -c -o "temp/scroll.o" "src/utils/scroll.s"
  "$gbdk/lcc" $cflag -c -o "temp/sfx_player.o" "src/utils/sfx_player.c"
  "$gbdk/lcc" $cflag -c -o "temp/sgb.o" "src/utils/sgb.c"
  "$gbdk/lcc" $cflag -c -o "temp/sleep.o" "src/utils/sleep.s"
  "$gbdk/lcc" $cflag -c -o "temp/text.o" "src/utils/text.c"
  "$gbdk/lcc" $cflag -c -o "temp/timer_handler.o" "src/utils/timer_handler.s"
  "$gbdk/lcc" $cflag -c -o "temp/utils.o" "src/utils/utils.c"
  "$gbdk/lcc" $cflag -c -o "temp/utils_banked.o" "src/utils/utils_banked.c"

  if [ $withcrashhandler -eq 1 ]; then
    "$gbdk/lcc" $cflag -c -o "temp/crash_handler.o" "src/utils/crash_handler.s"
  fi
  echo "Ok."
  echo
else
  color_echo "3F" "1. Ignore compiling the libs..."
  echo "Ok."
  echo
fi

if [ $rebuild -eq 1 ]; then
  color_echo "3F" "2. Compile the controllers..."
  "$gbdk/lcc" $cflag -c -o "temp/controller.o" "src/ctrl/controller.c"
  "$gbdk/lcc" $cflag -c -o "temp/navigation.o" "src/ctrl/navigation.c"
  "$gbdk/lcc" $cflag -c -o "temp/platformer.o" "src/ctrl/platformer.c"
  "$gbdk/lcc" $cflag -c -o "temp/pointnclick.o" "src/ctrl/pointnclick.c"
  "$gbdk/lcc" $cflag -c -o "temp/topdown.o" "src/ctrl/topdown.c"
  echo "Ok."
  echo
else
  color_echo "3F" "2. Ignore compiling the controllers..."
  echo "Ok."
  echo
fi

color_echo "3F" "3. Compile the VM..."
set -x
"$gbdk/lcc" $cflag -c -o "temp/vm.o" "src/vm.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_actor.o" "src/vm_actor.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_actor_aux.o" "src/vm_actor_aux.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_audio.o" "src/vm_audio.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_device.o" "src/vm_device.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_device_ext.o" "src/vm_device_ext.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_effects.o" "src/vm_effects.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_emote.o" "src/vm_emote.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_game.o" "src/vm_game.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_graphics.o" "src/vm_graphics.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_gui.o" "src/vm_gui.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_gui_label.o" "src/vm_gui_label.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_gui_menu.o" "src/vm_gui_menu.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_gui_progressbar.o" "src/vm_gui_progressbar.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_input.o" "src/vm_input.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_memory.o" "src/vm_memory.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_native.o" "src/vm_native.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_object.o" "src/vm_object.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_persistence.o" "src/vm_persistence.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_physics.o" "src/vm_physics.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_projectile.o" "src/vm_projectile.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_scene.o" "src/vm_scene.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_scroll.o" "src/vm_scroll.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_serial.o" "src/vm_serial.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_system.o" "src/vm_system.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_trigger.o" "src/vm_trigger.c"
"$gbdk/lcc" $cflag -c -o "temp/vm_instructions.o" "src/vm_instructions.c"
"$gbdk/lcc" $cflag -c -o "temp/${main}.o" "src/${main}.c"
set +x
echo "Ok."
echo

if [ $rebuild -eq 1 ]; then
  color_echo "3F" "4. Compile the data..."
  "$gbdk/lcc" $cflag -c -o "temp/${bootstrap}.o" "src/data/${bootstrap}.s"
  "$gbdk/lcc" $cflag -c -o "temp/${builtin}.o" "src/data/${builtin}.c"
  echo "Ok."
  echo
else
  color_echo "3F" "4. Ignore compiling the data..."
  echo "Ok."
  echo
fi

color_echo "3F" "5. Link..."
libobj=(
  "temp/exception.o"
  "temp/font.o"
  "temp/graphics.o"
  "temp/scroll.o"
  "temp/sfx_player.o"
  "temp/sgb.o"
  "temp/sleep.o"
  "temp/text.o"
  "temp/timer_handler.o"
  "temp/utils.o"
  "temp/utils_banked.o"
)

if [ $withcrashhandler -eq 1 ]; then
  libobj+=("temp/crash_handler.o")
fi

ctrlobj=(
  "temp/controller.o"
  "temp/navigation.o"
  "temp/platformer.o"
  "temp/pointnclick.o"
  "temp/topdown.o"
)

dataobj=(
  "temp/${bootstrap}.o"
  "temp/${builtin}.o"
)

set -x
"$gbdk/lcc" $lflag -o "temp/gbbvm.gb" \
  "${libobj[@]}" \
  "${ctrlobj[@]}" \
  "temp/vm.o" \
  "temp/vm_actor.o" \
  "temp/vm_actor_aux.o" \
  "temp/vm_audio.o" \
  "temp/vm_device.o" \
  "temp/vm_device_ext.o" \
  "temp/vm_effects.o" \
  "temp/vm_emote.o" \
  "temp/vm_game.o" \
  "temp/vm_graphics.o" \
  "temp/vm_gui.o" \
  "temp/vm_gui_label.o" \
  "temp/vm_gui_menu.o" \
  "temp/vm_gui_progressbar.o" \
  "temp/vm_input.o" \
  "temp/vm_memory.o" \
  "temp/vm_native.o" \
  "temp/vm_object.o" \
  "temp/vm_persistence.o" \
  "temp/vm_physics.o" \
  "temp/vm_projectile.o" \
  "temp/vm_scene.o" \
  "temp/vm_scroll.o" \
  "temp/vm_serial.o" \
  "temp/vm_system.o" \
  "temp/vm_trigger.o" \
  "temp/vm_instructions.o" \
  "temp/${main}.o" \
  "${dataobj[@]}"
set +x
echo "Ok."
echo

# Copy.
color_echo "2F" "Copying..."
if [ -f "temp/gbbvm.gb" ]; then
  mkdir -p "."
  cp "temp/gbbvm.gb" "./"
  cp "temp/gbbvm.sym" "./"
  echo "Copied successfully."
else
  echo "gbbvm.gb doesn't exist."
fi
echo "Ok."
echo

# Finish.
echo "Building done!"
exit 0
