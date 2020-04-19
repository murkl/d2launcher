# Diablo II • Median XL • Standalone
**No wine installation required!**

First of all I would like to thank the Median XL team for the great work! This zenity shell script downloads a wine standalone version and the latest Median XL mod and save this files locally. After that you can simple patch your Diablo II with this script to work with the latest Median XL version. The patch also includes Sven's glide wrapper.

Enjoy the simplicity :)

![d2launcher main](https://raw.githubusercontent.com/murkl/d2launcher/master/res/screenshots/screenshot-menu.png)
![d2launcher patches](https://raw.githubusercontent.com/murkl/d2launcher/master/res/screenshots/screenshot-patches.png)

## Features
* Standalone (no wine installation required)
* Downloads latest Median XL patch
* Import/Export of savegames
* Sven's Glide wrapper included
* Diablo II 1.13c files to work with Median XL included

## Dependencies
You will need a Diablo II installation. The script will ask for your for the location.

### Arch
```
sudo pacman -S p7zip jq
```
### Debian/Ubuntu/elementaryOS
```
sudo apt install -y p7zip jq
```

## Run the script
On first execute you will ask for the Diablo II installtion dir and a promt to download wine standalone will appears.
```
./d2launcher
```
