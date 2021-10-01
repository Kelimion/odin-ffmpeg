/*
	Helper functions for the Odin `avcodec` bindings.
	Bindings and helpers available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_avcodec

import "ffmpeg:avutil"
import "core:c"
import "core:slice"

Error :: avutil.Error

version_semantic :: proc() -> (major, minor, micro: u32) {
	v := version()
	return v >> 16, (v >> 8) & 255, v & 255
}

Get_Codecs_Type :: enum c.int {
	Decoder = 0,
	Encoder = 1,
	Both    = 2,
}

is_codec_type :: proc(codec: ^Codec, type: Get_Codecs_Type) -> (check: b32) {
	switch type {
	case .Decoder: return is_decoder(codec) > 0
	case .Encoder: return is_encoder(codec) > 0
	case .Both:    return true
	}
	unreachable()
}

next_codec_for_id :: proc(id: Codec_ID, iter: ^rawptr, type := Get_Codecs_Type.Both) -> (codec: ^Codec) {
	for codec = iterate(iter); codec != nil; codec = iterate(iter) {
		if codec.id == id && is_codec_type(codec, type) {
			return
		}
	}
	return nil
}

compare_codec_descriptors :: proc(a, b: ^Codec_Descriptor) -> (ordering: slice.Ordering) {
	assert(a != nil && b != nil)

	// Sort based on codec type first
	if a.type != b.type {
		return slice.cmp(a.type, b.type)
	}

	// Sort on codec name.
	// TODO(Jeroen): Replace with string compare that doesn't do a strlen on the cstring.
	return slice.cmp(a.name, b.name)
}

get_codec_descriptors :: proc(sorted := true, allocator := context.allocator) -> (codecs: []^Codec_Descriptor, err: Error) {
	number_of_codecs := 0
	descriptor: ^Codec_Descriptor = nil

	// Iterate over codecs to get the number to allocate.
	for {
		descriptor = descriptor_next(descriptor)
		if descriptor == nil {
			break
		}
		number_of_codecs += 1
	}

	codecs, err = make([]^Codec_Descriptor, number_of_codecs)
	if err != .None {
		return
	}

	// Iterate again and store in slice
	descriptor = nil
	for i := 0; i < number_of_codecs; i += 1 {
		descriptor = descriptor_next(descriptor)
		codecs[i]  = descriptor
	}

	// Sort codecs
	if sorted {
		slice.sort_by_cmp(codecs, compare_codec_descriptors)
	}

	return
}