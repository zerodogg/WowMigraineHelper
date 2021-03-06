# WoW Migraine Helper

[![pipeline status](https://gitlab.com/zerodogg/WowMigraineHelper/badges/master/pipeline.svg)](https://gitlab.com/zerodogg/WowMigraineHelper/-/commits/master)

*WoW Migraine Helper* is an accessibility addon for people that suffer from
migraines or other headaches. Some areas in World of Warcraft have graphics
that can hurt or trigger migraines. This addon includes two helpers that can
mitigate some of the effects. These are not subtle, the addon uses the
sledgehammer approach to problem solving. The intention is to have you quickly
enable one of the helpers when you're in an area of the game with effects that
trigger migraines (like the "Cloak of Ve'nari" effect in the Maw), and then
disable them afterwards. The addon also provides access to some config options
that can be helpful which are not exposed in the default Blizzard settings
dialog.

By default the helpers are bound to `CTRL-ALT-M` (screen frame) and
`CTRL-ALT-D` (brightness filter). These are customizable (and you may also
disable them).

## Helper modes

### Brightness filter

This toggles a filter that makes the game world a lot less bright than normal.
By default the filter leaves UI elements untouched, but you can configure it to
also reduce the brightness of the UI elements, which can be useful during a
migraine attack. By default this is bound to `CTRL-ALT-D`, or you can use
`/migrainebrightness`.

### Frame overlay

This toggles black bars around the screen, which can be used to hide effects
like the "Cloak of Ve'nari". Any UI elements placed on the edges of the screen
work as normal.  By default this is bound to `CTRL-ALT-M`, or you can use
`/migraineframe`.

## Configuration

To configure Migraine Helper, open up the addon settings panel (`Esc` ->
`Interface` -> `AddOns` -> `Migraine Helper`). There you can choose if you want
the addon to remember enabled filters the next time you log in, select the width
and height of the frame overlay, the strength of the brightness filter, choose
if you want to include the UI elements in the brightness filter or not,
configure the key bindings and set some WoW config options (see below).

### WoW options

Migraine Helper also gives you access to modify three game graphics settings in
its UI panel. Toggling these may also help alleviate migraine. Note that
changes to these persist even if the addon is removed.

## Issues

Please use the [issue tracker at
Gitlab](https://gitlab.com/zerodogg/WowMigraineHelper/-/issues) to report any
issues or submit feature requests.

## Acknowledgements

Thanks to the authors of the [*Ace3*](https://www.wowace.com/projects/ace3)
config, event and UI library, and the authors of the
[*LibStub*](https://www.wowace.com/projects/libstub) helper library. These
libraries handle a lot of the lower level plumbing so I don't have to, and made
life a lot easier than it would have been without.

## Getting WoW Migraine Helper

You can install WoW Migraine Helper from
[WoWInterface](https://www.wowinterface.com/downloads/fileinfo.php?id=25862) or
[Curseforge](https://www.curseforge.com/wow/addons/migraine-helper) using your
favourite WoW addon manager, like [WowUp](https://wowup.io/), or you can
[download the zip directly from
gitlab](https://gitlab.com/zerodogg/WowMigraineHelper/-/releases).

## License

Copyright (C) Eskild Hustvedt 2021

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Third party legal notice

World of Warcraft and Blizzard is a trademark or registered trademark of
Blizzard Entertainment, Inc.
