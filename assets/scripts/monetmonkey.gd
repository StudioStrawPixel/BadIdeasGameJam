extends Area2D

@onready var monet: AnimatedSprite2D = $Monet
@onready var monet_collision: CollisionShape2D = $MonetCollsion
@onready var smoke: GPUParticles2D = $Smoke

signal hit_and_changed

var monet_hit := false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	monet.animation = "monetbox"
	monet.play()
	if smoke:
		smoke.emitting = false

func _on_area_entered(area: Area2D) -> void:
	if monet_hit:
		return
	if area.is_in_group("bullet"):
		monet_hit = true
		monet.animation = "monetnobox"
		monet.play()
		if monet_collision:
			monet_collision.disabled = true
		collision_layer = 0
		collision_mask = 0
		area.queue_free()
		if smoke:
			smoke.restart()
			smoke.emitting = true
		emit_signal("hit_and_changed")
