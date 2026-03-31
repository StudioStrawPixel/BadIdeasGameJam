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
@onready var boxes: Node2D = $Boxes
@onready var yucky: CollisionShape2D = $icky/yucky

var triggered := false
var waterfall_clean := false
var farquidhelp_done := false
var farquidpass_done := false

func _ready() -> void:
	player.can_play_footsteps = true
	if player and camera_limits:
		player.set_camera_limits(camera_limits)
	player.gun_unlocked = true
	fade_layer.color_rect.color.a = 1.0
	fade_layer.fade(0.0, 1.5)
	if is_instance_valid(farquid_audio) and farquid_audio.stream:
		farquid_audio.play()
	if boxes and boxes.has_signal("flower_changed"):
		boxes.connect("flower_changed", Callable(self, "_on_flower_changed"))
	await play_player_dialogue("enterfarquid")

func set_waterfall_clean(value: bool) -> void:
	waterfall_clean = value
	if not value:
		return
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

	if is_instance_valid(yucky):
		yucky.queue_free()  

	await play_player_dialogue("farquidhelp")
	farquidhelp_done = true

	var stream_audio = AudioStreamPlayer2D.new()
	stream_audio.stream = load("res://assets/sounds/stream.mp3")
	stream_audio.volume_db = -20
	stream_audio.max_distance = 10000
	add_child(stream_audio)
	stream_audio.play()

	await _check_clearfarquid()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player and not triggered:
		triggered = true
		await play_player_dialogue("waterfall")

func _on_shallnotpass_body_entered(body: Node2D) -> void:
	if body != player or waterfall_clean:
		return
	await play_player_dialogue("nopass")

func _on_flower_changed(new_count: int) -> void:
	await _check_clearfarquid()

func _check_clearfarquid():
	if farquidpass_done or not farquidhelp_done or boxes.flower_count != 11:
		return
	farquidpass_done = true
	await play_player_dialogue("farquidpass")

func play_player_dialogue(timeline_name: String):
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
