extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera_limits: Node2D = $CameraLimits
@onready var fade_layer: CanvasLayer = $Fade
@onready var bubble: Marker2D = $Player/bubble
@onready var farquidbubble: Marker2D = $farquidcharacter/farquidbubble
@onready var shallnotpass: Area2D = $shallnotpass
@onready var waterfall_sprite: Sprite2D = $Area2D/DirtyWaterfall
@onready var animated_sprite_2d: AnimatedSprite2D = $farquidcharacter/AnimatedSprite2D
@onready var farquid_audio: AudioStreamPlayer2D = $farquid
@onready var bridge: Sprite2D = $Bridge
@onready var waterpool: Sprite2D = $Waterpool

var triggered := false
var waterfall_clean := false

func _ready():
	player.can_play_footsteps = true
	if player and camera_limits:
		player.set_camera_limits(camera_limits)
	player.gun_unlocked = true
	fade_layer.color_rect.color.a = 1.0
	var tween = fade_layer.fade(0.0, 1.5)
	if is_instance_valid(farquid_audio) and farquid_audio.stream:
		farquid_audio.play()

func set_waterfall_clean(value: bool) -> void:
	waterfall_clean = value
	if value:
		if is_instance_valid(shallnotpass):
			shallnotpass.queue_free()
		if is_instance_valid(animated_sprite_2d):
			animated_sprite_2d.visible = true
		if is_instance_valid(waterfall_sprite):
			waterfall_sprite.z_index = -10
		if is_instance_valid(bridge):
			bridge.visible = true
		if is_instance_valid(waterpool):
			waterpool.visible = true
		await play_player_dialogue("farquidhelp")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player and not triggered:
		triggered = true
		await play_player_dialogue("waterfall")

func _on_shallnotpass_body_entered(body: Node2D) -> void:
	if body != player or waterfall_clean:
		return
	await play_player_dialogue("nopass")

func play_player_dialogue(timeline_name: String) -> void:
	var stored_velocity_y = player.velocity.y
	player.start_dialogue()
	player.animated_sprite.play("idle")
	var layout = Dialogic.start(timeline_name)
	add_child(layout)
	layout.register_character(load("res://Dialogue/farquid.dch"), farquidbubble)
	layout.register_character(load("res://Dialogue/unknown.dch"), farquidbubble)
	layout.register_character(load("res://Dialogue/glorb.dch"), bubble)
	await Dialogic.timeline_ended
	player.end_dialogue()
