extends Node

signal sfx_requested(sfx: AudioStream)
signal sfx_toggled(is_on: bool)


func play_sfx(sfx: AudioStream):
	sfx_requested.emit(sfx)


func toggle_sfx(is_on: bool):
	sfx_toggled.emit(is_on)
	
