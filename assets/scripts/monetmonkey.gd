extends Area2D

@onready var monet: AnimatedSprite2D = $Monet
@onready var monet_collsion: CollisionShape2D = $MonetCollsion


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
	# Start with the default box animation
	monet.animation = "monetbox"
	monet.play()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		monet.animation = "monetnobox"
		monet.play()
		
		monet_collsion.disabled = true
		collision_layer = 0
		collision_mask = 0
		
		area.queue_free()
