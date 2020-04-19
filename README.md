# Diablo II • Median XL • Linux
**No wine required**

First of all I would like to thank the Median XL team for the great work! This zenity shell script downloads the latest Median XL mod and save this files locally. After that you can simple patch your Diablo II with this script to work with the latest Median XL version. The patch also includes Sven's glide wrapper.

![d2launcher main](https://raw.githubusercontent.com/murkl/d2launcher/master/res/screenshots/menu.png)
![d2launcher patches](https://raw.githubusercontent.com/murkl/d2launcher/master/res/screenshots/patches.png)

## Features
* Standalone (no wine required)
* Downloads latest Median XL patch
* Includes Sven's Glide wrapper
* Import/Export of savegames

## Dependencies
You will need a Diablo II installation to work

### Arch
```
sudo pacman -S p7zip jq
```
### Debian/Ubuntu/elementaryOS
```
sudo apt install -y p7zip jq
```

## Run the script
```
./d2launcher
```
