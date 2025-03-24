# NMRiH 1.14.1 Hotfixes

Fixes a bunch of regressions introduced in NMRiH 1.14.1
 
## Cvars  

Editable in `cfg/sourcemod/1141-fixes.cfg`

| Cvar                          | Values  | Description                                      |
|-------------------------------|---------|--------------------------------------------------|
| `hotfix_zombie_attack_bulleye` | `1`/`0` | Fixes an issue where zombies fail to attack bullseyes. This affects maps like `nmo_project_enigma` where special zombies no longer trigger explosions. |
| `hotfix_fmod_sounds`          | `1`/`0` | Fixes an issue preventing clients from hearing FMOD sounds. Affects newer maps like `nmo_cambalache_barrios` that make heavy use of them. |
| `hotfix_damage_filters`       | `1`/`0` | Fixes improper damage filter behavior, which can cause issues like special zombies not dying or dying too easily. |

## Installation

- Install [Metamod](https://www.sourcemm.net/downloads.php?branch=stable) and [Sourcemod](https://www.sourcemod.net/downloads.php)
- Extract the zip from the [releases](https://github.com/dysphie/nmrih-1141-fixes/releases) section into your server's `addons/sourcemod` folder
- Refresh the plugin list (`sm plugins refresh`)

## Notes

- Thanks to [felis-catus](https://github.com/felis-catus) for invaluable insights! 🫶
- This plugin will be obsolete and self-destruct when 1.14.2 comes out
