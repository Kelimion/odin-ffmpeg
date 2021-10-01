/*
	Example for the Odin FFmpeg bindings.

	Examples are in the [Public Domain](https://unlicense.org/).

	Contributions:
		2021-09-28 - Jeroen van Rijn - Initial work.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_example

VERSION :: "0.0.1"
GIT_HASH_BYTES := #load_or("../.git/refs/heads/master", []u8{'u', 'n', 'k', 'n', 'o', 'w', 'n'})
GIT_HASH       := string(GIT_HASH_BYTES)[:7]

import "ffmpeg:avcodec"
import "ffmpeg:avdevice"
import "ffmpeg:avfilter"
import "ffmpeg:avformat"
import "ffmpeg:avutil"
import "ffmpeg:swresample"
import "ffmpeg:swscale"

import "core:c"
import "core:fmt"
import "core:mem"
import "core:strings"
import "core:os"

print_versions_and_config :: proc() {
	using fmt

	printf("odin-ffmpeg v%v-%v\n", VERSION, GIT_HASH)
	printf("\tbuilt with Odin %v\n", ODIN_VERSION)
	printf("\tconfiguration: %v\n", avcodec.configuration())

	printf("\tlibavutil      %v.%v.%v\n", avutil.    version_semantic())
	printf("\tlibavcodec     %v.%v.%v\n", avcodec.   version_semantic())
	printf("\tlibavformat    %v.%v.%v\n", avformat.  version_semantic())
	printf("\tlibavdevice    %v.%v.%v\n", avdevice.  version_semantic())
	printf("\tlibavfilter    %v.%v.%v\n", avfilter.  version_semantic())
	printf("\tlibswscale     %v.%v.%v\n", swscale.   version_semantic())
	printf("\tlibswresample  %v.%v.%v\n", swresample.version_semantic())

	printf("\tffmpeg version: %v\n", avutil.version_info())
	printf("\tffmpeg license: %v\n", avcodec.license())
}

version_to_string :: proc(version: c.int) -> (version_string: string) {
	return fmt.tprintf("%v.%v.%v", version >> 16, (version >> 8) & 255, version & 255)
}

print_codec :: proc(codec: ^avcodec.Codec) {
	using fmt
	using codec

	printf("[%v] %v\n", name, long_name)
	printf("\tType:          %v\n", type)
	printf("\tCapabilities:  %v\n", capabilities)
	printf("\tMax Low Res:   %v\n", max_lowres)
	printf("\tFramerates:    [")
	if supported_framerates == nil {
		printf("any")
	} else {
		fr  := supported_framerates[:]
		for idx := 0; fr[idx] != {0, 0}; idx += 1 {
			if idx > 0 {
				printf(", ")
			}
			printf("%v", fr[idx])
		}
	}
	printf("]\n")

	if pixel_formats != nil {
		printf("\tPixel Formats: [")
		pf  := pixel_formats[:]
		for idx := 0; pf[idx] != .NONE; idx += 1 {
			if idx > 0 {
				printf(", ")
			}
			printf("%v", pf[idx])
		}
	}
	printf("]\n")

	// supported_samplerates: [^]c.int,                // Array of supported audio samplerates, or NULL if unknown.       Terminated by 0
	// sample_formats:        [^]avutil.Sample_Format, // Array of supported sample formats,    or NULL if unknown.       Terminated by -1
	// channel_layouts:       [^]c.uint64_t,           // Array of supported channel layouts,   or NULL if unknown.       Terminated by 0
	// priv_class:            avutil.Class,
	// profiles:              [^]Profile,              // Array of recognized profiles,         or NULL if unknown.        Terminated by .Profile_Unknown
	if wrapper_name != nil {
		printf("\twrapper name: %v\n", wrapper_name)	
	}
}

print_codecs_for_id :: proc(id: avcodec.Codec_ID, type := avcodec.Get_Codecs_Type.Both) {
	using fmt
	using avcodec

	iter: rawptr
	codec := &Codec{}
	printf(" (%s: ", "encoders" if type == .Encoder else "decoders")

	for iter = nil; codec != nil; codec = next_codec_for_id(id, &iter, type) {
		if codec.name != "" {
			printf("%s ", codec.name)	
		}
	}
	printf(")")
}

show_codecs :: proc() {
	using fmt

	println("Codecs:\n" + 
		   " D..... = Decoding supported\n" +
		   " .E.... = Encoding supported\n" +
		   " ..V... = Video codec\n" +
		   " ..A... = Audio codec\n" +
		   " ..S... = Subtitle codec\n" +
		   " ...I.. = Intra frame-only codec\n" +
		   " ....L. = Lossy compression\n" +
		   " .....S = Lossless compression\n" +
		   " -------\n")

	descriptors, err := avcodec.get_codec_descriptors()
	defer delete(descriptors)

	if err != .None {
		println("avcodec.get_codec_descriptors returned %v\n", err)
		return
	}

	i := 0
	for d in descriptors {
		using avcodec

		i += 1
		name := string(d.name)
		if strings.contains(name, "_deprecated") {
			continue
		}

		printf(" ")
		printf(find_decoder(d.id) != nil ? "D" : ".")
		printf(find_encoder(d.id) != nil ? "E" : ".")

		printf("%c", avutil.get_media_type_rune(d.type))
		printf(.Intra_Only in d.props ? "I" : ".")
		printf(.Lossy      in d.props ? "L" : ".")
		printf(.Lossless   in d.props ? "S" : ".")

		long_name := string(d.long_name)
		printf(" %-20s %s", name, long_name)

		/*
			Print decoders/encoders when there's more than one or their names are different from codec name.
		*/
		iter: rawptr
		codec := &Codec{}

		for iter = nil; codec != nil; codec = next_codec_for_id(d.id, &iter, .Decoder) {
			if codec.name != d.name && codec.name != "" {
				print_codecs_for_id(d.id, .Decoder)
				break
			}
		}

		codec = &Codec{}
		for iter = nil; codec != nil; codec = next_codec_for_id(d.id, &iter, .Encoder) {
			if codec.name != d.name && codec.name != "" {
				print_codecs_for_id(d.id, .Encoder)
				break
			}
		}
		println()
	}

	printf("\n%v codecs found.\n", i)
}

enumerate_muxers :: proc() {
	using fmt

	println("\nAvailable muxers:")
	handle := rawptr(nil)

	for {
		muxer := avformat.muxer_iterate(&handle)
		if muxer == nil do break
		using muxer

		printf("\t%v:\n", name)
		printf("\t\tlong name:      %v\n", long_name)
		printf("\t\tmime type:      %v\n", mime_type)
		printf("\t\textensions:     %v\n", extensions)
		printf("\t\taudio codec:    %v\n", audio_codec)
		printf("\t\tvideo codec:    %v\n", video_codec)
		printf("\t\tsubtitle codec: %v\n", subtitle_codec)
		printf("\t\tflags:          %v\n", flags)
		if codec_tags != nil {
			print_tags(codec_tags)
		}
		if priv_class != nil {
			printf("\t\tpriv_class:     %v (avutil v%v)\n", priv_class.class_name, version_to_string(priv_class.av_util_verion))
		}
	}
}

print_tags :: proc(codec_tags: ^[^]avcodec.Codec_Tag) {
	assert(codec_tags != nil)
	using fmt

	printf("\t\tcodec tags:     ")
	tags := codec_tags[:]
	idx := 0
	for {
		tag := tags[idx]
		if int(tag.id) == 0{
			break
		}
		if idx > 0 {
			printf(", ")
		}
		printf("%v", avcodec.codec_tag_to_string(tag))
		idx += 1
		if idx == 6 {
			printf("... more")
			break
		}
	}
	println()
}

enumerate_demuxers :: proc() {
	using fmt

	println("\nAvailable demuxers:")
	handle := rawptr(nil)

	for {
		demuxer := avformat.demuxer_iterate(&handle)
		if demuxer == nil do break
		using demuxer

		printf("\t%v:\n", name)
		printf("\t\tlong name:      %v\n", long_name)
		printf("\t\tmime type:      %v\n", mime_type)
		printf("\t\textensions:     %v\n", extensions)
		if codec_tags != nil {
			print_tags(codec_tags)
		}
		printf("\t\tflags:          %v\n", flags)
		if priv_class != nil {
			printf("\t\tpriv_class:     %v (avutil v%v)\n", priv_class.class_name, version_to_string(priv_class.av_util_verion))
		}
	}
}

do_default :: proc() {
	using fmt

	print_versions_and_config()
	println("\nSimple example program.")
	exe_name := strings.split(os.args[0], ".", context.temp_allocator)[0]
	printf("Usage:\n\t%v command [arguments]\n", exe_name)
	println()
}

print_usage :: proc() {
	using fmt

	println(`Commands:
	-codecs		Show a list of supported codecs.
	-muxers		Show a list of supported muxers.
	-demuxers	Show a list of supported demuxers.
`)
}

example :: proc() {
	args := os.args

	if len(args) == 1 {
		// Just the EXE name. Show usage.
		args = []string{""}
	} else {
		args = args[1:]	
	}

	command := strings.to_lower(args[0], context.temp_allocator)
	switch command {
	case "-codecs":   show_codecs()
	case "-muxers":   enumerate_muxers()
	case "-demuxers": enumerate_demuxers()
	case "-h":        fallthrough
	case:
		do_default()
		print_usage()
		enumerate_muxers()
	}
}

main :: proc() {
	using fmt
	track := mem.Tracking_Allocator{}
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)
	
	example()

	if len(track.allocation_map) > 0 {
		eprintf("Leaks:")
		for _, v in track.allocation_map {
			eprintf("\t%v\n\n", v)
		}
	}
	if len(track.bad_free_array) > 0 {
		eprintf("Bad Frees:")
		for v in track.bad_free_array {
			eprintf("\t%v\n\n", v)
		}
	}
}