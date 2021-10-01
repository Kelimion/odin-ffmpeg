/*
	Odin bindings for FFmpeg's `avfilter` library.
	Bindings available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_avfilter

when ODIN_OS == "windows" { foreign import avfilter "avfilter.lib"       }
when ODIN_OS == "linux"   { foreign import avfilter "system:libavfilter" }

/*
	`avfilter_*` functions, except for `avfilter_string`, because that would conflict with the string type.
*/
@(default_calling_convention="c", link_prefix="avfilter_")
foreign avfilter {
	// Return the LIBavfilter_VERSION_INT constant
	// major, minor, micro := version >> 16, (version >> 8) & 255, version & 255
	version :: proc() -> (version: u32) ---

	// Return the libavfilter build-time configuration.
	configuration :: proc() -> (build_time_configuration: cstring) ---

	// Return the libavfilter license.
	license :: proc() -> (license: cstring) ---
}

/*
	av_abuffersink_params_alloc
	av_buffersink_get_channel_layout
	av_buffersink_get_channels
	av_buffersink_get_format
	av_buffersink_get_frame
	av_buffersink_get_frame_flags
	av_buffersink_get_frame_rate
	av_buffersink_get_h
	av_buffersink_get_hw_frames_ctx
	av_buffersink_get_sample_aspect_ratio
	av_buffersink_get_sample_rate
	av_buffersink_get_samples
	av_buffersink_get_time_base
	av_buffersink_get_type
	av_buffersink_get_w
	av_buffersink_params_alloc
	av_buffersink_set_frame_size
	av_buffersrc_add_frame
	av_buffersrc_add_frame_flags
	av_buffersrc_close
	av_buffersrc_get_nb_failed_requests
	av_buffersrc_parameters_alloc
	av_buffersrc_parameters_set
	av_buffersrc_write_frame
	av_filter_ffversion
	av_filter_iterate
	avfilter_add_matrix
	avfilter_config_links
	avfilter_free
	avfilter_get_by_name
	avfilter_get_class
	avfilter_graph_alloc
	avfilter_graph_alloc_filter
	avfilter_graph_config
	avfilter_graph_create_filter
	avfilter_graph_dump
	avfilter_graph_free
	avfilter_graph_get_filter
	avfilter_graph_parse
	avfilter_graph_parse2
	avfilter_graph_parse_ptr
	avfilter_graph_queue_command
	avfilter_graph_request_oldest
	avfilter_graph_send_command
	avfilter_graph_set_auto_convert
	avfilter_init_dict
	avfilter_init_str
	avfilter_inout_alloc
	avfilter_inout_free
	avfilter_insert_filter
	avfilter_link
	avfilter_link_free
	avfilter_link_get_channels
	avfilter_link_set_closed
	avfilter_make_format64_list
	avfilter_mul_matrix
	avfilter_next
	avfilter_pad_count
	avfilter_pad_get_name
	avfilter_pad_get_type
	avfilter_process_command
	avfilter_register
	avfilter_register_all
	avfilter_sub_matrix
	avfilter_transform
*/