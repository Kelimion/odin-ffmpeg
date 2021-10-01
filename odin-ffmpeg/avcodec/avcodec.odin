/*
	Odin bindings for FFmpeg's `avcodec` library.
	Bindings available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_avcodec

import "ffmpeg:types"
import "core:c"

when ODIN_OS == "windows" { foreign import avcodec "avcodec.lib"       }
when ODIN_OS == "linux"   { foreign import avcodec "system:libavcodec" }

/*
	Globals.
*/
@(default_calling_convention="c")
foreign avcodec {
	/*
		av_codec_ffversion: cstring
		^ segfaults on access. Address way out of range.
	*/
}

/*
	`avcodec_*` functions, except for `avcodec_string`, because that would conflict with the string type.
*/
@(default_calling_convention="c", link_prefix="avcodec_")
foreign avcodec {
	// Return the LIBAVCODEC_VERSION_INT constant
	// major, minor, micro := version >> 16, (version >> 8) & 255, version & 255
	version         :: proc() -> (version: u32) ---

	// Return the libavcodec build-time configuration.
	configuration   :: proc() -> (build_time_configuration: cstring) ---

	// Return the libavcodec license.
	license         :: proc() -> (license: cstring) ---

	// Get codec name. Never nil.
	get_name        :: proc(codec_id: types.Codec_ID) -> (codec_name: cstring) ---

	// Get codec type.
	get_type        :: proc(codec_id: types.Codec_ID) -> (media_type: types.Media_Type) ---

	// Iterate over codec descriptors
	descriptor_next :: proc(prev: ^types.Codec_Descriptor) -> (next: ^types.Codec_Descriptor) ---

	// Do we have a decoder for this codec?
	find_decoder    :: proc(codec_id: types.Codec_ID) -> (decoder: ^types.Codec) ---

	// Do we have an encoder for this codec?
	find_encoder    :: proc(codec_id: types.Codec_ID) -> (encoder: ^types.Codec) ---
}

/*
	`av_codec_*` functions.
*/
@(default_calling_convention="c", link_prefix="av_codec_")
foreign avcodec {
	// Iterate over all codecs
	iterate    :: proc(iter: ^rawptr) -> (codec: ^types.Codec) ---

	// Codec is decoder
	is_decoder :: proc(codec: ^types.Codec) -> c.int ---

	// Codec is encoder
	is_encoder :: proc(codec: ^types.Codec) -> c.int ---
}
/*
	av_ac3_parse_header
	av_adts_header_parse
	av_bitstream_filter_close
	av_bitstream_filter_filter
	av_bitstream_filter_init
	av_bitstream_filter_next
	av_bsf_alloc
	av_bsf_flush
	av_bsf_free
	av_bsf_get_by_name
	av_bsf_get_class
	av_bsf_get_null_filter
	av_bsf_init
	av_bsf_iterate
	av_bsf_list_alloc
	av_bsf_list_append
	av_bsf_list_append2
	av_bsf_list_finalize
	av_bsf_list_free
	av_bsf_list_parse_str
	av_bsf_next
	av_bsf_receive_packet
	av_bsf_send_packet
	av_codec_get_chroma_intra_matrix
	av_codec_get_codec_descriptor
	av_codec_get_codec_properties
	av_codec_get_lowres
	av_codec_get_max_lowres
	av_codec_get_pkt_timebase
	av_codec_get_seek_preroll
	av_codec_is_decoder
	av_codec_is_encoder
	av_codec_iterate
	av_codec_next
	av_codec_set_chroma_intra_matrix
	av_codec_set_codec_descriptor
	av_codec_set_lowres
	av_codec_set_pkt_timebase
	av_codec_set_seek_preroll
	av_copy_packet
	av_copy_packet_side_data
	av_cpb_properties_alloc
	av_d3d11va_alloc_context
	av_dct_calc
	av_dct_end
	av_dct_init
	av_dirac_parse_sequence_header
	av_dup_packet
	av_dv_codec_profile
	av_dv_codec_profile2
	av_dv_frame_profile
	av_fast_padded_malloc
	av_fast_padded_mallocz
	av_fft_calc
	av_fft_end
	av_fft_init
	av_fft_permute
	av_free_packet
	av_get_audio_frame_duration
	av_get_audio_frame_duration2
	av_get_bits_per_sample
	av_get_codec_tag_string
	av_get_exact_bits_per_sample
	av_get_pcm_codec
	av_get_profile_name
	av_grow_packet
	av_hwaccel_next
	av_imdct_calc
	av_imdct_half
	av_init_packet
	av_jni_get_java_vm
	av_jni_set_java_vm
	av_lockmgr_register
	av_mdct_calc
	av_mdct_end
	av_mdct_init
	av_mediacodec_alloc_context
	av_mediacodec_default_free
	av_mediacodec_default_init
	av_mediacodec_release_buffer
	av_mediacodec_render_buffer_at_time
	av_new_packet
	av_packet_add_side_data
	av_packet_alloc
	av_packet_clone
	av_packet_copy_props
	av_packet_free
	av_packet_free_side_data
	av_packet_from_data
	av_packet_get_side_data
	av_packet_make_refcounted
	av_packet_make_writable
	av_packet_merge_side_data
	av_packet_move_ref
	av_packet_new_side_data
	av_packet_pack_dictionary
	av_packet_ref
	av_packet_rescale_ts
	av_packet_shrink_side_data
	av_packet_side_data_name
	av_packet_split_side_data
	av_packet_unpack_dictionary
	av_packet_unref
	av_parser_change
	av_parser_close
	av_parser_init
	av_parser_iterate
	av_parser_next
	av_parser_parse2
	av_picture_copy
	av_picture_crop
	av_picture_pad
	av_qsv_alloc_context
	av_rdft_calc
	av_rdft_end
	av_rdft_init
	av_register_bitstream_filter
	av_register_codec_parser
	av_register_hwaccel
	av_shrink_packet
	av_vorbis_parse_frame
	av_vorbis_parse_frame_flags
	av_vorbis_parse_free
	av_vorbis_parse_init
	av_vorbis_parse_reset
	av_xiphlacing
	avcodec_align_dimensions
	avcodec_align_dimensions2
	avcodec_alloc_context3
	avcodec_chroma_pos_to_enum
	avcodec_close
	avcodec_copy_context
	avcodec_dct_alloc
	avcodec_dct_get_class
	avcodec_dct_init
	avcodec_decode_audio4
	avcodec_decode_subtitle2
	avcodec_decode_video2
	avcodec_default_execute
	avcodec_default_execute2
	avcodec_default_get_buffer2
	avcodec_default_get_encode_buffer
	avcodec_default_get_format
	avcodec_descriptor_get
	avcodec_descriptor_get_by_name
	avcodec_descriptor_next
	avcodec_encode_audio2
	avcodec_encode_subtitle
	avcodec_encode_video2
	avcodec_enum_to_chroma_pos
	avcodec_fill_audio_frame
	avcodec_find_best_pix_fmt2
	avcodec_find_best_pix_fmt_of_2
	avcodec_find_best_pix_fmt_of_list
	avcodec_find_decoder
	avcodec_find_decoder_by_name
	avcodec_find_encoder
	avcodec_find_encoder_by_name
	avcodec_flush_buffers
	avcodec_free_context
	avcodec_get_chroma_sub_sample
	avcodec_get_class
	avcodec_get_context_defaults3
	avcodec_get_frame_class
	avcodec_get_hw_config
	avcodec_get_hw_frames_parameters
	avcodec_get_name
	avcodec_get_pix_fmt_loss
	avcodec_get_subtitle_rect_class
	avcodec_get_type
	avcodec_is_open
	avcodec_open2
	avcodec_parameters_alloc
	avcodec_parameters_copy
	avcodec_parameters_free
	avcodec_parameters_from_context
	avcodec_parameters_to_context
	avcodec_pix_fmt_to_codec_tag
	avcodec_profile_name
	avcodec_receive_frame
	avcodec_receive_packet
	avcodec_register
	avcodec_register_all
	avcodec_send_frame
	avcodec_send_packet
	avcodec_string
	avpicture_alloc
	avpicture_fill
	avpicture_free
	avpicture_get_size
	avpicture_layout
	avpriv_ac3_channel_layout_tab
	avpriv_ac3_parse_header
	avpriv_align_put_bits
	avpriv_codec2_mode_bit_rate
	avpriv_codec2_mode_block_align
	avpriv_codec2_mode_frame_size
	avpriv_codec_get_cap_skip_frame_fill_param
	avpriv_copy_bits
	avpriv_dca_convert_bitstream
	avpriv_dca_parse_core_frame_header
	avpriv_dca_sample_rates
	avpriv_dnxhd_get_frame_size
	avpriv_dnxhd_get_hr_frame_size
	avpriv_dnxhd_get_interlaced
	avpriv_do_elbg
	avpriv_exif_decode_ifd
	avpriv_find_pix_fmt
	avpriv_find_start_code
	avpriv_fits_header_init
	avpriv_fits_header_parse_line
	avpriv_get_raw_pix_fmt_tags
	avpriv_h264_has_num_reorder_frames
	avpriv_init_elbg
	avpriv_mjpeg_bits_ac_chrominance
	avpriv_mjpeg_bits_ac_luminance
	avpriv_mjpeg_bits_dc_chrominance
	avpriv_mjpeg_bits_dc_luminance
	avpriv_mjpeg_val_ac_chrominance
	avpriv_mjpeg_val_ac_luminance
	avpriv_mjpeg_val_dc
	avpriv_mpa_bitrate_tab
	avpriv_mpa_freq_tab
	avpriv_mpeg4audio_get_config
	avpriv_mpeg4audio_get_config2
	avpriv_mpeg4audio_sample_rates
	avpriv_mpegaudio_decode_header
	avpriv_packet_list_free
	avpriv_packet_list_get
	avpriv_packet_list_put
	avpriv_pix_fmt_bps_avi
	avpriv_pix_fmt_bps_mov
	avpriv_split_xiph_headers
	avpriv_tak_parse_streaminfo
	avpriv_toupper4
	avsubtitle_free
*/