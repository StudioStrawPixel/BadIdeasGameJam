extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fade_layer: CanvasLayer = $Fade
@onready var mamabubble: Marker2D = $raccoon/AnimatedSprite2D/mamabubble
@onready var bubble: Marker2D = $glorp/AnimatedSprite2D/bubble
@onready var camera_2d: Camera2D = $glorp/Camera2D
@onready var music_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var random: Marker2D = $random

var new_song := preload("res://assets/sounds/sillyserenade.mp3")

func _ready() -> void:
	camera_2d.make_current()
	camera_2d.limit_left = -2000
	camera_2d.limit_right = 9500
	camera_2d.limit_top = -1500
	camera_2d.limit_bottom = 500
	await fade_layer.fade(0.0, 1.5).finished
	music_player.play()
	await _play_cutscene()

func _play_cutscene() -> void:
	animation_player.play("start")
	await animation_player.animation_finished

	var layout1 = Dialogic.start("finale1")
	layout1.register_character(load("res://Dialogue/raccoonmama.dch"), mamabubble)
	layout1.register_character(load("res://Dialogue/glorb.dch"), bubble)
	await Dialogic.timeline_ended

	animation_player.play("mamaenter")
	await animation_player.animation_finished

	var layout2 = Dialogic.start("finale2")
	layout2.register_character(load("res://Dialogue/raccoon_mama.dch"), mamabubble)
	layout2.register_character(load("res://Dialogue/glorb.dch"), bubble)
	layout2.register_character(load("res://Dialogue/unknown.dch"), random)
	await Dialogic.timeline_ended

	animation_player.play("walk")
	await animation_player.animation_finished

	var layout3 = Dialogic.start("finale3")
	layout3.register_character(load("res://Dialogue/raccoon_mama.dch"), mamabubble)
	layout3.register_character(load("res://Dialogue/glorb.dch"), bubble)
	layout3.register_character(load("res://Dialogue/unknown.dch"), random)
	await Dialogic.timeline_ended

	music_player.stop()
	music_player.stream = new_song
	music_player.volume_db = -20
	music_player.play()

	animation_player.play("follow")
	await animation_player.animation_finished

	await fade_layer.fade(1.0, 1.5).finished
	get_tree().change_scene_to_file("res://goodbye.tscn")
