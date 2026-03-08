extends Area2D

@onready var box_sprite: Sprite2D = $BoxSprite
@onready var box_collision: CollisionShape2D = $BoxCollison

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		box_sprite.texture = preload("res://assets/art/watercolor-flower-garden-clipart-free-png.png")
		box_collision.disabled = true
		collision_layer = 0   
		collision_mask = 0   
		area.queue_free()
