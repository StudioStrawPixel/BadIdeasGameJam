extends Node2D

@onready var player: Node = $Player
@onready var bubble: Marker2D = $Player/bubble
@onready var monetbubble: Node = $Monkey/monetbubble2
@onready var monetcutscene: CollisionShape2D = $Monetcutscene/CollisionShape2D
@onready var monet: AnimatedSprite2D = $Monkey/Monet
@onready var smoke: GPUParticles2D = $Monkey/Smoke

var triggered := false

func _ready():
	$Fade.fade(0.0, 1.5)

func _on_monetcutscene_body_entered(body: Node2D) -> void:
	if body == player and not triggered:
		triggered = true
		monetcutscene.disabled = true
		start_monet_dialogue()

func start_monet_dialogue() -> void:
	var stored_velocity_y = player.velocity.y
	player.start_dialogue()
	player.animated_sprite.play("idle")
	var layout = Dialogic.start("meetmonet")
	add_child(layout)
	layout.register_character(load("res://Dialogue/monet.dch"), monetbubble)
	layout.register_character(load("res://Dialogue/glorb.dch"), bubble)
	await Dialogic.timeline_ended
	player.end_dialogue()
	player.velocity.y = stored_velocity_y
	player.gun_unlocked = true
	$Monetcutscene.queue_free()
	await wait_for_monetnobox_and_smoke()
	await get_tree().create_timer(0.5).timeout
	player.start_dialogue()
	Dialogic.start("monetflower")
	await Dialogic.timeline_ended
	player.end_dialogue()

func wait_for_monetnobox_and_smoke() -> void:
	while monet.animation != "monetnobox" or (smoke and smoke.emitting):
		await get_tree().process_frame
