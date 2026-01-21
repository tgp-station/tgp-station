## TGP Station (/tg/station Downstream)

| Website                 | Link                                                                                     |
| ----------------------- | ---------------------------------------------------------------------------------------- |
| Code                    | [https://github.com/tgp-station/tgp-station](https://github.com/tgp-station/tgp-station) |
| Codedocs                | [https://codedocs.tgstation13.org/](https://codedocs.tgstation13.org/)                   |
| Guide to Modularization | [./modular_tgp/readme.md](./modular_tgp/readme.md)                                       |
| Guide to Mirroring      | [./modular_tgp/mirroring_guide.md](./modular_tgp/mirroring_guide.md)                     |
| TG Wiki                 | [https://tgstation13.org/wiki/Main_Page](https://tgstation13.org/wiki/Main_Page)         |
| TGP Discord             | [https://discord.gg/axyRuURhSQ](https://discord.gg/axyRuURhSQ)                           |
| Coderbus Discord        | [https://discord.gg/Vh8TJp9](https://discord.gg/Vh8TJp9)                                 |

/tg/ Persistence Station (TGP) is a downstream fork of the /tg/station codebase for Space Station 13. This project is dedicated to building a fully persistent game world, shifting the focus away from traditional round-based gameplay.

## DEVELOPMENT FLOWCHART (copied from Skyrat-SS13)

![image](https://i.imgur.com/aJnE4WT.png)

[Modularisation Guide](./modular_TGP/readme.md)

## DOWNLOADING

[Downloading](.github/guides/DOWNLOADING.md)

[Running a server](.github/guides/RUNNING_A_SERVER.md)

[Maps and Away Missions](.github/guides/MAPS_AND_AWAY_MISSIONS.md)

## Compilation

**The quick way**. Find `bin/server.cmd` in this folder and double click it to automatically build and host the server on port 1337.

**The long way**. Find `bin/build.cmd` in this folder, and double click it to initiate the build. It consists of multiple steps and might take around 1-5 minutes to compile. If it closes, it means it has finished its job. You can then [setup the server](.github/guides/RUNNING_A_SERVER.md) normally by opening `tgstation.dmb` in DreamDaemon.

**Building tgstation in DreamMaker directly is deprecated and might produce errors**, such as `'tgui.bundle.js': cannot find file`.

**[How to compile in VSCode and other build options](tools/build/README.md).**

## Getting started

For contribution guidelines refer to the [Guides for Contributors](.github/CONTRIBUTING.md).

For getting started (dev env, compilation) see the HackMD document [here](https://hackmd.io/@tgstation/HJ8OdjNBc#tgstation-Development-Guide).

For overall design documentation see [HackMD](https://hackmd.io/@tgstation).

For lore, [see Common Core](https://github.com/tgstation/common_core).

## LICENSE

All code after [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU AGPL v3](https://www.gnu.org/licenses/agpl-3.0.html).

All code before [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).
(Including tools unless their readme specifies otherwise.)

See LICENSE and GPLv3.txt for more details.

The TGS DMAPI is licensed as a subproject under the MIT license.

See the footer of [code/\_\_DEFINES/tgs.dm](./code/__DEFINES/tgs.dm) and [code/modules/tgs/LICENSE](./code/modules/tgs/LICENSE) for the MIT license.

All assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated.
