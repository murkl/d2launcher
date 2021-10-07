<div align="center">
  <h1>Diablo II • Median XL Launcher</h1>
  <p><b>The userfriendly Mod Launcher</b></p>
  <div><a href="https://github.com/murkl/d2launcher/releases/latest"><b>Download</b></a></div>
  <div><img src="https://raw.githubusercontent.com/murkl/d2launcher/master/res/screenshot.png" /></div>
  <p><img src="https://img.shields.io/badge/MAINTAINED-YES-green?style=for-the-badge" /></p>
</div>

# Features

- Custom proton (64 Bit) build will download by script
- Sandbox architecture
- Leightweight
- Download latest Median XL patch (incl. notification on new updates)
- Median XL version management
- Import/Export of savegames
- D2 Stats included (will download by script)
- Sven's Glide wrapper included
- Diablo II 1.13c files to work with Median XL included
- Updater (incl. notification on new updates)
- Configuration of every script variable
- 100% GUI

# Dependencies

You will need a Diablo II installation to work! (the script will ask you for the location)

```
# Arch
sudo pacman -S wine zenity curl p7zip unrar jq wmctrl fuse2 zip xdelta3

# Debian/Ubuntu/elementaryOS
sudo apt install wine zenity curl p7zip-full unrar jq wmctrl fuse2 xdelta3

# Pop_OS!
sudo apt install wine zenity curl p7zip-full unrar jq wmctrl fuse2 ruby-notify xdelta3
```

# Run

```
./d2launcher
```

# Documentation

## Using D2Stats

It's nessesary to start D2Stats (Statistics) in d2launcher first, before starting Diablo II. Because d2launcher will check every start of Diablo II (using pgrep) if D2Stats is running. In this case, d2launcher starts Diablo II automatically with [sigma-loader](https://github.com/SyndromeDayna/diablo-2-median-xl-sigma-loader).

## Custom Configuration

You can override the script properties in the configuration settings.

### Change Download URL's

```
wine_native_url="https://github.com/Kron4ek/Wine-Builds/releases/download/6.3-7-proton/wine-6.3-7-proton-amd64.tar.xz"
d2_stats_url="https://github.com/Kyromyr/D2Stats/releases/download/3.11.1/D2Stats-3.11.1.rar"
d2_sigma_loader_url="https://github.com/SyndromeDayna/diablo-2-median-xl-sigma-loader/releases/download/3/sigma-loader.exe"
```

### Change Theming

```
gui_width="360"
gui_height="280"
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
wine_default="/path/to/your/custom/wine"
wineprefix="$HOME/my/custom/wine_prefix"
```
