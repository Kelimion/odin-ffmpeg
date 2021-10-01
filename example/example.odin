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

import "ffmpeg:types"

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

print_tags :: proc(codec_tags: ^[^]types.Codec_Tag) {
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

print_codec :: proc(codec: ^types.Codec) {
	using fmt
	using codec

	printf("[%v] %v\n", name, long_name)
	printf("\tType:            %v\n", type)
	if capabilities != {} {
		printf("\tCapabilities:    ")
		print_codec_caps(capabilities)		
	}

	if max_lowres != 0 {
		printf("\tMax Low Res:     %v\n", max_lowres)	
	}

	if supported_framerates != nil {
		printf("\tFramerates:      ")
		fr  := supported_framerates[:]
		for idx := 0; fr[idx] != {0, 0}; idx += 1 {
			if idx > 0 {
				printf(", ")
			}
			printf("%3.3f fps", f64(fr[idx].numerator) / f64(fr[idx].denominator))
		}
		println()
	}

	if pixel_formats != nil {
		printf("\tPixel Formats:   ")
		pf  := pixel_formats[:]
		for idx := 0; pf[idx] != .NONE; idx += 1 {
			if idx > 0 {
				printf(", ")
			}
			printf("%v", pf[idx])
		}
		println()
	}

	if supported_samplerates != nil {
		printf("\tSample Rates:    ")
		ssr  := supported_samplerates[:]
		for idx := 0; ssr[idx] != 0; idx += 1 {
			if idx > 0 {
				printf(", ")
			}
			printf("%v", ssr[idx])
		}
		println()
	}

	if sample_formats != nil {
		printf("\tSample Formats:  ")
		sf  := sample_formats[:]
		for idx := 0; sf[idx] != .NONE; idx += 1 {
			if idx > 0 {
				printf(", ")
			}
			printf("%v", sf[idx])
		}
		println()
	}

	if channel_layouts != nil {
		printf("\tChannel Layouts: ")
		cl  := channel_layouts[:]
		for idx := 0; cl[idx] != {}; idx += 1 {
			if idx > 0 {
				printf(", ")
			}
			print_channel_layout(cl[idx])
		}
		println()
	}

	if priv_class != nil {
		printf("\tPriv Class:      %v (avutil v%v)\n", priv_class.class_name, version_to_string(priv_class.av_util_verion))
	}

	if profiles != nil {
		printf("\tProfiles:        ")
		p  := profiles[:]
		for idx := 0; p[idx].name != nil; idx += 1 {
			if idx > 0 {
				printf(", ")
			}
			printf("%v", p[idx].name)
		}
		println()
	}

	// profiles:              [^]Profile,              // Array of recognized profiles,         or NULL if unknown.        Terminated by .Profile_Unknown

	if wrapper_name != nil {
		printf("\tWrapper name:    %v\n", wrapper_name)
	}
}

codec_id_to_string :: proc(id: types.Codec_ID) -> (codec_id: string) {
	using fmt
	using avcodec

	codec_id = tprintf("%v", id)
	if strings.contains(codec_id, "BAD ENUM") {
		return tprintf("< 0x%08x >", i32(id))
	} else if codec_id == "NONE" {
		return "None"
	}
	return
}

print_codecs_for_id :: proc(id: types.Codec_ID, type := types.Get_Codecs_Type.Both) {
	using fmt
	using avcodec
	using types

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

print_channel_layout :: proc(channels: types.Channel_Layout) {
	using fmt
	using types

	first := true
	printf("[")
	for i in Channel {
		if i in channels {
			if !first {
				printf(", ")
			}
			printf("%v", i)
			first = false
		}
	}
	printf("]")
}

print_codec_caps :: proc(flags: types.Codec_Capabilities) {
	using fmt
	using types

	first := true
	for i in Codec_Capability {
		if i in flags {
			if !first {
				printf(", ")
			}
			printf("%v", i)
			first = false
		}
	}
	println()
}

print_format_flags :: proc(flags: types.Format_Flags) {
	using fmt
	using types

	first := true
	for i in Format_Flag {
		if i in flags {
			if !first {
				printf(", ")
			}
			printf("%v", i)
			first = false
		}
	}
	println()
}

show_codecs_alt :: proc() {
	using avcodec
	using types

	for id in Codec_ID {
		if id == .NONE { continue }

		codec := &Codec{}
		iter := rawptr(nil)

		for iter = nil; codec != nil; codec = next_codec_for_id(id, &iter, .Both) {
			if codec.name != "" {
				print_codec(codec)
				fmt.println()
			}
		}
	}
}

show_codecs :: proc() {
	using fmt
	using types

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
		printf("\t\tLong name:      %v\n", long_name)
		printf("\t\tMime type:      %v\n", mime_type)
		printf("\t\tExtensions:     %v\n", extensions)
		printf("\t\tAudio codec:    %v\n", codec_id_to_string(audio_codec))
		printf("\t\tVideo codec:    %v\n", codec_id_to_string(video_codec))
		printf("\t\tSubtitle codec: %v\n", codec_id_to_string(subtitle_codec))
		printf("\t\tFlags:          ")
		print_format_flags(flags)

		if codec_tags != nil {
			print_tags(codec_tags)
		}
		if priv_class != nil {
			printf("\t\tPriv_class:     %v (avutil v%v)\n", priv_class.class_name, version_to_string(priv_class.av_util_verion))
		}
	}
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
		printf("\t\tLong name:      %v\n", long_name)
		printf("\t\tMime type:      %v\n", mime_type)
		printf("\t\tExtensions:     %v\n", extensions)
		if codec_tags != nil {
			print_tags(codec_tags)
		}
		printf("\t\tFlags:          ")
		print_format_flags(flags)

		if priv_class != nil {
			printf("\t\tPriv_class:     %v (avutil v%v)\n", priv_class.class_name, version_to_string(priv_class.av_util_verion))
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
		/*
			Just the EXE name. Show usage.
		*/
		args = []string{""}
	} else {
		args = args[1:]	
	}

	command := strings.to_lower(args[0], context.temp_allocator)
	switch command {
	case "-codecs":
		if len(args) > 1 && args[1] == "alt" {
			show_codecs_alt()
		} else {
			show_codecs()
		}
	case "-muxers":   enumerate_muxers()
	case "-demuxers": enumerate_demuxers()
	case "-h":        fallthrough
	case:
		do_default()
		print_usage()
		show_codecs_alt()
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