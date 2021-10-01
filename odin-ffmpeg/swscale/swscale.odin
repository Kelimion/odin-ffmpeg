/*
	Odin bindings for FFmpeg's `swscale` library.
	Bindings available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_swscale

when ODIN_OS == "windows" { foreign import swscale "swscale.lib"       }
when ODIN_OS == "linux"   { foreign import swscale "system:libswscale" }

/*
	`swscale_*` functions.
*/
@(default_calling_convention="c", link_prefix="swscale_")
foreign swscale {
	// Return the LIBswscale_VERSION_INT constant
	// major, minor, micro := version >> 16, (version >> 8) & 255, version & 255
	version :: proc() -> (version: u32) ---

	// Return the libswscale build-time configuration.
	configuration :: proc() -> (build_time_configuration: cstring) ---

	// Return the libswscale license.
	license :: proc() -> (license: cstring) ---
}

/*
	sws_addVec
	sws_allocVec
	sws_alloc_context
	sws_alloc_set_opts
	sws_cloneVec
	sws_convVec
	sws_convertPalette8ToPacked24
	sws_convertPalette8ToPacked32
	sws_freeContext
	sws_freeFilter
	sws_freeVec
	sws_getCachedContext
	sws_getCoefficients
	sws_getColorspaceDetails
	sws_getConstVec
	sws_getContext
	sws_getDefaultFilter
	sws_getGaussianVec
	sws_getIdentityVec
	sws_get_class
	sws_init_context
	sws_isSupportedEndiannessConversion
	sws_isSupportedInput
	sws_isSupportedOutput
	sws_normalizeVec
	sws_printVec2
	sws_scale
	sws_scaleVec
	sws_setColorspaceDetails
	sws_shiftVec
	sws_subVec
*/