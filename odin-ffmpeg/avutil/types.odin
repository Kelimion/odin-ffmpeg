/*
	Odin bindings for FFmpeg's `avutil` library.
	Bindings available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_avutil

import "core:c"
import "core:runtime"

AV_Util_Error :: enum {

}

Error :: union {
	runtime.Allocator_Error,
	AV_Util_Error,
}

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