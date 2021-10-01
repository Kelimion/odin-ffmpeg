/*
	Helper functions for the Odin `avfilter` bindings.
	Bindings and helpers available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_avfilter

version_semantic :: proc() -> (major, minor, micro: u32) {
	v := version()
	return v >> 16, (v >> 8) & 255, v & 255
}