# Diablo II • Median XL • Standalone

**Download: [d2launcher-latest](https://github.com/murkl/d2launcher/releases/latest)**

No wine installation required!

First of all I would like to thank the Median XL team for the great work! This zenity shell script downloads a wine standalone version and the latest Median XL mod and save this files locally. After that you can simple patch your Diablo II with this script to work with the latest Median XL version. The patch also includes Sven's glide wrapper.

Enjoy the simplicity :)

![d2launcher screenshot](https://raw.githubusercontent.com/murkl/d2launcher/master/res/screenshot.png)

## Features
* No wine installation required (wine AppImage will download by script)
* Sandbox architecture
* Leightweight & less dependencies
* Download latest Median XL patch (incl. notification on new updates)
* Median XL version management
* Import/Export of savegames
* D2 Stats included (will download by script)
* Sven's Glide wrapper included
* Diablo II 1.13c files to work with Median XL included
* Updater (incl. notification on new updates)
* Configuration of every script variable
* 100% GUI

## Example Configuration
```
d2_dir="/home/$USER/.local/apps/diablo2"
d2_exe="Diablo II.exe"
d2_args="-3dfx"
wine5_enabled=true
gui_width=465
gui_height=365
desktop_icon=true
update_check=true
mxl_update_check=true
logging_enabled=true
```

## Dependencies
You will need a Diablo II installation to work! (the script will ask you for the location)

### Arch
```
sudo pacman -S zenity curl p7zip unrar jq wmctrl
```

### Debian/Ubuntu/elementaryOS
```
sudo apt install zenity curl p7zip unrar jq wmctrl
```

## Run the script
```
./d2launcher
```
