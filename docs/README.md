<div align="center">
  <h1>Diablo II • Median XL • Launcher</h1>
  <div><a href="https://github.com/murkl/d2launcher/releases/latest"><b>Download</b></a></div>
  <div><img src="./screenshot.png" /></div>
  <p><img src="https://img.shields.io/badge/MAINTAINED-YES-green?style=for-the-badge" /></p>
</div>

# Features

- Custom Proton (64 Bit) build will download by script
- Download latest Median XL patch (incl. notification on new updates)
- Median XL Version Management
- Import/Export of savegames
- D2 Stats included (will download by script)
- Sven's Glide wrapper included
- cnc-ddraw supported
- Diablo II 1.13c files to work with Median XL included
- Updater (incl. notification on new updates)
- Configuration of Script Properties
- 100% GUI

# Installation

You will need a Diablo II installation to work! (the script will ask you for the location)

## Arch Linux

- Install from AUR
  - `aur/d2launcher`

## Debian/Ubuntu/elementaryOS

- Download & Extract: <a href="https://github.com/murkl/d2launcher/releases/latest"><b>d2launcher.tar.gz</b></a>
- Install Dependencies
  - `sudo apt install wine zenity curl p7zip-full unrar jq wmctrl fuse2 xdelta3`
- Run
  - `./d2launcher`

## Pop_OS!

- Download & Extract: <a href="https://github.com/murkl/d2launcher/releases/latest"><b>d2launcher.tar.gz</b></a>
- Install Dependencies
  - `sudo apt install wine zenity curl p7zip-full unrar jq wmctrl fuse2 ruby-notify xdelta3`
- Run
  - `./d2launcher`

# Documentation

You can override the script properties in the configuration settings. All files are located here: `~/.d2launcher`

## Example config

```
d2_dir="~/.d2launcher/bin/diablo2"
d2_exe="Diablo II.exe"
d2_args="-ddraw"
wine_init="gamemoderun"
d2_stats_tray="true"
update_check="true"
mxl_update_check="true"
gui_width="420"
gui_height="320"
```

## Change Download URL's

```
wine_native_url="https://github.com/Kron4ek/Wine-Builds/releases/download/6.3-7-proton/wine-6.3-7-proton-amd64.tar.xz"
d2_stats_url="https://github.com/Kyromyr/D2Stats/releases/download/3.11.4/D2Stats-3.11.4.rar"
d2_sigma_loader_url="https://github.com/SyndromeDayna/diablo-2-median-xl-sigma-loader/releases/download/3/sigma-loader.exe"
```

**Note:** If you change the URLs, you have to force the regarding update in d2launcher (Update Manger --> Force Proton Update/Force D2Stats Update)

## Custom Wine Version

If you use Wine you have to set `wine_user="$USER"` otherwise for Proton set to `wine_user="steamuser"`

```
wine_default="/path/to/your/custom/wine"
wineprefix="$HOME/my/custom/wine_prefix"
wine_user="steamuser"
```

## Theming

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

## Using D2Stats

It's nessesary to start D2Stats (Statistics) in d2launcher first, before starting Diablo II. Because d2launcher will check every start of Diablo II (using pgrep) if D2Stats is running. In this case, d2launcher starts Diablo II automatically with [sigma-loader](https://github.com/SyndromeDayna/diablo-2-median-xl-sigma-loader).

## Using cnc-ddraw

1. Download latest [cnc-ddraw.zip](https://github.com/FunkyFr3sh/cnc-ddraw/releases)
2. Follow [install instruction](https://github.com/murkl/d2launcher/issues/8#issuecomment-1553762919)

## Using Game Mode

Install the `gamemode` package in your system and add this property in d2launcher settings:

```
wine_init="gamemoderun"
```

## Diablo II arguments

```
Enable Glide wrapper       | -3dfx
Window mode                | -w
Skip to Median XL Login    | -skiptobnet
No sound                   | -ns
```

## Glide Wrapper Settings

```
┌────────────────────────────────────────────────────────┐
│ Glide Wrapper Settings                                 │
└────────────────────────────────────────────────────────┘
☐          window mode
☑          capture mouse
☐          keep aspect ratio
☐          vertical synchronization (VSYNC)
no         fps-limit
no         static size
☐          window extras
auto       refreshrate
☑          desktopresolution

┌────────────────────────────────────────────────────────┐
│ Glide Wrapper Renderer                                 │
└────────────────────────────────────────────────────────┘
32 MB      texture-memory
1024x1024  buffer-texture-size
☑          32 bit rendering
☑          texture for videos
☑          bilinear filtering
☑          supersampling
☑          shader-gamma
☐          no gamma
☑          keep desktop composition

┌────────────────────────────────────────────────────────┐
│ Glide Wrapper Extensions                               │
└────────────────────────────────────────────────────────┘
☑          GL_EXT_vertex_array
☑          GL_ATI_fragment_shader
☑          GL_ARB_fragment_program
☑          GL_EXT_paletted_texture
☑          GL_EXT_shared_texture_palette
☑          GL_EXT_packed_pixels
☑          GL_EXT_texture_env_combine
☑          WGL_EXT_swap_control
☑          WGL_ARB_render_texture
```

# External Sources

- https://median-xl.com
- https://github.com/Kron4ek/Wine-Builds/
- https://github.com/Kyromyr/D2Stats
- https://github.com/SyndromeDayna/diablo-2-median-xl-sigma-loader
- https://github.com/synthagency/icons-flat-osx
- http://www.svenswrapper.de
- https://github.com/FunkyFr3sh/cnc-ddraw
