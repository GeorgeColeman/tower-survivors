class_name SoundEffectsPlayer
extends Node

@export var audio_stream_players: Array[AudioStreamPlayer]
@export var mob_killed_sfx: AudioStream

var _audio_player_dict = {}


func _ready():
	Audio.sfx_requested.connect(_on_sfx_requested)

	for audio_player in audio_stream_players:
		_audio_player_dict[audio_player] = true
		audio_player.finished.connect(func():
			_audio_player_dict[audio_player] = true)


func _on_sfx_requested(sfx: AudioStream):
	_play_sfx(sfx)


func _play_sfx(sfx: AudioStream):
	for player in _audio_player_dict.keys():
		if _audio_player_dict[player]:
			player.stream = sfx
			player.play()
			_audio_player_dict[player] = false
			break
