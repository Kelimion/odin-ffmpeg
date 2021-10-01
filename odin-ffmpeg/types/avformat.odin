/*
	Odin bindings for FFmpeg.
	Bindings available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_types

import "core:c"

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
