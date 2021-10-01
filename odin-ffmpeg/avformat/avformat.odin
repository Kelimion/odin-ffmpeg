/*
	Odin bindings for FFmpeg's `avformat` library.
	Bindings available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_avformat

import "ffmpeg:types"

when ODIN_OS == "windows" { foreign import avformat "avformat.lib"       }
when ODIN_OS == "linux"   { foreign import avformat "system:libavformat" }

/*
	Globals.
*/
@(default_calling_convention="c")
foreign avformat {
	/*
		av_codec_ffversion: cstring
		^ segfaults on access. Address way out of range.
	*/
}

/*
	`avformat_*` functions.
*/
@(default_calling_convention="c", link_prefix="avformat_")
foreign avformat {
	// Return the LIBAVFORMAT_VERSION_INT constant
	// major, minor, micro := version >> 16, (version >> 8) & 255, version & 255
	version :: proc() -> (version: u32) ---

	// Return the libavformat build-time configuration.
	configuration :: proc() -> (build_time_configuration: cstring) ---

	// Return the libavformat license.
	license :: proc() -> (license: cstring) ---
}

/*
	`av_*` functions.
*/
@(default_calling_convention="c", link_prefix="av_")
foreign avformat {
	muxer_iterate   :: proc(handle: ^rawptr) -> (muxer:   ^types.Output_Format) ---
	demuxer_iterate :: proc(handle: ^rawptr) -> (demuxer: ^types.Input_Format) ---
}

/*
	av_add_index_entry
	av_append_packet
	av_apply_bitstream_filters
	av_codec_get_id
	av_codec_get_tag
	av_codec_get_tag2
	av_demuxer_iterate
	av_demuxer_open
	av_dump_format
	av_filename_number_test
	av_find_best_stream
	av_find_default_stream_index
	av_find_input_format
	av_find_program_from_stream
	av_fmt_ctx_get_duration_estimation_method
	av_format_get_audio_codec
	av_format_get_control_message_cb
	av_format_get_data_codec
	av_format_get_metadata_header_padding
	av_format_get_opaque
	av_format_get_open_cb
	av_format_get_probe_score
	av_format_get_subtitle_codec
	av_format_get_video_codec
	av_format_inject_global_side_data
	av_format_set_audio_codec
	av_format_set_control_message_cb
	av_format_set_data_codec
	av_format_set_metadata_header_padding
	av_format_set_opaque
	av_format_set_open_cb
	av_format_set_subtitle_codec
	av_format_set_video_codec
	av_get_frame_filename
	av_get_frame_filename2
	av_get_output_timestamp
	av_get_packet
	av_guess_codec
	av_guess_format
	av_guess_frame_rate
	av_guess_sample_aspect_ratio
	av_hex_dump
	av_hex_dump_log
	av_iformat_next
	av_index_search_timestamp
	av_interleaved_write_frame
	av_interleaved_write_uncoded_frame
	av_match_ext
	av_muxer_iterate
	av_new_program
	av_oformat_next
	av_pkt_dump2
	av_pkt_dump_log2
	av_probe_input_buffer
	av_probe_input_buffer2
	av_probe_input_format
	av_probe_input_format2
	av_probe_input_format3
	av_program_add_stream_index
	av_read_frame
	av_read_pause
	av_read_play
	av_register_all
	av_register_input_format
	av_register_output_format
	av_sdp_create
	av_seek_frame
	av_stream_add_side_data
	av_stream_get_codec_timebase
	av_stream_get_end_pts
	av_stream_get_parser
	av_stream_get_r_frame_rate
	av_stream_get_recommended_encoder_configuration
	av_stream_get_side_data
	av_stream_new_side_data
	av_stream_set_r_frame_rate
	av_stream_set_recommended_encoder_configuration
	av_url_split
	av_write_frame
	av_write_trailer
	av_write_uncoded_frame
	av_write_uncoded_frame_query
	avformat_alloc_context
	avformat_alloc_output_context2
	avformat_close_input
	avformat_find_stream_info
	avformat_flush
	avformat_free_context
	avformat_get_class
	avformat_get_mov_audio_tags
	avformat_get_mov_video_tags
	avformat_get_riff_audio_tags
	avformat_get_riff_video_tags
	avformat_init_output
	avformat_match_stream_specifier
	avformat_network_deinit
	avformat_network_init
	avformat_new_stream
	avformat_open_input
	avformat_query_codec
	avformat_queue_attached_pictures
	avformat_seek_file
	avformat_transfer_internal_stream_timing_info
	avformat_write_header
	avio_accept
	avio_alloc_context
	avio_check
	avio_close
	avio_close_dir
	avio_close_dyn_buf
	avio_closep
	avio_context_free
	avio_enum_protocols
	avio_feof
	avio_find_protocol_name
	avio_flush
	avio_free_directory_entry
	avio_get_dyn_buf
	avio_get_str
	avio_get_str16be
	avio_get_str16le
	avio_handshake
	avio_open
	avio_open2
	avio_open_dir
	avio_open_dyn_buf
	avio_pause
	avio_print_string_array
	avio_printf
	avio_protocol_get_class
	avio_put_str
	avio_put_str16be
	avio_put_str16le
	avio_r8
	avio_rb16
	avio_rb24
	avio_rb32
	avio_rb64
	avio_read
	avio_read_dir
	avio_read_partial
	avio_read_to_bprint
	avio_rl16
	avio_rl24
	avio_rl32
	avio_rl64
	avio_seek
	avio_seek_time
	avio_size
	avio_skip
	avio_w8
	avio_wb16
	avio_wb24
	avio_wb32
	avio_wb64
	avio_wl16
	avio_wl24
	avio_wl32
	avio_wl64
	avio_write
	avio_write_marker
	avpriv_dv_get_packet
	avpriv_dv_init_demux
	avpriv_dv_produce_packet
	avpriv_io_delete
	avpriv_io_move
	avpriv_mpegts_parse_close
	avpriv_mpegts_parse_open
	avpriv_mpegts_parse_packet
	avpriv_new_chapter
	avpriv_register_devices
	avpriv_set_pts_info
*/