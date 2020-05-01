# Diablo II • Median XL • Standalone

**No wine installation required!**

First of all I would like to thank the Median XL team for the great work! This zenity shell script downloads a wine standalone version and the latest Median XL mod and save this files locally. After that you can simple patch your Diablo II with this script to work with the latest Median XL version. The patch also includes Sven's glide wrapper.

Enjoy the simplicity :)

![d2launcher menu](https://raw.githubusercontent.com/murkl/d2launcher/master/res/screenshots/menu.png)
![d2launcher patches](https://raw.githubusercontent.com/murkl/d2launcher/master/res/screenshots/patches.png)
![d2launcher configuration](https://raw.githubusercontent.com/murkl/d2launcher/master/res/screenshots/configuration.png)
![d2launcher help](https://raw.githubusercontent.com/murkl/d2launcher/master/res/screenshots/help.png)

## Features
* Standalone (no wine installation required)
* Downloads latest Median XL patch
* Median XL version management
* Import/Export of savegames
* D2 Stats included
* Sven's Glide wrapper included
* Diablo II 1.13c files to work with Median XL included

## Example Configuration
```
d2_binary_dir="/home/$USER/.local/apps/diablo2"
d2_exec="Diablo II.exe"
d2_args="-3dfx"
wine5_enabled=true
gui_height=333
gui_width=432
desktop_icon=true
update_check=true
```

## Dependencies
You will need a Diablo II installation. The script will ask for your for the location.

### Arch
```
sudo pacman -S zenity p7zip unrar jq wmctrl
```

### Debian/Ubuntu/elementaryOS
```
sudo apt install zenity p7zip unrar jq wmctrl
```

## Run the script
On first execution you will ask for the Diablo II installtion dir.

```
./d2launcher
```
