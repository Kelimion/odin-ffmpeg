/*
	Odin bindings for FFmpeg's `avdevice` library.
	Bindings available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_avdevice

when ODIN_OS == "windows" { foreign import avdevice "avdevice.lib"       }
when ODIN_OS == "linux"   { foreign import avdevice "system:libavdevice" }

/*
	`avdevice_*` functions.
*/
@(default_calling_convention="c", link_prefix="avdevice_")
foreign avdevice {
	// Return the LIBAVDEVICE_VERSION_INT constant
	// major, minor, micro := version >> 16, (version >> 8) & 255, version & 255
	version :: proc() -> (version: u32) ---

	// Return the libavcodec build-time configuration.
	configuration :: proc() -> (build_time_configuration: cstring) ---

	// Return the libavcodec license.
	license :: proc() -> (license: cstring) ---
}

/*
	av_device_capabilities
	av_device_ffversion
	av_input_audio_device_next
	av_input_video_device_next
	av_output_audio_device_next
	av_output_video_device_next
	avdevice_app_to_dev_control_message
	avdevice_capabilities_create
	avdevice_capabilities_free
	avdevice_dev_to_app_control_message
	avdevice_free_list_devices
	avdevice_list_devices
	avdevice_list_input_sources
	avdevice_list_output_sinks
	avdevice_register_all
*/