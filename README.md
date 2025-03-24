# NMRiH 1.14.1 Hotfixes

Fixes a bunch of regressions introduced in NMRiH 1.14.1

## Installation

- Install [Metamod](https://www.sourcemm.net/downloads.php?branch=stable) and [Sourcemod](https://www.sourcemod.net/downloads.php)
- Extract the zip from the [releases](https://github.com/dysphie/nmrih-1141-fixes/releases) section into your server's `addons/sourcemod` folder
- Refresh the plugin list (`sm plugins refresh`)
 
## Cvars  
| Cvar                          | Values  | Description                                      |
|-------------------------------|---------|--------------------------------------------------|
| `hotfix_zombie_attack_bulleye` | `1`/`0` | Fixes zombies not attacking bullseyes           |
| `hotfix_fmod_sounds`          | `1`/`0` | Fixes clients not hearing FMOD sounds           |
| `hotfix_damage_filters`       | `1`/`0` | Fixes damage filters not working correctly ("Immortal zombies" bug)      |


Thanks to [felis-catus](https://github.com/felis-catus) for invaluable insights! 🫶

> [!NOTE]  
> This plugin will self-destruct when 1.14.2 comes out!
