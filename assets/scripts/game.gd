extends Node2D

@onready var animation_player: AnimationPlayer = $Human/AnimationPlayer
@onready var player: Node = $Player
@onready var humanbubble: Marker2D = $Human/humanbubble
@onready var tutorial: Control = $"Tutorial Window"
@onready var fade_layer: CanvasLayer = $Fade
@onready var music_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var camera_limits: Node = $CameraLimits

func _ready() -> void:
	music_player.play()
	await fade_layer.fade(0.0, 1.5).finished
	if player and camera_limits:
		player.set_camera_limits(camera_limits)
	_start_game()

func _start_game():
	if not player:
		return
	player.start_dialogue()
	var bubble_node = player.get_node_or_null("bubble")
	if bubble_node:
		var layout1 = Dialogic.start("startgame")
		layout1.register_character(load("res://Dialogue/glorb.dch"), bubble_node)
	await Dialogic.timeline_ended
	animation_player.play("humanwalkout")
	await animation_player.animation_finished
	if bubble_node:
		var layout2 = Dialogic.start("startgame2")
		layout2.register_character(load("res://Dialogue/glorb.dch"), bubble_node)
	await Dialogic.timeline_ended
	player.start_dialogue()
	animation_player.play("glorphide")
	await animation_player.animation_finished
	if humanbubble:
		var layout3 = Dialogic.start("humanbox")
		layout3.register_character(load("res://Dialogue/human.dch"), humanbubble)
	await Dialogic.timeline_ended
	animation_player.play("humanend")
	await animation_player.animation_finished
	if bubble_node:
		var layout4 = Dialogic.start("humanendtimeline")
		layout4.register_character(load("res://Dialogue/glorb.dch"), bubble_node)
	await Dialogic.timeline_ended
	tutorial.show_tutorial("While you are on this strange planet use:\nWASD to move\nSpace to jump\nShift to Sprint\n*Press Space to continue")
	tutorial.tutorial_finished.connect(_on_tutorial_done)

func _on_tutorial_done():
	player.end_dialogue()
	player.set_process(true)
	player.set_physics_process(true)
