# MusicManager.gd
extends Node

@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer

var current_track: AudioStream = null

func _ready():
	print("MusicManager is ready. Music player: ", music_player)

func play_music(stream: AudioStream):
	if current_track != stream:
		music_player.stream = stream
		music_player.play()
		current_track = stream

func stop_music():
	music_player.stop()
	current_track = null
