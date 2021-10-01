/*
	Odin bindings for FFmpeg's `swresample` library.
	Bindings available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_swresample

when ODIN_OS == "windows" { foreign import swresample "swresample.lib"       }
when ODIN_OS == "linux"   { foreign import swresample "system:libswresample" }

/*
	`swresample_*` functions.
*/
@(default_calling_convention="c", link_prefix="swresample_")
foreign swresample {
	// Return the LIBswresample_VERSION_INT constant
	// major, minor, micro := version >> 16, (version >> 8) & 255, version & 255
	version :: proc() -> (version: u32) ---

	// Return the libswresample build-time configuration.
	configuration :: proc() -> (build_time_configuration: cstring) ---

	// Return the libswresample license.
	license :: proc() -> (license: cstring) ---
}

/*
	swr_alloc
	swr_alloc_set_opts
	swr_build_matrix
	swr_close
	swr_config_frame
	swr_convert
	swr_convert_frame
	swr_drop_output
	swr_ffversion
	swr_free
	swr_get_class
	swr_get_delay
	swr_get_out_samples
	swr_init
	swr_inject_silence
	swr_is_initialized
	swr_next_pts
	swr_set_channel_mapping
	swr_set_compensation
	swr_set_matrix
*/