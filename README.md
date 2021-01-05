# WoW Migraine Helper

[![pipeline status](https://gitlab.com/zerodogg/WowMigraineHelper/badges/master/pipeline.svg)](https://gitlab.com/zerodogg/WowMigraineHelper/-/commits/master)

*WoW Migraine Helper* is an accessibility addon for people that suffer from
migraines or other headaches. Some areas in WoW have graphics that can hurt or
trigger migraines. This addon includes two helpers that can mitigate some of
the effects. These are not subtle, the addon uses the sledgehammer approach to
problem solving. The intention is to have you quickly enable one of the
overlays when you're in an area of the game with effects that trigger migraines
(like the "Cloak of Ve'nari" effect in the Maw), and then disable them
afterwards.

By default the helpers are bound to `CTRL-ALT-M` and `CTRL-ALT-D`. These are
customizable (and you may also disable them).

## Helper modes

### Brightness filter

This toggles a filter overlaying the screen, making the game world a lot less
bright than normal, while the UI remains normal.  By default this is bound to
`CTRL-ALT-D`, or you can use `/migrainedark`.

### Frame overlay

This toggles black bars around the screen, which can be used to hide effects
like the "Cloak of Ve'nari". Any UI elements placed on the edges of the screen
work as normal.  By default this is bound to `CTRL-ALT-M`, or you can use
`/migraineedge`.

## Configuration

To configure Migraine Helper, open up the addon settings panel (`Esc` ->
`Interface` -> `AddOns` -> `Migraine Helper`). There you can select the width
and height of the frame overlay, the strength of the brightness overlay,
configure the key bindings and set some WoW config options (see below).

### WoW options

Migraine Helper also gives you access to modify three game graphics settings in
its UI panel. Toggling these may also help alleviate migraine. Note that
changes to these persist even if the addon is removed.

## Issues

Please use the [issue tracker at
Gitlab](https://gitlab.com/zerodogg/WowMigraineHelper/-/issues) to report any
issues or submit feature requests.

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
