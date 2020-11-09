# Diablo II • Median XL • Standalone

**Download: [d2launcher-latest](https://github.com/murkl/d2launcher/releases/latest)**

No wine installation required!

First of all I would like to thank the Median XL team for the great work! This zenity shell script downloads a wine standalone version and the latest Median XL mod and save this files locally. After that you can simple patch your Diablo II with this script to work with the latest Median XL version. The patch also includes Sven's glide wrapper.

Enjoy the simplicity :)

![d2launcher screenshot](https://raw.githubusercontent.com/murkl/d2launcher/master/res/screenshot.png)

## Features

- No wine installation required (wine AppImage will download by script)
- Sandbox architecture
- Leightweight & less dependencies
- Download latest Median XL patch (incl. notification on new updates)
- Median XL version management
- Import/Export of savegames
- D2 Stats included (will download by script)
- Sven's Glide wrapper included
- Diablo II 1.13c files to work with Median XL included
- Updater (incl. notification on new updates)
- Configuration of every script variable
- 100% GUI

### Using D2Stats

It's nessesary to start D2Stats (Statistics) in d2launcher first, before starting Diablo II. Because d2launcher will check every start of Diablo II (using pgrep) if D2Stats is running. In this case, d2launcher starts Diablo II automatically with [sigma-loader](https://github.com/SyndromeDayna/diablo-2-median-xl-sigma-loader).

## Custom Configuration

You can override the script properties in the configuration settings.

### Change Download URL's

```
wine4_url="https://github.com/ferion11/Wine_Appimage/releases/download/v4.21/wine-staging-linux-x86-v4.21-PlayOnLinux-x86_64.AppImage"
wine5_url="https://github.com/ferion11/Wine_Appimage/releases/download/v5.11/wine-staging-linux-x86-v5.11-PlayOnLinux-x86_64.AppImage"
d2_stats_url="https://github.com/Kyromyr/D2Stats/releases/download/3.11.1/D2Stats-3.11.1.rar"
d2_sigma_loader_url="https://github.com/SyndromeDayna/diablo-2-median-xl-sigma-loader/releases/download/3/sigma-loader.exe"
```

### Change Theming

```
gui_width="358"
gui_height="258"
gui_font="UbuntuMono Nerd Font"
gui_color="#eeeeee"
gui_size="9"
gui_dialog_width="280"
gui_dialog_height="140"
gui_dialog_font="UbuntuMono Nerd Font"
gui_dialog_color="#aaaaaa"
gui_dialog_size="9"
```

### Use custom Wine version

```
default_wine="/path/to/your/custom/wine"
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

### Pop_OS!

```
sudo apt install zenity curl p7zip-full unrar jq wmctrl fuse2 ruby-notify
```

## Run the script

```
./d2launcher
```
