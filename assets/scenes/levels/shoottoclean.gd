extends Area2D

@onready var waterfall_sprite: Sprite2D = $DirtyWaterfall
@onready var waterfall_collision: CollisionShape2D = $waterfallcutscene

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	waterfall_collision.disabled = false

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("bullet"):
		return
	waterfall_sprite.texture = preload("res://assets/art/Background and Decor/clean waterfall no bridge.png")
	waterfall_collision.disabled = true
	collision_layer = 0
	collision_mask = 0
	if get_parent().has_method("set_waterfall_clean"):
		get_parent().set_waterfall_clean(true)
	area.queue_free()
