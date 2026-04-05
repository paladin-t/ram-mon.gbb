@echo off
echo Building, a moment please...

REM Prepare environment.
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)

REM To clear build cache only.
if "%1"=="clear" (
  echo Cleaning build artifacts...
  if exist "temp" rmdir /s /q "temp"
  del "for_ram_mon.gb" 2>nul
  del "for_ram_mon.sym" 2>nul
  echo Clean done.
  exit /b 0
)

REM Get the build options.
set rebuild=0
if "%1"=="/y" (
  set rebuild=1
  echo Rebuild all.
  goto :BLD
) else (
if "%1"=="/n" (
  echo Not rebuild all.
  goto :BLD
)
)
set rebuild=1
set /p i="Rebuild all? [y/n]"
if "%i%" neq "y" set rebuild=0
:BLD
set withcrashhandler=1

REM Set the variables.
if "%gbdk%"=="" set gbdk=gbdk\win\bin

set main=main
set bootstrap=bootstrap
set builtin=builtin

set macros=-DVM_TOTAL_CONTEXT_STACK_SIZE=1024 -DVM_MAX_CONTEXTS=16 -DVM_HEAP_SIZE=1024
set cflag=-Wf"--max-allocs-per-node 50000" -Wf"--opt-code-speed" %macros% -Wf-Isrc -Wa-Isrc -Wa-Isrc\drv\hUGE\player-gbdk

set libs=-Wl-lsrc\drv\hUGE\lib\hUGEDriver.lib -Wl-ksrc\drv\hUGE\lib
set carty=-Wl-yt0x1b -Wm-yc
set nbanks=-Wl-yo16 -Wm-ya16 -autobank
set symbols=-Wl-j -Wl-m -Wl-w -Wm-yS
set lflag=%libs% %carty% %nbanks% %symbols%

REM Build.
call :COLOR 2F "Building..."
if not exist "temp" (
  mkdir "temp"
)
if %rebuild%==1 (
  call :COLOR 3F "1. Compile the libs..."
  call %gbdk%\lcc.exe %cflag% -c -o "temp\exception.o" "src\utils\exception.c"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\font.o" "src\utils\font.s"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\graphics.o" "src\utils\graphics.s"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\scroll.o" "src\utils\scroll.s"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\sfx_player.o" "src\utils\sfx_player.c"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\sgb.o" "src\utils\sgb.c"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\sleep.o" "src\utils\sleep.s"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\text.o" "src\utils\text.c"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\timer_handler.o" "src\utils\timer_handler.s"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\utils.o" "src\utils\utils.c"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\utils_banked.o" "src\utils\utils_banked.c"
  if %withcrashhandler%==1 (
    call %gbdk%\lcc.exe %cflag% -c -o "temp\crash_handler.o" "src\utils\crash_handler.s"
  )
  echo Ok.
  @echo,
) else (
  call :COLOR 3F "1. Ignore compiling the libs..."
  echo Ok.
  @echo,
)

if %rebuild%==1 (
  call :COLOR 3F "2. Compile the controllers..."
  call %gbdk%\lcc.exe %cflag% -c -o "temp\controller.o" "src\ctrl\controller.c"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\navigation.o" "src\ctrl\navigation.c"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\platformer.o" "src\ctrl\platformer.c"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\pointnclick.o" "src\ctrl\pointnclick.c"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\topdown.o" "src\ctrl\topdown.c"
  echo Ok.
  @echo,
) else (
  call :COLOR 3F "2. Ignore compiling the controllers..."
  echo Ok.
  @echo,
)

call :COLOR 3F "3. Compile the VM..."
@echo on
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm.o" "src\vm.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_actor.o" "src\vm_actor.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_actor_aux.o" "src\vm_actor_aux.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_audio.o" "src\vm_audio.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_device.o" "src\vm_device.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_device_ext.o" "src\vm_device_ext.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_effects.o" "src\vm_effects.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_emote.o" "src\vm_emote.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_game.o" "src\vm_game.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_graphics.o" "src\vm_graphics.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_gui.o" "src\vm_gui.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_gui_label.o" "src\vm_gui_label.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_gui_menu.o" "src\vm_gui_menu.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_gui_progressbar.o" "src\vm_gui_progressbar.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_input.o" "src\vm_input.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_memory.o" "src\vm_memory.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_native.o" "src\vm_native.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_object.o" "src\vm_object.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_persistence.o" "src\vm_persistence.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_physics.o" "src\vm_physics.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_projectile.o" "src\vm_projectile.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_scene.o" "src\vm_scene.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_scroll.o" "src\vm_scroll.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_serial.o" "src\vm_serial.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_system.o" "src\vm_system.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_trigger.o" "src\vm_trigger.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\vm_instructions.o" "src\vm_instructions.c"
call %gbdk%\lcc.exe %cflag% -c -o "temp\%main%.o" "src\%main%.c"
@echo off
echo Ok.
@echo,

if %rebuild%==1 (
  call :COLOR 3F "4. Compile the data..."
  call %gbdk%\lcc.exe %cflag% -c -o "temp\%bootstrap%.o" "src\data\%bootstrap%.s"
  call %gbdk%\lcc.exe %cflag% -c -o "temp\%builtin%.o" "src\data\%builtin%.c"
  echo Ok.
  @echo,
) else (
  call :COLOR 3F "4. Ignore compiling the data..."
  echo Ok.
  @echo,
)

call :COLOR 3F "5. Link..."
set libobj=^
  "temp\exception.o" ^
  "temp\font.o" ^
  "temp\graphics.o" ^
  "temp\scroll.o" ^
  "temp\sfx_player.o" ^
  "temp\sgb.o" ^
  "temp\sleep.o" ^
  "temp\text.o" ^
  "temp\timer_handler.o" ^
  "temp\utils.o" ^
  "temp\utils_banked.o"
if %withcrashhandler%==1 (
  set libobj=%libobj% "temp\crash_handler.o"
)
set ctrlobj=^
  "temp\controller.o" ^
  "temp\navigation.o" ^
  "temp\platformer.o" ^
  "temp\pointnclick.o" ^
  "temp\topdown.o"
set dataobj="temp\%bootstrap%.o" ^
  "temp\%builtin%.o"
@echo on
call %gbdk%\lcc.exe %lflag% -o "temp\gbbvm.gb" ^
  %libobj% ^
  %ctrlobj% ^
  "temp\vm.o" ^
  "temp\vm_actor.o" ^
  "temp\vm_actor_aux.o" ^
  "temp\vm_audio.o" ^
  "temp\vm_device.o" ^
  "temp\vm_device_ext.o" ^
  "temp\vm_effects.o" ^
  "temp\vm_emote.o" ^
  "temp\vm_game.o" ^
  "temp\vm_graphics.o" ^
  "temp\vm_gui.o" ^
  "temp\vm_gui_label.o" ^
  "temp\vm_gui_menu.o" ^
  "temp\vm_gui_progressbar.o" ^
  "temp\vm_input.o" ^
  "temp\vm_memory.o" ^
  "temp\vm_native.o" ^
  "temp\vm_object.o" ^
  "temp\vm_persistence.o" ^
  "temp\vm_physics.o" ^
  "temp\vm_projectile.o" ^
  "temp\vm_scene.o" ^
  "temp\vm_scroll.o" ^
  "temp\vm_serial.o" ^
  "temp\vm_system.o" ^
  "temp\vm_trigger.o" ^
  "temp\vm_instructions.o" ^
  "temp\%main%.o" ^
  %dataobj%
@echo off
echo Ok.
@echo,

REM Copy.
call :COLOR 2F "Copying..."
if exist "temp\gbbvm.gb" (
  xcopy /y "temp\gbbvm.gb" "for_ram_mon.*"
  xcopy /y "temp\gbbvm.sym" "for_ram_mon.*"
) else (
  echo gbbvm.gb doesn't exist.
)
echo Ok.
@echo,

REM Finish.
echo Building done!
goto :eof

REM Colorizer.
:COLOR
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
echo.
goto :eof

exit /b 0
