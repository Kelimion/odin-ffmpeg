# Odin-FFmpeg

This repository contains [Odin](https://odin-lang.org) bindings for [FFmpeg](https://ffmpeg.org).

# How to use

Use your own ffmpeg shared libraries or those provided under [shared](shared). The provided Win64 DLLs are licensed under the LGPL v2.1.

# Roadmap
## Done
### Structs and enums
[X] LibAVCodec
[X] LibAVFormat
[X] LibAVUtil
[X] LibAVFilter

## In Progress
[ ] FFMPEG.h
[ ] CmdUtils

## To do

[ ] LibAVDevice
[ ] LibSWResample
[ ] LibSWScale

# License

The bindings are made available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md`

The libraries themselves are made available under their own licenses. See `FFMPEG-*.md`.

# Upgrade the libraries
## Download a Win64 build of FFMPEG rel-4.4

Suggestion, use an LGPL'd release. E.g.: [BtbN's ffmpeg-n4.4-154-g79c114e1b2-win64-lgpl-shared-4.4.zip](https://github.com/BtbN/FFmpeg-Builds/releases)