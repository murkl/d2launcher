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

## Example configuration
```
d2_dir="$HOME/.local/apps/diablo2"
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

### Custom download url's
Use this properties to override the default download url's
```
d2_stats_url="https://github.com/Kyromyr/D2Stats/releases/download/3.11.1/D2Stats-3.11.1.rar"
d2_sigma_loader_url="https://github.com/SyndromeDayna/diablo-2-median-xl-sigma-loader/releases/download/3/sigma-loader.exe"
wine4_url="https://github.com/ferion11/Wine_Appimage/releases/download/v4.21/wine-staging-linux-x86-v4.21-PlayOnLinux-x86_64.AppImage"
wine5_url="https://github.com/pawitp/wine-appimage/releases/download/v5.7/wine"
```

## Dependencies
You will need a Diablo II installation to work! (the script will ask you for the location)

### Arch
```
sudo pacman -S zenity curl p7zip unrar jq wmctrl fuse2 zip
```

### Debian/Ubuntu/elementaryOS
```
sudo apt install zenity curl p7zip-full unrar jq wmctrl fuse2
```

## Run the script
```
./d2launcher
```
