/*
	Odin bindings for FFmpeg's `avcodec` library.
	Bindings available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_avcodec

import "ffmpeg:avutil"
import "core:c"

/*
	Buffer padding in bytes for decoder to allow larger reads.
*/
INPUT_BUFFER_PADDING_SIZE :: 64

/*
	Minimum encoding buffer size.
*/
INPUT_BUFFER_MIN_SIZE :: 16384

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
	type:                  avutil.Media_Type,
	id:                    Codec_ID,
	capabilities:          Codec_Capabilities,
	max_lowres:            c.uint8_t,

	supported_framerates:  [^]avutil.Rational,      // Array of supported framerates,        or NULL if any framerate. Terminated by {0, 0}
	pixel_formats:         [^]avutil.Pixel_Format,  // Array of supported pixel formats,     or NULL if unknown.       Terminated by -1
	supported_samplerates: [^]c.int,                // Array of supported audio samplerates, or NULL if unknown.       Terminated by 0
	sample_formats:        [^]avutil.Sample_Format, // Array of supported sample formats,    or NULL if unknown.       Terminated by -1
	channel_layouts:       [^]Channel_Layout,       // Array of supported channel layouts,   or NULL if unknown.       Terminated by 0

	priv_class:            ^avutil.Class,
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
	av_class:         ^avutil.Class,
	log_level_offset: c.int,

	codec_type:       avutil.Media_Type,
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
	type:       avutil.Media_Type,

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