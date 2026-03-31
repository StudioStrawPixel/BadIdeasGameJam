extends Node2D

@onready var bird: CharacterBody2D = $bird
@onready var bird_animation: AnimationPlayer = $bird/AnimationPlayer
@onready var player: CharacterBody2D = $Player
@onready var bubble: Marker2D = $Player/bubble
@onready var birdbubble: Marker2D = $bird/birdbubble
@onready var birdbubble_2: Marker2D = $bird/birdbubble2
@onready var fade_layer: CanvasLayer = $Fade
@onready var music_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var camera_limits: Node2D = $CameraLimits
@onready var boxes: Node = $Boxes

func _ready() -> void:
	player.start_dialogue()
	music_player.play()
	await fade_layer.fade(0.0, 1.5).finished
	if player and camera_limits:
		player.set_camera_limits(camera_limits)
	player.can_play_footsteps = true
	player.gun_unlocked = true
	await _start_game()

func _start_game() -> void:
	player.set_process(false)
	player.set_physics_process(false)
	if "state" in player:
		player.state = "IDLE"

	bird_animation.play("bird_fly_in")
	await bird_animation.animation_finished

	player.start_dialogue()
	if birdbubble:
		var layout = Dialogic.start("birdbox")
		layout.register_character(load("res://Dialogue/bird1.dch"), birdbubble)
		layout.register_character(load("res://Dialogue/glorb.dch"), bubble)
	await Dialogic.timeline_ended

	player.end_dialogue()

	bird_animation.play("bird_fly_out2")
	await bird_animation.animation_finished

	player.set_process(true)
	player.set_physics_process(true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != player:
		return
	player.start_dialogue()
	var layout
	if boxes.flower_count >= 20:
		layout = Dialogic.start("birdsound")
		layout.register_character(load("res://Dialogue/bird1.dch"), birdbubble_2)
		layout.register_character(load("res://Dialogue/glorb.dch"), bubble)
		await Dialogic.timeline_ended
		player.end_dialogue()
	else:
		layout = Dialogic.start("notenough")
		layout.register_character(load("res://Dialogue/bird1.dch"), birdbubble_2)
		layout.register_character(load("res://Dialogue/glorb.dch"), bubble)
		await Dialogic.timeline_ended
		player.end_dialogue()
