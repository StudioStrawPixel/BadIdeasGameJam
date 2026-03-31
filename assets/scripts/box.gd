extends Area2D

@onready var box_sprite: Sprite2D = $BoxSprite
@onready var box_collision: CollisionShape2D = $BoxCollison
var transform_sound: AudioStreamPlayer2D

func _ready():
	area_entered.connect(_on_area_entered)


	transform_sound = AudioStreamPlayer2D.new()
	transform_sound.stream = preload("res://assets/sounds/switch.mp3")  
	transform_sound.pitch_scale = 1.3  
	transform_sound.volume_db = -5
	add_child(transform_sound)
	add_child(transform_sound)

func _on_area_entered(area: Area2D):
	if area.is_in_group("bullet"):
		box_sprite.scale = Vector2(0.3, 0.3)
		box_sprite.texture = preload("res://assets/art/2d/items/flower2.png")
		box_collision.disabled = true
		collision_layer = 0
		collision_mask = 0
		area.queue_free()
		get_parent().add_flower()
		
		if transform_sound:
			transform_sound.play()
