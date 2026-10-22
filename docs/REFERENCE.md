# Reference

## Settings

**Settings › Configuration** opens `~/.d2launcher/d2launcher.conf`. A line is `setting=value` and `#` starts a comment. The first start writes each setting at its default, and a setting left out keeps it.

| Setting | Default | Meaning |
| --- | --- | --- |
| `launch_options` | `-3dfx` | The command line of Diablo II, as in Steam |
| `channel` | `public` | The Median XL channel, `public` or `beta` |
| `wine` | empty, the Wine included | A Wine of your own, such as `/usr/bin/wine` |
| `prefix` | `~/.d2launcher/wineprefix` | The Wine prefix |
| `median_xl` | `true` | Median XL on top of Diablo II |
| `d2stats` | `false` | D2Stats beside Median XL |

### Launch Options

`%command%` stands for the game, as in Steam. Without it, the options are the game's arguments.

| Launch Options | Starts |
| --- | --- |
| `-3dfx` | D2GL, which Median XL brings |
| `-ddraw` | cnc-ddraw, which Median XL brings |
| `-3dfx -w` | In a window |
| `-3dfx -skiptobnet` | At the Median XL login |
| `-3dfx -ns` | Without sound |
| `gamemoderun %command% -3dfx` | With GameMode |
| `prime-run %command% -3dfx` | On the NVIDIA card of a laptop |
| `PULSE_LATENCY_MSEC=120 %command% -3dfx` | Without crackling sound |
| `gamescope -w 1920 -h 1080 -f -- %command% -3dfx` | In gamescope |
| `WINEDEBUG=warn+all %command% -3dfx` | With more of Wine in the log |

**Note:** _No shell runs the options. They split at spaces, and D2Launcher refuses quotes and ``; & | < > $ ` \ ( ) { }``. A program in front of `%command%` has to be installed._

## Graphics

`-3dfx` starts D2GL, `-ddraw` starts cnc-ddraw. Each keeps its settings in the game folder, and updates leave them as they are.

| Renderer | Settings | File |
| --- | --- | --- |
| D2GL | Ctrl+O in the game | `d2gl.ini` |
| cnc-ddraw | **Settings › Tools › cnc-ddraw Settings** | `ddraw.ini` |

Without a `d2gl.ini`, D2Launcher starts D2GL in fullscreen with sharp upscaling (`xbr-lv2-sharp`), Sharpen, FXAA, the HD cursor and Motion Prediction, and skips the intro. The colors stay as Blizzard made them. Color grading, Bloom and the other shaders are in Ctrl+O.

## Wine

D2Launcher brings its own Wine: Proton 11.0-2 in the WoW64 build of Kron4ek, checked against its sha256. It runs the 32-bit game without a 32-bit library, so a Wine of the system is never needed. A new version of D2Launcher can bring a new Wine. The first start with it backs up the saves into `~/.d2launcher/backup`, then updates the prefix.

D2Launcher keeps Wine apart from the system:

- Wine variables of the shell, such as `WINEDLLOVERRIDES`, stay away from the game. What it should get goes into `launch_options`
- Windows programs get no menu entries or file types in the desktop
- `Game.exe` alone sees Windows 7. On a newer one, Diablo II 1.13 asks for its disc
- The prefix is `~/.d2launcher/wineprefix`, never `~/.wine`

**Settings › Tools** opens the Wine configuration and the cnc-ddraw settings, runs any Windows program in the prefix, and downloads Wine again.

## Median XL

**Play** asks the Median XL server for a new version first. **Update** installs it, the other button plays the version you have. Without a connection, the version you have starts. The first start installs the newest version without a question.

- An update downloads only the files that changed and checks each against the sha1 the server names
- A file you changed since the last update stays, unless you replace it when the update names it
- **Median XL › Check for Updates** asks the server at any time
- **Median XL › Choose Version** installs a stored version, the one you have too
- The store keeps the three newest versions and the one you have

## Diablo II Alone

With `median_xl=false`, **Play** starts Diablo II without Median XL, from `~/.d2launcher/bin/diablo2-vanilla`. Its first start copies the folder you choose. The Median XL folder stays, so the setting switches back and forth.

- D2GL comes along for `-3dfx`, the default
- The saves lie in the prefix under `Saved Games/Diablo II`, before 1.14 in the game folder
- D2Stats and the Median XL menu stay off

## D2Stats

With `d2stats=true`, **Play** starts D2Stats first, then the game through sigma-loader, which D2Stats reads it through. Both download at their first use. **Settings › Update D2Stats** brings the newest of both and keeps your D2Stats settings, notifier rules and sounds.

## Tweaks

A tweak is a script that changes the game folder. It shows its script, and **Install** runs it. D2Launcher brings two:

| Tweak | Installs |
| --- | --- |
| `cnc-ddraw` | The newest cnc-ddraw with its settings program |
| `d2gl` | The newest D2GL, for Median XL or for Diablo II |

Median XL brings both. **Play** runs `d2gl` by itself when `-3dfx` finds no `glide3x.dll`.

A tweak of your own is `~/.d2launcher/tweaks/<name>.sh`, its second line a comment that says what it does. It replaces a tweak of the same name. It runs in a folder of its own, with these variables:

| Variable | Holds |
| --- | --- |
| `D2_DIR` | The game folder |
| `D2_CACHE` | A folder for downloads that stays between runs |
| `WINEPREFIX` | The Wine prefix |

## Backups and Saves

- The first start backs up the game folder. **Settings › Backups › Create Backup** does it again
- **Settings › Backups › Restore Backup** puts the backup in place of the game folder, the saves stay
- **Settings › Backups › Export Saves** packs the saves into a zip
- **Settings › Backups › Import Saves** unpacks one, after it backed up the current saves into `~/.d2launcher/backup`

## Log

Each start writes `~/.d2launcher/logs/d2launcher.log`, the four starts before it stay as `d2launcher.log.1` to `.4`. A line holds the time, its source and what happened:

```
2026-10-21 11:15:02  launcher  D2Launcher 5.0.0 on Arch Linux, kernel 7.2.11-zen1-1-zen, zenity 4.2.2
2026-10-21 11:15:09  launcher  Starting gamemoderun wine Diablo II.exe -3dfx
2026-10-21 11:15:10  game      0130:err:ole:CoMarshalInterface Failed to marshal the interface
```

| Source | Writes |
| --- | --- |
| `launcher` | D2Launcher itself: settings, menu choices, downloads and their errors |
| `wine` | Wine programs D2Launcher runs, such as `wineboot` and `winecfg` |
| `game` | Diablo II and Wine while the game runs |
| `d2stats` | D2Stats |
| `tweak` | A tweak |

Wine leaves out its fixme lines, `WINEDEBUG` in `launch_options` sets what it writes. The game writes its own logs into `~/.d2launcher/bin/diablo2`, D2Stats into `~/.d2launcher/bin/d2-stats`.

## Files

| Path | Holds |
| --- | --- |
| `~/.d2launcher/d2launcher.conf` | The settings |
| `~/.d2launcher/logs` | The logs of the last five starts |
| `~/.d2launcher/bin/diablo2` | The game with Median XL |
| `~/.d2launcher/bin/diablo2-vanilla` | The game alone, with `median_xl=false` |
| `~/.d2launcher/bin/wine` | The Wine included |
| `~/.d2launcher/bin/d2-stats` | D2Stats |
| `~/.d2launcher/patches` | The stored Median XL versions, each file once |
| `~/.d2launcher/tweaks` | Your tweaks |
| `~/.d2launcher/wineprefix` | The Wine prefix with the saves |
| `~/.d2launcher/backup` | A backup of each game folder, and the saves before an import or a new Wine |

**Note:** _Copied to another computer, `~/.d2launcher` plays there as before._

## Troubleshooting

| Problem | Way Out |
| --- | --- |
| Diablo II asks for its disc | Copy every `.mpq` of the discs into `~/.d2launcher/bin/diablo2` |
| The game shows no picture | The graphics driver lacks OpenGL. The log names what Wine missed |
| D2Stats shows nothing | Set `d2stats=true`, so **Play** starts the game through sigma-loader |
| Anything else | `~/.d2launcher/logs/d2launcher.log` names what failed |
