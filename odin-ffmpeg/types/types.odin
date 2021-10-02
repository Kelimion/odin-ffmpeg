/*
	Odin bindings for FFmpeg.
	Bindings available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_types

import "core:c"
import "core:runtime"

FFmpeg_Error :: enum {

}

Error :: union {
	runtime.Allocator_Error,
	FFmpeg_Error,
}

/*
	Buffer padding in bytes for decoder to allow larger reads.
*/
INPUT_BUFFER_PADDING_SIZE :: 64

/*
	Minimum encoding buffer size.
*/
INPUT_BUFFER_MIN_SIZE :: 16384

/* ==============================================================================================
	   CODECS - CODECS - CODECS - CODECS - CODECS - CODECS - CODECS - CODECS - CODECS - CODECS
   ============================================================================================== */

Get_Codecs_Type :: enum c.int {
	Decoder = 0,
	Encoder = 1,
	Both    = 2,
}

Discard :: enum {
	None          = -16,
	Default       =   0,
	Non_Reference =   8,
	Bidrectional  =  16,
	Non_Intra     =  24,
	Non_Key       =  32,
	All           =  48,
}

Audio_Service_Type :: enum {
	Main              = 0,
	Effects           = 1,
	Visually_Impaired = 2,
	Hearing_Impaired  = 3,
	Dialogue          = 4,
	Commentary        = 5,
	Emergency         = 6,
	Voice_over        = 7,
	Karaoke           = 8,
	Not_Part_of_ABI,
}

RC_Override :: struct {
	start_frame:    c.int,
	end_frame:      c.int,
	qscale:         c.int,
	quality_factor: c.float,
}

/*
	`AV_Codec_Flags` can be passed into `AV_Codec_Context.flags` before initialization.
*/
Codec_Flag :: enum c.int {
	/*
		FLAG_*
	*/
	Unaligned                    =  0,
	Q_Scale                      =  1,
	Four_MV                      =  2,
	Output_Corrupt               =  3,
	Quarter_Pel                  =  4,
	Drop_Changed                 =  5,
	Pass_1                       =  9,
	Pass_2                       = 10,
	Loop_Filter                  = 11,
	Grayscale_Decode             = 13,
	Report_PSNR                  = 15,
	Truncated_Bitstream          = 16,
	Interlaced_DCT               = 18,
	Low_Delay                    = 19,
	Global_Header                = 22,
	Bit_Exact                    = 23,
	AC_Prediction                = 24,
	Interlaced_Motion_Estimation = 29,
	Closed_GOP                   = 31,

	/*
		FLAG2_*
	*/
	Fast                         =  0,
	Non_Compliant_Speedups       =  0,
	No_Output                    =  2,
	Local_Header                 =  3,
	_Drop_Frame_Timecode         = 13, // Deprecated
	Chunks                       = 15,
	Ignore_Crop                  = 16,
	Show_All_Frames              = 22,
	Export_Motion_Vectors        = 28,
	Skip_Manual                  = 29,
	No_Flush_Loop                = 30,
}
Codec_Flags :: bit_set[Codec_Flag; c.int]

/*
	`Codec_Export_Data_Flags` can be passed into `Codec_Context.export_side_data` before initialization.
*/
Codec_Export_Data_Flag :: enum c.int {
	Motion_Vectors               = 0,
	Producer_Reference_Time      = 1,
	Video_Encoding_Parameters    = 2,
	Film_Grain                   = 3,
}
Codec_Export_Data_Flags :: bit_set[Codec_Export_Data_Flag; c.int]

/*
	Pan/Scan area to display
*/
Vec2_u16 :: [2]c.int16_t

Pan_Scan :: struct {
	id:     c.int,
	width:  c.int, // Width and Height in 1/16th of a pixel.
	height: c.int,

	position: [3]Vec2_u16, // Top left in 1/16th of a pixel for up to 3 frames.
}

when #config(API_UNSANITIZED_BITRATES, true) {
	br_unit :: c.int64_t
} else {
	br_unit :: c.int
}

/*
	Stream bitrate properties.
*/
Codec_Bitrate_Properties :: struct {
	max_bitrate: br_unit,
	min_bitrate: br_unit,
	avg_bitrate: br_unit,

	buffer_size: c.int,
	vbv_delay:   c.uint64_t,
}

/*
	Producer Reference Time (prft), per ISO/IEC 14496-12.
*/
Producer_Reference_Time :: struct {
	wall_clock: c.int64_t, // UTC timestamp in microseconds, e.g. `avcodec.get_time`.
	flags: c.int,
}

FourCC :: distinct [4]u8

/*
	AV Codec Tag
*/
Codec_Tag :: struct {
	id:  Codec_ID,
	tag: FourCC,
}

Codec_Mime :: struct {
	str: [32]u8,
	id: Codec_ID,
}

Get_Buffer_Flag_Ref        :: 1 << 0
Get_Encode_Buffer_Flag_Ref :: 1 << 0

Codec_Capability :: enum c.int {
	Draw_Horizontal_Band     =  0,
	DR1                      =  1,
	_Reserved_1              =  2,
	Truncated                =  3,
	_Reserved                =  4,
	Delay                    =  5,
	Small_Last_Frame         =  6,
	_Reserved_2              =  7,
	Subframes                =  8,
	Experimental             =  9,
	Channel_Configuration    = 10,
	_Reserved_3              = 11,
	Frame_Threads            = 12,
	Slice_Threads            = 13,
	Parameter_Change         = 14,
	Other_Threads            = 15,
	Variable_Frame_Size      = 16,
	Avoid_Probing            = 17,
	Hardware                 = 18,
	Hybrid                   = 19, // Potentially backed by hardware encoder, but can fall back to software.
	Encoder_Reordered_Opaque = 20,
	Encoder_Flush            = 21,
}
Codec_Capabilities :: bit_set[Codec_Capability; c.int]

Profile :: struct {
	id:                    c.int,
	name:                  cstring,
}

Channel :: enum c.uint64_t {
	Front_Left            =  0,
	Front_Right           =  1,
	Front_Center          =  2,
	Low_Frequency         =  3,
	Back_Left             =  4,
	Back_Right            =  5,
	Front_Left_of_Center  =  6,
	Front_Right_of_Center =  7,
	Back_Center           =  8,
	Side_Left             =  9,
	Side_Right            = 10,
	Top_Center            = 11,
	Top_Front_Left        = 12,
	Top_Front_Center      = 13,
	Top_Front_Right       = 14,
	Top_Back_Left         = 15,
	Top_Back_Center       = 16,
	Top_Back_Right        = 17,
	Stereo_Left           = 29, ///< Stereo downmix.
	Stereo_Right          = 30, ///< See STEREO_LEFT.
	Wide_Left             = 31,
	Wide_Right            = 32,
	Surround_Direct_Left  = 33,
	Surround_Direct_Right = 34,
	Low_Frequency_2       = 35,
	Top_Side_Left         = 36,
	Top_Side_Right        = 37,
}
Channel_Layout :: bit_set[Channel; c.uint64_t]

Codec :: struct {
	name:                  cstring,
	long_name:             cstring,
	type:                  Media_Type,
	id:                    Codec_ID,
	capabilities:          Codec_Capabilities,
	max_lowres:            c.uint8_t,

	supported_framerates:  [^]Rational,      // Array of supported framerates,        or NULL if any framerate. Terminated by {0, 0}
	pixel_formats:         [^]Pixel_Format,  // Array of supported pixel formats,     or NULL if unknown.       Terminated by -1
	supported_samplerates: [^]c.int,                // Array of supported audio samplerates, or NULL if unknown.       Terminated by 0
	sample_formats:        [^]Sample_Format, // Array of supported sample formats,    or NULL if unknown.       Terminated by -1
	channel_layouts:       [^]Channel_Layout,       // Array of supported channel layouts,   or NULL if unknown.       Terminated by 0

	priv_class:            ^Class,
	profiles:              [^]Profile,              // Array of recognized profiles,         or NULL if unknown.        Terminated by .Profile_Unknown

	wrapper_name:          cstring,
}

/*
	main external API structure.

	New fields can be added to the end with minor version bumps.
	Removal, reordering and changes to existing fields require a major version bump.
	You can use AVOptions (av_opt* / av_set/get*()) to access these fields from user applications.
	The name string for AVOptions options matches the associated command line
	parameter name and can be found in libavcodec/options_table.h
	The AVOption/command line parameter names differ in some cases from the C
	structure field names for historic reasons or brevity.
	sizeof(AVCodecContext) must not be used outside libav*.
*/
Codec_Context :: struct {
	av_class:         ^Class,
	log_level_offset: c.int,

	codec_type:       Media_Type,
	codec:            ^Codec,
	codec_id:         Codec_ID,

	codec_tag: FourCC,
/*

	void *priv_data;

	/**
	 * Private context used for internal data.
	 *
	 * Unlike priv_data, this is not codec-specific. It is used in general
	 * libavcodec functions.
	 */
	struct AVCodecInternal *internal;

	/**
	 * Private data of the user, can be used to carry app specific stuff.
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	void *opaque;

	/**
	 * the average bitrate
	 * - encoding: Set by user; unused for constant quantizer encoding.
	 * - decoding: Set by user, may be overwritten by libavcodec
	 *             if this info is available in the stream
	 */
	int64_t bit_rate;

	/**
	 * number of bits the bitstream is allowed to diverge from the reference.
	 *           the reference can be CBR (for CBR pass1) or VBR (for pass2)
	 * - encoding: Set by user; unused for constant quantizer encoding.
	 * - decoding: unused
	 */
	int bit_rate_tolerance;

	/**
	 * Global quality for codecs which cannot change it per frame.
	 * This should be proportional to MPEG-1/2/4 qscale.
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int global_quality;

	/**
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int compression_level;
#define FF_COMPRESSION_DEFAULT -1

	/**
	 * AV_CODEC_FLAG_*.
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	int flags;

	/**
	 * AV_CODEC_FLAG2_*
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	int flags2;

	/**
	 * some codecs need / can use extradata like Huffman tables.
	 * MJPEG: Huffman tables
	 * rv10: additional flags
	 * MPEG-4: global headers (they can be in the bitstream or here)
	 * The allocated memory should be AV_INPUT_BUFFER_PADDING_SIZE bytes larger
	 * than extradata_size to avoid problems if it is read with the bitstream reader.
	 * The bytewise contents of extradata must not depend on the architecture or CPU endianness.
	 * Must be allocated with the av_malloc() family of functions.
	 * - encoding: Set/allocated/freed by libavcodec.
	 * - decoding: Set/allocated/freed by user.
	 */
	uint8_t *extradata;
	int extradata_size;

	/**
	 * This is the fundamental unit of time (in seconds) in terms
	 * of which frame timestamps are represented. For fixed-fps content,
	 * timebase should be 1/framerate and timestamp increments should be
	 * identically 1.
	 * This often, but not always is the inverse of the frame rate or field rate
	 * for video. 1/time_base is not the average frame rate if the frame rate is not
	 * constant.
	 *
	 * Like containers, elementary streams also can store timestamps, 1/time_base
	 * is the unit in which these timestamps are specified.
	 * As example of such codec time base see ISO/IEC 14496-2:2001(E)
	 * vop_time_increment_resolution and fixed_vop_rate
	 * (fixed_vop_rate == 0 implies that it is different from the framerate)
	 *
	 * - encoding: MUST be set by user.
	 * - decoding: the use of this field for decoding is deprecated.
	 *             Use framerate instead.
	 */
	AVRational time_base;

	/**
	 * For some codecs, the time base is closer to the field rate than the frame rate.
	 * Most notably, H.264 and MPEG-2 specify time_base as half of frame duration
	 * if no telecine is used ...
	 *
	 * Set to time_base ticks per frame. Default 1, e.g., H.264/MPEG-2 set it to 2.
	 */
	int ticks_per_frame;

	/**
	 * Codec delay.
	 *
	 * Encoding: Number of frames delay there will be from the encoder input to
	 *           the decoder output. (we assume the decoder matches the spec)
	 * Decoding: Number of frames delay in addition to what a standard decoder
	 *           as specified in the spec would produce.
	 *
	 * Video:
	 *   Number of frames the decoded output will be delayed relative to the
	 *   encoded input.
	 *
	 * Audio:
	 *   For encoding, this field is unused (see initial_padding).
	 *
	 *   For decoding, this is the number of samples the decoder needs to
	 *   output before the decoder's output is valid. When seeking, you should
	 *   start decoding this many samples prior to your desired seek point.
	 *
	 * - encoding: Set by libavcodec.
	 * - decoding: Set by libavcodec.
	 */
	int delay;


	/* video only */
	/**
	 * picture width / height.
	 *
	 * @note Those fields may not match the values of the last
	 * AVFrame output by avcodec_decode_video2 due frame
	 * reordering.
	 *
	 * - encoding: MUST be set by user.
	 * - decoding: May be set by the user before opening the decoder if known e.g.
	 *             from the container. Some decoders will require the dimensions
	 *             to be set by the caller. During decoding, the decoder may
	 *             overwrite those values as required while parsing the data.
	 */
	int width, height;

	/**
	 * Bitstream width / height, may be different from width/height e.g. when
	 * the decoded frame is cropped before being output or lowres is enabled.
	 *
	 * @note Those field may not match the value of the last
	 * AVFrame output by avcodec_receive_frame() due frame
	 * reordering.
	 *
	 * - encoding: unused
	 * - decoding: May be set by the user before opening the decoder if known
	 *             e.g. from the container. During decoding, the decoder may
	 *             overwrite those values as required while parsing the data.
	 */
	int coded_width, coded_height;

	/**
	 * the number of pictures in a group of pictures, or 0 for intra_only
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int gop_size;

	/**
	 * Pixel format, see AV_PIX_FMT_xxx.
	 * May be set by the demuxer if known from headers.
	 * May be overridden by the decoder if it knows better.
	 *
	 * @note This field may not match the value of the last
	 * AVFrame output by avcodec_receive_frame() due frame
	 * reordering.
	 *
	 * - encoding: Set by user.
	 * - decoding: Set by user if known, overridden by libavcodec while
	 *             parsing the data.
	 */
	enum AVPixelFormat pix_fmt;

	/**
	 * If non NULL, 'draw_horiz_band' is called by the libavcodec
	 * decoder to draw a horizontal band. It improves cache usage. Not
	 * all codecs can do that. You must check the codec capabilities
	 * beforehand.
	 * When multithreading is used, it may be called from multiple threads
	 * at the same time; threads might draw different parts of the same AVFrame,
	 * or multiple AVFrames, and there is no guarantee that slices will be drawn
	 * in order.
	 * The function is also used by hardware acceleration APIs.
	 * It is called at least once during frame decoding to pass
	 * the data needed for hardware render.
	 * In that mode instead of pixel data, AVFrame points to
	 * a structure specific to the acceleration API. The application
	 * reads the structure and can change some fields to indicate progress
	 * or mark state.
	 * - encoding: unused
	 * - decoding: Set by user.
	 * @param height the height of the slice
	 * @param y the y position of the slice
	 * @param type 1->top field, 2->bottom field, 3->frame
	 * @param offset offset into the AVFrame.data from which the slice should be read
	 */
	void (*draw_horiz_band)(struct AVCodecContext *s,
							const AVFrame *src, int offset[AV_NUM_DATA_POINTERS],
							int y, int type, int height);

	/**
	 * callback to negotiate the pixelFormat
	 * @param fmt is the list of formats which are supported by the codec,
	 * it is terminated by -1 as 0 is a valid format, the formats are ordered by quality.
	 * The first is always the native one.
	 * @note The callback may be called again immediately if initialization for
	 * the selected (hardware-accelerated) pixel format failed.
	 * @warning Behavior is undefined if the callback returns a value not
	 * in the fmt list of formats.
	 * @return the chosen format
	 * - encoding: unused
	 * - decoding: Set by user, if not set the native format will be chosen.
	 */
	enum AVPixelFormat (*get_format)(struct AVCodecContext *s, const enum AVPixelFormat * fmt);

	/**
	 * maximum number of B-frames between non-B-frames
	 * Note: The output will be delayed by max_b_frames+1 relative to the input.
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int max_b_frames;

	/**
	 * qscale factor between IP and B-frames
	 * If > 0 then the last P-frame quantizer will be used (q= lastp_q*factor+offset).
	 * If < 0 then normal ratecontrol will be done (q= -normal_q*factor+offset).
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	float b_quant_factor;

#if FF_API_PRIVATE_OPT
	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int b_frame_strategy;
#endif

	/**
	 * qscale offset between IP and B-frames
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	float b_quant_offset;

	/**
	 * Size of the frame reordering buffer in the decoder.
	 * For MPEG-2 it is 1 IPB or 0 low delay IP.
	 * - encoding: Set by libavcodec.
	 * - decoding: Set by libavcodec.
	 */
	int has_b_frames;

#if FF_API_PRIVATE_OPT
	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int mpeg_quant;
#endif

	/**
	 * qscale factor between P- and I-frames
	 * If > 0 then the last P-frame quantizer will be used (q = lastp_q * factor + offset).
	 * If < 0 then normal ratecontrol will be done (q= -normal_q*factor+offset).
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	float i_quant_factor;

	/**
	 * qscale offset between P and I-frames
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	float i_quant_offset;

	/**
	 * luminance masking (0-> disabled)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	float lumi_masking;

	/**
	 * temporary complexity masking (0-> disabled)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	float temporal_cplx_masking;

	/**
	 * spatial complexity masking (0-> disabled)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	float spatial_cplx_masking;

	/**
	 * p block masking (0-> disabled)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	float p_masking;

	/**
	 * darkness masking (0-> disabled)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	float dark_masking;

	/**
	 * slice count
	 * - encoding: Set by libavcodec.
	 * - decoding: Set by user (or 0).
	 */
	int slice_count;

#if FF_API_PRIVATE_OPT
	/** @deprecated use encoder private options instead */
	attribute_deprecated
	 int prediction_method;
#define FF_PRED_LEFT   0
#define FF_PRED_PLANE  1
#define FF_PRED_MEDIAN 2
#endif

	/**
	 * slice offsets in the frame in bytes
	 * - encoding: Set/allocated by libavcodec.
	 * - decoding: Set/allocated by user (or NULL).
	 */
	int *slice_offset;

	/**
	 * sample aspect ratio (0 if unknown)
	 * That is the width of a pixel divided by the height of the pixel.
	 * Numerator and denominator must be relatively prime and smaller than 256 for some video standards.
	 * - encoding: Set by user.
	 * - decoding: Set by libavcodec.
	 */
	AVRational sample_aspect_ratio;

	/**
	 * motion estimation comparison function
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int me_cmp;
	/**
	 * subpixel motion estimation comparison function
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int me_sub_cmp;
	/**
	 * macroblock comparison function (not supported yet)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int mb_cmp;
	/**
	 * interlaced DCT comparison function
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int ildct_cmp;
#define FF_CMP_SAD          0
#define FF_CMP_SSE          1
#define FF_CMP_SATD         2
#define FF_CMP_DCT          3
#define FF_CMP_PSNR         4
#define FF_CMP_BIT          5
#define FF_CMP_RD           6
#define FF_CMP_ZERO         7
#define FF_CMP_VSAD         8
#define FF_CMP_VSSE         9
#define FF_CMP_NSSE         10
#define FF_CMP_W53          11
#define FF_CMP_W97          12
#define FF_CMP_DCTMAX       13
#define FF_CMP_DCT264       14
#define FF_CMP_MEDIAN_SAD   15
#define FF_CMP_CHROMA       256

	/**
	 * ME diamond size & shape
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int dia_size;

	/**
	 * amount of previous MV predictors (2a+1 x 2a+1 square)
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int last_predictor_count;

#if FF_API_PRIVATE_OPT
	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int pre_me;
#endif

	/**
	 * motion estimation prepass comparison function
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int me_pre_cmp;

	/**
	 * ME prepass diamond size & shape
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int pre_dia_size;

	/**
	 * subpel ME quality
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int me_subpel_quality;

	/**
	 * maximum motion estimation search range in subpel units
	 * If 0 then no limit.
	 *
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int me_range;

	/**
	 * slice flags
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	int slice_flags;
#define SLICE_FLAG_CODED_ORDER    0x0001 ///< draw_horiz_band() is called in coded order instead of display
#define SLICE_FLAG_ALLOW_FIELD    0x0002 ///< allow draw_horiz_band() with field slices (MPEG-2 field pics)
#define SLICE_FLAG_ALLOW_PLANE    0x0004 ///< allow draw_horiz_band() with 1 component at a time (SVQ1)

	/**
	 * macroblock decision mode
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int mb_decision;
#define FF_MB_DECISION_SIMPLE 0        ///< uses mb_cmp
#define FF_MB_DECISION_BITS   1        ///< chooses the one which needs the fewest bits
#define FF_MB_DECISION_RD     2        ///< rate distortion

	/**
	 * custom intra quantization matrix
	 * Must be allocated with the av_malloc() family of functions, and will be freed in
	 * avcodec_free_context().
	 * - encoding: Set/allocated by user, freed by libavcodec. Can be NULL.
	 * - decoding: Set/allocated/freed by libavcodec.
	 */
	uint16_t *intra_matrix;

	/**
	 * custom inter quantization matrix
	 * Must be allocated with the av_malloc() family of functions, and will be freed in
	 * avcodec_free_context().
	 * - encoding: Set/allocated by user, freed by libavcodec. Can be NULL.
	 * - decoding: Set/allocated/freed by libavcodec.
	 */
	uint16_t *inter_matrix;

#if FF_API_PRIVATE_OPT
	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int scenechange_threshold;

	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int noise_reduction;
#endif

	/**
	 * precision of the intra DC coefficient - 8
	 * - encoding: Set by user.
	 * - decoding: Set by libavcodec
	 */
	int intra_dc_precision;

	/**
	 * Number of macroblock rows at the top which are skipped.
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	int skip_top;

	/**
	 * Number of macroblock rows at the bottom which are skipped.
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	int skip_bottom;

	/**
	 * minimum MB Lagrange multiplier
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int mb_lmin;

	/**
	 * maximum MB Lagrange multiplier
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int mb_lmax;

#if FF_API_PRIVATE_OPT
	/**
	 * @deprecated use encoder private options instead
	 */
	attribute_deprecated
	int me_penalty_compensation;
#endif

	/**
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int bidir_refine;

#if FF_API_PRIVATE_OPT
	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int brd_scale;
#endif

	/**
	 * minimum GOP size
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int keyint_min;

	/**
	 * number of reference frames
	 * - encoding: Set by user.
	 * - decoding: Set by lavc.
	 */
	int refs;

#if FF_API_PRIVATE_OPT
	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int chromaoffset;
#endif

	/**
	 * Note: Value depends upon the compare function used for fullpel ME.
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int mv0_threshold;

#if FF_API_PRIVATE_OPT
	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int b_sensitivity;
#endif

	/**
	 * Chromaticity coordinates of the source primaries.
	 * - encoding: Set by user
	 * - decoding: Set by libavcodec
	 */
	enum AVColorPrimaries color_primaries;

	/**
	 * Color Transfer Characteristic.
	 * - encoding: Set by user
	 * - decoding: Set by libavcodec
	 */
	enum AVColorTransferCharacteristic color_trc;

	/**
	 * YUV colorspace type.
	 * - encoding: Set by user
	 * - decoding: Set by libavcodec
	 */
	enum AVColorSpace colorspace;

	/**
	 * MPEG vs JPEG YUV range.
	 * - encoding: Set by user
	 * - decoding: Set by libavcodec
	 */
	enum AVColorRange color_range;

	/**
	 * This defines the location of chroma samples.
	 * - encoding: Set by user
	 * - decoding: Set by libavcodec
	 */
	enum AVChromaLocation chroma_sample_location;

	/**
	 * Number of slices.
	 * Indicates number of picture subdivisions. Used for parallelized
	 * decoding.
	 * - encoding: Set by user
	 * - decoding: unused
	 */
	int slices;

	/** Field order
	 * - encoding: set by libavcodec
	 * - decoding: Set by user.
	 */
	enum AVFieldOrder field_order;

	/* audio only */
	int sample_rate; ///< samples per second
	int channels;    ///< number of audio channels

	/**
	 * audio sample format
	 * - encoding: Set by user.
	 * - decoding: Set by libavcodec.
	 */
	enum AVSampleFormat sample_fmt;  ///< sample format

	/* The following data should not be initialized. */
	/**
	 * Number of samples per channel in an audio frame.
	 *
	 * - encoding: set by libavcodec in avcodec_open2(). Each submitted frame
	 *   except the last must contain exactly frame_size samples per channel.
	 *   May be 0 when the codec has AV_CODEC_CAP_VARIABLE_FRAME_SIZE set, then the
	 *   frame size is not restricted.
	 * - decoding: may be set by some decoders to indicate constant frame size
	 */
	int frame_size;

	/**
	 * Frame counter, set by libavcodec.
	 *
	 * - decoding: total number of frames returned from the decoder so far.
	 * - encoding: total number of frames passed to the encoder so far.
	 *
	 *   @note the counter is not incremented if encoding/decoding resulted in
	 *   an error.
	 */
	int frame_number;

	/**
	 * number of bytes per packet if constant and known or 0
	 * Used by some WAV based audio codecs.
	 */
	int block_align;

	/**
	 * Audio cutoff bandwidth (0 means "automatic")
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int cutoff;

	/**
	 * Audio channel layout.
	 * - encoding: set by user.
	 * - decoding: set by user, may be overwritten by libavcodec.
	 */
	uint64_t channel_layout;

	/**
	 * Request decoder to use this channel layout if it can (0 for default)
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	uint64_t request_channel_layout;

	/**
	 * Type of service that the audio stream conveys.
	 * - encoding: Set by user.
	 * - decoding: Set by libavcodec.
	 */
	enum AVAudioServiceType audio_service_type;

	/**
	 * desired sample format
	 * - encoding: Not used.
	 * - decoding: Set by user.
	 * Decoder will decode to this format if it can.
	 */
	enum AVSampleFormat request_sample_fmt;

	/**
	 * This callback is called at the beginning of each frame to get data
	 * buffer(s) for it. There may be one contiguous buffer for all the data or
	 * there may be a buffer per each data plane or anything in between. What
	 * this means is, you may set however many entries in buf[] you feel necessary.
	 * Each buffer must be reference-counted using the AVBuffer API (see description
	 * of buf[] below).
	 *
	 * The following fields will be set in the frame before this callback is
	 * called:
	 * - format
	 * - width, height (video only)
	 * - sample_rate, channel_layout, nb_samples (audio only)
	 * Their values may differ from the corresponding values in
	 * AVCodecContext. This callback must use the frame values, not the codec
	 * context values, to calculate the required buffer size.
	 *
	 * This callback must fill the following fields in the frame:
	 * - data[]
	 * - linesize[]
	 * - extended_data:
	 *   * if the data is planar audio with more than 8 channels, then this
	 *     callback must allocate and fill extended_data to contain all pointers
	 *     to all data planes. data[] must hold as many pointers as it can.
	 *     extended_data must be allocated with av_malloc() and will be freed in
	 *     av_frame_unref().
	 *   * otherwise extended_data must point to data
	 * - buf[] must contain one or more pointers to AVBufferRef structures. Each of
	 *   the frame's data and extended_data pointers must be contained in these. That
	 *   is, one AVBufferRef for each allocated chunk of memory, not necessarily one
	 *   AVBufferRef per data[] entry. See: av_buffer_create(), av_buffer_alloc(),
	 *   and av_buffer_ref().
	 * - extended_buf and nb_extended_buf must be allocated with av_malloc() by
	 *   this callback and filled with the extra buffers if there are more
	 *   buffers than buf[] can hold. extended_buf will be freed in
	 *   av_frame_unref().
	 *
	 * If AV_CODEC_CAP_DR1 is not set then get_buffer2() must call
	 * avcodec_default_get_buffer2() instead of providing buffers allocated by
	 * some other means.
	 *
	 * Each data plane must be aligned to the maximum required by the target
	 * CPU.
	 *
	 * @see avcodec_default_get_buffer2()
	 *
	 * Video:
	 *
	 * If AV_GET_BUFFER_FLAG_REF is set in flags then the frame may be reused
	 * (read and/or written to if it is writable) later by libavcodec.
	 *
	 * avcodec_align_dimensions2() should be used to find the required width and
	 * height, as they normally need to be rounded up to the next multiple of 16.
	 *
	 * Some decoders do not support linesizes changing between frames.
	 *
	 * If frame multithreading is used, this callback may be called from a
	 * different thread, but not from more than one at once. Does not need to be
	 * reentrant.
	 *
	 * @see avcodec_align_dimensions2()
	 *
	 * Audio:
	 *
	 * Decoders request a buffer of a particular size by setting
	 * AVFrame.nb_samples prior to calling get_buffer2(). The decoder may,
	 * however, utilize only part of the buffer by setting AVFrame.nb_samples
	 * to a smaller value in the output frame.
	 *
	 * As a convenience, av_samples_get_buffer_size() and
	 * av_samples_fill_arrays() in libavutil may be used by custom get_buffer2()
	 * functions to find the required data size and to fill data pointers and
	 * linesize. In AVFrame.linesize, only linesize[0] may be set for audio
	 * since all planes must be the same size.
	 *
	 * @see av_samples_get_buffer_size(), av_samples_fill_arrays()
	 *
	 * - encoding: unused
	 * - decoding: Set by libavcodec, user can override.
	 */
	int (*get_buffer2)(struct AVCodecContext *s, AVFrame *frame, int flags);

#if FF_API_OLD_ENCDEC
	/**
	 * If non-zero, the decoded audio and video frames returned from
	 * avcodec_decode_video2() and avcodec_decode_audio4() are reference-counted
	 * and are valid indefinitely. The caller must free them with
	 * av_frame_unref() when they are not needed anymore.
	 * Otherwise, the decoded frames must not be freed by the caller and are
	 * only valid until the next decode call.
	 *
	 * This is always automatically enabled if avcodec_receive_frame() is used.
	 *
	 * - encoding: unused
	 * - decoding: set by the caller before avcodec_open2().
	 */
	attribute_deprecated
	int refcounted_frames;
#endif

	/* - encoding parameters */
	float qcompress;  ///< amount of qscale change between easy & hard scenes (0.0-1.0)
	float qblur;      ///< amount of qscale smoothing over time (0.0-1.0)

	/**
	 * minimum quantizer
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int qmin;

	/**
	 * maximum quantizer
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int qmax;

	/**
	 * maximum quantizer difference between frames
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int max_qdiff;

	/**
	 * decoder bitstream buffer size
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int rc_buffer_size;

	/**
	 * ratecontrol override, see RcOverride
	 * - encoding: Allocated/set/freed by user.
	 * - decoding: unused
	 */
	int rc_override_count;
	RcOverride *rc_override;

	/**
	 * maximum bitrate
	 * - encoding: Set by user.
	 * - decoding: Set by user, may be overwritten by libavcodec.
	 */
	int64_t rc_max_rate;

	/**
	 * minimum bitrate
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int64_t rc_min_rate;

	/**
	 * Ratecontrol attempt to use, at maximum, <value> of what can be used without an underflow.
	 * - encoding: Set by user.
	 * - decoding: unused.
	 */
	float rc_max_available_vbv_use;

	/**
	 * Ratecontrol attempt to use, at least, <value> times the amount needed to prevent a vbv overflow.
	 * - encoding: Set by user.
	 * - decoding: unused.
	 */
	float rc_min_vbv_overflow_use;

	/**
	 * Number of bits which should be loaded into the rc buffer before decoding starts.
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int rc_initial_buffer_occupancy;

#if FF_API_CODER_TYPE
#define FF_CODER_TYPE_VLC       0
#define FF_CODER_TYPE_AC        1
#define FF_CODER_TYPE_RAW       2
#define FF_CODER_TYPE_RLE       3
	/**
	 * @deprecated use encoder private options instead
	 */
	attribute_deprecated
	int coder_type;
#endif /* FF_API_CODER_TYPE */

#if FF_API_PRIVATE_OPT
	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int context_model;
#endif

#if FF_API_PRIVATE_OPT
	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int frame_skip_threshold;

	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int frame_skip_factor;

	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int frame_skip_exp;

	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int frame_skip_cmp;
#endif /* FF_API_PRIVATE_OPT */

	/**
	 * trellis RD quantization
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int trellis;

#if FF_API_PRIVATE_OPT
	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int min_prediction_order;

	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int max_prediction_order;

	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int64_t timecode_frame_start;
#endif

#if FF_API_RTP_CALLBACK
	/**
	 * @deprecated unused
	 */
	/* The RTP callback: This function is called    */
	/* every time the encoder has a packet to send. */
	/* It depends on the encoder if the data starts */
	/* with a Start Code (it should). H.263 does.   */
	/* mb_nb contains the number of macroblocks     */
	/* encoded in the RTP payload.                  */
	attribute_deprecated
	void (*rtp_callback)(struct AVCodecContext *avctx, void *data, int size, int mb_nb);
#endif

#if FF_API_PRIVATE_OPT
	/** @deprecated use encoder private options instead */
	attribute_deprecated
	int rtp_payload_size;   /* The size of the RTP payload: the coder will  */
							/* do its best to deliver a chunk with size     */
							/* below rtp_payload_size, the chunk will start */
							/* with a start code on some codecs like H.263. */
							/* This doesn't take account of any particular  */
							/* headers inside the transmitted RTP payload.  */
#endif

#if FF_API_STAT_BITS
	/* statistics, used for 2-pass encoding */
	attribute_deprecated
	int mv_bits;
	attribute_deprecated
	int header_bits;
	attribute_deprecated
	int i_tex_bits;
	attribute_deprecated
	int p_tex_bits;
	attribute_deprecated
	int i_count;
	attribute_deprecated
	int p_count;
	attribute_deprecated
	int skip_count;
	attribute_deprecated
	int misc_bits;

	/** @deprecated this field is unused */
	attribute_deprecated
	int frame_bits;
#endif

	/**
	 * pass1 encoding statistics output buffer
	 * - encoding: Set by libavcodec.
	 * - decoding: unused
	 */
	char *stats_out;

	/**
	 * pass2 encoding statistics input buffer
	 * Concatenated stuff from stats_out of pass1 should be placed here.
	 * - encoding: Allocated/set/freed by user.
	 * - decoding: unused
	 */
	char *stats_in;

	/**
	 * Work around bugs in encoders which sometimes cannot be detected automatically.
	 * - encoding: Set by user
	 * - decoding: Set by user
	 */
	int workaround_bugs;
#define FF_BUG_AUTODETECT       1  ///< autodetection
#define FF_BUG_XVID_ILACE       4
#define FF_BUG_UMP4             8
#define FF_BUG_NO_PADDING       16
#define FF_BUG_AMV              32
#define FF_BUG_QPEL_CHROMA      64
#define FF_BUG_STD_QPEL         128
#define FF_BUG_QPEL_CHROMA2     256
#define FF_BUG_DIRECT_BLOCKSIZE 512
#define FF_BUG_EDGE             1024
#define FF_BUG_HPEL_CHROMA      2048
#define FF_BUG_DC_CLIP          4096
#define FF_BUG_MS               8192 ///< Work around various bugs in Microsoft's broken decoders.
#define FF_BUG_TRUNCATED       16384
#define FF_BUG_IEDGE           32768

	/**
	 * strictly follow the standard (MPEG-4, ...).
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 * Setting this to STRICT or higher means the encoder and decoder will
	 * generally do stupid things, whereas setting it to unofficial or lower
	 * will mean the encoder might produce output that is not supported by all
	 * spec-compliant decoders. Decoders don't differentiate between normal,
	 * unofficial and experimental (that is, they always try to decode things
	 * when they can) unless they are explicitly asked to behave stupidly
	 * (=strictly conform to the specs)
	 */
	int strict_std_compliance;
#define FF_COMPLIANCE_VERY_STRICT   2 ///< Strictly conform to an older more strict version of the spec or reference software.
#define FF_COMPLIANCE_STRICT        1 ///< Strictly conform to all the things in the spec no matter what consequences.
#define FF_COMPLIANCE_NORMAL        0
#define FF_COMPLIANCE_UNOFFICIAL   -1 ///< Allow unofficial extensions
#define FF_COMPLIANCE_EXPERIMENTAL -2 ///< Allow nonstandardized experimental things.

	/**
	 * error concealment flags
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	int error_concealment;
#define FF_EC_GUESS_MVS   1
#define FF_EC_DEBLOCK     2
#define FF_EC_FAVOR_INTER 256

	/**
	 * debug
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	int debug;
#define FF_DEBUG_PICT_INFO   1
#define FF_DEBUG_RC          2
#define FF_DEBUG_BITSTREAM   4
#define FF_DEBUG_MB_TYPE     8
#define FF_DEBUG_QP          16
#define FF_DEBUG_DCT_COEFF   0x00000040
#define FF_DEBUG_SKIP        0x00000080
#define FF_DEBUG_STARTCODE   0x00000100
#define FF_DEBUG_ER          0x00000400
#define FF_DEBUG_MMCO        0x00000800
#define FF_DEBUG_BUGS        0x00001000
#define FF_DEBUG_BUFFERS     0x00008000
#define FF_DEBUG_THREADS     0x00010000
#define FF_DEBUG_GREEN_MD    0x00800000
#define FF_DEBUG_NOMC        0x01000000

	/**
	 * Error recognition; may misdetect some more or less valid parts as errors.
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	int err_recognition;

/**
 * Verify checksums embedded in the bitstream (could be of either encoded or
 * decoded data, depending on the codec) and print an error message on mismatch.
 * If AV_EF_EXPLODE is also set, a mismatching checksum will result in the
 * decoder returning an error.
 */
#define AV_EF_CRCCHECK  (1<<0)
#define AV_EF_BITSTREAM (1<<1)          ///< detect bitstream specification deviations
#define AV_EF_BUFFER    (1<<2)          ///< detect improper bitstream length
#define AV_EF_EXPLODE   (1<<3)          ///< abort decoding on minor error detection

#define AV_EF_IGNORE_ERR (1<<15)        ///< ignore errors and continue
#define AV_EF_CAREFUL    (1<<16)        ///< consider things that violate the spec, are fast to calculate and have not been seen in the wild as errors
#define AV_EF_COMPLIANT  (1<<17)        ///< consider all spec non compliances as errors
#define AV_EF_AGGRESSIVE (1<<18)        ///< consider things that a sane encoder should not do as an error


	/**
	 * opaque 64-bit number (generally a PTS) that will be reordered and
	 * output in AVFrame.reordered_opaque
	 * - encoding: Set by libavcodec to the reordered_opaque of the input
	 *             frame corresponding to the last returned packet. Only
	 *             supported by encoders with the
	 *             AV_CODEC_CAP_ENCODER_REORDERED_OPAQUE capability.
	 * - decoding: Set by user.
	 */
	int64_t reordered_opaque;

	/**
	 * Hardware accelerator in use
	 * - encoding: unused.
	 * - decoding: Set by libavcodec
	 */
	const struct AVHWAccel *hwaccel;

	/**
	 * Hardware accelerator context.
	 * For some hardware accelerators, a global context needs to be
	 * provided by the user. In that case, this holds display-dependent
	 * data FFmpeg cannot instantiate itself. Please refer to the
	 * FFmpeg HW accelerator documentation to know how to fill this
	 * is. e.g. for VA API, this is a struct vaapi_context.
	 * - encoding: unused
	 * - decoding: Set by user
	 */
	void *hwaccel_context;

	/**
	 * error
	 * - encoding: Set by libavcodec if flags & AV_CODEC_FLAG_PSNR.
	 * - decoding: unused
	 */
	uint64_t error[AV_NUM_DATA_POINTERS];

	/**
	 * DCT algorithm, see FF_DCT_* below
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	int dct_algo;
#define FF_DCT_AUTO    0
#define FF_DCT_FASTINT 1
#define FF_DCT_INT     2
#define FF_DCT_MMX     3
#define FF_DCT_ALTIVEC 5
#define FF_DCT_FAAN    6

	/**
	 * IDCT algorithm, see FF_IDCT_* below.
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	int idct_algo;
#define FF_IDCT_AUTO          0
#define FF_IDCT_INT           1
#define FF_IDCT_SIMPLE        2
#define FF_IDCT_SIMPLEMMX     3
#define FF_IDCT_ARM           7
#define FF_IDCT_ALTIVEC       8
#define FF_IDCT_SIMPLEARM     10
#define FF_IDCT_XVID          14
#define FF_IDCT_SIMPLEARMV5TE 16
#define FF_IDCT_SIMPLEARMV6   17
#define FF_IDCT_FAAN          20
#define FF_IDCT_SIMPLENEON    22
#define FF_IDCT_NONE          24 /* Used by XvMC to extract IDCT coefficients with FF_IDCT_PERM_NONE */
#define FF_IDCT_SIMPLEAUTO    128

	/**
	 * bits per sample/pixel from the demuxer (needed for huffyuv).
	 * - encoding: Set by libavcodec.
	 * - decoding: Set by user.
	 */
	 int bits_per_coded_sample;

	/**
	 * Bits per sample/pixel of internal libavcodec pixel/sample format.
	 * - encoding: set by user.
	 * - decoding: set by libavcodec.
	 */
	int bits_per_raw_sample;

	/**
	 * low resolution decoding, 1-> 1/2 size, 2->1/4 size
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	 int lowres;

#if FF_API_CODED_FRAME
	/**
	 * the picture in the bitstream
	 * - encoding: Set by libavcodec.
	 * - decoding: unused
	 *
	 * @deprecated use the quality factor packet side data instead
	 */
	attribute_deprecated AVFrame *coded_frame;
#endif

	/**
	 * thread count
	 * is used to decide how many independent tasks should be passed to execute()
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	int thread_count;

	/**
	 * Which multithreading methods to use.
	 * Use of FF_THREAD_FRAME will increase decoding delay by one frame per thread,
	 * so clients which cannot provide future frames should not use it.
	 *
	 * - encoding: Set by user, otherwise the default is used.
	 * - decoding: Set by user, otherwise the default is used.
	 */
	int thread_type;
#define FF_THREAD_FRAME   1 ///< Decode more than one frame at once
#define FF_THREAD_SLICE   2 ///< Decode more than one part of a single frame at once

	/**
	 * Which multithreading methods are in use by the codec.
	 * - encoding: Set by libavcodec.
	 * - decoding: Set by libavcodec.
	 */
	int active_thread_type;

#if FF_API_THREAD_SAFE_CALLBACKS
	/**
	 * Set by the client if its custom get_buffer() callback can be called
	 * synchronously from another thread, which allows faster multithreaded decoding.
	 * draw_horiz_band() will be called from other threads regardless of this setting.
	 * Ignored if the default get_buffer() is used.
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 *
	 * @deprecated the custom get_buffer2() callback should always be
	 *   thread-safe. Thread-unsafe get_buffer2() implementations will be
	 *   invalid starting with LIBAVCODEC_VERSION_MAJOR=60; in other words,
	 *   libavcodec will behave as if this field was always set to 1.
	 *   Callers that want to be forward compatible with future libavcodec
	 *   versions should wrap access to this field in
	 *     #if LIBAVCODEC_VERSION_MAJOR < 60
	 */
	attribute_deprecated
	int thread_safe_callbacks;
#endif

	/**
	 * The codec may call this to execute several independent things.
	 * It will return only after finishing all tasks.
	 * The user may replace this with some multithreaded implementation,
	 * the default implementation will execute the parts serially.
	 * @param count the number of things to execute
	 * - encoding: Set by libavcodec, user can override.
	 * - decoding: Set by libavcodec, user can override.
	 */
	int (*execute)(struct AVCodecContext *c, int (*func)(struct AVCodecContext *c2, void *arg), void *arg2, int *ret, int count, int size);

	/**
	 * The codec may call this to execute several independent things.
	 * It will return only after finishing all tasks.
	 * The user may replace this with some multithreaded implementation,
	 * the default implementation will execute the parts serially.
	 * Also see avcodec_thread_init and e.g. the --enable-pthread configure option.
	 * @param c context passed also to func
	 * @param count the number of things to execute
	 * @param arg2 argument passed unchanged to func
	 * @param ret return values of executed functions, must have space for "count" values. May be NULL.
	 * @param func function that will be called count times, with jobnr from 0 to count-1.
	 *             threadnr will be in the range 0 to c->thread_count-1 < MAX_THREADS and so that no
	 *             two instances of func executing at the same time will have the same threadnr.
	 * @return always 0 currently, but code should handle a future improvement where when any call to func
	 *         returns < 0 no further calls to func may be done and < 0 is returned.
	 * - encoding: Set by libavcodec, user can override.
	 * - decoding: Set by libavcodec, user can override.
	 */
	int (*execute2)(struct AVCodecContext *c, int (*func)(struct AVCodecContext *c2, void *arg, int jobnr, int threadnr), void *arg2, int *ret, int count);

	/**
	 * noise vs. sse weight for the nsse comparison function
	 * - encoding: Set by user.
	 * - decoding: unused
	 */
	 int nsse_weight;

	/**
	 * profile
	 * - encoding: Set by user.
	 * - decoding: Set by libavcodec.
	 */
	 int profile;
#define FF_PROFILE_UNKNOWN -99
#define FF_PROFILE_RESERVED -100

#define FF_PROFILE_AAC_MAIN 0
#define FF_PROFILE_AAC_LOW  1
#define FF_PROFILE_AAC_SSR  2
#define FF_PROFILE_AAC_LTP  3
#define FF_PROFILE_AAC_HE   4
#define FF_PROFILE_AAC_HE_V2 28
#define FF_PROFILE_AAC_LD   22
#define FF_PROFILE_AAC_ELD  38
#define FF_PROFILE_MPEG2_AAC_LOW 128
#define FF_PROFILE_MPEG2_AAC_HE  131

#define FF_PROFILE_DNXHD         0
#define FF_PROFILE_DNXHR_LB      1
#define FF_PROFILE_DNXHR_SQ      2
#define FF_PROFILE_DNXHR_HQ      3
#define FF_PROFILE_DNXHR_HQX     4
#define FF_PROFILE_DNXHR_444     5

#define FF_PROFILE_DTS         20
#define FF_PROFILE_DTS_ES      30
#define FF_PROFILE_DTS_96_24   40
#define FF_PROFILE_DTS_HD_HRA  50
#define FF_PROFILE_DTS_HD_MA   60
#define FF_PROFILE_DTS_EXPRESS 70

#define FF_PROFILE_MPEG2_422    0
#define FF_PROFILE_MPEG2_HIGH   1
#define FF_PROFILE_MPEG2_SS     2
#define FF_PROFILE_MPEG2_SNR_SCALABLE  3
#define FF_PROFILE_MPEG2_MAIN   4
#define FF_PROFILE_MPEG2_SIMPLE 5

#define FF_PROFILE_H264_CONSTRAINED  (1<<9)  // 8+1; constraint_set1_flag
#define FF_PROFILE_H264_INTRA        (1<<11) // 8+3; constraint_set3_flag

#define FF_PROFILE_H264_BASELINE             66
#define FF_PROFILE_H264_CONSTRAINED_BASELINE (66|FF_PROFILE_H264_CONSTRAINED)
#define FF_PROFILE_H264_MAIN                 77
#define FF_PROFILE_H264_EXTENDED             88
#define FF_PROFILE_H264_HIGH                 100
#define FF_PROFILE_H264_HIGH_10              110
#define FF_PROFILE_H264_HIGH_10_INTRA        (110|FF_PROFILE_H264_INTRA)
#define FF_PROFILE_H264_MULTIVIEW_HIGH       118
#define FF_PROFILE_H264_HIGH_422             122
#define FF_PROFILE_H264_HIGH_422_INTRA       (122|FF_PROFILE_H264_INTRA)
#define FF_PROFILE_H264_STEREO_HIGH          128
#define FF_PROFILE_H264_HIGH_444             144
#define FF_PROFILE_H264_HIGH_444_PREDICTIVE  244
#define FF_PROFILE_H264_HIGH_444_INTRA       (244|FF_PROFILE_H264_INTRA)
#define FF_PROFILE_H264_CAVLC_444            44

#define FF_PROFILE_VC1_SIMPLE   0
#define FF_PROFILE_VC1_MAIN     1
#define FF_PROFILE_VC1_COMPLEX  2
#define FF_PROFILE_VC1_ADVANCED 3

#define FF_PROFILE_MPEG4_SIMPLE                     0
#define FF_PROFILE_MPEG4_SIMPLE_SCALABLE            1
#define FF_PROFILE_MPEG4_CORE                       2
#define FF_PROFILE_MPEG4_MAIN                       3
#define FF_PROFILE_MPEG4_N_BIT                      4
#define FF_PROFILE_MPEG4_SCALABLE_TEXTURE           5
#define FF_PROFILE_MPEG4_SIMPLE_FACE_ANIMATION      6
#define FF_PROFILE_MPEG4_BASIC_ANIMATED_TEXTURE     7
#define FF_PROFILE_MPEG4_HYBRID                     8
#define FF_PROFILE_MPEG4_ADVANCED_REAL_TIME         9
#define FF_PROFILE_MPEG4_CORE_SCALABLE             10
#define FF_PROFILE_MPEG4_ADVANCED_CODING           11
#define FF_PROFILE_MPEG4_ADVANCED_CORE             12
#define FF_PROFILE_MPEG4_ADVANCED_SCALABLE_TEXTURE 13
#define FF_PROFILE_MPEG4_SIMPLE_STUDIO             14
#define FF_PROFILE_MPEG4_ADVANCED_SIMPLE           15

#define FF_PROFILE_JPEG2000_CSTREAM_RESTRICTION_0   1
#define FF_PROFILE_JPEG2000_CSTREAM_RESTRICTION_1   2
#define FF_PROFILE_JPEG2000_CSTREAM_NO_RESTRICTION  32768
#define FF_PROFILE_JPEG2000_DCINEMA_2K              3
#define FF_PROFILE_JPEG2000_DCINEMA_4K              4

#define FF_PROFILE_VP9_0                            0
#define FF_PROFILE_VP9_1                            1
#define FF_PROFILE_VP9_2                            2
#define FF_PROFILE_VP9_3                            3

#define FF_PROFILE_HEVC_MAIN                        1
#define FF_PROFILE_HEVC_MAIN_10                     2
#define FF_PROFILE_HEVC_MAIN_STILL_PICTURE          3
#define FF_PROFILE_HEVC_REXT                        4

#define FF_PROFILE_VVC_MAIN_10                      1
#define FF_PROFILE_VVC_MAIN_10_444                 33

#define FF_PROFILE_AV1_MAIN                         0
#define FF_PROFILE_AV1_HIGH                         1
#define FF_PROFILE_AV1_PROFESSIONAL                 2

#define FF_PROFILE_MJPEG_HUFFMAN_BASELINE_DCT            0xc0
#define FF_PROFILE_MJPEG_HUFFMAN_EXTENDED_SEQUENTIAL_DCT 0xc1
#define FF_PROFILE_MJPEG_HUFFMAN_PROGRESSIVE_DCT         0xc2
#define FF_PROFILE_MJPEG_HUFFMAN_LOSSLESS                0xc3
#define FF_PROFILE_MJPEG_JPEG_LS                         0xf7

#define FF_PROFILE_SBC_MSBC                         1

#define FF_PROFILE_PRORES_PROXY     0
#define FF_PROFILE_PRORES_LT        1
#define FF_PROFILE_PRORES_STANDARD  2
#define FF_PROFILE_PRORES_HQ        3
#define FF_PROFILE_PRORES_4444      4
#define FF_PROFILE_PRORES_XQ        5

#define FF_PROFILE_ARIB_PROFILE_A 0
#define FF_PROFILE_ARIB_PROFILE_C 1

#define FF_PROFILE_KLVA_SYNC 0
#define FF_PROFILE_KLVA_ASYNC 1

	/**
	 * level
	 * - encoding: Set by user.
	 * - decoding: Set by libavcodec.
	 */
	 int level;
#define FF_LEVEL_UNKNOWN -99

	/**
	 * Skip loop filtering for selected frames.
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	enum AVDiscard skip_loop_filter;

	/**
	 * Skip IDCT/dequantization for selected frames.
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	enum AVDiscard skip_idct;

	/**
	 * Skip decoding for selected frames.
	 * - encoding: unused
	 * - decoding: Set by user.
	 */
	enum AVDiscard skip_frame;

	/**
	 * Header containing style information for text subtitles.
	 * For SUBTITLE_ASS subtitle type, it should contain the whole ASS
	 * [Script Info] and [V4+ Styles] section, plus the [Events] line and
	 * the Format line following. It shouldn't include any Dialogue line.
	 * - encoding: Set/allocated/freed by user (before avcodec_open2())
	 * - decoding: Set/allocated/freed by libavcodec (by avcodec_open2())
	 */
	uint8_t *subtitle_header;
	int subtitle_header_size;

#if FF_API_VBV_DELAY
	/**
	 * VBV delay coded in the last frame (in periods of a 27 MHz clock).
	 * Used for compliant TS muxing.
	 * - encoding: Set by libavcodec.
	 * - decoding: unused.
	 * @deprecated this value is now exported as a part of
	 * AV_PKT_DATA_CPB_PROPERTIES packet side data
	 */
	attribute_deprecated
	uint64_t vbv_delay;
#endif

#if FF_API_SIDEDATA_ONLY_PKT
	/**
	 * Encoding only and set by default. Allow encoders to output packets
	 * that do not contain any encoded data, only side data.
	 *
	 * Some encoders need to output such packets, e.g. to update some stream
	 * parameters at the end of encoding.
	 *
	 * @deprecated this field disables the default behaviour and
	 *             it is kept only for compatibility.
	 */
	attribute_deprecated
	int side_data_only_packets;
#endif

	/**
	 * Audio only. The number of "priming" samples (padding) inserted by the
	 * encoder at the beginning of the audio. I.e. this number of leading
	 * decoded samples must be discarded by the caller to get the original audio
	 * without leading padding.
	 *
	 * - decoding: unused
	 * - encoding: Set by libavcodec. The timestamps on the output packets are
	 *             adjusted by the encoder so that they always refer to the
	 *             first sample of the data actually contained in the packet,
	 *             including any added padding.  E.g. if the timebase is
	 *             1/samplerate and the timestamp of the first input sample is
	 *             0, the timestamp of the first output packet will be
	 *             -initial_padding.
	 */
	int initial_padding;

	/**
	 * - decoding: For codecs that store a framerate value in the compressed
	 *             bitstream, the decoder may export it here. { 0, 1} when
	 *             unknown.
	 * - encoding: May be used to signal the framerate of CFR content to an
	 *             encoder.
	 */
	AVRational framerate;

	/**
	 * Nominal unaccelerated pixel format, see AV_PIX_FMT_xxx.
	 * - encoding: unused.
	 * - decoding: Set by libavcodec before calling get_format()
	 */
	enum AVPixelFormat sw_pix_fmt;

	/**
	 * Timebase in which pkt_dts/pts and AVPacket.dts/pts are.
	 * - encoding unused.
	 * - decoding set by user.
	 */
	AVRational pkt_timebase;

	/**
	 * AVCodecDescriptor
	 * - encoding: unused.
	 * - decoding: set by libavcodec.
	 */
	const AVCodecDescriptor *codec_descriptor;

	/**
	 * Current statistics for PTS correction.
	 * - decoding: maintained and used by libavcodec, not intended to be used by user apps
	 * - encoding: unused
	 */
	int64_t pts_correction_num_faulty_pts; /// Number of incorrect PTS values so far
	int64_t pts_correction_num_faulty_dts; /// Number of incorrect DTS values so far
	int64_t pts_correction_last_pts;       /// PTS of the last frame
	int64_t pts_correction_last_dts;       /// DTS of the last frame

	/**
	 * Character encoding of the input subtitles file.
	 * - decoding: set by user
	 * - encoding: unused
	 */
	char *sub_charenc;

	/**
	 * Subtitles character encoding mode. Formats or codecs might be adjusting
	 * this setting (if they are doing the conversion themselves for instance).
	 * - decoding: set by libavcodec
	 * - encoding: unused
	 */
	int sub_charenc_mode;
#define FF_SUB_CHARENC_MODE_DO_NOTHING  -1  ///< do nothing (demuxer outputs a stream supposed to be already in UTF-8, or the codec is bitmap for instance)
#define FF_SUB_CHARENC_MODE_AUTOMATIC    0  ///< libavcodec will select the mode itself
#define FF_SUB_CHARENC_MODE_PRE_DECODER  1  ///< the AVPacket data needs to be recoded to UTF-8 before being fed to the decoder, requires iconv
#define FF_SUB_CHARENC_MODE_IGNORE       2  ///< neither convert the subtitles, nor check them for valid UTF-8

	/**
	 * Skip processing alpha if supported by codec.
	 * Note that if the format uses pre-multiplied alpha (common with VP6,
	 * and recommended due to better video quality/compression)
	 * the image will look as if alpha-blended onto a black background.
	 * However for formats that do not use pre-multiplied alpha
	 * there might be serious artefacts (though e.g. libswscale currently
	 * assumes pre-multiplied alpha anyway).
	 *
	 * - decoding: set by user
	 * - encoding: unused
	 */
	int skip_alpha;

	/**
	 * Number of samples to skip after a discontinuity
	 * - decoding: unused
	 * - encoding: set by libavcodec
	 */
	int seek_preroll;

#if FF_API_DEBUG_MV
	/**
	 * @deprecated unused
	 */
	attribute_deprecated
	int debug_mv;
#define FF_DEBUG_VIS_MV_P_FOR  0x00000001 //visualize forward predicted MVs of P frames
#define FF_DEBUG_VIS_MV_B_FOR  0x00000002 //visualize forward predicted MVs of B frames
#define FF_DEBUG_VIS_MV_B_BACK 0x00000004 //visualize backward predicted MVs of B frames
#endif

	/**
	 * custom intra quantization matrix
	 * - encoding: Set by user, can be NULL.
	 * - decoding: unused.
	 */
	uint16_t *chroma_intra_matrix;

	/**
	 * dump format separator.
	 * can be ", " or "\n      " or anything else
	 * - encoding: Set by user.
	 * - decoding: Set by user.
	 */
	uint8_t *dump_separator;

	/**
	 * ',' separated list of allowed decoders.
	 * If NULL then all are allowed
	 * - encoding: unused
	 * - decoding: set by user
	 */
	char *codec_whitelist;

	/**
	 * Properties of the stream that gets decoded
	 * - encoding: unused
	 * - decoding: set by libavcodec
	 */
	unsigned properties;
#define FF_CODEC_PROPERTY_LOSSLESS        0x00000001
#define FF_CODEC_PROPERTY_CLOSED_CAPTIONS 0x00000002

	/**
	 * Additional data associated with the entire coded stream.
	 *
	 * - decoding: unused
	 * - encoding: may be set by libavcodec after avcodec_open2().
	 */
	AVPacketSideData *coded_side_data;
	int            nb_coded_side_data;

	/**
	 * A reference to the AVHWFramesContext describing the input (for encoding)
	 * or output (decoding) frames. The reference is set by the caller and
	 * afterwards owned (and freed) by libavcodec - it should never be read by
	 * the caller after being set.
	 *
	 * - decoding: This field should be set by the caller from the get_format()
	 *             callback. The previous reference (if any) will always be
	 *             unreffed by libavcodec before the get_format() call.
	 *
	 *             If the default get_buffer2() is used with a hwaccel pixel
	 *             format, then this AVHWFramesContext will be used for
	 *             allocating the frame buffers.
	 *
	 * - encoding: For hardware encoders configured to use a hwaccel pixel
	 *             format, this field should be set by the caller to a reference
	 *             to the AVHWFramesContext describing input frames.
	 *             AVHWFramesContext.format must be equal to
	 *             AVCodecContext.pix_fmt.
	 *
	 *             This field should be set before avcodec_open2() is called.
	 */
	AVBufferRef *hw_frames_ctx;

	/**
	 * Control the form of AVSubtitle.rects[N]->ass
	 * - decoding: set by user
	 * - encoding: unused
	 */
	int sub_text_format;
#define FF_SUB_TEXT_FMT_ASS              0
#if FF_API_ASS_TIMING
#define FF_SUB_TEXT_FMT_ASS_WITH_TIMINGS 1
#endif

	/**
	 * Audio only. The amount of padding (in samples) appended by the encoder to
	 * the end of the audio. I.e. this number of decoded samples must be
	 * discarded by the caller from the end of the stream to get the original
	 * audio without any trailing padding.
	 *
	 * - decoding: unused
	 * - encoding: unused
	 */
	int trailing_padding;

	/**
	 * The number of pixels per image to maximally accept.
	 *
	 * - decoding: set by user
	 * - encoding: set by user
	 */
	int64_t max_pixels;

	/**
	 * A reference to the AVHWDeviceContext describing the device which will
	 * be used by a hardware encoder/decoder.  The reference is set by the
	 * caller and afterwards owned (and freed) by libavcodec.
	 *
	 * This should be used if either the codec device does not require
	 * hardware frames or any that are used are to be allocated internally by
	 * libavcodec.  If the user wishes to supply any of the frames used as
	 * encoder input or decoder output then hw_frames_ctx should be used
	 * instead.  When hw_frames_ctx is set in get_format() for a decoder, this
	 * field will be ignored while decoding the associated stream segment, but
	 * may again be used on a following one after another get_format() call.
	 *
	 * For both encoders and decoders this field should be set before
	 * avcodec_open2() is called and must not be written to thereafter.
	 *
	 * Note that some decoders may require this field to be set initially in
	 * order to support hw_frames_ctx at all - in that case, all frames
	 * contexts used must be created on the same device.
	 */
	AVBufferRef *hw_device_ctx;

	/**
	 * Bit set of AV_HWACCEL_FLAG_* flags, which affect hardware accelerated
	 * decoding (if active).
	 * - encoding: unused
	 * - decoding: Set by user (either before avcodec_open2(), or in the
	 *             AVCodecContext.get_format callback)
	 */
	int hwaccel_flags;

	/**
	 * Video decoding only. Certain video codecs support cropping, meaning that
	 * only a sub-rectangle of the decoded frame is intended for display.  This
	 * option controls how cropping is handled by libavcodec.
	 *
	 * When set to 1 (the default), libavcodec will apply cropping internally.
	 * I.e. it will modify the output frame width/height fields and offset the
	 * data pointers (only by as much as possible while preserving alignment, or
	 * by the full amount if the AV_CODEC_FLAG_UNALIGNED flag is set) so that
	 * the frames output by the decoder refer only to the cropped area. The
	 * crop_* fields of the output frames will be zero.
	 *
	 * When set to 0, the width/height fields of the output frames will be set
	 * to the coded dimensions and the crop_* fields will describe the cropping
	 * rectangle. Applying the cropping is left to the caller.
	 *
	 * @warning When hardware acceleration with opaque output frames is used,
	 * libavcodec is unable to apply cropping from the top/left border.
	 *
	 * @note when this option is set to zero, the width/height fields of the
	 * AVCodecContext and output AVFrames have different meanings. The codec
	 * context fields store display dimensions (with the coded dimensions in
	 * coded_width/height), while the frame fields store the coded dimensions
	 * (with the display dimensions being determined by the crop_* fields).
	 */
	int apply_cropping;

	/*
	 * Video decoding only.  Sets the number of extra hardware frames which
	 * the decoder will allocate for use by the caller.  This must be set
	 * before avcodec_open2() is called.
	 *
	 * Some hardware decoders require all frames that they will use for
	 * output to be defined in advance before decoding starts.  For such
	 * decoders, the hardware frame pool must therefore be of a fixed size.
	 * The extra frames set here are on top of any number that the decoder
	 * needs internally in order to operate normally (for example, frames
	 * used as reference pictures).
	 */
	int extra_hw_frames;

	/**
	 * The percentage of damaged samples to discard a frame.
	 *
	 * - decoding: set by user
	 * - encoding: unused
	 */
	int discard_damaged_percentage;

	/**
	 * The number of samples per frame to maximally accept.
	 *
	 * - decoding: set by user
	 * - encoding: set by user
	 */
	int64_t max_samples;

	/**
	 * Bit set of AV_CODEC_EXPORT_DATA_* flags, which affects the kind of
	 * metadata exported in frame, packet, or coded stream side data by
	 * decoders and encoders.
	 *
	 * - decoding: set by user
	 * - encoding: set by user
	 */
	int export_side_data;

	/**
	 * This callback is called at the beginning of each packet to get a data
	 * buffer for it.
	 *
	 * The following field will be set in the packet before this callback is
	 * called:
	 * - size
	 * This callback must use the above value to calculate the required buffer size,
	 * which must padded by at least AV_INPUT_BUFFER_PADDING_SIZE bytes.
	 *
	 * This callback must fill the following fields in the packet:
	 * - data: alignment requirements for AVPacket apply, if any. Some architectures and
	 *   encoders may benefit from having aligned data.
	 * - buf: must contain a pointer to an AVBufferRef structure. The packet's
	 *   data pointer must be contained in it. See: av_buffer_create(), av_buffer_alloc(),
	 *   and av_buffer_ref().
	 *
	 * If AV_CODEC_CAP_DR1 is not set then get_encode_buffer() must call
	 * avcodec_default_get_encode_buffer() instead of providing a buffer allocated by
	 * some other means.
	 *
	 * The flags field may contain a combination of AV_GET_ENCODE_BUFFER_FLAG_ flags.
	 * They may be used for example to hint what use the buffer may get after being
	 * created.
	 * Implementations of this callback may ignore flags they don't understand.
	 * If AV_GET_ENCODE_BUFFER_FLAG_REF is set in flags then the packet may be reused
	 * (read and/or written to if it is writable) later by libavcodec.
	 *
	 * This callback must be thread-safe, as when frame threading is used, it may
	 * be called from multiple threads simultaneously.
	 *
	 * @see avcodec_default_get_encode_buffer()
	 *
	 * - encoding: Set by libavcodec, user can override.
	 * - decoding: unused
	 */
	int (*get_encode_buffer)(struct AVCodecContext *s, AVPacket *pkt, int flags);

*/
}

/*

/**
 * @defgroup lavc_hwaccel AVHWAccel
 *
 * @note  Nothing in this structure should be accessed by the user.  At some
 *        point in future it will not be externally visible at all.
 *
 * @{
 */
typedef struct AVHWAccel {
	/**
	 * Name of the hardware accelerated codec.
	 * The name is globally unique among encoders and among decoders (but an
	 * encoder and a decoder can share the same name).
	 */
	const char *name;

	/**
	 * Type of codec implemented by the hardware accelerator.
	 *
	 * See AVMEDIA_TYPE_xxx
	 */
	enum AVMediaType type;

	/**
	 * Codec implemented by the hardware accelerator.
	 *
	 * See AV_CODEC_ID_xxx
	 */
	enum AVCodecID id;

	/**
	 * Supported pixel format.
	 *
	 * Only hardware accelerated formats are supported here.
	 */
	enum AVPixelFormat pix_fmt;

	/**
	 * Hardware accelerated codec capabilities.
	 * see AV_HWACCEL_CODEC_CAP_*
	 */
	int capabilities;

	/*****************************************************************
	 * No fields below this line are part of the public API. They
	 * may not be used outside of libavcodec and can be changed and
	 * removed at will.
	 * New public fields should be added right above.
	 *****************************************************************
	 */

	/**
	 * Allocate a custom buffer
	 */
	int (*alloc_frame)(AVCodecContext *avctx, AVFrame *frame);

	/**
	 * Called at the beginning of each frame or field picture.
	 *
	 * Meaningful frame information (codec specific) is guaranteed to
	 * be parsed at this point. This function is mandatory.
	 *
	 * Note that buf can be NULL along with buf_size set to 0.
	 * Otherwise, this means the whole frame is available at this point.
	 *
	 * @param avctx the codec context
	 * @param buf the frame data buffer base
	 * @param buf_size the size of the frame in bytes
	 * @return zero if successful, a negative value otherwise
	 */
	int (*start_frame)(AVCodecContext *avctx, const uint8_t *buf, uint32_t buf_size);

	/**
	 * Callback for parameter data (SPS/PPS/VPS etc).
	 *
	 * Useful for hardware decoders which keep persistent state about the
	 * video parameters, and need to receive any changes to update that state.
	 *
	 * @param avctx the codec context
	 * @param type the nal unit type
	 * @param buf the nal unit data buffer
	 * @param buf_size the size of the nal unit in bytes
	 * @return zero if successful, a negative value otherwise
	 */
	int (*decode_params)(AVCodecContext *avctx, int type, const uint8_t *buf, uint32_t buf_size);

	/**
	 * Callback for each slice.
	 *
	 * Meaningful slice information (codec specific) is guaranteed to
	 * be parsed at this point. This function is mandatory.
	 * The only exception is XvMC, that works on MB level.
	 *
	 * @param avctx the codec context
	 * @param buf the slice data buffer base
	 * @param buf_size the size of the slice in bytes
	 * @return zero if successful, a negative value otherwise
	 */
	int (*decode_slice)(AVCodecContext *avctx, const uint8_t *buf, uint32_t buf_size);

	/**
	 * Called at the end of each frame or field picture.
	 *
	 * The whole picture is parsed at this point and can now be sent
	 * to the hardware accelerator. This function is mandatory.
	 *
	 * @param avctx the codec context
	 * @return zero if successful, a negative value otherwise
	 */
	int (*end_frame)(AVCodecContext *avctx);

	/**
	 * Size of per-frame hardware accelerator private data.
	 *
	 * Private data is allocated with av_mallocz() before
	 * AVCodecContext.get_buffer() and deallocated after
	 * AVCodecContext.release_buffer().
	 */
	int frame_priv_data_size;

	/**
	 * Called for every Macroblock in a slice.
	 *
	 * XvMC uses it to replace the ff_mpv_reconstruct_mb().
	 * Instead of decoding to raw picture, MB parameters are
	 * stored in an array provided by the video driver.
	 *
	 * @param s the mpeg context
	 */
	void (*decode_mb)(struct MpegEncContext *s);

	/**
	 * Initialize the hwaccel private data.
	 *
	 * This will be called from ff_get_format(), after hwaccel and
	 * hwaccel_context are set and the hwaccel private data in AVCodecInternal
	 * is allocated.
	 */
	int (*init)(AVCodecContext *avctx);

	/**
	 * Uninitialize the hwaccel private data.
	 *
	 * This will be called from get_format() or avcodec_close(), after hwaccel
	 * and hwaccel_context are already uninitialized.
	 */
	int (*uninit)(AVCodecContext *avctx);

	/**
	 * Size of the private data to allocate in
	 * AVCodecInternal.hwaccel_priv_data.
	 */
	int priv_data_size;

	/**
	 * Internal hwaccel capabilities.
	 */
	int caps_internal;

	/**
	 * Fill the given hw_frames context with current codec parameters. Called
	 * from get_format. Refer to avcodec_get_hw_frames_parameters() for
	 * details.
	 *
	 * This CAN be called before AVHWAccel.init is called, and you must assume
	 * that avctx->hwaccel_priv_data is invalid.
	 */
	int (*frame_params)(AVCodecContext *avctx, AVBufferRef *hw_frames_ctx);
} AVHWAccel;

/**
 * HWAccel is experimental and is thus avoided in favor of non experimental
 * codecs
 */
#define AV_HWACCEL_CODEC_CAP_EXPERIMENTAL 0x0200

/**
 * Hardware acceleration should be used for decoding even if the codec level
 * used is unknown or higher than the maximum supported level reported by the
 * hardware driver.
 *
 * It's generally a good idea to pass this flag unless you have a specific
 * reason not to, as hardware tends to under-report supported levels.
 */
#define AV_HWACCEL_FLAG_IGNORE_LEVEL (1 << 0)

/**
 * Hardware acceleration can output YUV pixel formats with a different chroma
 * sampling than 4:2:0 and/or other than 8 bits per component.
 */
#define AV_HWACCEL_FLAG_ALLOW_HIGH_DEPTH (1 << 1)

/**
 * Hardware acceleration should still be attempted for decoding when the
 * codec profile does not match the reported capabilities of the hardware.
 *
 * For example, this can be used to try to decode baseline profile H.264
 * streams in hardware - it will often succeed, because many streams marked
 * as baseline profile actually conform to constrained baseline profile.
 *
 * @warning If the stream is actually not supported then the behaviour is
 *          undefined, and may include returning entirely incorrect output
 *          while indicating success.
 */
#define AV_HWACCEL_FLAG_ALLOW_PROFILE_MISMATCH (1 << 2)

/**
 * @}
 */

#if FF_API_AVPICTURE
/**
 * @defgroup lavc_picture AVPicture
 *
 * Functions for working with AVPicture
 * @{
 */

/**
 * Picture data structure.
 *
 * Up to four components can be stored into it, the last component is
 * alpha.
 * @deprecated use AVFrame or imgutils functions instead
 */
typedef struct AVPicture {
	attribute_deprecated
	uint8_t *data[AV_NUM_DATA_POINTERS];    ///< pointers to the image data planes
	attribute_deprecated
	int linesize[AV_NUM_DATA_POINTERS];     ///< number of bytes per line
} AVPicture;

/**
 * @}
 */
#endif

enum AVSubtitleType {
	SUBTITLE_NONE,

	SUBTITLE_BITMAP,                ///< A bitmap, pict will be set

	/**
	 * Plain text, the text field must be set by the decoder and is
	 * authoritative. ass and pict fields may contain approximations.
	 */
	SUBTITLE_TEXT,

	/**
	 * Formatted text, the ass field must be set by the decoder and is
	 * authoritative. pict and text fields may contain approximations.
	 */
	SUBTITLE_ASS,
};

#define AV_SUBTITLE_FLAG_FORCED 0x00000001

typedef struct AVSubtitleRect {
	int x;         ///< top left corner  of pict, undefined when pict is not set
	int y;         ///< top left corner  of pict, undefined when pict is not set
	int w;         ///< width            of pict, undefined when pict is not set
	int h;         ///< height           of pict, undefined when pict is not set
	int nb_colors; ///< number of colors in pict, undefined when pict is not set

#if FF_API_AVPICTURE
	/**
	 * @deprecated unused
	 */
	attribute_deprecated
	AVPicture pict;
#endif
	/**
	 * data+linesize for the bitmap of this subtitle.
	 * Can be set for text/ass as well once they are rendered.
	 */
	uint8_t *data[4];
	int linesize[4];

	enum AVSubtitleType type;

	char *text;                     ///< 0 terminated plain UTF-8 text

	/**
	 * 0 terminated ASS/SSA compatible event line.
	 * The presentation of this is unaffected by the other values in this
	 * struct.
	 */
	char *ass;

	int flags;
} AVSubtitleRect;

typedef struct AVSubtitle {
	uint16_t format; /* 0 = graphics */
	uint32_t start_display_time; /* relative to packet pts, in ms */
	uint32_t end_display_time; /* relative to packet pts, in ms */
	unsigned num_rects;
	AVSubtitleRect **rects;
	int64_t pts;    ///< Same as packet pts, in AV_TIME_BASE
} AVSubtitle;

enum AVPictureStructure {
	AV_PICTURE_STRUCTURE_UNKNOWN,      //< unknown
	AV_PICTURE_STRUCTURE_TOP_FIELD,    //< coded as top field
	AV_PICTURE_STRUCTURE_BOTTOM_FIELD, //< coded as bottom field
	AV_PICTURE_STRUCTURE_FRAME,        //< coded as frame
};

typedef struct AVCodecParserContext {
	void *priv_data;
	struct AVCodecParser *parser;
	int64_t frame_offset; /* offset of the current frame */
	int64_t cur_offset; /* current offset
						   (incremented by each av_parser_parse()) */
	int64_t next_frame_offset; /* offset of the next frame */
	/* video info */
	int pict_type; /* XXX: Put it back in AVCodecContext. */
	/**
	 * This field is used for proper frame duration computation in lavf.
	 * It signals, how much longer the frame duration of the current frame
	 * is compared to normal frame duration.
	 *
	 * frame_duration = (1 + repeat_pict) * time_base
	 *
	 * It is used by codecs like H.264 to display telecined material.
	 */
	int repeat_pict; /* XXX: Put it back in AVCodecContext. */
	int64_t pts;     /* pts of the current frame */
	int64_t dts;     /* dts of the current frame */

	/* private data */
	int64_t last_pts;
	int64_t last_dts;
	int fetch_timestamp;

#define AV_PARSER_PTS_NB 4
	int cur_frame_start_index;
	int64_t cur_frame_offset[AV_PARSER_PTS_NB];
	int64_t cur_frame_pts[AV_PARSER_PTS_NB];
	int64_t cur_frame_dts[AV_PARSER_PTS_NB];

	int flags;
#define PARSER_FLAG_COMPLETE_FRAMES           0x0001
#define PARSER_FLAG_ONCE                      0x0002
/// Set if the parser has a valid file offset
#define PARSER_FLAG_FETCHED_OFFSET            0x0004
#define PARSER_FLAG_USE_CODEC_TS              0x1000

	int64_t offset;      ///< byte offset from starting packet start
	int64_t cur_frame_end[AV_PARSER_PTS_NB];

	/**
	 * Set by parser to 1 for key frames and 0 for non-key frames.
	 * It is initialized to -1, so if the parser doesn't set this flag,
	 * old-style fallback using AV_PICTURE_TYPE_I picture type as key frames
	 * will be used.
	 */
	int key_frame;

#if FF_API_CONVERGENCE_DURATION
	/**
	 * @deprecated unused
	 */
	attribute_deprecated
	int64_t convergence_duration;
#endif

	// Timestamp generation support:
	/**
	 * Synchronization point for start of timestamp generation.
	 *
	 * Set to >0 for sync point, 0 for no sync point and <0 for undefined
	 * (default).
	 *
	 * For example, this corresponds to presence of H.264 buffering period
	 * SEI message.
	 */
	int dts_sync_point;

	/**
	 * Offset of the current timestamp against last timestamp sync point in
	 * units of AVCodecContext.time_base.
	 *
	 * Set to INT_MIN when dts_sync_point unused. Otherwise, it must
	 * contain a valid timestamp offset.
	 *
	 * Note that the timestamp of sync point has usually a nonzero
	 * dts_ref_dts_delta, which refers to the previous sync point. Offset of
	 * the next frame after timestamp sync point will be usually 1.
	 *
	 * For example, this corresponds to H.264 cpb_removal_delay.
	 */
	int dts_ref_dts_delta;

	/**
	 * Presentation delay of current frame in units of AVCodecContext.time_base.
	 *
	 * Set to INT_MIN when dts_sync_point unused. Otherwise, it must
	 * contain valid non-negative timestamp delta (presentation time of a frame
	 * must not lie in the past).
	 *
	 * This delay represents the difference between decoding and presentation
	 * time of the frame.
	 *
	 * For example, this corresponds to H.264 dpb_output_delay.
	 */
	int pts_dts_delta;

	/**
	 * Position of the packet in file.
	 *
	 * Analogous to cur_frame_pts/dts
	 */
	int64_t cur_frame_pos[AV_PARSER_PTS_NB];

	/**
	 * Byte position of currently parsed frame in stream.
	 */
	int64_t pos;

	/**
	 * Previous frame byte position.
	 */
	int64_t last_pos;

	/**
	 * Duration of the current frame.
	 * For audio, this is in units of 1 / AVCodecContext.sample_rate.
	 * For all other types, this is in units of AVCodecContext.time_base.
	 */
	int duration;

	enum AVFieldOrder field_order;

	/**
	 * Indicate whether a picture is coded as a frame, top field or bottom field.
	 *
	 * For example, H.264 field_pic_flag equal to 0 corresponds to
	 * AV_PICTURE_STRUCTURE_FRAME. An H.264 picture with field_pic_flag
	 * equal to 1 and bottom_field_flag equal to 0 corresponds to
	 * AV_PICTURE_STRUCTURE_TOP_FIELD.
	 */
	enum AVPictureStructure picture_structure;

	/**
	 * Picture number incremented in presentation or output order.
	 * This field may be reinitialized at the first picture of a new sequence.
	 *
	 * For example, this corresponds to H.264 PicOrderCnt.
	 */
	int output_picture_number;

	/**
	 * Dimensions of the decoded video intended for presentation.
	 */
	int width;
	int height;

	/**
	 * Dimensions of the coded video.
	 */
	int coded_width;
	int coded_height;

	/**
	 * The format of the coded data, corresponds to enum AVPixelFormat for video
	 * and for enum AVSampleFormat for audio.
	 *
	 * Note that a decoder can have considerable freedom in how exactly it
	 * decodes the data, so the format reported here might be different from the
	 * one returned by a decoder.
	 */
	int format;
} AVCodecParserContext;

typedef struct AVCodecParser {
	int codec_ids[5]; /* several codec IDs are permitted */
	int priv_data_size;
	int (*parser_init)(AVCodecParserContext *s);
	/* This callback never returns an error, a negative value means that
	 * the frame start was in a previous packet. */
	int (*parser_parse)(AVCodecParserContext *s,
						AVCodecContext *avctx,
						const uint8_t **poutbuf, int *poutbuf_size,
						const uint8_t *buf, int buf_size);
	void (*parser_close)(AVCodecParserContext *s);
	int (*split)(AVCodecContext *avctx, const uint8_t *buf, int buf_size);
#if FF_API_NEXT
	attribute_deprecated
	struct AVCodecParser *next;
#endif
} AVCodecParser;

typedef struct AVBitStreamFilterContext {
	void *priv_data;
	const struct AVBitStreamFilter *filter;
	AVCodecParserContext *parser;
	struct AVBitStreamFilterContext *next;
	/**
	 * Internal default arguments, used if NULL is passed to av_bitstream_filter_filter().
	 * Not for access by library users.
	 */
	char *args;
} AVBitStreamFilterContext;

enum AVLockOp {
  AV_LOCK_CREATE,  ///< Create a mutex
  AV_LOCK_OBTAIN,  ///< Lock the mutex
  AV_LOCK_RELEASE, ///< Unlock the mutex
  AV_LOCK_DESTROY, ///< Free mutex resources
};

*/

Codec_Descriptor_Property :: enum c.int {
	/**
	 * Codec uses only intra compression.
	 * Video and audio codecs only.
	 */
	Intra_Only = 0,
	/**
	 * Codec supports lossy compression. Audio and video codecs only.
	 * @note a codec may support both lossy and lossless
	 * compression modes
	 */
	Lossy       = 1,
	/**
	 * Codec supports lossless compression. Audio and video codecs only.
	 */
	Lossless    = 2,
	/**
	 * Codec supports frame reordering. That is, the coded order (the order in which
	 * the encoded packets are output by the encoders / stored / input to the
	 * decoders) may be different from the presentation order of the corresponding
	 * frames.
	 *
	 * For codecs that do not have this property set, PTS and DTS should always be
	 * equal.
	 */
	Reorder     = 3,
	/**
	 * Subtitle codec is bitmap based
	 * Decoded AVSubtitle data can be read from the AVSubtitleRect->pict field.
	 */
	Bitmap_Sub  = 16,
	/**
	 * Subtitle codec is text based.
	 * Decoded AVSubtitle data can be read from the AVSubtitleRect->ass field.
	 */
	Text_Sub    = 17,
}
Codec_Descriptor_Properties :: bit_set[Codec_Descriptor_Property; c.int]

Codec_Descriptor :: struct {
	id:         Codec_ID,
	type:       Media_Type,

	/**
	 * Name of the codec described by this descriptor. It is non-empty and
	 * unique for each codec descriptor. It should contain alphanumeric
	 * characters and '_' only.
	 */
	name:       cstring,
	/**
	 * A more descriptive name for this codec. May be NULL.
	 */
	long_name:  cstring,
	/**
	 * Codec properties, a combination of AV_CODEC_PROP_* flags.
	 */
	props:      Codec_Descriptor_Properties,
	/**
	 * MIME type(s) associated with the codec.
	 * May be NULL; if not, a NULL-terminated array of MIME types.
	 * The first item is always non-NULL and is the preferred MIME type.
	 */
	mime_types: [^]cstring,
	/**
	 * If non-NULL, an array of profiles recognized for this codec.
	 * Terminated with FF_PROFILE_UNKNOWN.
	 */
	profiles:   [^]Profile,
}

/* ==============================================================================================
   CODEC IDS - CODEC IDS - CODEC IDS - CODEC IDS - CODEC IDS - CODEC IDS - CODEC IDS - CODEC IDS
   ============================================================================================== */

Codec_ID :: enum c.uint {
	NONE = 0x0,

	/* Video Codecs */
	MPEG1VIDEO,
	MPEG2VIDEO,
	H261,
	H263,
	RV10,
	RV20,
	MJPEG,
	MJPEGB,
	LJPEG,
	SP5X,
	JPEGLS,
	MPEG4,
	RAWVIDEO,
	MSMPEG4V1,
	MSMPEG4V2,
	MSMPEG4V3,
	WMV1,
	WMV2,
	H263P,
	H263I,
	FLV1,
	SVQ1,
	SVQ3,
	DVVIDEO,
	HUFFYUV,
	CYUV,
	H264,
	INDEO3,
	VP3,
	THEORA,
	ASV1,
	ASV2,
	FFV1,
	_4XM,
	VCR1,
	CLJR,
	MDEC,
	ROQ,
	INTERPLAY_VIDEO,
	XAN_WC3,
	XAN_WC4,
	RPZA,
	CINEPAK,
	WS_VQA,
	MSRLE,
	MSVIDEO1,
	IDCIN,
	_8BPS,
	SMC,
	FLIC,
	TRUEMOTION1,
	VMDVIDEO,
	MSZH,
	ZLIB,
	QTRLE,
	TSCC,
	ULTI,
	QDRAW,
	VIXL,
	QPEG,
	PNG,
	PPM,
	PBM,
	PGM,
	PGMYUV,
	PAM,
	FFVHUFF,
	RV30,
	RV40,
	VC1,
	WMV3,
	LOCO,
	WNV1,
	AASC,
	INDEO2,
	FRAPS,
	TRUEMOTION2,
	BMP,
	CSCD,
	MMVIDEO,
	ZMBV,
	AVS,
	SMACKVIDEO,
	NUV,
	KMVC,
	FLASHSV,
	CAVS,
	JPEG2000,
	VMNC,
	VP5,
	VP6,
	VP6F,
	TARGA,
	DSICINVIDEO,
	TIERTEXSEQVIDEO,
	TIFF,
	GIF,
	DXA,
	DNXHD,
	THP,
	SGI,
	C93,
	BETHSOFTVID,
	PTX,
	TXD,
	VP6A,
	AMV,
	VB,
	PCX,
	SUNRAST,
	INDEO4,
	INDEO5,
	MIMIC,
	RL2,
	ESCAPE124,
	DIRAC,
	BFI,
	CMV,
	MOTIONPIXELS,
	TGV,
	TGQ,
	TQI,
	AURA,
	AURA2,
	V210X,
	TMV,
	V210,
	DPX,
	MAD,
	FRWU,
	FLASHSV2,
	CDGRAPHICS,
	R210,
	ANM,
	BINKVIDEO,
	IFF_ILBM,
	IFF_BYTERUN1 = IFF_ILBM,
	KGV1,
	YOP,
	VP8,
	PICTOR,
	ANSI,
	A64_MULTI,
	A64_MULTI5,
	R10K,
	MXPEG,
	LAGARITH,
	PRORES,
	JV,
	DFA,
	WMV3IMAGE,
	VC1IMAGE,
	UTVIDEO,
	BMV_VIDEO,
	VBLE,
	DXTORY,
	V410,
	XWD,
	CDXL,
	XBM,
	ZEROCODEC,
	MSS1,
	MSA1,
	TSCC2,
	MTS2,
	CLLC,
	MSS2,
	VP9,
	AIC,
	ESCAPE130,
	G2M,
	WEBP,
	HNM4_VIDEO,
	HEVC,
	H265 = HEVC,
	FIC,
	ALIAS_PIX,
	BRENDER_PIX,
	PAF_VIDEO,
	EXR,
	VP7,
	SANM,
	SGIRLE,
	MVC1,
	MVC2,
	HQX,
	TDSC,
	HQ_HQA,
	HAP,
	DDS,
	DXV,
	SCREENPRESSO,
	RSCC,
	AVS2,
	PGX,
	AVS3,
	MSP2,
	VVC,
	H266 = VVC,

	Y41P = 0x8000,
	AVRP,
	_012V,
	AVUI,
	AYUV,
	TARGA_Y216,
	V308,
	V408,
	YUV4,
	AVRN,
	CPIA,
	XFACE,
	SNOW,
	SMVJPEG,
	APNG,
	DAALA,
	CFHD,
	TRUEMOTION2RT,
	M101,
	MAGICYUV,
	SHEERVIDEO,
	YLC,
	PSD,
	PIXLET,
	SPEEDHQ,
	FMVC,
	SCPR,
	CLEARVIDEO,
	XPM,
	AV1,
	BITPACKED,
	MSCC,
	SRGC,
	SVG,
	GDV,
	FITS,
	IMM4,
	PROSUMER,
	MWSC,
	WCMV,
	RASC,
	HYMT,
	ARBC,
	AGM,
	LSCR,
	VP4,
	IMM5,
	MVDV,
	MVHA,
	CDTOONS,
	MV30,
	NOTCHLC,
	PFM,
	MOBICLIP,
	PHOTOCD,
	IPU,
	ARGO,
	CRI,
	SIMBIOSIS_IMX,
	SGA_VIDEO,

	/* Various PCM "codecs" */
	FIRST_AUDIO     = 0x10000,
	PCM_S16LE       = 0x10000,
	PCM_S16BE,
	PCM_U16LE,
	PCM_U16BE,
	PCM_S8,
	PCM_U8,
	PCM_MULAW,
	PCM_ALAW,
	PCM_S32LE,
	PCM_S32BE,
	PCM_U32LE,
	PCM_U32BE,
	PCM_S24LE,
	PCM_S24BE,
	PCM_U24LE,
	PCM_U24BE,
	PCM_S24DAUD,
	PCM_ZORK,
	PCM_S16LE_PLANAR,
	PCM_DVD,
	PCM_F32BE,
	PCM_F32LE,
	PCM_F64BE,
	PCM_F64LE,
	PCM_BLURAY,
	PCM_LXF,
	S302M,
	PCM_S8_PLANAR,
	PCM_S24LE_PLANAR,
	PCM_S32LE_PLANAR,
	PCM_S16BE_PLANAR,

	PCM_S64LE = 0x10800,
	PCM_S64BE,
	PCM_F16LE,
	PCM_F24LE,
	PCM_VIDC,
	PCM_SGA,

	/* Various ADPCM codecs */
	ADPCM_IMA_QT = 0x11000,
	ADPCM_IMA_WAV,
	ADPCM_IMA_DK3,
	ADPCM_IMA_DK4,
	ADPCM_IMA_WS,
	ADPCM_IMA_SMJPEG,
	ADPCM_MS,
	ADPCM_4XM,
	ADPCM_XA,
	ADPCM_ADX,
	ADPCM_EA,
	ADPCM_G726,
	ADPCM_CT,
	ADPCM_SWF,
	ADPCM_YAMAHA,
	ADPCM_SBPRO_4,
	ADPCM_SBPRO_3,
	ADPCM_SBPRO_2,
	ADPCM_THP,
	ADPCM_IMA_AMV,
	ADPCM_EA_R1,
	ADPCM_EA_R3,
	ADPCM_EA_R2,
	ADPCM_IMA_EA_SEAD,
	ADPCM_IMA_EA_EACS,
	ADPCM_EA_XAS,
	ADPCM_EA_MAXIS_XA,
	ADPCM_IMA_ISS,
	ADPCM_G722,
	ADPCM_IMA_APC,
	ADPCM_VIMA,
	ADPCM_VARIOUS,

	ADPCM_AFC = 0x11800,
	ADPCM_IMA_OKI,
	ADPCM_DTK,
	ADPCM_IMA_RAD,
	ADPCM_G726LE,
	ADPCM_THP_LE,
	ADPCM_PSX,
	ADPCM_AICA,
	ADPCM_IMA_DAT4,
	ADPCM_MTAF,
	ADPCM_AGM,
	ADPCM_ARGO,
	ADPCM_IMA_SSI,
	ADPCM_ZORK,
	ADPCM_IMA_APM,
	ADPCM_IMA_ALP,
	ADPCM_IMA_MTF,
	ADPCM_IMA_CUNNING,
	ADPCM_IMA_MOFLEX,

	/* AMR */
	AMR_NB = 0x12000,
	AMR_WB,

	/* RealAudio Codecs */
	RA_144 = 0x13000,
	RA_288,

	/* Various DPCM codecs */
	ROQ_DPCM = 0x14000,
	INTERPLAY_DPCM,
	XAN_DPCM,
	SOL_DPCM,

	SDX2_DPCM = 0x14800,
	GREMLIN_DPCM,
	DERF_DPCM,

	/* Audio Codecs */
	MP2             = 0x15000,
	MP3,
	AAC,
	AC3,
	DTS,
	VORBIS,
	DVAUDIO,
	WMAV1,
	WMAV2,
	MACE3,
	MACE6,
	VMDAUDIO,
	FLAC,
	MP3ADU,
	MP3ON4,
	SHORTEN,
	ALAC,
	WESTWOOD_SND1,
	GSM,
	QDM2,
	COOK,
	TRUESPEECH,
	TTA,
	SMACKAUDIO,
	QCELP,
	WAVPACK,
	DSICINAUDIO,
	IMC,
	MUSEPACK7,
	MLP,
	GSM_MS,
	ATRAC3,
	APE,
	NELLYMOSER,
	MUSEPACK8,
	SPEEX,
	WMAVOICE,
	WMAPRO,
	WMALOSSLESS,
	ATRAC3P,
	EAC3,
	SIPR,
	MP1,
	TWINVQ,
	TRUEHD,
	MP4ALS,
	ATRAC1,
	BINKAUDIO_RDFT,
	BINKAUDIO_DCT,
	AAC_LATM,
	QDMC,
	CELT,
	G723_1,
	G729,
	_8SVX_EXP,
	_8SVX_FIB,
	BMV_AUDIO,
	RALF,
	IAC,
	ILBC,
	OPUS,
	COMFORT_NOISE,
	TAK,
	METASOUND,
	PAF_AUDIO,
	ON2AVC,
	DSS_SP,
	CODEC2,

	FFWAVESYNTH     = 0x15800,
	SONIC,
	SONIC_LS,
	EVRC,
	SMV,
	DSD_LSBF,
	DSD_MSBF,
	DSD_LSBF_PLANAR,
	DSD_MSBF_PLANAR,
	_4GV,
	INTERPLAY_ACM,
	XMA1,
	XMA2,
	DST,
	ATRAC3AL,
	ATRAC3PAL,
	DOLBY_E,
	APTX,
	APTX_HD,
	SBC,
	ATRAC9,
	HCOM,
	ACELP_KELVIN,
	MPEGH_3D_AUDIO,
	SIREN,
	HCA,
	FASTAUDIO,

	/* Subtitle Codecs */
	FIRST_SUBTITLE  = 0x17000, // Dummy ID for start of subtitle codecs.
	DVD_SUBTITLE    = 0x17000,
	DVB_SUBTITLE,
	TEXT,  ///< raw UTF-8 text
	XSUB,
	SSA,
	MOV_TEXT,
	HDMV_PGS_SUBTITLE,
	DVB_TELETEXT,
	SRT,

	MICRODVD        = 0x17800,
	EIA_608,
	JACOSUB,
	SAMI,
	REALTEXT,
	STL,
	SUBVIEWER1,
	SUBVIEWER,
	SUBRIP,
	WEBVTT,
	MPL2,
	VPLAYER,
	PJS,
	ASS,
	HDMV_TEXT_SUBTITLE,
	TTML,
	ARIB_CAPTION,

	/* Other specific kind of codecs (generally used for attachments) */
	FIRST_UNKNOWN   = 0x18000, // Dummy ID for start of fake codecs.
	TTF             = 0x18000,

	SCTE_35,
	EPG,
	BINTEXT         = 0x18800,
	XBIN,
	IDF,
	OTF,
	SMPTE_KLV,
	DVD_NAV,
	TIMED_ID3,
	BIN_DATA,

	PROBE           = 0x19000, // Unknown codec. Probe.
	MPEG2TS         = 0x20000, // Raw MPEG2 Transport Stream
	MPEG4SYSTEMS    = 0x20001, // MPEG4 Systems Stream
	FFMETADATA      = 0x21000, // Metadata only
	WRAPPED_AVFRAME = 0x21001, // Passthrough codec, AVFrames wrapped in AVPacket
}

/* ==============================================================================================
      FORMATS - FORMATS - FORMATS - FORMATS - FORMATS - FORMATS - FORMATS - FORMATS - FORMATS
   ============================================================================================== */

Probe_Data :: struct {
	filename:  cstring,
	buf:       [^]u8,
	buf_size:  c.int,
	mime_type: cstring,
}

PROBE_SCORE_EXTENSION    ::  50
PROBE_SCORE_MIME         ::  75
PROBE_SCORE_MAX          :: 100
PROBE_SCORE_RETRY        ::  PROBE_SCORE_MAX / 4
PROBE_SCORE_STREAM_RETRY :: (PROBE_SCORE_MAX / 4 - 1)
PROBE_PADDING_SIZE       ::  32

/*
	Demuxer uses `avio_open`. No file handle should be provided.
*/
Format_Flag :: enum c.int {
	No_File           =  0,
	Need_Number       =  1,
	Show_IDs          =  3,
	Global_Header     =  6,
	No_Timestamps     =  7,
	Generic_Index     =  8,
	TS_Discontinuous  =  9,
	Variable_FPS      = 10,
	No_Dimensions     = 11,
	No_Streams        = 12,
	No_Binary_Search  = 13,
	No_Generic_Search = 14,
	No_Byte_Seek      = 15,
	Allow_Flush       = 16,
	TS_Non_Strict     = 17,
	TS_Negative       = 18,
	Seek_to_PTS       = 26,
}
Format_Flags :: bit_set[Format_Flag; c.int]

/*
	Muxers
*/
Output_Format :: struct {
	name:       cstring,
	long_name:  cstring,
	mime_type:  cstring,
	extensions: cstring,

	/*
		Output support.
	*/
	audio_codec:    Codec_ID, // Default Audio    Codec
	video_codec:    Codec_ID, // Default Video    Codec
	subtitle_codec: Codec_ID, // Default Subtitle Codec

	flags: Format_Flags,

	/*
		List of supported codec_id-codec_tag pairs, ordered by "better
		choice first". The arrays are all terminated by .None
	*/
	codec_tags: ^[^]Codec_Tag,
	priv_class: ^Class,





}

/*
	Demuxers
*/
Input_Format :: struct {
	name:       cstring,
	long_name:  cstring,
	flags:      Format_Flags,
	extensions: cstring,

	codec_tags:  ^[^]Codec_Tag,
	priv_class: ^Class,
	mime_type:  cstring,

	// The rest of the fields are not part of the public API.
}

Stream_Parse_Type :: enum c.int {
	None,
	Full,       /**< full parsing and repack */
	Headers,    /**< Only parse headers, do not repack. */
	Timestamps, /**< full parsing and interpolation of timestamps for frames not starting on a packet boundary */
	Full_Once,  /**< full parsing and repack of the first frame only, only implemented for H.264 currently */
	Full_Raw,   /**< full parsing and repack with timestamp and position generation by parser for raw
									this assumes that each packet in the file contains no demuxer level headers and
									just codec level data, otherwise position generation would fail */
}

Index_Flag :: enum c.int {
	Keyframe      = 1,
	Discard_Frame = 2,
}

Index_Entry :: struct {
	pos:       c.int64_t,
	timestamp: c.int64_t, /**< Timestamp in Stream.time_base units, preferably the time from which on correctly decoded frames are available
							*  when seeking to this entry. That means preferable PTS on keyframe based formats.
							*  But demuxers can choose to store a different timestamp, if it is more convenient for the implementation or nothing better
							*  is known
						  */

	flags_and_size: c.int, // Index_Flag in bottom two bits, size in top 30 bits.
	min_distance:   c.int, /**< Minimum distance between this and the previous keyframe, used to avoid unneeded searching. */
}

Disposition_Flag :: enum c.int {
	Default          = 0,
	Dub              = 1,
	Original         = 2,
	Comment          = 3,
	Lyrics           = 4,
	Karaoke          = 5,

	/**
	 * Track should be used during playback by default.
	 * Useful for subtitle track that should be displayed
	 * even when user did not explicitly ask for subtitles.
	 */
	Forced           = 6,
	Hearing_Impaired = 7, /**< stream for hearing impaired audiences */
	Visual_Impaired  = 8, /**< stream for visual impaired audiences */
	Clean_Effects    = 9, /**< stream without voice */

	/**
	 * The stream is stored in the file as an attached picture/"cover art" (e.g.
	 * APIC frame in ID3v2). The first (usually only) packet associated with it
	 * will be returned among the first few packets read from the file unless
	 * seeking takes place. It can also be accessed at any time in
	 * AVStream.attached_pic.
	 */
	Attached_Pic     = 10,

	/**
	 * The stream is sparse, and contains thumbnail images, often corresponding
	 * to chapter markers. Only ever used with AV_DISPOSITION_ATTACHED_PIC.
	 */
	Timed_Thumbnails = 11,

	/**
	 * To specify text track kind (different from subtitles default).
	 */
	Captions         = 16,
	Descriptions     = 17,
	Metadata         = 18,
	Dependent        = 19, ///< dependent audio stream (mix_type=0 in mpegts)
	Still_Image      = 20, ///< still images in video stream (still_picture_flag=1 in mpegts)
}
Disposition_Flags :: bit_set[Disposition_Flag; c.int]

/*
	Options for behavior on timestamp wrap detection.
*/
Timestamp_Wrap :: enum c.int {
	Ignore     =  0, ///< ignore the wrap
	Add_offset =  1, ///< add the format specific offset on wrap detection
	Sub_offset = -1, ///< subtract the format specific offset on wrap detection
}

Event_Flags :: enum c.int {
	/**
	 * - demuxing: the demuxer read new metadata from the file and updated
	 *     AVStream.metadata accordingly
	 * - muxing: the user updated AVStream.metadata and wishes the muxer to write
	 *     it into the file
	 */
	Metadata_Updated = 0,
	/**
	 * - demuxing: new packets for this stream were read from the file. This
	 *   event is informational only and does not guarantee that new packets
	 *   for this stream will necessarily be returned from av_read_frame().
	 */
	New_Packets = 1,
}

/**
 * Stream structure.
 * New fields can be added to the end with minor version bumps.
 * Removal, reordering and changes to existing fields require a major
 * version bump.
 * sizeof(AVStream) must not be used outside libav*.
 */
Stream :: struct {
	index: c.int, /**< stream index in Format_Context */
	/*
	 * Format-specific stream ID.
	 * decoding: set by libavformat
	 * encoding: set by the user, replaced by libavformat if left unset
	 */
	id: c.int,

	priv_data: rawptr,

	/**
	 * This is the fundamental unit of time (in seconds) in terms
	 * of which frame timestamps are represented.
	 *
	 * decoding: set by libavformat
	 * encoding: May be set by the caller before avformat_write_header() to
	 *           provide a hint to the muxer about the desired timebase. In
	 *           avformat_write_header(), the muxer will overwrite this field
	 *           with the timebase that will actually be used for the timestamps
	 *           written into the file (which may or may not be related to the
	 *           user-provided one, depending on the format).
	 */
	time_base: Rational,

	/**
	 * Decoding: pts of the first frame of the stream in presentation order, in stream time base.
	 * Only set this if you are absolutely 100% sure that the value you set
	 * it to really is the pts of the first frame.
	 * This may be undefined (AV_NOPTS_VALUE).
	 * @note The ASF header does NOT contain a correct start_time the ASF
	 * demuxer must NOT set this.
	 */
	start_time: c.int64_t,

	/**
	 * Decoding: duration of the stream, in stream time base.
	 * If a source file does not specify a duration, but does specify
	 * a bitrate, this value will be estimated from bitrate and file size.
	 *
	 * Encoding: May be set by the caller before avformat_write_header() to
	 * provide a hint to the muxer about the estimated duration.
	 */
	duration:    c.int64_t,
	nb_frames:   c.int64_t,         ///< number of frames in this stream if known or 0
	disposition: Disposition_Flags, /**< AV_DISPOSITION_* bit field */
	discard:     Discard,   ///< Selects which packets can be discarded at will and do not need to be demuxed.

	/**
	 * sample aspect ratio (0 if unknown)
	 * - encoding: Set by user.
	 * - decoding: Set by libavformat.
	 */
	sample_aspect_ratio: Rational,

	metadata: rawptr, // metadata: ^Dictionary,

	/**
	 * Average framerate
	 *
	 * - demuxing: May be set by libavformat when creating the stream or in
	 *             avformat_find_stream_info().
	 * - muxing: May be set by the caller before avformat_write_header().
	 */
	avg_frame_rate: Rational,

	/**
	 * For streams with AV_DISPOSITION_ATTACHED_PIC disposition, this packet
	 * will contain the attached picture.
	 *
	 * decoding: set by libavformat, must not be modified by the caller.
	 * encoding: unused
	 */
	attached_pic: Packet,

	/**
	 * An array of side data that applies to the whole stream (i.e. the
	 * container does not allow it to change between packets).
	 *
	 * There may be no overlap between the side data in this array and side data
	 * in the packets. I.e. a given side data is either exported by the muxer
	 * (demuxing) / set by the caller (muxing) in this array, then it never
	 * appears in the packets, or the side data is exported / sent through
	 * the packets (always in the first packet where the value becomes known or
	 * changes), then it does not appear in this array.
	 *
	 * - demuxing: Set by libavformat when the stream is created.
	 * - muxing: May be set by the caller before avformat_write_header().
	 *
	 * Freed by libavformat in avformat_free_context().
	 *
	 * @see av_format_inject_global_side_data()
	 */
	side_data: ^Packet_Side_Data, // AVPacketSideData *side_data;
	/**
	 * The number of elements in the AVStream.side_data array.
	 */
	nb_side_data: c.int,

	/**
	 * Flags indicating events happening on the stream, a combination of
	 * AVSTREAM_EVENT_FLAG_*.
	 *
	 * - demuxing: may be set by the demuxer in avformat_open_input(),
	 *   avformat_find_stream_info() and av_read_frame(). Flags must be cleared
	 *   by the user once the event has been handled.
	 * - muxing: may be set by the user after avformat_write_header(). to
	 *   indicate a user-triggered event.  The muxer will clear the flags for
	 *   events it has handled in av_[interleaved]_write_frame().
	 */
	event_flags: Event_Flags,

	/**
	 * Real base framerate of the stream.
	 * This is the lowest framerate with which all timestamps can be
	 * represented accurately (it is the least common multiple of all
	 * framerates in the stream). Note, this value is just a guess!
	 * For example, if the time base is 1/90000 and all frames have either
	 * approximately 3600 or 1800 timer ticks, then r_frame_rate will be 50/1.
	 */
	r_frame_rate: Rational,

	/**
	 * Codec parameters associated with this stream. Allocated and freed by
	 * libavformat in avformat_new_stream() and avformat_free_context()
	 * respectively.
	 *
	 * - demuxing: filled by libavformat on stream creation or in
	 *             avformat_find_stream_info()
	 * - muxing: filled by the caller before avformat_write_header()
	 */
	codecpar: Codec_Parameters,

	/*****************************************************************
	 * All fields below this line are not part of the public API. They
	 * may not be used outside of libavformat and can be changed and
	 * removed at will.
	 * Internal note: be aware that physically removing these fields
	 * will break ABI. Replace removed fields with dummy fields, and
	 * add new fields to AVStreamInternal.
	 *****************************************************************
	 */
	unused: rawptr,
}

Packet_Flag :: enum c.int {
	Key        = 0, ///< The packet contains a keyframe
	Corrupt    = 1, ///< The packet content is corrupted
	/**
	 * Flag is used to discard packets which are required to maintain valid
	 * decoder state but are not required for output and should be dropped
	 * after decoding.
	 **/
	Discard    = 2,
	/**
	 * The packet comes from a trusted source.
	 *
	 * Otherwise-unsafe constructs such as arbitrary pointers to data
	 * outside the packet may be followed.
	 */
	Trusted    = 3,
	/**
	 * Flag is used to indicate packets that contain frames that can
	 * be discarded by the decoder.  I.e. Non-reference frames.
	 */
	Disposable = 4,
}
Packet_Flags :: bit_set[Packet_Flag; c.int]

Packet :: struct {
	/**
	 * A reference to the reference-counted buffer where the packet data is
	 * stored.
	 * May be NULL, then the packet data is not reference-counted.
	 */
	buf: rawptr, // BufferRef *buf;

	/**
	 * Presentation timestamp in AVStream->time_base units; the time at which
	 * the decompressed packet will be presented to the user.
	 * Can be AV_NOPTS_VALUE if it is not stored in the file.
	 * pts MUST be larger or equal to dts as presentation cannot happen before
	 * decompression, unless one wants to view hex dumps. Some formats misuse
	 * the terms dts and pts/cts to mean something different. Such timestamps
	 * must be converted to true pts/dts before they are stored in AVPacket.
	 */
	pts: c.int64_t,

	/**
	 * Decompression timestamp in AVStream->time_base units; the time at which
	 * the packet is decompressed.
	 * Can be AV_NOPTS_VALUE if it is not stored in the file.
	 */
	dts: c.int64_t,
	data: [^]u8,
	size: c.int,
	stream_index: c.int,

	/**
	 * A combination of FLAG values
	 */
	flags: Packet_Flags,
	/**
	 * Additional packet data that can be provided by the container.
	 * Packet can contain several types of side information.
	 */
	side_data: [^]Packet_Side_Data,
	side_data_elems: c.int,

	/**
	 * Duration of this packet in AVStream->time_base units, 0 if unknown.
	 * Equals next_pts - this_pts in presentation order.
	 */
	duration: c.int64_t,

	pos: c.int64_t, ///< byte position in stream, -1 if unknown
}

Packet_List :: struct {
	plt: Packet,
	next: ^Packet_List,
}

Side_Data_Param_Change_Flags :: enum c.int {
	Channel_Count  = 0x0001,
	Channel_Layout = 0x0002,
	Sample_Rate    = 0x0004,
	Dimensions     = 0x0008,
}

/**
 * @defgroup lavc_packet AVPacket
 *
 * Types and functions for working with AVPacket.
 * @{
 */
Packet_Side_Data_Type :: enum c.int {
	/**
	 * An PALETTE side data packet contains exactly AVPALETTE_SIZE
	 * bytes worth of palette. This side data signals that a new palette is
	 * present.
	 */
	Palette,

	/**
	 * The NEW_EXTRADATA is used to notify the codec or the format
	 * that the extradata buffer was changed and the receiving side should
	 * act upon it appropriately. The new extradata is embedded in the side
	 * data buffer and should be immediately used for processing the current
	 * frame or packet.
	 */
	New_ExtraData,

	/**
	 * An PARAM_CHANGE side data packet is laid out as follows:
	 * @code
	 * u32le param_flags
	 * if (param_flags & AV_SIDE_PARAM_CHANGE_CHANNEL_COUNT)
	 *     s32le channel_count
	 * if (param_flags & AV_SIDE_PARAM_CHANGE_CHANNEL_LAYOUT)
	 *     u64le channel_layout
	 * if (param_flags & AV_SIDE_PARAM_CHANGE_SAMPLE_RATE)
	 *     s32le sample_rate
	 * if (param_flags & AV_SIDE_PARAM_CHANGE_DIMENSIONS)
	 *     s32le width
	 *     s32le height
	 * @endcode
	 */
	Param_Change,

	/**
	 * An H263_MB_INFO side data packet contains a number of
	 * structures with info about macroblocks relevant to splitting the
	 * packet into smaller packets on macroblock edges (e.g. as for RFC 2190).
	 * That is, it does not necessarily contain info about all macroblocks,
	 * as long as the distance between macroblocks in the info is smaller
	 * than the target payload size.
	 * Each MB info structure is 12 bytes, and is laid out as follows:
	 * @code
	 * u32le bit offset from the start of the packet
	 * u8    current quantizer at the start of the macroblock
	 * u8    GOB number
	 * u16le macroblock address within the GOB
	 * u8    horizontal MV predictor
	 * u8    vertical MV predictor
	 * u8    horizontal MV predictor for block number 3
	 * u8    vertical MV predictor for block number 3
	 * @endcode
	 */
	H263_mb_info,

	/**
	 * This side data should be associated with an audio stream and contains
	 * ReplayGain information in form of the AVReplayGain struct.
	 */
	ReplayGain,

	/**
	 * This side data contains a 3x3 transformation matrix describing an affine
	 * transformation that needs to be applied to the decoded video frames for
	 * correct presentation.
	 *
	 * See libavutil/display.h for a detailed description of the data.
	 */
	Display_Matrix,

	/**
	 * This side data should be associated with a video stream and contains
	 * Stereoscopic 3D information in form of the AVStereo3D struct.
	 */
	Stereo3D,

	/**
	 * This side data should be associated with an audio stream and corresponds
	 * to enum AVAudioServiceType.
	 */
	Audio_Service_Type,

	/**
	 * This side data contains quality related information from the encoder.
	 * @code
	 * u32le quality factor of the compressed frame. Allowed range is between 1 (good) and FF_LAMBDA_MAX (bad).
	 * u8    picture type
	 * u8    error count
	 * u16   reserved
	 * u64le[error count] sum of squared differences between encoder in and output
	 * @endcode
	 */
	Quality_Stats,

	/**
	 * This side data contains an integer value representing the stream index
	 * of a "fallback" track.  A fallback track indicates an alternate
	 * track to use when the current track can not be decoded for some reason.
	 * e.g. no decoder available for codec.
	 */
	Fallback_Track,

	/**
	 * This side data corresponds to the AVCPBProperties struct.
	 */
	CPB_Properties,

	/**
	 * Recommmends skipping the specified number of samples
	 * @code
	 * u32le number of samples to skip from start of this packet
	 * u32le number of samples to skip from end of this packet
	 * u8    reason for start skip
	 * u8    reason for end   skip (0=padding silence, 1=convergence)
	 * @endcode
	 */
	Skip_Samples,

	/**
	 * An JP_DUALMONO side data packet indicates that
	 * the packet may contain "dual mono" audio specific to Japanese DTV
	 * and if it is true, recommends only the selected channel to be used.
	 * @code
	 * u8    selected channels (0=mail/left, 1=sub/right, 2=both)
	 * @endcode
	 */
	JP_DualMono,

	/**
	 * A list of zero terminated key/value strings. There is no end marker for
	 * the list, so it is required to rely on the side data size to stop.
	 */
	Strings_Metadata,

	/**
	 * Subtitle event position
	 * @code
	 * u32le x1
	 * u32le y1
	 * u32le x2
	 * u32le y2
	 * @endcode
	 */
	Subtitle_Position,

	/**
	 * Data found in BlockAdditional element of matroska container. There is
	 * no end marker for the data, so it is required to rely on the side data
	 * size to recognize the end. 8 byte id (as found in BlockAddId) followed
	 * by data.
	 */
	Matroska_Block_Additional,

	/**
	 * The optional first identifier line of a WebVTT cue.
	 */
	WebVTT_Identifier,

	/**
	 * The optional settings (rendering instructions) that immediately
	 * follow the timestamp specifier of a WebVTT cue.
	 */
	WebVTT_Settings,

	/**
	 * A list of zero terminated key/value strings. There is no end marker for
	 * the list, so it is required to rely on the side data size to stop. This
	 * side data includes updated metadata which appeared in the stream.
	 */
	Meta_Update,

	/**
	 * MPEGTS stream ID as uint8_t, this is required to pass the stream ID
	 * information from the demuxer to the corresponding muxer.
	 */
	MPEGTS_Stream_ID,

	/**
	 * Mastering display metadata (based on SMPTE-2086:2014). This metadata
	 * should be associated with a video stream and contains data in the form
	 * of the AVMasteringDisplayMetadata struct.
	 */
	Mastering_Display_Metadata,

	/**
	 * This side data should be associated with a video stream and corresponds
	 * to the AVSphericalMapping structure.
	 */
	Spherical,

	/**
	 * Content light level (based on CTA-861.3). This metadata should be
	 * associated with a video stream and contains data in the form of the
	 * AVContentLightMetadata struct.
	 */
	Content_Light_Level,

	/**
	 * ATSC A53 Part 4 Closed Captions. This metadata should be associated with
	 * a video stream. A53 CC bitstream is stored as uint8_t in AVPacketSideData.data.
	 * The number of bytes of CC data is AVPacketSideData.size.
	 */
	A53_CC,

	/**
	 * This side data is encryption initialization data.
	 * The format is not part of ABI, use av_encryption_init_info_* methods to
	 * access.
	 */
	Encryption_Init_Info,

	/**
	 * This side data contains encryption info for how to decrypt the packet.
	 * The format is not part of ABI, use av_encryption_info_* methods to access.
	 */
	Encryption_Info,

	/**
	 * Active Format Description data consisting of a single byte as specified
	 * in ETSI TS 101 154 using AVActiveFormatDescription enum.
	 */
	AFD,

	/**
	 * Producer Reference Time data corresponding to the AVProducerReferenceTime struct,
	 * usually exported by some encoders (on demand through the prft flag set in the
	 * AVCodecContext export_side_data field).
	 */
	PRFT,

	/**
	 * ICC profile data consisting of an opaque octet buffer following the
	 * format described by ISO 15076-1.
	 */
	ICC_Profile,

	/**
	 * DOVI configuration
	 * ref:
	 * dolby-vision-bitstreams-within-the-iso-base-media-file-format-v2.1.2, section 2.2
	 * dolby-vision-bitstreams-in-mpeg-2-transport-stream-multiplex-v1.2, section 3.3
	 * Tags are stored in struct AVDOVIDecoderConfigurationRecord.
	 */
	DOVI_Conf,

	/**
	 * Timecode which conforms to SMPTE ST 12-1:2014. The data is an array of 4 uint32_t
	 * where the first uint32_t describes how many (1-3) of the other timecodes are used.
	 * The timecode format is described in the documentation of av_timecode_get_smpte_from_framenum()
	 * function in libavutil/timecode.h.
	 */
	S12m_TimeCode,

	/**
	 * The number of side data types.
	 * This is not part of the public API/ABI in the sense that it may
	 * change when new side data types are added.
	 * This must stay the last enum value.
	 * If its value becomes huge, some code using it
	 * needs to be updated as it assumes it to be smaller than other limits.
	 */
	Not_Part_of_ABI,
}

Packet_Side_Data :: struct {
	data: [^]u8,
	size: c.int,
	type: Packet_Side_Data_Type,
}

PROGRAM_RUNNING :: 1

Field_Order :: enum c.int {
	Unknown,
	Progressive,
	TT,          //< Top coded_first, top displayed first
	BB,          //< Bottom coded first, bottom displayed first
	TB,          //< Top coded first, bottom displayed first
	BT,          //< Bottom coded first, top displayed first
}

/**
 * This struct describes the properties of an encoded stream.
 *
 * sizeof(AVCodecParameters) is not a part of the public ABI, this struct must
 * be allocated with avcodec_parameters_alloc() and freed with
 * avcodec_parameters_free().
 */
Codec_Parameters :: struct {
	/**
	 * General type of the encoded data.
	 */
	codec_type:            Media_Type,
	/**
	 * Specific type of the encoded data (the codec used).
	 */
	codec_id:              Codec_ID,
	/**
	 * Additional information about the codec (corresponds to the AVI FOURCC).
	 */
	codec_tag:             FourCC,

	/**
	 * Extra binary data needed for initializing the decoder, codec-dependent.
	 *
	 * Must be allocated with av_malloc() and will be freed by
	 * avcodec_parameters_free(). The allocated size of extradata must be at
	 * least extradata_size + AV_INPUT_BUFFER_PADDING_SIZE, with the padding
	 * bytes zeroed.
	 */
	extra_data:            [^]u8,
	/**
	 * Size of the extradata content in bytes.
	 */
	extra_data_size:       c.int,

	/**
	 * - video: the  pixel format, the value corresponds to enum `Pixel_Format`.
	 * - audio: the sample format, the value corresponds to enum `Sample_Format`.
	 */
	format: struct #raw_union {
		video: Pixel_Format,
		audio: Sample_Format,
	},

	/**
	 * The average bitrate of the encoded data (in bits per second).
	 */
	bit_rate:              c.int64_t,

	/**
	 * The number of bits per sample in the codedwords.
	 *
	 * This is basically the bitrate per sample. It is mandatory for a bunch of
	 * formats to actually decode them. It's the number of bits for one sample in
	 * the actual coded bitstream.
	 *
	 * This could be for example 4 for ADPCM
	 * For PCM formats this matches bits_per_raw_sample
	 * Can be 0
	 */
	bits_per_coded_sample: c.int,

	/**
	 * This is the number of valid bits in each output sample. If the
	 * sample format has more bits, the least significant bits are additional
	 * padding bits, which are always 0. Use right shifts to reduce the sample
	 * to its actual size. For example, audio formats with 24 bit samples will
	 * have bits_per_raw_sample set to 24, and format set to AV_SAMPLE_FMT_S32.
	 * To get the original sample use "(int32_t)sample >> 8"."
	 *
	 * For ADPCM this might be 12 or 16 or similar
	 * Can be 0
	 */
	bits_per_raw_sample:   c.int,

	/**
	 * Codec-specific bitstream restrictions that the stream conforms to.
	 */
	profile:               c.int,
	level:                 c.int,

	/**
	 * Video only. The dimensions of the video frame in pixels.
	 */
	width:                 c.int,
	height:                c.int,

	/**
	 * Video only. The aspect ratio (width / height) which a single pixel
	 * should have when displayed.
	 *
	 * When the aspect ratio is unknown / undefined, the numerator should be
	 * set to 0 (the denominator may have any value).
	 */
	sample_aspect_ratio: Rational,

	/**
	 * Video only. The order of the fields in interlaced video.
	 */
	field_order:           Field_Order,

	/**
	 * Video only. Additional colorspace characteristics.
	 */

	color_range:           Color_Range,
	color_primaries:       Color_Primaries,
	color_trc:             Color_Transfer_Characteristic,
	color_space:           Color_Space,
	chroma_location:       Chroma_Location,

	/**
	 * Video only. Number of delayed frames.
	 */
	video_delay:           c.int,

	/**
	 * Audio only. The channel layout bitmask. May be 0 if the channel layout is
	 * unknown or unspecified, otherwise the number of bits set must be equal to
	 * the channels field.
	 */
	channel_layout:        c.uint64_t,
	/**
	 * Audio only. The number of audio channels.
	 */
	channels:              c.int,
	/**
	 * Audio only. The number of audio samples per second.
	 */
	sample_rate:           c.int,
	/**
	 * Audio only. The number of bytes per coded audio frame, required by some
	 * formats.
	 *
	 * Corresponds to nBlockAlign in WAVEFORMATEX.
	 */
	block_align:           c.int,
	/**
	 * Audio only. Audio frame size, if known. Required by some formats to be static.
	 */
	frame_size:            c.int,

	/**
	 * Audio only. The amount of padding (in samples) inserted by the encoder at
	 * the beginning of the audio. I.e. this number of leading decoded samples
	 * must be discarded by the caller to get the original audio without leading
	 * padding.
	 */
	initial_padding:       c.int,
	/**
	 * Audio only. The amount of padding (in samples) appended by the encoder to
	 * the end of the audio. I.e. this number of decoded samples must be
	 * discarded by the caller from the end of the stream to get the original
	 * audio without any trailing padding.
	 */
	trailing_padding:      c.int,
	/**
	 * Audio only. Number of samples to skip after a discontinuity.
	 */
	seek_preroll:          c.int,
}

/*

/**
 * New fields can be added to the end with minor version bumps.
 * Removal, reordering and changes to existing fields require a major
 * version bump.
 * sizeof(AVProgram) must not be used outside libav*.
 */
typedef struct AVProgram {
	int            id;
	int            flags;
	enum AVDiscard discard;        ///< selects which program to discard and which to feed to the caller
	unsigned int   *stream_index;
	unsigned int   nb_stream_indexes;
	AVDictionary *metadata;

	int program_num;
	int pmt_pid;
	int pcr_pid;
	int pmt_version;

	/*****************************************************************
	 * All fields below this line are not part of the public API. They
	 * may not be used outside of libavformat and can be changed and
	 * removed at will.
	 * New public fields should be added right above.
	 *****************************************************************
	 */
	int64_t start_time;
	int64_t end_time;

	int64_t pts_wrap_reference;    ///< reference dts for wrap detection
	int pts_wrap_behavior;         ///< behavior on wrap detection
} AVProgram;

#define AVFMTCTX_NOHEADER      0x0001 /**< signal that no header is present
										 (streams are added dynamically) */
#define AVFMTCTX_UNSEEKABLE    0x0002 /**< signal that the stream is definitely
										 not seekable, and attempts to call the
										 seek function will fail. For some
										 network protocols (e.g. HLS), this can
										 change dynamically at runtime. */

typedef struct AVChapter {
#if FF_API_CHAPTER_ID_INT
	int id;                 ///< unique ID to identify the chapter
#else
	int64_t id;             ///< unique ID to identify the chapter
#endif
	AVRational time_base;   ///< time base in which the start/end timestamps are specified
	int64_t start, end;     ///< chapter start/end time in time_base units
	AVDictionary *metadata;
} AVChapter;

/**
 * The duration of a video can be estimated through various ways, and this enum can be used
 * to know how the duration was estimated.
 */
enum AVDurationEstimationMethod {
	AVFMT_DURATION_FROM_PTS,    ///< Duration accurately estimated from PTSes
	AVFMT_DURATION_FROM_STREAM, ///< Duration estimated from a stream with a known duration
	AVFMT_DURATION_FROM_BITRATE ///< Duration estimated from bitrate (less accurate)
};

/**
 * Format I/O context.
 * New fields can be added to the end with minor version bumps.
 * Removal, reordering and changes to existing fields require a major
 * version bump.
 * sizeof(AVFormatContext) must not be used outside libav*, use
 * avformat_alloc_context() to create an AVFormatContext.
 *
 * Fields can be accessed through AVOptions (av_opt*),
 * the name string used matches the associated command line parameter name and
 * can be found in libavformat/options_table.h.
 * The AVOption/command line parameter names differ in some cases from the C
 * structure field names for historic reasons or brevity.
 */
typedef struct AVFormatContext {
	/**
	 * A class for logging and @ref avoptions. Set by avformat_alloc_context().
	 * Exports (de)muxer private options if they exist.
	 */
	const AVClass *av_class;

	/**
	 * The input container format.
	 *
	 * Demuxing only, set by avformat_open_input().
	 */
	ff_const59 struct AVInputFormat *iformat;

	/**
	 * The output container format.
	 *
	 * Muxing only, must be set by the caller before avformat_write_header().
	 */
	ff_const59 struct AVOutputFormat *oformat;

	/**
	 * Format private data. This is an AVOptions-enabled struct
	 * if and only if iformat/oformat.priv_class is not NULL.
	 *
	 * - muxing: set by avformat_write_header()
	 * - demuxing: set by avformat_open_input()
	 */
	void *priv_data;

	/**
	 * I/O context.
	 *
	 * - demuxing: either set by the user before avformat_open_input() (then
	 *             the user must close it manually) or set by avformat_open_input().
	 * - muxing: set by the user before avformat_write_header(). The caller must
	 *           take care of closing / freeing the IO context.
	 *
	 * Do NOT set this field if AVFMT_NOFILE flag is set in
	 * iformat/oformat.flags. In such a case, the (de)muxer will handle
	 * I/O in some other way and this field will be NULL.
	 */
	AVIOContext *pb;

	/* stream info */
	/**
	 * Flags signalling stream properties. A combination of AVFMTCTX_*.
	 * Set by libavformat.
	 */
	int ctx_flags;

	/**
	 * Number of elements in AVFormatContext.streams.
	 *
	 * Set by avformat_new_stream(), must not be modified by any other code.
	 */
	unsigned int nb_streams;
	/**
	 * A list of all streams in the file. New streams are created with
	 * avformat_new_stream().
	 *
	 * - demuxing: streams are created by libavformat in avformat_open_input().
	 *             If AVFMTCTX_NOHEADER is set in ctx_flags, then new streams may also
	 *             appear in av_read_frame().
	 * - muxing: streams are created by the user before avformat_write_header().
	 *
	 * Freed by libavformat in avformat_free_context().
	 */
	AVStream **streams;

#if FF_API_FORMAT_FILENAME
	/**
	 * input or output filename
	 *
	 * - demuxing: set by avformat_open_input()
	 * - muxing: may be set by the caller before avformat_write_header()
	 *
	 * @deprecated Use url instead.
	 */
	attribute_deprecated
	char filename[1024];
#endif

	/**
	 * input or output URL. Unlike the old filename field, this field has no
	 * length restriction.
	 *
	 * - demuxing: set by avformat_open_input(), initialized to an empty
	 *             string if url parameter was NULL in avformat_open_input().
	 * - muxing: may be set by the caller before calling avformat_write_header()
	 *           (or avformat_init_output() if that is called first) to a string
	 *           which is freeable by av_free(). Set to an empty string if it
	 *           was NULL in avformat_init_output().
	 *
	 * Freed by libavformat in avformat_free_context().
	 */
	char *url;

	/**
	 * Position of the first frame of the component, in
	 * AV_TIME_BASE fractional seconds. NEVER set this value directly:
	 * It is deduced from the AVStream values.
	 *
	 * Demuxing only, set by libavformat.
	 */
	int64_t start_time;

	/**
	 * Duration of the stream, in AV_TIME_BASE fractional
	 * seconds. Only set this value if you know none of the individual stream
	 * durations and also do not set any of them. This is deduced from the
	 * AVStream values if not set.
	 *
	 * Demuxing only, set by libavformat.
	 */
	int64_t duration;

	/**
	 * Total stream bitrate in bit/s, 0 if not
	 * available. Never set it directly if the file_size and the
	 * duration are known as FFmpeg can compute it automatically.
	 */
	int64_t bit_rate;

	unsigned int packet_size;
	int max_delay;

	/**
	 * Flags modifying the (de)muxer behaviour. A combination of AVFMT_FLAG_*.
	 * Set by the user before avformat_open_input() / avformat_write_header().
	 */
	int flags;
#define AVFMT_FLAG_GENPTS       0x0001 ///< Generate missing pts even if it requires parsing future frames.
#define AVFMT_FLAG_IGNIDX       0x0002 ///< Ignore index.
#define AVFMT_FLAG_NONBLOCK     0x0004 ///< Do not block when reading packets from input.
#define AVFMT_FLAG_IGNDTS       0x0008 ///< Ignore DTS on frames that contain both DTS & PTS
#define AVFMT_FLAG_NOFILLIN     0x0010 ///< Do not infer any values from other values, just return what is stored in the container
#define AVFMT_FLAG_NOPARSE      0x0020 ///< Do not use AVParsers, you also must set AVFMT_FLAG_NOFILLIN as the fillin code works on frames and no parsing -> no frames. Also seeking to frames can not work if parsing to find frame boundaries has been disabled
#define AVFMT_FLAG_NOBUFFER     0x0040 ///< Do not buffer frames when possible
#define AVFMT_FLAG_CUSTOM_IO    0x0080 ///< The caller has supplied a custom AVIOContext, don't avio_close() it.
#define AVFMT_FLAG_DISCARD_CORRUPT  0x0100 ///< Discard frames marked corrupted
#define AVFMT_FLAG_FLUSH_PACKETS    0x0200 ///< Flush the AVIOContext every packet.
/**
 * When muxing, try to avoid writing any random/volatile data to the output.
 * This includes any random IDs, real-time timestamps/dates, muxer version, etc.
 *
 * This flag is mainly intended for testing.
 */
#define AVFMT_FLAG_BITEXACT         0x0400
#if FF_API_LAVF_MP4A_LATM
#define AVFMT_FLAG_MP4A_LATM    0x8000 ///< Deprecated, does nothing.
#endif
#define AVFMT_FLAG_SORT_DTS    0x10000 ///< try to interleave outputted packets by dts (using this flag can slow demuxing down)
#if FF_API_LAVF_PRIV_OPT
#define AVFMT_FLAG_PRIV_OPT    0x20000 ///< Enable use of private options by delaying codec open (deprecated, will do nothing once av_demuxer_open() is removed)
#endif
#if FF_API_LAVF_KEEPSIDE_FLAG
#define AVFMT_FLAG_KEEP_SIDE_DATA 0x40000 ///< Deprecated, does nothing.
#endif
#define AVFMT_FLAG_FAST_SEEK   0x80000 ///< Enable fast, but inaccurate seeks for some formats
#define AVFMT_FLAG_SHORTEST   0x100000 ///< Stop muxing when the shortest stream stops.
#define AVFMT_FLAG_AUTO_BSF   0x200000 ///< Add bitstream filters as requested by the muxer

	/**
	 * Maximum size of the data read from input for determining
	 * the input container format.
	 * Demuxing only, set by the caller before avformat_open_input().
	 */
	int64_t probesize;

	/**
	 * Maximum duration (in AV_TIME_BASE units) of the data read
	 * from input in avformat_find_stream_info().
	 * Demuxing only, set by the caller before avformat_find_stream_info().
	 * Can be set to 0 to let avformat choose using a heuristic.
	 */
	int64_t max_analyze_duration;

	const uint8_t *key;
	int keylen;

	unsigned int nb_programs;
	AVProgram **programs;

	/**
	 * Forced video codec_id.
	 * Demuxing: Set by user.
	 */
	enum AVCodecID video_codec_id;

	/**
	 * Forced audio codec_id.
	 * Demuxing: Set by user.
	 */
	enum AVCodecID audio_codec_id;

	/**
	 * Forced subtitle codec_id.
	 * Demuxing: Set by user.
	 */
	enum AVCodecID subtitle_codec_id;

	/**
	 * Maximum amount of memory in bytes to use for the index of each stream.
	 * If the index exceeds this size, entries will be discarded as
	 * needed to maintain a smaller size. This can lead to slower or less
	 * accurate seeking (depends on demuxer).
	 * Demuxers for which a full in-memory index is mandatory will ignore
	 * this.
	 * - muxing: unused
	 * - demuxing: set by user
	 */
	unsigned int max_index_size;

	/**
	 * Maximum amount of memory in bytes to use for buffering frames
	 * obtained from realtime capture devices.
	 */
	unsigned int max_picture_buffer;

	/**
	 * Number of chapters in AVChapter array.
	 * When muxing, chapters are normally written in the file header,
	 * so nb_chapters should normally be initialized before write_header
	 * is called. Some muxers (e.g. mov and mkv) can also write chapters
	 * in the trailer.  To write chapters in the trailer, nb_chapters
	 * must be zero when write_header is called and non-zero when
	 * write_trailer is called.
	 * - muxing: set by user
	 * - demuxing: set by libavformat
	 */
	unsigned int nb_chapters;
	AVChapter **chapters;

	/**
	 * Metadata that applies to the whole file.
	 *
	 * - demuxing: set by libavformat in avformat_open_input()
	 * - muxing: may be set by the caller before avformat_write_header()
	 *
	 * Freed by libavformat in avformat_free_context().
	 */
	AVDictionary *metadata;

	/**
	 * Start time of the stream in real world time, in microseconds
	 * since the Unix epoch (00:00 1st January 1970). That is, pts=0 in the
	 * stream was captured at this real world time.
	 * - muxing: Set by the caller before avformat_write_header(). If set to
	 *           either 0 or AV_NOPTS_VALUE, then the current wall-time will
	 *           be used.
	 * - demuxing: Set by libavformat. AV_NOPTS_VALUE if unknown. Note that
	 *             the value may become known after some number of frames
	 *             have been received.
	 */
	int64_t start_time_realtime;

	/**
	 * The number of frames used for determining the framerate in
	 * avformat_find_stream_info().
	 * Demuxing only, set by the caller before avformat_find_stream_info().
	 */
	int fps_probe_size;

	/**
	 * Error recognition; higher values will detect more errors but may
	 * misdetect some more or less valid parts as errors.
	 * Demuxing only, set by the caller before avformat_open_input().
	 */
	int error_recognition;

	/**
	 * Custom interrupt callbacks for the I/O layer.
	 *
	 * demuxing: set by the user before avformat_open_input().
	 * muxing: set by the user before avformat_write_header()
	 * (mainly useful for AVFMT_NOFILE formats). The callback
	 * should also be passed to avio_open2() if it's used to
	 * open the file.
	 */
	AVIOInterruptCB interrupt_callback;

	/**
	 * Flags to enable debugging.
	 */
	int debug;
#define FF_FDEBUG_TS        0x0001

	/**
	 * Maximum buffering duration for interleaving.
	 *
	 * To ensure all the streams are interleaved correctly,
	 * av_interleaved_write_frame() will wait until it has at least one packet
	 * for each stream before actually writing any packets to the output file.
	 * When some streams are "sparse" (i.e. there are large gaps between
	 * successive packets), this can result in excessive buffering.
	 *
	 * This field specifies the maximum difference between the timestamps of the
	 * first and the last packet in the muxing queue, above which libavformat
	 * will output a packet regardless of whether it has queued a packet for all
	 * the streams.
	 *
	 * Muxing only, set by the caller before avformat_write_header().
	 */
	int64_t max_interleave_delta;

	/**
	 * Allow non-standard and experimental extension
	 * @see AVCodecContext.strict_std_compliance
	 */
	int strict_std_compliance;

	/**
	 * Flags indicating events happening on the file, a combination of
	 * AVFMT_EVENT_FLAG_*.
	 *
	 * - demuxing: may be set by the demuxer in avformat_open_input(),
	 *   avformat_find_stream_info() and av_read_frame(). Flags must be cleared
	 *   by the user once the event has been handled.
	 * - muxing: may be set by the user after avformat_write_header() to
	 *   indicate a user-triggered event.  The muxer will clear the flags for
	 *   events it has handled in av_[interleaved]_write_frame().
	 */
	int event_flags;
/**
 * - demuxing: the demuxer read new metadata from the file and updated
 *   AVFormatContext.metadata accordingly
 * - muxing: the user updated AVFormatContext.metadata and wishes the muxer to
 *   write it into the file
 */
#define AVFMT_EVENT_FLAG_METADATA_UPDATED 0x0001

	/**
	 * Maximum number of packets to read while waiting for the first timestamp.
	 * Decoding only.
	 */
	int max_ts_probe;

	/**
	 * Avoid negative timestamps during muxing.
	 * Any value of the AVFMT_AVOID_NEG_TS_* constants.
	 * Note, this only works when using av_interleaved_write_frame. (interleave_packet_per_dts is in use)
	 * - muxing: Set by user
	 * - demuxing: unused
	 */
	int avoid_negative_ts;
#define AVFMT_AVOID_NEG_TS_AUTO             -1 ///< Enabled when required by target format
#define AVFMT_AVOID_NEG_TS_MAKE_NON_NEGATIVE 1 ///< Shift timestamps so they are non negative
#define AVFMT_AVOID_NEG_TS_MAKE_ZERO         2 ///< Shift timestamps so that they start at 0

	/**
	 * Transport stream id.
	 * This will be moved into demuxer private options. Thus no API/ABI compatibility
	 */
	int ts_id;

	/**
	 * Audio preload in microseconds.
	 * Note, not all formats support this and unpredictable things may happen if it is used when not supported.
	 * - encoding: Set by user
	 * - decoding: unused
	 */
	int audio_preload;

	/**
	 * Max chunk time in microseconds.
	 * Note, not all formats support this and unpredictable things may happen if it is used when not supported.
	 * - encoding: Set by user
	 * - decoding: unused
	 */
	int max_chunk_duration;

	/**
	 * Max chunk size in bytes
	 * Note, not all formats support this and unpredictable things may happen if it is used when not supported.
	 * - encoding: Set by user
	 * - decoding: unused
	 */
	int max_chunk_size;

	/**
	 * forces the use of wallclock timestamps as pts/dts of packets
	 * This has undefined results in the presence of B frames.
	 * - encoding: unused
	 * - decoding: Set by user
	 */
	int use_wallclock_as_timestamps;

	/**
	 * avio flags, used to force AVIO_FLAG_DIRECT.
	 * - encoding: unused
	 * - decoding: Set by user
	 */
	int avio_flags;

	/**
	 * The duration field can be estimated through various ways, and this field can be used
	 * to know how the duration was estimated.
	 * - encoding: unused
	 * - decoding: Read by user
	 */
	enum AVDurationEstimationMethod duration_estimation_method;

	/**
	 * Skip initial bytes when opening stream
	 * - encoding: unused
	 * - decoding: Set by user
	 */
	int64_t skip_initial_bytes;

	/**
	 * Correct single timestamp overflows
	 * - encoding: unused
	 * - decoding: Set by user
	 */
	unsigned int correct_ts_overflow;

	/**
	 * Force seeking to any (also non key) frames.
	 * - encoding: unused
	 * - decoding: Set by user
	 */
	int seek2any;

	/**
	 * Flush the I/O context after each packet.
	 * - encoding: Set by user
	 * - decoding: unused
	 */
	int flush_packets;

	/**
	 * format probing score.
	 * The maximal score is AVPROBE_SCORE_MAX, its set when the demuxer probes
	 * the format.
	 * - encoding: unused
	 * - decoding: set by avformat, read by user
	 */
	int probe_score;

	/**
	 * number of bytes to read maximally to identify format.
	 * - encoding: unused
	 * - decoding: set by user
	 */
	int format_probesize;

	/**
	 * ',' separated list of allowed decoders.
	 * If NULL then all are allowed
	 * - encoding: unused
	 * - decoding: set by user
	 */
	char *codec_whitelist;

	/**
	 * ',' separated list of allowed demuxers.
	 * If NULL then all are allowed
	 * - encoding: unused
	 * - decoding: set by user
	 */
	char *format_whitelist;

	/**
	 * An opaque field for libavformat internal usage.
	 * Must not be accessed in any way by callers.
	 */
	AVFormatInternal *internal;

	/**
	 * IO repositioned flag.
	 * This is set by avformat when the underlaying IO context read pointer
	 * is repositioned, for example when doing byte based seeking.
	 * Demuxers can use the flag to detect such changes.
	 */
	int io_repositioned;

	/**
	 * Forced video codec.
	 * This allows forcing a specific decoder, even when there are multiple with
	 * the same codec_id.
	 * Demuxing: Set by user
	 */
	AVCodec *video_codec;

	/**
	 * Forced audio codec.
	 * This allows forcing a specific decoder, even when there are multiple with
	 * the same codec_id.
	 * Demuxing: Set by user
	 */
	AVCodec *audio_codec;

	/**
	 * Forced subtitle codec.
	 * This allows forcing a specific decoder, even when there are multiple with
	 * the same codec_id.
	 * Demuxing: Set by user
	 */
	AVCodec *subtitle_codec;

	/**
	 * Forced data codec.
	 * This allows forcing a specific decoder, even when there are multiple with
	 * the same codec_id.
	 * Demuxing: Set by user
	 */
	AVCodec *data_codec;

	/**
	 * Number of bytes to be written as padding in a metadata header.
	 * Demuxing: Unused.
	 * Muxing: Set by user via av_format_set_metadata_header_padding.
	 */
	int metadata_header_padding;

	/**
	 * User data.
	 * This is a place for some private data of the user.
	 */
	void *opaque;

	/**
	 * Callback used by devices to communicate with application.
	 */
	av_format_control_message control_message_cb;

	/**
	 * Output timestamp offset, in microseconds.
	 * Muxing: set by user
	 */
	int64_t output_ts_offset;

	/**
	 * dump format separator.
	 * can be ", " or "\n      " or anything else
	 * - muxing: Set by user.
	 * - demuxing: Set by user.
	 */
	uint8_t *dump_separator;

	/**
	 * Forced Data codec_id.
	 * Demuxing: Set by user.
	 */
	enum AVCodecID data_codec_id;

#if FF_API_OLD_OPEN_CALLBACKS
	/**
	 * Called to open further IO contexts when needed for demuxing.
	 *
	 * This can be set by the user application to perform security checks on
	 * the URLs before opening them.
	 * The function should behave like avio_open2(), AVFormatContext is provided
	 * as contextual information and to reach AVFormatContext.opaque.
	 *
	 * If NULL then some simple checks are used together with avio_open2().
	 *
	 * Must not be accessed directly from outside avformat.
	 * @See av_format_set_open_cb()
	 *
	 * Demuxing: Set by user.
	 *
	 * @deprecated Use io_open and io_close.
	 */
	attribute_deprecated
	int (*open_cb)(struct AVFormatContext *s, AVIOContext **p, const char *url, int flags, const AVIOInterruptCB *int_cb, AVDictionary **options);
#endif

	/**
	 * ',' separated list of allowed protocols.
	 * - encoding: unused
	 * - decoding: set by user
	 */
	char *protocol_whitelist;

	/**
	 * A callback for opening new IO streams.
	 *
	 * Whenever a muxer or a demuxer needs to open an IO stream (typically from
	 * avformat_open_input() for demuxers, but for certain formats can happen at
	 * other times as well), it will call this callback to obtain an IO context.
	 *
	 * @param s the format context
	 * @param pb on success, the newly opened IO context should be returned here
	 * @param url the url to open
	 * @param flags a combination of AVIO_FLAG_*
	 * @param options a dictionary of additional options, with the same
	 *                semantics as in avio_open2()
	 * @return 0 on success, a negative AVERROR code on failure
	 *
	 * @note Certain muxers and demuxers do nesting, i.e. they open one or more
	 * additional internal format contexts. Thus the AVFormatContext pointer
	 * passed to this callback may be different from the one facing the caller.
	 * It will, however, have the same 'opaque' field.
	 */
	int (*io_open)(struct AVFormatContext *s, AVIOContext **pb, const char *url,
				   int flags, AVDictionary **options);

	/**
	 * A callback for closing the streams opened with AVFormatContext.io_open().
	 */
	void (*io_close)(struct AVFormatContext *s, AVIOContext *pb);

	/**
	 * ',' separated list of disallowed protocols.
	 * - encoding: unused
	 * - decoding: set by user
	 */
	char *protocol_blacklist;

	/**
	 * The maximum number of streams.
	 * - encoding: unused
	 * - decoding: set by user
	 */
	int max_streams;

	/**
	 * Skip duration calcuation in estimate_timings_from_pts.
	 * - encoding: unused
	 * - decoding: set by user
	 */
	int skip_estimate_duration_from_pts;

	/**
	 * Maximum number of packets that can be probed
	 * - encoding: unused
	 * - decoding: set by user
	 */
	int max_probe_packets;
}
*/

SEEK_FLAG_BACKWARD            :: 1 ///< seek backward
SEEK_FLAG_BYTE                :: 2 ///< seeking based on position in bytes
SEEK_FLAG_ANY                 :: 4 ///< seek to any frame, even non-keyframes
SEEK_FLAG_FRAME               :: 8 ///< seeking based on frame number

STREAM_INIT_IN_WRITE_HEADER   :: 0 ///< stream parameters initialized in avformat_write_header
STREAM_INIT_IN_INIT_OUTPUT    :: 1 ///< stream parameters initialized in avformat_init_output
FRAME_FILENAME_FLAGS_MULTIPLE :: 1 ///< Allow multiple %d

Timebase_Source :: enum c.int {
	AUTO = -1,
	DECODER,
	DEMUXER,
	R_FRAMERATE,
}

/* ==============================================================================================
      UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL - UTIL
   ============================================================================================== */

Rational :: struct {
	numerator:   c.int,
	denominator: c.int,
}

Media_Type :: enum c.int {
	Unknown = -1,
	Video,
	Audio,
	Data,
	Subtitle,
	Attachment,
	Not_Part_of_ABI,
}

Class_Category :: enum c.int {
	None = 0,
	Input,
	Output,
	Muxer,
	Demuxer,
	Encoder,
	Decoder,
	Filter,
	Bitstream_Filter,
	Swscaler,
	Swresampler,
	Device_Video_Output = 40,
	Device_Video_Input,
	Device_Audio_Output,
	Device_Audio_Input,
	Device_Output,
	Device_Input,
	Not_Part_of_ABI,
}

Option_Type :: enum c.int {
	Flags,
	Int,
	Int64,
	Double,
	Float,
	String,
	Rational,
	Binary,
	Dict,
	Uint64,
	Const,
	Image_Size,
	Pixel_Fmt,
	Sample_Fmt,
	Video_Rate,
	Duration,
	Color,
	Channel_Layout,
	Bool,
}

Option_Flag :: enum c.int {
	Encoding_Param  =  0,
	Decoding_Param  =  1,
	Audio_Param     =  3,
	Video_Param     =  4,
	Subtitle_Param  =  5,
	Export          =  6,
	Read_Only       =  7,
	BSF_Param       =  8,
	Runtime_Param   = 15,
	Filtering_Param = 16,
	Deprecated      = 17,
	Child_Constants = 18,
}
Option_Flags :: bit_set[Option_Flag; c.int]

Option :: struct {
	name: cstring,
	help: cstring,

	option_offset: c.int,
	type: Option_Type,
	default_val: struct #raw_union {
		int_64: c.int64_t,
		dbl:    c.double,
		str:    cstring,
		q: Rational,
	},
	min: c.double,
	max: c.double,

	flags: Option_Flags,

	unit: cstring,
}

Class :: struct {
	class_name:                cstring,
	item_name:                 proc(ctx: rawptr) -> cstring,

	option:                    ^Option,
	av_util_verion:            c.int,

	log_level_offset_offset:   c.int,
	parent_log_context_offset: c.int,

	next_child:                proc(obj: rawptr, prev: rawptr) -> rawptr,
	child_class_next:          proc(prev: ^Class) -> (next: ^Class),
	category:                  Class_Category,
	get_category:              proc(ctx: rawptr) -> (category: Class_Category),
	query_ranges:              proc(ranges: ^[^]Option_Ranges, obj: rawptr, key: cstring, flags: Option_Flags) -> c.int,
	child_class_iterate:       proc(iter: ^rawptr) -> ^Class,
}

Option_Range :: struct {
	str:           cstring,
	value_min:     c.double,
	value_max:     c.double,
	component_min: c.double,
	component_max: c.double,
	is_range:      c.int,
}

Option_Ranges :: struct {
	range:           ^[^]Option_Range,
	ranges_count:    c.int,
	component_count: c.int,
}

Log_Level :: enum c.int {
	QUIET      = -8,
	PANIC      =  0,
	FATAL      =  8,
	ERROR      = 16,
	WARNING    = 24,
	INFO       = 32,
	VERBOSE    = 40,
	DEBUG      = 48,
	TRACE      = 56,
	MAX_OFFSET = (TRACE - QUIET),
}

FF_LAMBDA_SHIFT  :: 7
FF_LAMBDA_SCALE  :: (1 << FF_LAMBDA_SHIFT)
FF_QP2LAMBDA     :: 118
FF_LAMBDA_MAX    :: (256 * 128 - 1)
FF_QUALITY_SCALE :: FF_LAMBDA_SCALE

NOPTS_VALUE      :: 0x8000000000000000
TIME_BASE        :: 1000000

TIME_BASE_Q      :: Rational{1, TIME_BASE}

Picture_Type :: enum c.int {
	NONE = 0,
	I,  // Intra
	P,  // Predicted
	B,  // Bidirectionally predicted
	S,  // S(GMC)-VOP MPEG-4
	SI, // Switching Intra
	SP, // Switching Predicted
	BI, // Bidirectional
}

FOURCC_MAX_STRING_SIZE :: 32

Opt_Flag :: enum c.int {
	None                  =  0,
	Implicit_Key          =  1,
	Opt_Allow_Null        =  2,
	Multi_Component_Range = 12,
}
Opt_Flags :: bit_set[Opt_Flag; c.int]

Opt_Search_Flag :: enum c.int {
	Children    = 0,
	Fake_Object = 1,
}
Opt_Search_Flags :: bit_set[Opt_Search_Flag; c.int]

Opt_Serialize_Flag :: enum c.int {
	Skip_Defaults   = 0,
	Opt_Flags_Exact = 1,
}
Opt_Serialize_Flags :: bit_set[Opt_Serialize_Flag; c.int]

Sample_Format :: enum c.int {
	NONE = -1,
	U8,              ///< unsigned 8 bits
	S16,             ///< signed 16 bits
	S32,             ///< signed 32 bits
	FLT,             ///< float
	DBL,             ///< double

	U8P,             ///< unsigned 8 bits, planar
	S16P,            ///< signed 16 bits, planar
	S32P,            ///< signed 32 bits, planar
	FLTP,            ///< float, planar
	DBLP,            ///< double, planar
	S64,             ///< signed 64 bits
	S64P,            ///< signed 64 bits, planar

	Not_Part_of_ABI, //< Number of sample formats. DO NOT USE if linking dynamically
}


PALETTE_SIZE  :: 1024
PALETTE_COUNT :: 256

/**
 * Pixel format.
 *
 * @note
 * RGB32 is handled in an endian-specific manner. An RGBA
 * color is put together as:
 *  (A << 24) | (R << 16) | (G << 8) | B
 * This is stored as BGRA on little-endian CPU architectures and ARGB on
 * big-endian CPUs.
 *
 * @note
 * If the resolution is not a multiple of the chroma subsampling factor
 * then the chroma plane resolution must be rounded up.
 *
 * @par
 * When the pixel format is palettized RGB32 (PAL8), the palettized
 * image data is stored in AVFrame.data[0]. The palette is transported in
 * AVFrame.data[1], is 1024 bytes long (256 4-byte entries) and is
 * formatted the same as in RGB32 described above (i.e., it is
 * also endian-specific). Note also that the individual RGB32 palette
 * components stored in AVFrame.data[1] should be in the range 0..255.
 * This is important as many custom PAL8 video codecs that were designed
 * to run on the IBM VGA graphics adapter use 6-bit palette components.
 *
 * @par
 * For all the 8 bits per pixel formats, an RGB32 palette is in data[1] like
 * for pal8. This palette is filled in automatically by the function
 * allocating the picture.
 */
Pixel_Format :: enum c.int {
	NONE = -1,
	YUV420P,     ///< planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
	YUYV422,     ///< packed YUV 4:2:2, 16bpp, Y0 Cb Y1 Cr
	RGB24,       ///< packed RGB 8:8:8, 24bpp, RGBRGB...
	BGR24,       ///< packed RGB 8:8:8, 24bpp, BGRBGR...
	YUV422P,     ///< planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
	YUV444P,     ///< planar YUV 4:4:4, 24bpp, (1 Cr & Cb sample per 1x1 Y samples)
	YUV410P,     ///< planar YUV 4:1:0,  9bpp, (1 Cr & Cb sample per 4x4 Y samples)
	YUV411P,     ///< planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples)
	GRAY8,       ///<        Y        ,  8bpp
	MONOWHITE,   ///<        Y        ,  1bpp, 0 is white, 1 is black, in each byte pixels are ordered from the msb to the lsb
	MONOBLACK,   ///<        Y        ,  1bpp, 0 is black, 1 is white, in each byte pixels are ordered from the msb to the lsb
	PAL8,        ///< 8 bits with RGB32 palette
	YUVJ420P,    ///< planar YUV 4:2:0, 12bpp, full scale (JPEG), deprecated in favor of YUV420P and setting color_range
	YUVJ422P,    ///< planar YUV 4:2:2, 16bpp, full scale (JPEG), deprecated in favor of YUV422P and setting color_range
	YUVJ444P,    ///< planar YUV 4:4:4, 24bpp, full scale (JPEG), deprecated in favor of YUV444P and setting color_range
	UYVY422,     ///< packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
	UYYVYY411,   ///< packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
	BGR8,        ///< packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
	BGR4,        ///< packed RGB 1:2:1 bitstream,  4bpp, (msb)1B 2G 1R(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
	BGR4_BYTE,   ///< packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
	RGB8,        ///< packed RGB 3:3:2,  8bpp, (msb)2R 3G 3B(lsb)
	RGB4,        ///< packed RGB 1:2:1 bitstream,  4bpp, (msb)1R 2G 1B(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
	RGB4_BYTE,   ///< packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
	NV12,        ///< planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
	NV21,        ///< as above, but U and V bytes are swapped

	ARGB,        ///< packed ARGB 8:8:8:8, 32bpp, ARGBARGB...
	RGBA,        ///< packed RGBA 8:8:8:8, 32bpp, RGBARGBA...
	ABGR,        ///< packed ABGR 8:8:8:8, 32bpp, ABGRABGR...
	BGRA,        ///< packed BGRA 8:8:8:8, 32bpp, BGRABGRA...

	GRAY16BE,    ///<        Y        , 16bpp, big-endian
	GRAY16LE,    ///<        Y        , 16bpp, little-endian
	YUV440P,     ///< planar YUV 4:4:0 (1 Cr & Cb sample per 1x2 Y samples)
	YUVJ440P,    ///< planar YUV 4:4:0 full scale (JPEG), deprecated in favor of YUV440P and setting color_range
	YUVA420P,    ///< planar YUV 4:2:0, 20bpp, (1 Cr & Cb sample per 2x2 Y & A samples)
	RGB48BE,     ///< packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as big-endian
	RGB48LE,     ///< packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as little-endian

	RGB565BE,    ///< packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), big-endian
	RGB565LE,    ///< packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), little-endian
	RGB555BE,    ///< packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), big-endian   , X=unused/undefined
	RGB555LE,    ///< packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), little-endian, X=unused/undefined

	BGR565BE,    ///< packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), big-endian
	BGR565LE,    ///< packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), little-endian
	BGR555BE,    ///< packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), big-endian   , X=unused/undefined
	BGR555LE,    ///< packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), little-endian, X=unused/undefined

	VAAPI_MOCO,  ///< HW acceleration through VA API at motion compensation entry-point, Picture.data[3] contains a vaapi_render_state struct which contains macroblocks as well as various fields extracted from headers
	VAAPI_IDCT,  ///< HW acceleration through VA API at IDCT entry-point, Picture.data[3] contains a vaapi_render_state struct which contains fields extracted from headers
	VAAPI_VLD,   ///< HW decoding through VA API, Picture.data[3] contains a VASurfaceID
	VAAPI = VAAPI_VLD,

	YUV420P16LE, ///< planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV420P16BE, ///< planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV422P16LE, ///< planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	YUV422P16BE, ///< planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV444P16LE, ///< planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	YUV444P16BE, ///< planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	DXVA2_VLD,   ///< HW decoding through DXVA2, Picture.data[3] contains a LPDIRECT3DSURFACE9 pointer

	RGB444LE,    ///< packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), little-endian, X=unused/undefined
	RGB444BE,    ///< packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), big-endian,    X=unused/undefined
	BGR444LE,    ///< packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), little-endian, X=unused/undefined
	BGR444BE,    ///< packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), big-endian,    X=unused/undefined
	YA8,         ///< 8 bits gray, 8 bits alpha

	Y400A = YA8, ///< alias for YA8
	GRAY8A= YA8, ///< alias for YA8

	BGR48BE,     ///< packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as big-endian
	BGR48LE,     ///< packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as little-endian

	/**
	 * The following 12 formats have the disadvantage of needing 1 format for each bit depth.
	 * Notice that each 9/10 bits sample is stored in 16 bits with extra padding.
	 * If you want to support multiple bit depths, then using YUV420P16* with the bpp stored separately is better.
	 */
	YUV420P9BE,   ///< planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV420P9LE,   ///< planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV420P10BE,  ///< planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV420P10LE,  ///< planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV422P10BE,  ///< planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV422P10LE,  ///< planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	YUV444P9BE,   ///< planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	YUV444P9LE,   ///< planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	YUV444P10BE,  ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	YUV444P10LE,  ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	YUV422P9BE,   ///< planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV422P9LE,   ///< planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	GBRP,         ///< planar GBR 4:4:4 24bpp
	GBR24P = GBRP, // alias for #GBRP
	GBRP9BE,      ///< planar GBR 4:4:4 27bpp, big-endian
	GBRP9LE,      ///< planar GBR 4:4:4 27bpp, little-endian
	GBRP10BE,     ///< planar GBR 4:4:4 30bpp, big-endian
	GBRP10LE,     ///< planar GBR 4:4:4 30bpp, little-endian
	GBRP16BE,     ///< planar GBR 4:4:4 48bpp, big-endian
	GBRP16LE,     ///< planar GBR 4:4:4 48bpp, little-endian
	YUVA422P,     ///< planar YUV 4:2:2 24bpp, (1 Cr & Cb sample per 2x1 Y & A samples)
	YUVA444P,     ///< planar YUV 4:4:4 32bpp, (1 Cr & Cb sample per 1x1 Y & A samples)
	YUVA420P9BE,  ///< planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), big-endian
	YUVA420P9LE,  ///< planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), little-endian
	YUVA422P9BE,  ///< planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), big-endian
	YUVA422P9LE,  ///< planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), little-endian
	YUVA444P9BE,  ///< planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
	YUVA444P9LE,  ///< planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
	YUVA420P10BE, ///< planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
	YUVA420P10LE, ///< planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
	YUVA422P10BE, ///< planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
	YUVA422P10LE, ///< planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
	YUVA444P10BE, ///< planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
	YUVA444P10LE, ///< planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
	YUVA420P16BE, ///< planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
	YUVA420P16LE, ///< planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
	YUVA422P16BE, ///< planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
	YUVA422P16LE, ///< planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
	YUVA444P16BE, ///< planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
	YUVA444P16LE, ///< planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)

	VDPAU,        ///< HW acceleration through VDPAU, Picture.data[3] contains a VdpVideoSurface

	XYZ12LE,      ///< packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as little-endian, the 4 lower bits are set to 0
	XYZ12BE,      ///< packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as big-endian, the 4 lower bits are set to 0
	NV16,         ///< interleaved chroma YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
	NV20LE,       ///< interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	NV20BE,       ///< interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian

	RGBA64BE,     ///< packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
	RGBA64LE,     ///< packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
	BGRA64BE,     ///< packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
	BGRA64LE,     ///< packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian

	YVYU422,      ///< packed YUV 4:2:2, 16bpp, Y0 Cr Y1 Cb

	YA16BE,       ///< 16 bits gray, 16 bits alpha (big-endian)
	YA16LE,       ///< 16 bits gray, 16 bits alpha (little-endian)

	GBRAP,        ///< planar GBRA 4:4:4:4 32bpp
	GBRAP16BE,    ///< planar GBRA 4:4:4:4 64bpp, big-endian
	GBRAP16LE,    ///< planar GBRA 4:4:4:4 64bpp, little-endian
	/**
	 *  HW acceleration through QSV, data[3] contains a pointer to the
	 *  mfxFrameSurface1 structure.
	 */
	QSV,
	/**
	 * HW acceleration though MMAL, data[3] contains a pointer to the
	 * MMAL_BUFFER_HEADER_T structure.
	 */
	MMAL,

	D3D11VA_VLD,  ///< HW decoding through Direct3D11 via old API, Picture.data[3] contains a ID3D11VideoDecoderOutputView pointer

	/**
	 * HW acceleration through CUDA. data[i] contain CUdeviceptr pointers
	 * exactly as for system memory frames.
	 */
	CUDA,

	_0RGB,        ///< packed RGB 8:8:8, 32bpp, XRGBXRGB...   X=unused/undefined
	RGB0,        ///< packed RGB 8:8:8, 32bpp, RGBXRGBX...   X=unused/undefined
	_0BGR,        ///< packed BGR 8:8:8, 32bpp, XBGRXBGR...   X=unused/undefined
	BGR0,        ///< packed BGR 8:8:8, 32bpp, BGRXBGRX...   X=unused/undefined

	YUV420P12BE, ///< planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV420P12LE, ///< planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV420P14BE, ///< planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
	YUV420P14LE, ///< planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
	YUV422P12BE, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV422P12LE, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	YUV422P14BE, ///< planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
	YUV422P14LE, ///< planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
	YUV444P12BE, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	YUV444P12LE, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	YUV444P14BE, ///< planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
	YUV444P14LE, ///< planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
	GBRP12BE,    ///< planar GBR 4:4:4 36bpp, big-endian
	GBRP12LE,    ///< planar GBR 4:4:4 36bpp, little-endian
	GBRP14BE,    ///< planar GBR 4:4:4 42bpp, big-endian
	GBRP14LE,    ///< planar GBR 4:4:4 42bpp, little-endian
	YUVJ411P,    ///< planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples) full scale (JPEG), deprecated in favor of YUV411P and setting color_range

	BAYER_BGGR8,    ///< bayer, BGBG..(odd line), GRGR..(even line), 8-bit samples
	BAYER_RGGB8,    ///< bayer, RGRG..(odd line), GBGB..(even line), 8-bit samples
	BAYER_GBRG8,    ///< bayer, GBGB..(odd line), RGRG..(even line), 8-bit samples
	BAYER_GRBG8,    ///< bayer, GRGR..(odd line), BGBG..(even line), 8-bit samples
	BAYER_BGGR16LE, ///< bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, little-endian
	BAYER_BGGR16BE, ///< bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, big-endian
	BAYER_RGGB16LE, ///< bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, little-endian
	BAYER_RGGB16BE, ///< bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, big-endian
	BAYER_GBRG16LE, ///< bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, little-endian
	BAYER_GBRG16BE, ///< bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, big-endian
	BAYER_GRBG16LE, ///< bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, little-endian
	BAYER_GRBG16BE, ///< bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, big-endian

	XVMC,///< XVideo Motion Acceleration via common packet passing

	YUV440P10LE, ///< planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
	YUV440P10BE, ///< planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
	YUV440P12LE, ///< planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
	YUV440P12BE, ///< planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
	AYUV64LE,    ///< packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
	AYUV64BE,    ///< packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), big-endian

	VIDEOTOOLBOX, ///< hardware decoding through Videotoolbox

	P010LE, ///< like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, little-endian
	P010BE, ///< like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, big-endian

	GBRAP12BE,  ///< planar GBR 4:4:4:4 48bpp, big-endian
	GBRAP12LE,  ///< planar GBR 4:4:4:4 48bpp, little-endian

	GBRAP10BE,  ///< planar GBR 4:4:4:4 40bpp, big-endian
	GBRAP10LE,  ///< planar GBR 4:4:4:4 40bpp, little-endian

	MEDIACODEC, ///< hardware decoding through MediaCodec

	GRAY12BE,   ///<        Y        , 12bpp, big-endian
	GRAY12LE,   ///<        Y        , 12bpp, little-endian
	GRAY10BE,   ///<        Y        , 10bpp, big-endian
	GRAY10LE,   ///<        Y        , 10bpp, little-endian

	P016LE, ///< like NV12, with 16bpp per component, little-endian
	P016BE, ///< like NV12, with 16bpp per component, big-endian

	/**
	 * Hardware surfaces for Direct3D11.
	 *
	 * This is preferred over the legacy D3D11VA_VLD. The new D3D11
	 * hwaccel API and filtering support D3D11 only.
	 *
	 * data[0] contains a ID3D11Texture2D pointer, and data[1] contains the
	 * texture array index of the frame as intptr_t if the ID3D11Texture2D is
	 * an array texture (or always 0 if it's a normal texture).
	 */
	D3D11,

	GRAY9BE,   ///<        Y        , 9bpp, big-endian
	GRAY9LE,   ///<        Y        , 9bpp, little-endian

	GBRPF32BE,  ///< IEEE-754 single precision planar GBR 4:4:4,     96bpp, big-endian
	GBRPF32LE,  ///< IEEE-754 single precision planar GBR 4:4:4,     96bpp, little-endian
	GBRAPF32BE, ///< IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, big-endian
	GBRAPF32LE, ///< IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, little-endian

	/**
	 * DRM-managed buffers exposed through PRIME buffer sharing.
	 *
	 * data[0] points to an AVDRMFrameDescriptor.
	 */
	DRM_PRIME,
	/**
	 * Hardware surfaces for OpenCL.
	 *
	 * data[i] contain 2D image objects (typed in C as cl_mem, used
	 * in OpenCL as image2d_t) for each plane of the surface.
	 */
	OPENCL,

	GRAY14BE,   ///<        Y        , 14bpp, big-endian
	GRAY14LE,   ///<        Y        , 14bpp, little-endian

	GRAYF32BE,  ///< IEEE-754 single precision Y, 32bpp, big-endian
	GRAYF32LE,  ///< IEEE-754 single precision Y, 32bpp, little-endian

	YUVA422P12BE, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, big-endian
	YUVA422P12LE, ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, little-endian
	YUVA444P12BE, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, big-endian
	YUVA444P12LE, ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, little-endian

	NV24,      ///< planar YUV 4:4:4, 24bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
	NV42,      ///< as above, but U and V bytes are swapped

	/**
	 * Vulkan hardware images.
	 *
	 * data[0] points to an AVVkFrame
	 */
	VULKAN,

	Y210BE,    ///< packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, big-endian
	Y210LE,    ///< packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, little-endian

	X2RGB10LE, ///< packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), little-endian, X=unused/undefined
	X2RGB10BE, ///< packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), big-endian, X=unused/undefined
	Not_Part_of_ABI, ///< number of pixel formats, DO NOT USE THIS if you want to link with shared libav* because the number of formats might differ between versions
}

when ODIN_ENDIAN == "little" {
	 RGB32   :: Pixel_Format.BGRA // Little Endian
	 RGB32_1 :: Pixel_Format.ABGR // Little Endian
	 BGR32   :: Pixel_Format.RGBA // Little Endian
	 BGR32_1 :: Pixel_Format.ARGB // Little Endian
	_0RGB32  :: Pixel_Format.BGR0 // Little Endian
	_0BGR32  :: Pixel_Format.RGB0 // Little Endian
} else {
	 RGB32   :: Pixel_Format.ARGBBE // Big Endian 
	 RGB32_1 :: Pixel_Format.RGBABE // Big Endian 
	 BGR32   :: Pixel_Format.ABGRBE // Big Endian 
	 BGR32_1 :: Pixel_Format.BGRABE // Big Endian 
	_0RGB32  :: Pixel_Format._0RGBBE // Big Endian 
	_0BGR32  :: Pixel_Format._0BGRBE // Big Endian 
}

when ODIN_ENDIAN == "little" {
	GRAY9        :: Pixel_Format.GRAY9LE
	GRAY10       :: Pixel_Format.GRAY10LE
	GRAY12       :: Pixel_Format.GRAY12LE
	GRAY14       :: Pixel_Format.GRAY14LE
	GRAY16       :: Pixel_Format.GRAY16LE
	YA16         :: Pixel_Format.YA16LE
	RGB48        :: Pixel_Format.RGB48LE
	RGB565       :: Pixel_Format.RGB565LE
	RGB555       :: Pixel_Format.RGB555LE
	RGB444       :: Pixel_Format.RGB444LE
	RGBA64       :: Pixel_Format.RGBA64LE
	BGR48        :: Pixel_Format.BGR48LE
	BGR565       :: Pixel_Format.BGR565LE
	BGR555       :: Pixel_Format.BGR555LE
	BGR444       :: Pixel_Format.BGR444LE
	BGRA64       :: Pixel_Format.BGRA64LE

	YUV420P9     :: Pixel_Format.YUV420P9LE
	YUV422P9     :: Pixel_Format.YUV422P9LE
	YUV444P9     :: Pixel_Format.YUV444P9LE
	YUV420P10    :: Pixel_Format.YUV420P10LE
	YUV422P10    :: Pixel_Format.YUV422P10LE
	YUV440P10    :: Pixel_Format.YUV440P10LE
	YUV444P10    :: Pixel_Format.YUV444P10LE
	YUV420P12    :: Pixel_Format.YUV420P12LE
	YUV422P12    :: Pixel_Format.YUV422P12LE
	YUV440P12    :: Pixel_Format.YUV440P12LE
	YUV444P12    :: Pixel_Format.YUV444P12LE
	YUV420P14    :: Pixel_Format.YUV420P14LE
	YUV422P14    :: Pixel_Format.YUV422P14LE
	YUV444P14    :: Pixel_Format.YUV444P14LE
	YUV420P16    :: Pixel_Format.YUV420P16LE
	YUV422P16    :: Pixel_Format.YUV422P16LE
	YUV444P16    :: Pixel_Format.YUV444P16LE

	GBRP9        :: Pixel_Format.GBRP9LE
	GBRP10       :: Pixel_Format.GBRP10LE
	GBRP12       :: Pixel_Format.GBRP12LE
	GBRP14       :: Pixel_Format.GBRP14LE
	GBRP16       :: Pixel_Format.GBRP16LE
	GBRAP10      :: Pixel_Format.GBRAP10LE
	GBRAP12      :: Pixel_Format.GBRAP12LE
	GBRAP16      :: Pixel_Format.GBRAP16LE
	
	BAYER_BGGR16 :: Pixel_Format.BAYER_BGGR16LE
	BAYER_RGGB16 :: Pixel_Format.BAYER_RGGB16LE
	BAYER_GBRG16 :: Pixel_Format.BAYER_GBRG16LE
	BAYER_GRBG16 :: Pixel_Format.BAYER_GRBG16LE
	
	GBRPF32      :: Pixel_Format.GBRPF32LE
	GBRAPF32     :: Pixel_Format.GBRAPF32LE
	GRAYF32      :: Pixel_Format.GRAYF32LE
	
	YUVA420P9    :: Pixel_Format.YUVA420P9LE
	YUVA422P9    :: Pixel_Format.YUVA422P9LE
	YUVA444P9    :: Pixel_Format.YUVA444P9LE
	YUVA420P10   :: Pixel_Format.YUVA420P10LE
	YUVA422P10   :: Pixel_Format.YUVA422P10LE
	YUVA444P10   :: Pixel_Format.YUVA444P10LE
	YUVA422P12   :: Pixel_Format.YUVA422P12LE
	YUVA444P12   :: Pixel_Format.YUVA444P12LE
	YUVA420P16   :: Pixel_Format.YUVA420P16LE
	YUVA422P16   :: Pixel_Format.YUVA422P16LE
	YUVA444P16   :: Pixel_Format.YUVA444P16LE
	
	XYZ12        :: Pixel_Format.XYZ12LE
	NV20         :: Pixel_Format.NV20LE
	AYUV64       :: Pixel_Format.AYUV64LE
	P010         :: Pixel_Format.P010LE
	P016         :: Pixel_Format.P016LE
	Y210         :: Pixel_Format.Y210LE
	X2RGB10      :: Pixel_Format.X2RGB10LE
} else {
	GRAY9        :: Pixel_Format.GRAY9BE
	GRAY10       :: Pixel_Format.GRAY10BE
	GRAY12       :: Pixel_Format.GRAY12BE
	GRAY14       :: Pixel_Format.GRAY14BE
	GRAY16       :: Pixel_Format.GRAY16BE
	YA16         :: Pixel_Format.YA16BE
	RGB48        :: Pixel_Format.RGB48BE
	RGB565       :: Pixel_Format.RGB565BE
	RGB555       :: Pixel_Format.RGB555BE
	RGB444       :: Pixel_Format.RGB444BE
	RGBA64       :: Pixel_Format.RGBA64BE
	BGR48        :: Pixel_Format.BGR48BE
	BGR565       :: Pixel_Format.BGR565BE
	BGR555       :: Pixel_Format.BGR555BE
	BGR444       :: Pixel_Format.BGR444BE
	BGRA64       :: Pixel_Format.BGRA64BE

	YUV420P9     :: Pixel_Format.YUV420P9BE
	YUV422P9     :: Pixel_Format.YUV422P9BE
	YUV444P9     :: Pixel_Format.YUV444P9BE
	YUV420P10    :: Pixel_Format.YUV420P10BE
	YUV422P10    :: Pixel_Format.YUV422P10BE
	YUV440P10    :: Pixel_Format.YUV440P10BE
	YUV444P10    :: Pixel_Format.YUV444P10BE
	YUV420P12    :: Pixel_Format.YUV420P12BE
	YUV422P12    :: Pixel_Format.YUV422P12BE
	YUV440P12    :: Pixel_Format.YUV440P12BE
	YUV444P12    :: Pixel_Format.YUV444P12BE
	YUV420P14    :: Pixel_Format.YUV420P14BE
	YUV422P14    :: Pixel_Format.YUV422P14BE
	YUV444P14    :: Pixel_Format.YUV444P14BE
	YUV420P16    :: Pixel_Format.YUV420P16BE
	YUV422P16    :: Pixel_Format.YUV422P16BE
	YUV444P16    :: Pixel_Format.YUV444P16BE

	GBRP9        :: Pixel_Format.GBRP9BE
	GBRP10       :: Pixel_Format.GBRP10BE
	GBRP12       :: Pixel_Format.GBRP12BE
	GBRP14       :: Pixel_Format.GBRP14BE
	GBRP16       :: Pixel_Format.GBRP16BE
	GBRAP10      :: Pixel_Format.GBRAP10BE
	GBRAP12      :: Pixel_Format.GBRAP12BE
	GBRAP16      :: Pixel_Format.GBRAP16BE
	
	BAYER_BGGR16 :: Pixel_Format.BAYER_BGGR16BE
	BAYER_RGGB16 :: Pixel_Format.BAYER_RGGB16BE
	BAYER_GBRG16 :: Pixel_Format.BAYER_GBRG16BE
	BAYER_GRBG16 :: Pixel_Format.BAYER_GRBG16BE
	
	GBRPF32      :: Pixel_Format.GBRPF32BE
	GBRAPF32     :: Pixel_Format.GBRAPF32BE
	GRAYF32      :: Pixel_Format.GRAYF32BE
	
	YUVA420P9    :: Pixel_Format.YUVA420P9BE
	YUVA422P9    :: Pixel_Format.YUVA422P9BE
	YUVA444P9    :: Pixel_Format.YUVA444P9BE
	YUVA420P10   :: Pixel_Format.YUVA420P10BE
	YUVA422P10   :: Pixel_Format.YUVA422P10BE
	YUVA444P10   :: Pixel_Format.YUVA444P10BE
	YUVA422P12   :: Pixel_Format.YUVA422P12BE
	YUVA444P12   :: Pixel_Format.YUVA444P12BE
	YUVA420P16   :: Pixel_Format.YUVA420P16BE
	YUVA422P16   :: Pixel_Format.YUVA422P16BE
	YUVA444P16   :: Pixel_Format.YUVA444P16BE
	
	XYZ12        :: Pixel_Format.XYZ12BE
	NV20         :: Pixel_Format.NV20BE
	AYUV64       :: Pixel_Format.AYUV64BE
	P010         :: Pixel_Format.P010BE
	P016         :: Pixel_Format.P016BE
	Y210         :: Pixel_Format.Y210BE
	X2RGB10      :: Pixel_Format.X2RGB10BE
}

/**
  * Chromaticity coordinates of the source primaries.
  * These values match the ones defined by ISO/IEC 23001-8_2013 § 7.1.
  */
Color_Primaries :: enum c.int {
	RESERVED0          = 0,
	BT709              = 1,  ///< also ITU-R BT1361 / IEC 61966-2-4 / SMPTE RP177 Annex B
	UNSPECIFIED        = 2,
	RESERVED           = 3,
	BT470M             = 4,  ///< also FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
	BT470BG            = 5,  ///< also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM
	SMPTE170M          = 6,  ///< also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
	SMPTE240M          = 7,  ///< functionally identical to above
	FILM               = 8,  ///< colour filters using Illuminant C
	BT2020             = 9,  ///< ITU-R BT2020
	SMPTE428           = 10, ///< SMPTE ST 428-1 (CIE 1931 XYZ)
	SMPTEST428_1       = SMPTE428,
	SMPTE431           = 11, ///< SMPTE ST 431-2 (2011) / DCI P3
	SMPTE432           = 12, ///< SMPTE ST 432-1 (2010) / P3 D65 / Display P3
	EBU3213            = 22, ///< EBU Tech. 3213-E / JEDEC P22 phosphors
	JEDEC_P22          = EBU3213,
	Not_Part_of_ABI,         ///< Not part of ABI
}

/**
 * Color Transfer Characteristic.
 * These values match the ones defined by ISO/IEC 23001-8_2013 § 7.2.
 */
Color_Transfer_Characteristic :: enum c.int {
	RESERVED0          = 0,
	BT709              = 1,  ///< also ITU-R BT1361
	UNSPECIFIED        = 2,
	RESERVED           = 3,
	GAMMA22            = 4,  ///< also ITU-R BT470M / ITU-R BT1700 625 PAL & SECAM
	GAMMA28            = 5,  ///< also ITU-R BT470BG
	SMPTE170M          = 6,  ///< also ITU-R BT601-6 525 or 625 / ITU-R BT1358 525 or 625 / ITU-R BT1700 NTSC
	SMPTE240M          = 7,
	LINEAR             = 8,  ///< "Linear transfer characteristics"
	LOG                = 9,  ///< "Logarithmic transfer characteristic (100:1 range)"
	LOG_SQRT           = 10, ///< "Logarithmic transfer characteristic (100 * Sqrt(10) : 1 range)"
	IEC61966_2_4       = 11, ///< IEC 61966-2-4
	BT1361_ECG         = 12, ///< ITU-R BT1361 Extended Colour Gamut
	IEC61966_2_1       = 13, ///< IEC 61966-2-1 (sRGB or sYCC)
	BT2020_10          = 14, ///< ITU-R BT2020 for 10-bit system
	BT2020_12          = 15, ///< ITU-R BT2020 for 12-bit system
	SMPTE2084          = 16, ///< SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems
	SMPTEST2084        = SMPTE2084,
	SMPTE428           = 17, ///< SMPTE ST 428-1
	SMPTEST428_1       = SMPTE428,
	ARIB_STD_B67       = 18, ///< ARIB STD-B67, known as "Hybrid log-gamma"
	Not_Part_of_ABI,         ///< Not part of ABI
}

/**
 * YUV colorspace type.
 * These values match the ones defined by ISO/IEC 23001-8_2013 § 7.3.
 */
Color_Space :: enum c.int {
	RGB                = 0,  ///< order of coefficients is actually GBR, also IEC 61966-2-1 (sRGB)
	BT709              = 1,  ///< also ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / SMPTE RP177 Annex B
	UNSPECIFIED        = 2,
	RESERVED           = 3,
	FCC                = 4,  ///< FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
	BT470BG            = 5,  ///< also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM / IEC 61966-2-4 xvYCC601
	SMPTE170M          = 6,  ///< also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
	SMPTE240M          = 7,  ///< functionally identical to above
	YCGCO              = 8,  ///< Used by Dirac / VC-2 and H.264 FRext, see ITU-T SG16
	YCOCG              = YCGCO,
	BT2020_NCL         = 9,  ///< ITU-R BT2020 non-constant luminance system
	BT2020_CL          = 10, ///< ITU-R BT2020 constant luminance system
	SMPTE2085          = 11, ///< SMPTE 2085, Y'D'zD'x
	CHROMA_DERIVED_NCL = 12, ///< Chromaticity-derived non-constant luminance system
	CHROMA_DERIVED_CL  = 13, ///< Chromaticity-derived constant luminance system
	ICTCP              = 14, ///< ITU-R BT.2100-0, ICtCp
	Not_Part_of_ABI,         ///< Not part of ABI
}

/**
 * Visual content value range.
 *
 * These values are based on definitions that can be found in multiple
 * specifications, such as ITU-T BT.709 (3.4 - Quantization of RGB, luminance
 * and colour-difference signals), ITU-T BT.2020 (Table 5 - Digital
 * Representation) as well as ITU-T BT.2100 (Table 9 - Digital 10- and 12-bit
 * integer representation). At the time of writing, the BT.2100 one is
 * recommended, as it also defines the full range representation.
 *
 * Common definitions:
 *   - For RGB and luminance planes such as Y in YCbCr and I in ICtCp,
 *     'E' is the original value in range of 0.0 to 1.0.
 *   - For chrominance planes such as Cb,Cr and Ct,Cp, 'E' is the original
 *     value in range of -0.5 to 0.5.
 *   - 'n' is the output bit depth.
 *   - For additional definitions such as rounding and clipping to valid n
 *     bit unsigned integer range, please refer to BT.2100 (Table 9).
 */
Color_Range :: enum c.int {
	Unspecified        = 0,

	/**
	 * Narrow or limited range content.
	 *
	 * - For luminance planes:
	 *
	 *       (219 * E + 16) * 2^(n-8)
	 *
	 *   F.ex. the range of 16-235 for 8 bits
	 *
	 * - For chrominance planes:
	 *
	 *       (224 * E + 128) * 2^(n-8)
	 *
	 *   F.ex. the range of 16-240 for 8 bits
	 */
	MPEG               = 1,

	/**
	 * Full range content.
	 *
	 * - For RGB and luminance planes:
	 *
	 *       (2^n - 1) * E
	 *
	 *   F.ex. the range of 0-255 for 8 bits
	 *
	 * - For chrominance planes:
	 *
	 *       (2^n - 1) * E + 2^(n - 1)
	 *
	 *   F.ex. the range of 1-255 for 8 bits
	 */
	JPEG               = 2,
	Not_Part_of_ABI,               ///< Not part of ABI
}

/**
 * Location of chroma samples.
 *
 * Illustration showing the location of the first (top left) chroma sample of the
 * image, the left shows only luma, the right
 * shows the location of the chroma sample, the 2 could be imagined to overlay
 * each other but are drawn separately due to limitations of ASCII
 *
 *                1st 2nd       1st 2nd horizontal luma sample positions
 *                 v   v         v   v
 *                 ______        ______
 *1st luma line > |X   X ...    |3 4 X ...     X are luma samples,
 *                |             |1 2           1-6 are possible chroma positions
 *2nd luma line > |X   X ...    |5 6 X ...     0 is undefined/unknown position
 */
Chroma_Location :: enum c.int {
	Unspecified   = 0,
	Left          = 1, ///< MPEG-2/4 4:2:0, H.264 default for 4:2:0
	Center        = 2, ///< MPEG-1 4:2:0, JPEG 4:2:0, H.263 4:2:0
	Top_Left      = 3, ///< ITU-R 601, SMPTE 274M 296M S314M(DV 4:1:1), mpeg2 4:2:2
	Top           = 4,
	Bottom_Left   = 5,
	Bottom        = 6,
	Not_Part_of_ABI,   ///< Not part of ABI
}