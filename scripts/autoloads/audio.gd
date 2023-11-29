extends Node

signal sfx_requested(sfx: AudioStream)


func play_sfx(sfx: AudioStream):
	sfx_requested.emit(sfx)
