# Diablo II • Median XL • Standalone

**No wine installation required!**

First of all I would like to thank the Median XL team for the great work! This zenity shell script downloads a wine standalone version and the latest Median XL mod and save this files locally. After that you can simple patch your Diablo II with this script to work with the latest Median XL version. The patch also includes Sven's glide wrapper.

Enjoy the simplicity :)

![d2launcher screenshot](https://raw.githubusercontent.com/murkl/d2launcher/master/res/screenshot.png)

## Features
* No wine installation required (wine AppImage will download by script)
* Download latest Median XL patch
* Median XL version management
* Import/Export of savegames
* D2 Stats included (will download by script)
* Sven's Glide wrapper included
* Diablo II 1.13c files to work with Median XL included
* Update feature (incl. notification)
* Configuration of every script variable
* 100% GUI

## Example Configuration
```
d2_binary_dir="/home/$USER/.local/apps/diablo2"
d2_exec="Diablo II.exe"
d2_args="-3dfx"
wine5_enabled=true
gui_width=465
gui_height=365
desktop_icon=true
update_check=true
```

## Dependencies
You will need a Diablo II installation! The script will ask for your for the location (d2_binary_dir).

### Arch
```
sudo pacman -S zenity p7zip unrar jq wmctrl
```

### Debian/Ubuntu/elementaryOS
```
sudo apt install zenity p7zip unrar jq wmctrl
```

## Run the script
On first execution you will ask for the Diablo II installation dir (d2_binary_dir).
```
./d2launcher
```
