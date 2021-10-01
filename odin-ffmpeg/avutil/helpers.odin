/*
	Helper functions for the Odin `avutil` bindings.
	Bindings and helpers available under FFmpeg's license (GNU LGPL, v2.1+). See `LICENSE.md` in the package's top directory.

	Copyright (c) 2021 Jeroen van Rijn. All rights reserved.

	Libraries copyright their respective owner, available under their own licenses.
*/
package ffmpeg_avutil

import "ffmpeg:types"

version_semantic :: proc() -> (major, minor, micro: u32) {
	v := version()
	return v >> 16, (v >> 8) & 255, v & 255
}

is_input_device :: proc(category: types.Class_Category) -> bool {
	return category == .Device_Audio_Input || category == .Device_Video_Input || category == .Device_Input
}

is_output_device :: proc(category: types.Class_Category) -> bool {
	return category == .Device_Audio_Output || category == .Device_Video_Output || category == .Device_Output
}

get_media_type_rune :: proc(type: types.Media_Type) -> (type_string: rune) {
	#partial switch type {
	case .Video:      return 'V'
	case .Audio:      return 'A'
	case .Data:       return 'D'
	case .Subtitle:   return 'S'
	case .Attachment: return 'T'
	case:             return '?'
	}
}